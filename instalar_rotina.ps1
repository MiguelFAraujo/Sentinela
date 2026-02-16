# ============================================================
# 🛡️ Sentinela V3.0 — Instalador de Rotina Automática
# ============================================================
# Este script configura o Agendador de Tarefas do Windows para
# executar o agente.py diariamente às 09:00, em modo oculto.
#
# USO: Execute como Administrador no PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\instalar_rotina.ps1
# ============================================================

#Requires -RunAsAdministrator

# --- Configurações ---
$NomeTarefa = "Sentinela_EDR_Diario"
$Descricao = "Executa o agente Sentinela V3.0 (EDR com IA local) diariamente às 09:00"
$HoraExecucao = "09:00"
$PastaAtual = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptAlvo = Join-Path $PastaAtual "agente.py"
$PythonExe = (Get-Command python -ErrorAction SilentlyContinue).Source

# --- Validações ---
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Sentinela V3.0 - Instalador de Rotina" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se o Python foi encontrado
if (-not $PythonExe) {
    Write-Host "[ERRO] Python nao encontrado no PATH do sistema." -ForegroundColor Red
    Write-Host "       Instale o Python e marque 'Add to PATH' durante a instalacao." -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Python encontrado: $PythonExe" -ForegroundColor Green

# Verifica se o agente.py existe na pasta
if (-not (Test-Path $ScriptAlvo)) {
    Write-Host "[ERRO] Arquivo 'agente.py' nao encontrado em:" -ForegroundColor Red
    Write-Host "       $PastaAtual" -ForegroundColor Yellow
    Write-Host "       Coloque este script na mesma pasta do agente.py" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] agente.py encontrado: $ScriptAlvo" -ForegroundColor Green

# --- Remove tarefa anterior (se existir) ---
$tarefaExistente = Get-ScheduledTask -TaskName $NomeTarefa -ErrorAction SilentlyContinue
if ($tarefaExistente) {
    Write-Host ""
    Write-Host "[INFO] Tarefa '$NomeTarefa' ja existe. Substituindo..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $NomeTarefa -Confirm:$false
}

# --- Criar a Tarefa Agendada ---
Write-Host ""
Write-Host "[...] Configurando tarefa no Agendador do Windows..." -ForegroundColor Cyan

# Ação: executar python agente.py na pasta do projeto
$Acao = New-ScheduledTaskAction `
    -Execute $PythonExe `
    -Argument "`"$ScriptAlvo`"" `
    -WorkingDirectory $PastaAtual

# Gatilho: todos os dias às 09:00
$Gatilho = New-ScheduledTaskTrigger `
    -Daily `
    -At $HoraExecucao

# Configurações: rodar mesmo sem login, permitir iniciar manualmente
$Configuracoes = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30) `
    -Hidden

# Principal: rodar com o usuário atual com privilégios elevados
$Principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -RunLevel Highest `
    -LogonType Interactive

# Registrar a tarefa
try {
    Register-ScheduledTask `
        -TaskName $NomeTarefa `
        -Description $Descricao `
        -Action $Acao `
        -Trigger $Gatilho `
        -Settings $Configuracoes `
        -Principal $Principal `
        -Force | Out-Null

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  TAREFA INSTALADA COM SUCESSO!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Nome:      $NomeTarefa"
    Write-Host "  Horario:   Todos os dias as $HoraExecucao"
    Write-Host "  Script:    $ScriptAlvo"
    Write-Host "  Python:    $PythonExe"
    Write-Host "  Pasta:     $PastaAtual"
    Write-Host "  Modo:      Oculto (Hidden)"
    Write-Host ""
    Write-Host "  Para verificar, abra o Agendador de Tarefas" -ForegroundColor Yellow
    Write-Host "  ou execute: Get-ScheduledTask -TaskName '$NomeTarefa'" -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "[ERRO] Falha ao registrar a tarefa:" -ForegroundColor Red
    Write-Host "       $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Certifique-se de executar este script como Administrador." -ForegroundColor Yellow
    exit 1
}
