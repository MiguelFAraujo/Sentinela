#!/bin/sh
# ============================================================
# 🛡️ Sentinela — One-Command Installer (Linux/macOS)
# Usage: curl -fsSL install.cat/MiguelFAraujo/Sentinela | sh
# ============================================================

set -e

REPO="MiguelFAraujo/Sentinela"
APP_NAME="sentinela"
INSTALL_DIR="${HOME}/.local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

header() {
    printf "\n${CYAN}══════════════════════════════════════════════════${NC}\n"
    printf "${CYAN}  🛡️  Sentinela — Automatic Installer${NC}\n"
    printf "${CYAN}══════════════════════════════════════════════════${NC}\n\n"
}

info()    { printf "${CYAN}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
warn()    { printf "${YELLOW}[!]${NC}    %s\n" "$1"; }
fail()    { printf "${RED}[ERR]${NC}  %s\n" "$1"; exit 1; }

check_deps() {
    for cmd in docker git; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            fail "$cmd not found. Please install it before continuing."
        fi
    done
    success "Dependencies verified (docker, git)"
}

clone_or_update() {
    TARGET_DIR="${HOME}/.sentinela"
    if [ -d "$TARGET_DIR/.git" ]; then
        info "Updating existing installation..."
        cd "$TARGET_DIR"
        git pull --ff-only origin main 2>/dev/null || git pull origin main
        success "Repository updated"
    else
        info "Cloning repository..."
        rm -rf "$TARGET_DIR"
        git clone "https://github.com/${REPO}.git" "$TARGET_DIR"
        success "Repository cloned to $TARGET_DIR"
    fi
    cd "$TARGET_DIR"
}

create_launcher() {
    mkdir -p "$INSTALL_DIR"

    cat > "${INSTALL_DIR}/${APP_NAME}" << 'LAUNCHER'
#!/bin/sh
# Sentinela launcher
SENTINELA_HOME="${HOME}/.sentinela"

if [ ! -d "$SENTINELA_HOME" ]; then
    echo "Sentinela not found. Please run the installer again."
    exit 1
fi

cd "$SENTINELA_HOME"

case "${1:-up}" in
    up|start)
        echo "🛡️  Starting Sentinela..."
        docker compose up -d --build
        echo ""
        echo "✅ Sentinela running at http://localhost:3333"
        echo "   Documentation: http://localhost:3333/docs"
        ;;
    down|stop)
        echo "⏹️  Stopping Sentinela..."
        docker compose down
        ;;
    scan)
        echo "🔍 Running scan..."
        docker compose exec sentinela uv run python -m app.agente scan ${2:+--target "$2"}
        ;;
    logs)
        docker compose logs -f sentinela
        ;;
    status)
        docker compose ps
        ;;
    update)
        echo "🔄 Updating Sentinela..."
        git pull origin main
        docker compose up -d --build
        echo "✅ Updated successfully!"
        ;;
    *)
        echo "Usage: sentinela {up|down|scan|logs|status|update}"
        echo ""
        echo "  up      Start all services (default)"
        echo "  down    Stop all services"
        echo "  scan    Run a manual scan"
        echo "  logs    Follow logs in real-time"
        echo "  status  Show container status"
        echo "  update  Update to the latest version"
        ;;
esac
LAUNCHER

    chmod +x "${INSTALL_DIR}/${APP_NAME}"
    success "Command 'sentinela' installed at ${INSTALL_DIR}"
}

add_to_path() {
    if echo "$PATH" | grep -q "$INSTALL_DIR"; then
        return
    fi

    SHELL_NAME="$(basename "$SHELL" 2>/dev/null || echo "sh")"

    case "$SHELL_NAME" in
        zsh)  RC_FILE="${HOME}/.zshrc" ;;
        bash) RC_FILE="${HOME}/.bashrc" ;;
        fish) RC_FILE="${HOME}/.config/fish/config.fish" ;;
        *)    RC_FILE="${HOME}/.profile" ;;
    esac

    if [ -f "$RC_FILE" ] && grep -q "$INSTALL_DIR" "$RC_FILE" 2>/dev/null; then
        return
    fi

    if [ "$SHELL_NAME" = "fish" ]; then
        echo "set -gx PATH $INSTALL_DIR \$PATH" >> "$RC_FILE"
    else
        echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$RC_FILE"
    fi

    warn "PATH updated in $RC_FILE — run 'source $RC_FILE' or open a new terminal"
}

start_services() {
    info "Starting Docker services..."
    docker compose up -d --build 2>&1 | tail -5
    echo ""
    success "Sentinela installed and running!"
}

print_summary() {
    printf "\n${GREEN}══════════════════════════════════════════════════${NC}\n"
    printf "${GREEN}  ✅ Installation Complete!${NC}\n"
    printf "${GREEN}══════════════════════════════════════════════════${NC}\n\n"
    printf "  🌐 API:  ${CYAN}http://localhost:3333${NC}\n"
    printf "  📖 Docs: ${CYAN}http://localhost:3333/docs${NC}\n\n"
    printf "  Available commands:\n"
    printf "    ${CYAN}sentinela${NC}          Start services\n"
    printf "    ${CYAN}sentinela scan${NC}     Run a scan\n"
    printf "    ${CYAN}sentinela logs${NC}     Follow logs\n"
    printf "    ${CYAN}sentinela down${NC}     Stop services\n"
    printf "    ${CYAN}sentinela update${NC}   Update to the latest version\n\n"
}

# --- Main ---
header
check_deps
clone_or_update
create_launcher
add_to_path
start_services
print_summary
