#!/bin/bash

# Agent Sri Installer
# Usage: ./install.sh [telegram|whatsapp|both]

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            Agent Sri - Installation Wizard                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Install: https://git-scm.com"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install: https://nodejs.org"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Install: https://python.org"
    exit 1
fi

echo "✅ All prerequisites found"
echo ""

# Get installation type
INSTALL_TYPE="${1:-both}"

case "$INSTALL_TYPE" in
    telegram|whatsapp|both)
        ;;
    *)
        echo "Usage: $0 [telegram|whatsapp|both]"
        exit 1
        ;;
esac

# Setup configuration
echo "═══════════════════════════════════════════════════════"
echo "  Setup Configuration"
echo "═══════════════════════════════════════════════════════"
echo ""

read -p "Enter bot name (default: Agent Sri): " BOT_NAME
BOT_NAME=${BOT_NAME:-"Agent Sri"}

echo ""
echo "Select AI Model:"
echo "1) Ollama (FREE - local)"
echo "2) OpenAI GPT (Paid)"
echo "3) Claude (Paid)"
echo "4) DeepSeek (Paid)"
read -p "Choice (1-4): " LLM_CHOICE

LLM_PROVIDER="ollama"
LLM_MODEL="llama3.1"
LLM_URL="http://localhost:11434"

case "$LLM_CHOICE" in
    1)
        LLM_PROVIDER="ollama"
        LLM_MODEL="llama3.1"
        LLM_URL="http://localhost:11434"
        ;;
    2)
        LLM_PROVIDER="openai"
        LLM_MODEL="gpt-4"
        LLM_URL="https://api.openai.com/v1"
        ;;
    3)
        LLM_PROVIDER="claude"
        LLM_MODEL="claude-3-sonnet-20240229"
        LLM_URL="https://api.anthropic.com"
        ;;
    4)
        LLM_PROVIDER="deepseek"
        LLM_MODEL="deepseek-chat"
        LLM_URL="https://api.deepseek.com"
        ;;
esac

echo "Selected: $LLM_PROVIDER ($LLM_MODEL)"
echo ""

# Installation directory
INSTALL_DIR="$HOME/agent-sri"
echo "Installing to: $INSTALL_DIR"
echo ""

# Clone repository
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "This is a private repository."
    echo "Get your GitHub token from: https://github.com/settings/tokens"
    echo "Required scope: 'repo' (full control of private repositories)"
    echo ""
    read -sp "Enter your GitHub token: " GH_TOKEN
    echo ""

    if [ -z "$GH_TOKEN" ]; then
        echo "❌ No token provided"
        exit 1
    fi

    echo "Cloning repository..."
    git clone "https://${GH_TOKEN}@github.com/BrainHiveinc/sri-bot.git" "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # Remove token from git config
    git remote set-url origin https://github.com/BrainHiveinc/sri-bot.git
fi

# Install Python dependencies
echo ""
echo "Installing Python dependencies..."
pip3 install -r requirements.txt --break-system-packages 2>/dev/null || pip3 install -r requirements.txt

# Install Telegram
if [ "$INSTALL_TYPE" = "telegram" ] || [ "$INSTALL_TYPE" = "both" ]; then
    echo ""
    echo "Setting up Telegram bot..."

    TG_DIR="$INSTALL_DIR/telegram-personal"
    mkdir -p "$TG_DIR"

    # Copy files
    cp "$INSTALL_DIR/agent_cli_fixed.py" "$TG_DIR/"
    cp "$INSTALL_DIR/bot-working.js" "$TG_DIR/"

    # Create .env
    cat > "$TG_DIR/.env" << EOF
BOT_TOKEN=YOUR_BOT_TOKEN_HERE
BOT_NAME=$BOT_NAME
LLM_PROVIDER=$LLM_PROVIDER
LLM_MODEL=$LLM_MODEL
OLLAMA_URL=$LLM_URL
OLLAMA_MODEL=$LLM_MODEL
EOF

    # Install Node dependencies
    cd "$TG_DIR"
    npm init -y > /dev/null 2>&1
    npm install telegraf dotenv

    echo "✅ Telegram setup complete!"
fi

# Install WhatsApp
if [ "$INSTALL_TYPE" = "whatsapp" ] || [ "$INSTALL_TYPE" = "both" ]; then
    echo ""
    echo "⚠️  WhatsApp integration not yet available"
fi

# Check Ollama
if [ "$LLM_PROVIDER" = "ollama" ]; then
    echo ""
    if command -v ollama &> /dev/null; then
        echo "✅ Ollama found"
        if ollama list | grep -q "$LLM_MODEL"; then
            echo "✅ Model $LLM_MODEL ready"
        else
            echo "⚠️  Model not found. Run: ollama pull $LLM_MODEL"
        fi
    else
        echo "⚠️  Ollama not found. Install: https://ollama.ai"
        echo "   Then run: ollama pull $LLM_MODEL"
    fi
fi

# Final instructions
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Installation Complete!                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$INSTALL_TYPE" = "telegram" ] || [ "$INSTALL_TYPE" = "both" ]; then
    echo "📱 Telegram Bot Setup:"
    echo "1. Open Telegram, search @BotFather"
    echo "2. Send /newbot and follow prompts"
    echo "3. Copy your bot token"
    echo "4. Edit: $TG_DIR/.env"
    echo "5. Replace YOUR_BOT_TOKEN_HERE with your token"

    if [ "$LLM_PROVIDER" != "ollama" ]; then
        echo "6. Add your $LLM_PROVIDER API key to .env"
        echo "7. Run: cd $TG_DIR && node bot-working.js"
    else
        echo "6. Run: cd $TG_DIR && node bot-working.js"
    fi
    echo ""
fi

echo "📚 Installation directory: $INSTALL_DIR"
echo ""
