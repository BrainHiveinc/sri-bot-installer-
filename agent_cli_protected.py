#!/usr/bin/env python3
# Agent Sri - Protected Version
# Copyright (c) 2026 BrainHive Inc. All rights reserved.
# Free to use

import sys
import os

# Load actual agent code
import base64
import json
import requests
from pathlib import Path
from datetime import datetime

# Memory configuration
MEMORY_DIR = Path.home() / ".agent-sri"
MEMORY_FILE = MEMORY_DIR / "memory.json"
KNOWLEDGE_FILE = MEMORY_DIR / "knowledge.json"

def load_memory(user_id):
    """Load user's conversation history"""
    MEMORY_DIR.mkdir(exist_ok=True)
    if MEMORY_FILE.exists():
        try:
            with open(MEMORY_FILE, 'r') as f:
                all_memory = json.load(f)
                return all_memory.get(user_id, [])
        except:
            return []
    return []

def save_memory(user_id, message, response):
    """Save conversation to memory"""
    MEMORY_DIR.mkdir(exist_ok=True)
    if MEMORY_FILE.exists():
        try:
            with open(MEMORY_FILE, 'r') as f:
                all_memory = json.load(f)
        except:
            all_memory = {}
    else:
        all_memory = {}

    if user_id not in all_memory:
        all_memory[user_id] = []

    all_memory[user_id].append({
        "timestamp": datetime.now().isoformat(),
        "user": message,
        "agent": response
    })

    all_memory[user_id] = all_memory[user_id][-50:]

    with open(MEMORY_FILE, 'w') as f:
        json.dump(all_memory, f, indent=2)

def extract_context_from_memory(history):
    """Extract relevant context from conversation history"""
    if not history:
        return ""

    context_parts = []
    for entry in history[-5:]:
        context_parts.append(f"User: {entry['user']}")
        context_parts.append(f"Agent: {entry['agent']}")

    return "\\n".join(context_parts)

def load_learned_knowledge(user_id):
    """Load learned knowledge from documents/URLs"""
    if not KNOWLEDGE_FILE.exists():
        return ""

    try:
        with open(KNOWLEDGE_FILE, 'r') as f:
            knowledge = json.load(f)
            user_knowledge = knowledge.get(user_id, [])
            return "\\n".join([k['summary'] for k in user_knowledge[-10:]])
    except:
        return ""

def save_learned_knowledge(user_id, source, summary):
    """Store learned info"""
    MEMORY_DIR.mkdir(exist_ok=True)

    if KNOWLEDGE_FILE.exists():
        try:
            with open(KNOWLEDGE_FILE, 'r') as f:
                knowledge = json.load(f)
        except:
            knowledge = {}
    else:
        knowledge = {}

    if user_id not in knowledge:
        knowledge[user_id] = []

    knowledge[user_id].append({
        "timestamp": datetime.now().isoformat(),
        "source": source,
        "summary": summary
    })

    with open(KNOWLEDGE_FILE, 'w') as f:
        json.dump(knowledge, f, indent=2)

def fetch_url(url):
    """Fetch and extract clean text from URL"""
    try:
        from bs4 import BeautifulSoup
        response = requests.get(url, timeout=10)
        soup = BeautifulSoup(response.content, 'html.parser')

        for script in soup(["script", "style"]):
            script.decompose()

        text = soup.get_text()
        lines = (line.strip() for line in text.splitlines())
        chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
        text = '\\n'.join(chunk for chunk in chunks if chunk)

        return text[:5000]
    except Exception as e:
        return f"Error fetching URL: {e}"

def read_file(file_path):
    """Read and extract text from various file types"""
    try:
        if file_path.endswith('.pdf'):
            try:
                from PyPDF2 import PdfReader
                reader = PdfReader(file_path)
                text = ""
                for page in reader.pages[:10]:
                    text += page.extract_text()
                return text[:5000]
            except:
                return "Error reading PDF"

        elif file_path.endswith(('.txt', '.md', '.py', '.js', '.json')):
            with open(file_path, 'r') as f:
                return f.read()[:5000]

        else:
            return "Unsupported file type"

    except Exception as e:
        return f"Error reading file: {e}"

def get_ollama_response(message, context="", learned_info=""):
    """Get response from Ollama"""
    try:
        context_part = f"Previous conversation context:\n{context}\n" if context else ""
        learned_part = f"Learned knowledge:\n{learned_info}\n" if learned_info else ""

        prompt = f"""You are Agent Sri, an intelligent AI assistant.

{context_part}{learned_part}
User: {message}

Agent Sri:"""

        response = requests.post(
            'http://localhost:11434/api/generate',
            json={
                "model": "llama3.1",
                "prompt": prompt,
                "stream": False
            },
            timeout=30
        )

        if response.status_code == 200:
            return response.json().get('response', 'No response generated')
        else:
            return "Error connecting to Ollama"

    except Exception as e:
        return f"Ollama error: {e}"

def main():
    if len(sys.argv) < 3:
        print("Usage: agent_cli_protected.py <user_id> <message>")
        sys.exit(1)

    user_id = sys.argv[1]
    message = sys.argv[2]

    history = load_memory(user_id)
    context = extract_context_from_memory(history)
    learned_info = load_learned_knowledge(user_id)

    if message.startswith("http://") or message.startswith("https://"):
        url_content = fetch_url(message)
        save_learned_knowledge(user_id, message, f"Content from {message}")
        response = f"I've learned from {message}. Ask me anything about it!"

    elif message.startswith("read:"):
        file_path = message[5:].strip()
        file_content = read_file(file_path)
        save_learned_knowledge(user_id, file_path, file_content[:500])
        response = f"I've read the file. Ask me anything about it!"

    else:
        response = get_ollama_response(message, context, learned_info)

    save_memory(user_id, message, response)
    print(response)

if __name__ == "__main__":
    main()
