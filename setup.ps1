# ============================================================
# 🛡️ Sentinela — Windows Bare Metal Setup Wizard
# Automatically installs Nmap, Ollama, Python, and Sentinela
# Usage: irm https://raw.githubusercontent.com/MiguelFAraujo/Sentinela/main/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

$Repo = "MiguelFAraujo/Sentinela"
$DataDir = "$env:USERPROFILE\SentinelaApp"

function Write-Header {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  🛡️  Sentinela — Bare Metal Setup Wizard" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "This will install Nmap, Ollama, Python tools, and Sentinela locally."
    Write-Host ""
}

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[!]    $msg" -ForegroundColor Yellow }

function Write-Fail {
    param($msg)
    Write-Host "[ERR]  $msg" -ForegroundColor Red
    exit 1
}

function Test-Winget {
    if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
        Write-Fail "winget is not installed. Please install App Installer from the Microsoft Store."
    }
}

function Install-Dependency {
    param($AppId, $CommandName)
    
    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        Write-Success "$CommandName is already installed"
        return
    }

    Write-Info "Installing $AppId via winget... (This might prompt for Administrator privileges)"
    $args = @("install", "--id", $AppId, "-e", "--accept-package-agreements", "--accept-source-agreements", "--silent")
    & winget $args
    
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Failed to install $AppId"
    }
    Write-Success "$AppId installed successfully"
    
    # Reload PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Install-Uv {
    if (Get-Command "uv" -ErrorAction SilentlyContinue) {
        Write-Success "uv is already installed"
        return
    }
    Write-Info "Installing uv package manager..."
    Invoke-WebRequest -Uri "https://astral.sh/uv/install.ps1" -OutFile "$env:TEMP\install_uv.ps1"
    & "$env:TEMP\install_uv.ps1"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Success "uv installed successfully"
}

function Install-Repository {
    if (Test-Path "$DataDir\.git") {
        Write-Info "Updating existing Sentinela repository..."
        Push-Location $DataDir
        & git pull origin main
        Pop-Location
    }
    else {
        Write-Info "Cloning Sentinela repository..."
        if (Test-Path $DataDir) { Remove-Item $DataDir -Recurse -Force }
        & git clone "https://github.com/$Repo.git" $DataDir
    }
    Write-Success "Repository ready at $DataDir"
}

function Setup-Environment {
    Write-Info "Setting up Python environment and dependencies..."
    Push-Location $DataDir
    & uv sync
    Pop-Location
    Write-Success "Python environment ready"
}

function Pull-AI-Model {
    Write-Info "Pulling Ollama 'llama3' model. This is ~4.7GB and might take a while..."
    & ollama pull llama3
    Write-Success "Model llama3 is ready!"
}

function Write-Summary {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  ✅ Bare Metal Installation Complete!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  To run Sentinela locally without Docker:"
    Write-Host ""
    Write-Host "  1. Enter the directory:"
    Write-Host "     cd $DataDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Start the API:"
    Write-Host "     uv run python -m app.agente start_api" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Or run a network scan directly:"
    Write-Host "     uv run python -m app.agente scan --target 127.0.0.1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Note: you might need to restart your terminal first so the new PATH is fully applied." -ForegroundColor Yellow
    Write-Host ""
}

# --- Main Flow ---
Write-Header
Test-Winget
Install-Dependency "Git.Git" "git"
Install-Dependency "Insecure.Nmap" "nmap"
Install-Dependency "Ollama.Ollama" "ollama"
Install-Uv
Install-Repository
Setup-Environment
Pull-AI-Model
Write-Summary
