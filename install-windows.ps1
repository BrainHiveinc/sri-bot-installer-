# BrainHive Agent Sri - Windows Installer
# Run: powershell -ExecutionPolicy Bypass -File install-windows.ps1

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         BrainHive Agent Sri - Windows Installer             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git not found. Please install Git for Windows from: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js not found. Please install Node.js from: https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python not found. Please install Python from: https://www.python.org/downloads/" -ForegroundColor Red
    Write-Host "   Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ All prerequisites found!" -ForegroundColor Green
Write-Host ""

# Ask for bot name
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Setup Configuration" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
$botName = Read-Host "Enter your bot name (e.g., Agent Sri, My Assistant)"
if ([string]::IsNullOrWhiteSpace($botName)) {
    $botName = "Agent Sri"
    Write-Host "Using default: $botName" -ForegroundColor Yellow
}

# Ask for LLM choice
Write-Host ""
Write-Host "Select AI Model:" -ForegroundColor Cyan
Write-Host "1) Ollama (FREE - runs locally)"
Write-Host "2) OpenAI GPT (Paid - requires API key)"
Write-Host "3) Claude (Anthropic - requires API key)"
Write-Host "4) DeepSeek (Paid - requires API key)"
Write-Host ""
$llmChoice = Read-Host "Enter choice (1-4)"

$llmProvider = "ollama"
$llmModel = "llama3.1"
$llmUrl = "http://localhost:11434"

switch ($llmChoice) {
    "1" {
        $llmProvider = "ollama"
        $llmModel = "llama3.1"
        $llmUrl = "http://localhost:11434"
    }
    "2" {
        $llmProvider = "openai"
        $llmModel = "gpt-4"
        $llmUrl = "https://api.openai.com/v1"
    }
    "3" {
        $llmProvider = "claude"
        $llmModel = "claude-3-sonnet-20240229"
        $llmUrl = "https://api.anthropic.com"
    }
    "4" {
        $llmProvider = "deepseek"
        $llmModel = "deepseek-chat"
        $llmUrl = "https://api.deepseek.com"
    }
    default {
        Write-Host "Invalid choice. Using Ollama (default)." -ForegroundColor Yellow
    }
}

Write-Host "Selected: $llmProvider ($llmModel)" -ForegroundColor Green

# Ask installation type
Write-Host ""
Write-Host "Select platforms:" -ForegroundColor Cyan
Write-Host "1) Telegram bot only"
Write-Host "2) WhatsApp bot only"
Write-Host "3) Both (Telegram + WhatsApp)"
Write-Host ""
$choice = Read-Host "Enter choice (1-3)"

$installTelegram = $false
$installWhatsApp = $false

switch ($choice) {
    "1" { $installTelegram = $true }
    "2" { $installWhatsApp = $true }
    "3" {
        $installTelegram = $true
        $installWhatsApp = $true
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Create installation directory
$installDir = "$env:USERPROFILE\agent-sri"
Write-Host ""
Write-Host "Installing to: $installDir" -ForegroundColor Cyan

if (Test-Path $installDir) {
    Write-Host "⚠️  Directory already exists. Using existing installation." -ForegroundColor Yellow
} else {
    Write-Host "Creating directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# Clone repository
Write-Host ""
Write-Host "Downloading Agent Sri..." -ForegroundColor Yellow
Set-Location $installDir

if (Test-Path "$installDir\.git") {
    Write-Host "Updating existing repository..." -ForegroundColor Yellow
    git pull
} else {
    Write-Host "Note: This is a private repository" -ForegroundColor Yellow
    Write-Host "You'll need a GitHub Personal Access Token to clone it" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Get your token from: https://github.com/settings/tokens" -ForegroundColor Cyan
    Write-Host "Required scope: 'repo' (full control of private repositories)" -ForegroundColor Cyan
    Write-Host ""
    $token = Read-Host "Enter your GitHub token" -AsSecureString
    $tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))

    if ([string]::IsNullOrWhiteSpace($tokenPlain)) {
        Write-Host "❌ No token provided. Exiting." -ForegroundColor Red
        exit 1
    }

    $cloneUrl = "https://${tokenPlain}@github.com/BrainHiveinc/sri-bot.git"
    git clone $cloneUrl .

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to clone repository. Check your token and try again." -ForegroundColor Red
        exit 1
    }

    # Remove token from git config for security
    git remote set-url origin https://github.com/BrainHiveinc/sri-bot.git
}

# Install Python dependencies
Write-Host ""
Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
python -m pip install --upgrade pip
pip install -r requirements.txt

# Setup Telegram
if ($installTelegram) {
    Write-Host ""
    Write-Host "Setting up Telegram bot..." -ForegroundColor Cyan

    $tgDir = "$installDir\telegram-personal"
    if (-not (Test-Path $tgDir)) {
        New-Item -ItemType Directory -Path $tgDir | Out-Null
    }

    # Copy files
    Copy-Item "$installDir\agent_cli_fixed.py" $tgDir -Force
    Copy-Item "$installDir\bot-working.js" $tgDir -Force

    # Create .env file with user's choices
    $envContent = @"
# Telegram Bot Configuration
BOT_TOKEN=YOUR_BOT_TOKEN_HERE
BOT_NAME=$botName
LLM_PROVIDER=$llmProvider
LLM_MODEL=$llmModel
OLLAMA_URL=$llmUrl
OLLAMA_MODEL=$llmModel
"@
    Set-Content -Path "$tgDir\.env" -Value $envContent

    # Install Node.js dependencies
    Set-Location $tgDir
    npm init -y | Out-Null
    npm install telegraf dotenv

    Write-Host "✅ Telegram setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Get your bot token from @BotFather on Telegram"
    Write-Host "2. Edit: $tgDir\.env"
    Write-Host "3. Replace YOUR_BOT_TOKEN_HERE with your actual token"

    if ($llmProvider -ne "ollama") {
        Write-Host "4. Add your $llmProvider API key to .env file" -ForegroundColor Yellow
        Write-Host "   (Add line: API_KEY=your_api_key_here)" -ForegroundColor Yellow
        Write-Host "5. Run: cd $tgDir && node bot-working.js" -ForegroundColor White
    } else {
        Write-Host "4. Run: cd $tgDir && node bot-working.js" -ForegroundColor White
    }
}

# Setup WhatsApp
if ($installWhatsApp) {
    Write-Host ""
    Write-Host "Setting up WhatsApp bot..." -ForegroundColor Cyan

    $waDir = "$installDir\whatsapp-personal"
    if (-not (Test-Path $waDir)) {
        New-Item -ItemType Directory -Path $waDir | Out-Null
    }

    Write-Host "✅ WhatsApp setup complete!" -ForegroundColor Green
    Write-Host "Note: WhatsApp integration requires additional setup"
}

# Check for Ollama if selected
if ($llmProvider -eq "ollama") {
    Write-Host ""
    Write-Host "Checking for Ollama..." -ForegroundColor Yellow
    if (Get-Command ollama -ErrorAction SilentlyContinue) {
        Write-Host "✅ Ollama found!" -ForegroundColor Green
        Write-Host "   Checking for model $llmModel..." -ForegroundColor Yellow
        $ollamaList = ollama list 2>$null
        if ($ollamaList -match $llmModel) {
            Write-Host "   ✅ Model $llmModel is ready!" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Model not found. Pull it with: ollama pull $llmModel" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Ollama not found. Install from: https://ollama.ai/" -ForegroundColor Yellow
        Write-Host "   After installing, run: ollama pull $llmModel" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "You selected: $llmProvider" -ForegroundColor Cyan
    Write-Host "Make sure to add your API key to the .env file!" -ForegroundColor Yellow
}

# Final instructions
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                Installation Complete!                        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if ($installTelegram) {
    Write-Host "🤖 Telegram Bot Location: $installDir\telegram-personal" -ForegroundColor Cyan
    Write-Host "   Run: cd $installDir\telegram-personal && node bot-working.js" -ForegroundColor White
    Write-Host ""
}

Write-Host "📚 Documentation: $installDir\README.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Need help? Visit: https://github.com/BrainHiveinc/sri-bot" -ForegroundColor Yellow
Write-Host ""
