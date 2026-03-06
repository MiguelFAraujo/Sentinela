# ============================================================
# 🛡️ Sentinela — Uninstaller (Windows/PowerShell)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$InstallDir = "$env:LOCALAPPDATA\Sentinela"
$BinDir = "$InstallDir\bin"
$DataDir = "$env:USERPROFILE\.sentinela"

Write-Host ""
Write-Host "🛡️  Sentinela — Uninstaller" -ForegroundColor Cyan
Write-Host ""

# Stop containers
if (Test-Path $DataDir) {
    Write-Host "[INFO] Stopping containers..." -ForegroundColor Cyan
    Push-Location $DataDir
    & docker compose down 2>$null
    Pop-Location
}

# Remove launcher
if (Test-Path "$BinDir\sentinela.cmd") {
    Remove-Item "$BinDir\sentinela.cmd" -Force
    Write-Host "[OK]   Command 'sentinela' removed" -ForegroundColor Green
}

# Remove from PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -like "*$BinDir*") {
    $newPath = ($userPath -split ";" | Where-Object { $_ -ne $BinDir }) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[OK]   PATH cleaned" -ForegroundColor Green
}

# Remove data
if (Test-Path $DataDir) {
    Remove-Item $DataDir -Recurse -Force
    Write-Host "[OK]   Data removed" -ForegroundColor Green
}

# Remove install dir
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}

Write-Host ""
Write-Host "✅ Sentinela uninstalled successfully!" -ForegroundColor Green
Write-Host ""
