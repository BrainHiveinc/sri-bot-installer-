# 🤖 Autonomous AI Agent

**OpenClaw-inspired AI agent with business-grade guardrails**

Fast, secure, and compliant AI assistant that connects to WhatsApp, learns from interactions, and enforces safety policies for professional use.

---

## ✨ Key Features

### 🎯 Core Capabilities
- ✅ **Multi-LLM Support** - Ollama (free), DeepSeek, Claude, ChatGPT
- ✅ **WhatsApp Integration** - Chat with agent from your phone
- ✅ **Project Analysis** - Scans files, understands context
- ✅ **Vector Memory** - Learns from interactions (ChromaDB)
- ✅ **Code Protection** - Distribute without exposing source

### 🛡️ Business Guardrails (NEW!)
- ✅ **Content Safety** - Blocks illegal/harmful requests automatically
- ✅ **Risk Assessment** - Classifies every request (Safe → Blocked)
- ✅ **Audit Logging** - Full compliance trail for all actions
- ✅ **Privacy Protection** - Detects and protects PII/sensitive data
- ✅ **Rate Limiting** - Prevents abuse
- ✅ **Policy Enforcement** - Terms of service built-in

### 📱 Integrations
- WhatsApp (personal account)
- Telegram (personal account)
- Discord (coming soon)

---

## 🚀 Quick Start

### Linux/Mac Installation

```bash
curl -sSL https://raw.githubusercontent.com/BrainHiveinc/sri-bot/main/install.sh | bash -s both
```

Or download and run locally:
```bash
./install.sh
```

### Windows Installation

**Option 1: PowerShell (Recommended)**
```powershell
# Download install-windows.ps1 from GitHub, then run:
powershell -ExecutionPolicy Bypass -File install-windows.ps1
```

**Option 2: Double-click**
- Download `install-windows.bat`
- Double-click to run

**Option 3: Git Bash**
- Install Git for Windows
- Run the Linux/Mac command above in Git Bash

**The installer will:**
1. Check prerequisites (Git, Node.js, Python)
2. Prompt for your GitHub token (private repo)
3. Clone the repository
4. Install all dependencies
5. Set up Telegram bot
6. Guide you through configuration

### Test It

```bash
# Local chat
python3 simple_agent.py --interactive

# WhatsApp (already connected from install!)
# Just send yourself a message

# Test guardrails
python3 test_guardrails.py
```

---

## 🛡️ Guardrails in Action

### Safe Requests - Auto-Approved ✅

```bash
💬 You: analyze this project structure
🤖 Agent: [Provides analysis...]
```

### Risky Requests - Require Approval 🟠

```bash
💬 You: delete old log files
⚠️  Risk Level: MEDIUM
⚡ This is a sensitive operation. Proceed? (yes/no): yes
🤖 Agent: [Proceeds with deletion...]
```

### Blocked Requests - Policy Violation ⛔

```bash
💬 You: how to hack into a system
🚫 Request Blocked
Reason: Prohibited content detected - illegal activity

This agent includes business-grade guardrails.
See POLICIES.md for permitted use cases.
```

---

## 📋 What's Protected

The guardrails automatically **block** or **flag**:

| Category | Examples | Action |
|----------|----------|--------|
| **Illegal** | Hacking, drugs, fraud | ⛔ Blocked |
| **Harmful** | Violence, self-harm | ⛔ Blocked |
| **Malicious** | Malware, phishing | ⛔ Blocked |
| **Sensitive Data** | Credit cards, SSNs | ⛔ Blocked |
| **File Deletion** | rm, delete commands | 🟠 Approval needed |
| **External Comms** | Email, posting | 🟠 Approval needed |

Full list: See [POLICIES.md](POLICIES.md)

---

## 📊 Use Cases

### ✅ Permitted (Business Use)

- **Code Analysis** - Review code, find bugs, suggest improvements
- **Documentation** - Generate READMEs, API docs, reports
- **Data Analysis** - Analyze CSVs, create visualizations
- **Customer Support** - Answer questions, provide information
- **Automation** - Automate repetitive tasks, workflows
- **Research** - Gather information, summarize content

### ❌ Prohibited (Blocked by Guardrails)

- Illegal activities (hacking, fraud, etc.)
- Harmful content (violence, exploitation)
- Malicious code (malware, exploits)
- Privacy violations (PII exposure)
- Financial misconduct (insider trading)

---

## 🏗️ Architecture

```
sri-agent/
├── simple_agent.py          # Main agent (with guardrails!)
├── agent/
│   ├── core/                # Orchestrator, decision engine
│   ├── llm/                 # Multi-LLM providers
│   ├── memory/              # Vector store (ChromaDB)
│   ├── filesystem/          # Project scanner
│   ├── messaging/           # WhatsApp bridge
│   └── policies/            # 🛡️ Guardrails system (NEW!)
│       ├── guardrails.py    # Content safety, risk assessment
│       └── config.json      # Policy configuration
├── whatsapp-personal/       # WhatsApp integration
├── logs/                    # Audit & violation logs
├── install.sh               # Master installer
└── POLICIES.md              # Business policies documentation
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[QUICK_START.md](QUICK_START.md)** | 2-minute setup guide |
| **[POLICIES.md](POLICIES.md)** | Business guardrails & compliance |
| **[USER_GUIDE.md](USER_GUIDE.md)** | Complete user manual |
| **[INSTALL.md](INSTALL.md)** | Detailed installation |
| **[AGENT_ARCHITECTURE.md](AGENT_ARCHITECTURE.md)** | Technical design |

---

## 🔐 Security & Compliance

### Audit Logging

Every request is logged:

```bash
# View all actions
cat logs/audit.jsonl

# View violations
cat logs/violations.jsonl
```

**Sample log:**
```json
{
  "timestamp": "2024-02-11T10:30:45",
  "user_id": "user@company.com",
  "action": "request_approved",
  "details": {"request": "analyze project", "risk_level": "safe"},
  "approved": true
}
```

### Compliance Support

- ✅ GDPR compliant practices
- ✅ CCPA compliant practices
- ✅ SOC 2 aligned controls
- ✅ Enterprise audit trails

---

## 🆚 vs OpenClaw

| Feature | This Agent | OpenClaw |
|---------|------------|----------|
| **Setup** | One command | Multiple steps |
| **Cost** | FREE (with Ollama) | API costs |
| **Privacy** | 100% local option | Cloud-based |
| **WhatsApp** | Personal account | Not available |
| **Guardrails** | Built-in | Not mentioned |
| **Compliance** | Audit logs | Unknown |
| **Code Protection** | Encrypted plugins | Not mentioned |

---

## 🔧 Advanced Configuration

### Customize Policies

Edit `agent/policies/config.json`:

```json
{
  "rate_limits": {
    "requests_per_hour": 100,
    "cooldown_minutes": 5
  },
  "require_approval_for": [
    "file_deletion",
    "external_communication",
    "financial"
  ],
  "strict_mode": true
}
```

### Change LLM

Edit `.env`:

```bash
LLM_PROVIDER=ollama
LLM_MODEL=llama3.1
```

---

## 🆘 Support

### Troubleshooting

```bash
# Test guardrails
python3 test_guardrails.py

# Check logs
tail -f logs/audit.jsonl
tail -f logs/violations.jsonl

# Test Ollama
ollama run llama3.1
```

### Common Issues

**Q: Request blocked unexpectedly?**
A: Check `logs/violations.jsonl` for reason. May need to rephrase in business context.

**Q: WhatsApp not connecting?**
A: Restart with `./start_whatsapp.sh` and scan QR code again.

**Q: How to disable guardrails?**
A: Not recommended for business use. For development, set `strict_mode: false` in config.

---

## 📈 Roadmap

- [x] Multi-LLM support
- [x] WhatsApp integration
- [x] Business guardrails
- [x] Audit logging
- [x] Auto-QR on install
- [ ] Telegram integration
- [ ] Discord integration
- [ ] Web dashboard
- [ ] Advanced analytics
- [ ] Team collaboration features

---

## 📄 License

MIT License - See LICENSE file

---

## 🙏 Credits

Inspired by [OpenClaw](https://openclaw.ai/)

---

## 🎉 Get Started!

```bash
# Install (shows QR code automatically!)
./install.sh

# Test locally
python3 simple_agent.py --interactive

# Chat via WhatsApp
# (already connected!)

# Test guardrails
python3 test_guardrails.py
```

**Safe, compliant, and ready for business! 🚀**
