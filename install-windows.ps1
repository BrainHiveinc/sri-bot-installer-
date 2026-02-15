# Agent Sri - Windows Installer
# Free to use

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Agent Sri - Windows Installer                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js not found. Install: https://nodejs.org/" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python not found. Install: https://www.python.org/" -ForegroundColor Red
    exit 1
}

Write-Host "✅ All prerequisites found!" -ForegroundColor Green
Write-Host ""

# Configuration
$botName = Read-Host "Bot name (default: Agent Sri)"
if ([string]::IsNullOrWhiteSpace($botName)) {
    $botName = "Agent Sri"
}

Write-Host ""
Write-Host "Platform:" -ForegroundColor Cyan
Write-Host "1) Telegram"
Write-Host "2) WhatsApp"
Write-Host "3) Both"
$platformChoice = Read-Host "Choice (1-3)"

$installTelegram = $false
$installWhatsApp = $false

switch ($platformChoice) {
    "1" { $installTelegram = $true }
    "2" { $installWhatsApp = $true }
    "3" {
        $installTelegram = $true
        $installWhatsApp = $true
    }
    default { $installTelegram = $true }
}

Write-Host ""
Write-Host "AI Model:" -ForegroundColor Cyan
Write-Host "1) Ollama (FREE)"
Write-Host "2) OpenAI"
Write-Host "3) Claude"
Write-Host "4) DeepSeek"
$llmChoice = Read-Host "Choice (1-4)"

$llmProvider = "ollama"
$llmModel = "llama3.1"

switch ($llmChoice) {
    "1" { $llmProvider = "ollama"; $llmModel = "llama3.1" }
    "2" { $llmProvider = "openai"; $llmModel = "gpt-4" }
    "3" { $llmProvider = "claude"; $llmModel = "claude-3-sonnet" }
    "4" { $llmProvider = "deepseek"; $llmModel = "deepseek-chat" }
    default { $llmProvider = "ollama"; $llmModel = "llama3.1" }
}

Write-Host "Selected: $llmProvider" -ForegroundColor Green
Write-Host ""

# Setup directory
$installDir = "$env:USERPROFILE\agent-sri"
Write-Host "Installing to: $installDir" -ForegroundColor Cyan

# Download from PUBLIC repo
$baseUrl = "https://raw.githubusercontent.com/BrainHiveinc/sri-bot-installer-/main"

# Install Telegram
if ($installTelegram) {
    Write-Host ""
    Write-Host "Setting up Telegram..." -ForegroundColor Yellow

    $tgDir = "$installDir\telegram-personal"
    New-Item -ItemType Directory -Path $tgDir -Force | Out-Null

    Invoke-WebRequest -Uri "$baseUrl/agent_cli_protected.py" -OutFile "$tgDir\agent_cli_protected.py"
    Invoke-WebRequest -Uri "$baseUrl/bot-protected.js" -OutFile "$tgDir\bot-protected.js"
    Invoke-WebRequest -Uri "$baseUrl/license_validator.py" -OutFile "$tgDir\license_validator.py"
    Invoke-WebRequest -Uri "$baseUrl/requirements.txt" -OutFile "$tgDir\requirements.txt"

    Set-Location $tgDir
    pip install -r requirements.txt
    npm init -y | Out-Null
    npm install telegraf dotenv

    $envContent = @"
BOT_TOKEN=YOUR_BOT_TOKEN_HERE
BOT_NAME=$botName
LLM_PROVIDER=$llmProvider
LLM_MODEL=$llmModel
"@
    Set-Content -Path "$tgDir\.env" -Value $envContent

    Write-Host "✅ Telegram setup complete!" -ForegroundColor Green
}

# Install WhatsApp
if ($installWhatsApp) {
    Write-Host ""
    Write-Host "Setting up WhatsApp..." -ForegroundColor Yellow

    $waDir = "$installDir\whatsapp-personal"
    New-Item -ItemType Directory -Path $waDir -Force | Out-Null

    Invoke-WebRequest -Uri "$baseUrl/agent_cli_protected.py" -OutFile "$waDir\agent_cli_protected.py"
    Invoke-WebRequest -Uri "$baseUrl/whatsapp-bot.js" -OutFile "$waDir\whatsapp-bot.js"
    Invoke-WebRequest -Uri "$baseUrl/license_validator.py" -OutFile "$waDir\license_validator.py"
    Invoke-WebRequest -Uri "$baseUrl/requirements.txt" -OutFile "$waDir\requirements.txt"

    Set-Location $waDir
    pip install -r requirements.txt
    npm init -y | Out-Null
    npm install whatsapp-web.js qrcode-terminal

    Write-Host "✅ WhatsApp setup complete!" -ForegroundColor Green
}

# Final instructions
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                Installation Complete!                        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if ($installTelegram) {
    Write-Host "📱 Telegram Bot:" -ForegroundColor Cyan
    Write-Host "1. Get token from @BotFather"
    Write-Host "2. Edit: $tgDir\.env"
    Write-Host "3. Replace YOUR_BOT_TOKEN_HERE"
    Write-Host "4. Run: cd $tgDir && node bot-protected.js"
    Write-Host ""
}

if ($installWhatsApp) {
    Write-Host "💬 WhatsApp Bot:" -ForegroundColor Cyan
    Write-Host "1. Run: cd $waDir && node whatsapp-bot.js"
    Write-Host "2. Scan QR code with WhatsApp"
    Write-Host "3. Start chatting!"
    Write-Host ""
}

Write-Host "Installed to: $installDir" -ForegroundColor Green
Write-Host ""
