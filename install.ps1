# ============================================================
# 🛡️ Sentinela — Instalador One-Command (Windows/PowerShell)
# Uso: irm install.cat/MiguelFAraujo/Sentinela | iex
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
    Write-Host "  🛡️  Sentinela — Instalador Automático" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info    { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[!]    $msg" -ForegroundColor Yellow }

function Write-Fail {
    param($msg)
    Write-Host "[ERRO] $msg" -ForegroundColor Red
    exit 1
}

function Test-Dependencies {
    foreach ($cmd in @("docker", "git")) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            Write-Fail "$cmd não encontrado. Instale antes de continuar."
        }
    }
    Write-Success "Dependências verificadas (docker, git)"
}

function Install-Repository {
    if (Test-Path "$DataDir\.git") {
        Write-Info "Atualizando instalação existente..."
        Push-Location $DataDir
        & git pull --ff-only origin main 2>$null
        if ($LASTEXITCODE -ne 0) { & git pull origin main }
        Pop-Location
        Write-Success "Repositório atualizado"
    } else {
        Write-Info "Clonando repositório..."
        if (Test-Path $DataDir) { Remove-Item $DataDir -Recurse -Force }
        & git clone "https://github.com/$Repo.git" $DataDir
        Write-Success "Repositório clonado em $DataDir"
    }
}

function Install-Launcher {
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

    $LauncherContent = @'
@echo off
setlocal

set "SENTINELA_HOME=%USERPROFILE%\.sentinela"

if not exist "%SENTINELA_HOME%" (
    echo Sentinela não encontrado. Execute o instalador novamente.
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
echo 🛡️  Iniciando Sentinela...
docker compose up -d --build
echo.
echo ✅ Sentinela rodando em http://localhost:3333
echo    Documentação: http://localhost:3333/docs
goto :end

:cmd_down
echo ⏹️  Parando Sentinela...
docker compose down
goto :end

:cmd_scan
echo 🔍 Executando varredura...
docker compose exec sentinela uv run python -m app.agente scan %2 %3
goto :end

:cmd_logs
docker compose logs -f sentinela
goto :end

:cmd_status
docker compose ps
goto :end

:cmd_update
echo 🔄 Atualizando Sentinela...
git pull origin main
docker compose up -d --build
echo ✅ Atualizado com sucesso!
goto :end

:cmd_help
echo Uso: sentinela {up^|down^|scan^|logs^|status^|update}
echo.
echo   up      Inicia todos os serviços (padrão)
echo   down    Para todos os serviços
echo   scan    Executa uma varredura manual
echo   logs    Mostra logs em tempo real
echo   status  Mostra o status dos containers
echo   update  Atualiza para a versão mais recente
goto :end

:end
popd
endlocal
'@

    Set-Content -Path "$BinDir\sentinela.cmd" -Value $LauncherContent -Encoding UTF8
    Write-Success "Comando 'sentinela' instalado em $BinDir"
}

function Add-ToPath {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$BinDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$BinDir;$currentPath", "User")
        $env:Path = "$BinDir;$env:Path"
        Write-Warn "PATH atualizado — abra um novo terminal para usar o comando 'sentinela'"
    }
}

function Start-Services {
    Write-Info "Iniciando serviços Docker..."
    Push-Location $DataDir
    & docker compose up -d --build 2>&1 | Select-Object -Last 5
    Pop-Location
    Write-Success "Sentinela instalado e rodando!"
}

function Write-Summary {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  ✅ Instalação Completa!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  🌐 API:  http://localhost:3333" -ForegroundColor Cyan
    Write-Host "  📖 Docs: http://localhost:3333/docs" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Comandos disponíveis:"
    Write-Host "    sentinela          Inicia os serviços" -ForegroundColor Cyan
    Write-Host "    sentinela scan     Executa uma varredura" -ForegroundColor Cyan
    Write-Host "    sentinela logs     Acompanha os logs" -ForegroundColor Cyan
    Write-Host "    sentinela down     Para os serviços" -ForegroundColor Cyan
    Write-Host "    sentinela update   Atualiza para a versão mais recente" -ForegroundColor Cyan
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
