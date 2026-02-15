#!/bin/bash
# Agent Sri - Simple Installer (No GitHub Token Required)

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            Agent Sri - Installation                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Install: https://python.org"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install: https://nodejs.org"
    exit 1
fi

echo "✅ Prerequisites found"
echo ""

# Get configuration
read -p "Bot name (default: Agent Sri): " BOT_NAME
BOT_NAME=${BOT_NAME:-"Agent Sri"}

echo ""
echo "Platform:"
echo "1) Telegram"
echo "2) WhatsApp"
echo "3) Both"
read -p "Choice (1-3): " PLATFORM_CHOICE

case "$PLATFORM_CHOICE" in
    1) INSTALL_TG=true; INSTALL_WA=false ;;
    2) INSTALL_TG=false; INSTALL_WA=true ;;
    3) INSTALL_TG=true; INSTALL_WA=true ;;
    *) INSTALL_TG=true; INSTALL_WA=false ;;
esac

echo ""
echo "AI Model:"
echo "1) Ollama (FREE)"
echo "2) OpenAI"
echo "3) Claude"
echo "4) DeepSeek"
read -p "Choice (1-4): " LLM_CHOICE

case "$LLM_CHOICE" in
    1) LLM="ollama"; MODEL="llama3.1" ;;
    2) LLM="openai"; MODEL="gpt-4" ;;
    3) LLM="claude"; MODEL="claude-3-sonnet" ;;
    4) LLM="deepseek"; MODEL="deepseek-chat" ;;
    *) LLM="ollama"; MODEL="llama3.1" ;;
esac

echo "Selected: $LLM"
echo ""

# Setup directory
INSTALL_DIR="$HOME/agent-sri"
mkdir -p "$INSTALL_DIR"

echo "Installing to: $INSTALL_DIR"
echo ""

# Download files from PUBLIC repo
BASE_URL="https://raw.githubusercontent.com/BrainHiveinc/sri-bot-installer-/main"

# Install Telegram
if [ "$INSTALL_TG" = true ]; then
    echo "Setting up Telegram..."
    TG_DIR="$INSTALL_DIR/telegram-personal"
    mkdir -p "$TG_DIR"

    curl -sSL "$BASE_URL/agent_cli_protected.py" -o "$TG_DIR/agent_cli_protected.py"
    curl -sSL "$BASE_URL/bot-protected.js" -o "$TG_DIR/bot-protected.js"
    curl -sSL "$BASE_URL/license_validator.py" -o "$TG_DIR/license_validator.py"
    curl -sSL "$BASE_URL/requirements.txt" -o "$TG_DIR/requirements.txt"

    cd "$TG_DIR"
    pip3 install -r requirements.txt --break-system-packages 2>/dev/null || pip3 install -r requirements.txt
    npm init -y > /dev/null 2>&1
    npm install telegraf dotenv

    cat > "$TG_DIR/.env" << EOF
BOT_TOKEN=YOUR_BOT_TOKEN_HERE
BOT_NAME=$BOT_NAME
LLM_PROVIDER=$LLM
LLM_MODEL=$MODEL
EOF
    echo "✅ Telegram setup complete"
fi

# Install WhatsApp
if [ "$INSTALL_WA" = true ]; then
    echo ""
    echo "Setting up WhatsApp..."
    WA_DIR="$INSTALL_DIR/whatsapp-personal"
    mkdir -p "$WA_DIR"

    curl -sSL "$BASE_URL/agent_cli_protected.py" -o "$WA_DIR/agent_cli_protected.py"
    curl -sSL "$BASE_URL/whatsapp-bot.js" -o "$WA_DIR/whatsapp-bot.js"
    curl -sSL "$BASE_URL/license_validator.py" -o "$WA_DIR/license_validator.py"
    curl -sSL "$BASE_URL/requirements.txt" -o "$WA_DIR/requirements.txt"

    cd "$WA_DIR"
    pip3 install -r requirements.txt --break-system-packages 2>/dev/null || pip3 install -r requirements.txt
    npm init -y > /dev/null 2>&1
    npm install whatsapp-web.js qrcode-terminal

    echo "✅ WhatsApp setup complete"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Installation Complete!                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$INSTALL_TG" = true ]; then
    echo "📱 Telegram Bot:"
    echo "1. Get token from @BotFather"
    echo "2. Edit: $TG_DIR/.env"
    echo "3. Replace YOUR_BOT_TOKEN_HERE"
    echo "4. Run: cd $TG_DIR && node bot-protected.js"
    echo ""
fi

if [ "$INSTALL_WA" = true ]; then
    echo "💬 WhatsApp Bot:"
    echo "1. Run: cd $WA_DIR && node whatsapp-bot.js"
    echo "2. Scan QR code with WhatsApp"
    echo "3. Start chatting!"
    echo ""
fi

echo "Installed to: $INSTALL_DIR"
echo ""
