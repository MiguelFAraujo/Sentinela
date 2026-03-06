# ============================================================
# 🛡️ Sentinela — Windows Bare Metal Setup Wizard
# Automatically installs Nmap, Ollama, Python, and Sentinela
# Usage: irm https://raw.githubusercontent.com/MiguelFAraujo/Sentinela/main/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

$Repo = "MiguelFAraujo/Sentinela"
$InstallDir = "$env:LOCALAPPDATA\Sentinela"
$BinDir = "$InstallDir\bin"
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
    $wingetArgs = @("install", "--id", $AppId, "-e", "--accept-package-agreements", "--accept-source-agreements", "--silent")
    & winget $wingetArgs
    
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

function Initialize-Environment {
    Write-Info "Setting up Python environment and dependencies..."
    Push-Location $DataDir
    & uv sync
    Pop-Location
    Write-Success "Python environment ready"
}

function Install-AIModel {
    Write-Info "Pulling Ollama 'llama3.2' model. This is ~2.0GB and might take a few minutes..."
    & ollama pull llama3.2
    Write-Success "Model llama3.2 is ready!"
}

function Install-Launcher {
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

    $LauncherContent = @"
@echo off
setlocal

set "SENTINELA_HOME=$DataDir"

if not exist "%SENTINELA_HOME%" (
    echo Sentinela not found. Please run the setup wizard again.
    exit /b 1
)

pushd "%SENTINELA_HOME%"

if "%~1"=="" goto :cmd_up
if /i "%~1"=="up"     goto :cmd_up
if /i "%~1"=="start"  goto :cmd_up
if /i "%~1"=="scan"   goto :cmd_scan
goto :cmd_help

:cmd_up
echo 🛡️  Starting Sentinela API (Bare Metal)...
uv run python -m app.agente start_api
goto :end

:cmd_scan
echo 🔍 Running scan (Bare Metal)...
uv run python -m app.agente scan %2 %3
goto :end

:cmd_help
echo Usage: sentinela {up^|scan}
echo.
echo   up      Start the API service (default)
echo   scan    Run a manual scan
goto :end

:end
popd
endlocal
"@

    Set-Content -Path "$BinDir\sentinela.cmd" -Value $LauncherContent -Encoding UTF8
    Write-Success "Command 'sentinela' installed at $BinDir"
}

function Add-ToPath {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$BinDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$BinDir;$currentPath", "User")
        $env:Path = "$BinDir;$env:Path"
        Write-Warn "PATH updated — open a new terminal to use the 'sentinela' command"
    }
}

function Write-Summary {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  ✅ Bare Metal Installation Complete!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  To run Sentinela locally without Docker:"
    Write-Host ""
    Write-Host "  You can now use the global command from anywhere:" -ForegroundColor Cyan
    Write-Host "     sentinela up" -ForegroundColor Green
    Write-Host "     sentinela scan --target 127.0.0.1" -ForegroundColor Green
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
Initialize-Environment
Install-AIModel
Install-Launcher
Add-ToPath
Write-Summary
