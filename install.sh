#!/bin/sh
# ============================================================
# 🛡️ Sentinela — Instalador One-Command (Linux/macOS)
# Uso: curl -fsSL install.cat/MiguelFAraujo/Sentinela | sh
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
    printf "${CYAN}  🛡️  Sentinela — Instalador Automático${NC}\n"
    printf "${CYAN}══════════════════════════════════════════════════${NC}\n\n"
}

info()    { printf "${CYAN}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
warn()    { printf "${YELLOW}[!]${NC}    %s\n" "$1"; }
fail()    { printf "${RED}[ERRO]${NC} %s\n" "$1"; exit 1; }

check_deps() {
    for cmd in docker git; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            fail "$cmd não encontrado. Instale antes de continuar."
        fi
    done
    success "Dependências verificadas (docker, git)"
}

clone_or_update() {
    TARGET_DIR="${HOME}/.sentinela"
    if [ -d "$TARGET_DIR/.git" ]; then
        info "Atualizando instalação existente..."
        cd "$TARGET_DIR"
        git pull --ff-only origin main 2>/dev/null || git pull origin main
        success "Repositório atualizado"
    else
        info "Clonando repositório..."
        rm -rf "$TARGET_DIR"
        git clone "https://github.com/${REPO}.git" "$TARGET_DIR"
        success "Repositório clonado em $TARGET_DIR"
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
    echo "Sentinela não encontrado. Execute o instalador novamente."
    exit 1
fi

cd "$SENTINELA_HOME"

case "${1:-up}" in
    up|start)
        echo "🛡️  Iniciando Sentinela..."
        docker compose up -d --build
        echo ""
        echo "✅ Sentinela rodando em http://localhost:3333"
        echo "   Documentação: http://localhost:3333/docs"
        ;;
    down|stop)
        echo "⏹️  Parando Sentinela..."
        docker compose down
        ;;
    scan)
        echo "🔍 Executando varredura..."
        docker compose exec sentinela uv run python -m app.agente scan ${2:+--target "$2"}
        ;;
    logs)
        docker compose logs -f sentinela
        ;;
    status)
        docker compose ps
        ;;
    update)
        echo "🔄 Atualizando Sentinela..."
        git pull origin main
        docker compose up -d --build
        echo "✅ Atualizado com sucesso!"
        ;;
    *)
        echo "Uso: sentinela {up|down|scan|logs|status|update}"
        echo ""
        echo "  up      Inicia todos os serviços (padrão)"
        echo "  down    Para todos os serviços"
        echo "  scan    Executa uma varredura manual"
        echo "  logs    Mostra logs em tempo real"
        echo "  status  Mostra o status dos containers"
        echo "  update  Atualiza para a versão mais recente"
        ;;
esac
LAUNCHER

    chmod +x "${INSTALL_DIR}/${APP_NAME}"
    success "Comando 'sentinela' instalado em ${INSTALL_DIR}"
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

    warn "PATH atualizado em $RC_FILE — rode 'source $RC_FILE' ou abra um novo terminal"
}

start_services() {
    info "Iniciando serviços Docker..."
    docker compose up -d --build 2>&1 | tail -5
    echo ""
    success "Sentinela instalado e rodando!"
}

print_summary() {
    printf "\n${GREEN}══════════════════════════════════════════════════${NC}\n"
    printf "${GREEN}  ✅ Instalação Completa!${NC}\n"
    printf "${GREEN}══════════════════════════════════════════════════${NC}\n\n"
    printf "  🌐 API:  ${CYAN}http://localhost:3333${NC}\n"
    printf "  📖 Docs: ${CYAN}http://localhost:3333/docs${NC}\n\n"
    printf "  Comandos disponíveis:\n"
    printf "    ${CYAN}sentinela${NC}          Inicia os serviços\n"
    printf "    ${CYAN}sentinela scan${NC}     Executa uma varredura\n"
    printf "    ${CYAN}sentinela logs${NC}     Acompanha os logs\n"
    printf "    ${CYAN}sentinela down${NC}     Para os serviços\n"
    printf "    ${CYAN}sentinela update${NC}   Atualiza para a versão mais recente\n\n"
}

# --- Main ---
header
check_deps
clone_or_update
create_launcher
add_to_path
start_services
print_summary
