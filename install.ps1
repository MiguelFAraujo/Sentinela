# ============================================================
# 🛡️ Sentinela — One-Command Installer (Windows/PowerShell)
# Usage: irm install.cat/MiguelFAraujo/Sentinela | iex
# ============================================================

$ErrorActionPreference = "Stop"

$Repo = "MiguelFAraujo/Sentinela"
$AppName = "sentinela"
$InstallDir = "$env:LOCALAPPDATA\Sentinela"
$BinDir = "$InstallDir\bin"
$DataDir = "$env:USERPROFILE\.sentinela"

function Write-Header {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  🛡️  Sentinela — Automatic Installer" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info    { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[!]    $msg" -ForegroundColor Yellow }

function Write-Fail {
    param($msg)
    Write-Host "[ERR]  $msg" -ForegroundColor Red
    exit 1
}

function Test-Dependencies {
    foreach ($cmd in @("docker", "git")) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            Write-Fail "$cmd not found. Please install it before continuing."
        }
    }
    Write-Success "Dependencies verified (docker, git)"
}

function Install-Repository {
    if (Test-Path "$DataDir\.git") {
        Write-Info "Updating existing installation..."
        Push-Location $DataDir
        & git pull --ff-only origin main 2>$null
        if ($LASTEXITCODE -ne 0) { & git pull origin main }
        Pop-Location
        Write-Success "Repository updated"
    } else {
        Write-Info "Cloning repository..."
        if (Test-Path $DataDir) { Remove-Item $DataDir -Recurse -Force }
        & git clone "https://github.com/$Repo.git" $DataDir
        Write-Success "Repository cloned to $DataDir"
    }
}

function Install-Launcher {
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

    $LauncherContent = @'
@echo off
setlocal

set "SENTINELA_HOME=%USERPROFILE%\.sentinela"

if not exist "%SENTINELA_HOME%" (
    echo Sentinela not found. Please run the installer again.
    exit /b 1
)

pushd "%SENTINELA_HOME%"

if "%~1"=="" goto :cmd_up
if /i "%~1"=="up"     goto :cmd_up
if /i "%~1"=="start"  goto :cmd_up
if /i "%~1"=="down"   goto :cmd_down
if /i "%~1"=="stop"   goto :cmd_down
if /i "%~1"=="scan"   goto :cmd_scan
if /i "%~1"=="logs"   goto :cmd_logs
if /i "%~1"=="status" goto :cmd_status
if /i "%~1"=="update" goto :cmd_update
goto :cmd_help

:cmd_up
echo 🛡️  Starting Sentinela...
docker compose up -d --build
echo.
echo ✅ Sentinela running at http://localhost:3333
echo    Documentation: http://localhost:3333/docs
goto :end

:cmd_down
echo ⏹️  Stopping Sentinela...
docker compose down
goto :end

:cmd_scan
echo 🔍 Running scan...
docker compose exec sentinela uv run python -m app.agente scan %2 %3
goto :end

:cmd_logs
docker compose logs -f sentinela
goto :end

:cmd_status
docker compose ps
goto :end

:cmd_update
echo 🔄 Updating Sentinela...
git pull origin main
docker compose up -d --build
echo ✅ Updated successfully!
goto :end

:cmd_help
echo Usage: sentinela {up^|down^|scan^|logs^|status^|update}
echo.
echo   up      Start all services (default)
echo   down    Stop all services
echo   scan    Run a manual scan
echo   logs    Follow logs in real-time
echo   status  Show container status
echo   update  Update to the latest version
goto :end

:end
popd
endlocal
'@

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

function Start-Services {
    Write-Info "Starting Docker services..."
    Push-Location $DataDir
    & docker compose up -d --build 2>&1 | Select-Object -Last 5
    Pop-Location
    Write-Success "Sentinela installed and running!"
}

function Write-Summary {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  ✅ Installation Complete!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  🌐 API:  http://localhost:3333" -ForegroundColor Cyan
    Write-Host "  📖 Docs: http://localhost:3333/docs" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Available commands:"
    Write-Host "    sentinela          Start services" -ForegroundColor Cyan
    Write-Host "    sentinela scan     Run a scan" -ForegroundColor Cyan
    Write-Host "    sentinela logs     Follow logs" -ForegroundColor Cyan
    Write-Host "    sentinela down     Stop services" -ForegroundColor Cyan
    Write-Host "    sentinela update   Update to the latest version" -ForegroundColor Cyan
    Write-Host ""
}

# --- Main ---
Write-Header
Test-Dependencies
Install-Repository
Install-Launcher
Add-ToPath
Start-Services
Write-Summary
