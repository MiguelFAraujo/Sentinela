#!/bin/sh
# ============================================================
# 🛡️ Sentinela — Uninstaller (Linux/macOS)
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.sentinela"

printf "\n${CYAN}🛡️  Sentinela — Uninstaller${NC}\n\n"

# Stop containers
if [ -d "$DATA_DIR" ]; then
    printf "${CYAN}[INFO]${NC} Stopping containers...\n"
    cd "$DATA_DIR" && docker compose down 2>/dev/null || true
fi

# Remove launcher
if [ -f "${INSTALL_DIR}/sentinela" ]; then
    rm -f "${INSTALL_DIR}/sentinela"
    printf "${GREEN}[OK]${NC}   Command 'sentinela' removed\n"
fi

# Remove data
if [ -d "$DATA_DIR" ]; then
    rm -rf "$DATA_DIR"
    printf "${GREEN}[OK]${NC}   Data removed from $DATA_DIR\n"
fi

printf "\n${GREEN}✅ Sentinela uninstalled successfully!${NC}\n\n"
