#!/bin/bash
# TermuxServerX v2.0 - Ultimate Android Server Platform
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TSX_DIR="$HOME/TermuxServerX"
TSX_VERSION="2.0.0"

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${CYAN}[OK]${NC} $1"; }

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                      ║"
    echo "║   ██████╗  ██████╗  ██████╗ ███╗   ███╗███████╗  ██████╗ ██████╗ ║"
    echo "║   ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║██╔════╝ ██╔═══██╗██╔══██╗║"
    echo "║   ██████╔╝██║   ██║██║   ██║██╔████╔██║███████╗ ██║   ██║██████╔╝║"
    echo "║   ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║╚════██║ ██║   ██║██╔══██╗║"
    echo "║   ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║███████║ ╚██████╔╝██║  ██║║"
    echo "║   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝  ╚═════╝ ╚═╝  ╚═╝║"
    echo "║                                                                      ║"
    echo "║            ServerX v${TSX_VERSION} - Ultimate Android Server Platform         ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_termux() {
    log "Checking environment..."
    if [ ! -d "/data/data/com.termux/files/usr" ]; then
        error "Termux not detected! Please install from F-Droid."
        exit 1
    fi
    success "Environment OK"
}

update_packages() {
    log "Updating Termux packages..."
    pkg update -y && pkg upgrade -y 2>/dev/null || true
    success "Packages updated"
}

install_dependencies() {
    log "Installing core dependencies..."
    local pkgs=(
        coreutils util-linux findutils grep sed gawk tar gzip unzip
        curl wget git tmux htop bash bash-completion
        ncurses-utils procps-ng cronie termux-services
        openssh python python-pip ncurses-terminfo nano vim
        termux-api nodejs npm openssl
    )
    for pkg in "${pkgs[@]}"; do
        pkg install -y "$pkg" 2>/dev/null || warn "Failed: $pkg"
    done
    success "Dependencies installed"
}

create_directories() {
    log "Creating directory structure..."
    mkdir -p "$TSX_DIR"/{core,services,webui,scripts,templates,data,logs,backups,config}
    mkdir -p "$TSX_DIR/services"/{web,database,storage,games,dev,media,productivity,network,monitoring}
    mkdir -p "$TSX_DIR/backups"/{configs,databases,full,services}
    mkdir -p "$TSX_DIR/logs"/{nginx,php,mariadb,redis,minecraft,webui,system,watchdog,cron}
    mkdir -p "$TSX_DIR/data"/{www,mariadb,redis,minecraft,nextcloud,code-server,jellyfin}
    mkdir -p "$HOME/storage/shared"/{www,backups,media,games,sync}
    chmod -R 755 "$TSX_DIR"
    success "Directories created"
}

run_detection() {
    log "Detecting system resources..."
    bash "$TSX_DIR/core/detect.sh"
    source "$TSX_DIR/config.env"
    success "Detection complete"
}

install_python_deps() {
    log "Installing Python dependencies..."
    pip install --quiet --upgrade pip
    pip install --quiet flask psutil bcrypt requests cryptography distro schedule flask-cors
    success "Python installed"
}

show_menu() {
    echo ""
    echo -e "${BOLD}Device: ${TSX_DEVICE_MODEL} | RAM: ${TSX_TOTAL_RAM}MB (${TSX_RAM_TIER}) | Cores: ${TSX_CPU_CORES}${NC}"
    echo ""
    echo -e "${BOLD}Select Installation Type:${NC}"
    echo "  [1] Full Stack (Everything - All services)"
    echo "  [2] Web Stack (Nginx, PHP, Node, Python, Databases)"
    echo "  [3] Game Server Stack (Minecraft, PocketMine)"
    echo "  [4] Media Stack (Jellyfin, Streaming)"
    echo "  [5] Minimal (Basic web server only)"
    echo "  [6] Custom Selection"
    echo "  [7] Exit (skip installation)"
    echo ""
}

install_all() {
    log "Installing FULL STACK..."
    bash "$TSX_DIR/services/web/nginx.sh" install
    bash "$TSX_DIR/services/web/php.sh" install
    bash "$TSX_DIR/services/web/node.sh" install
    bash "$TSX_DIR/services/web/python.sh" install
    bash "$TSX_DIR/services/database/sqlite.sh" install
    bash "$TSX_DIR/services/database/redis.sh" install
    bash "$TSX_DIR/services/database/mariadb.sh" install
    bash "$TSX_DIR/services/storage/filebrowser.sh" install
    bash "$TSX_DIR/services/storage/rclone.sh" install
    bash "$TSX_DIR/services/games/minecraft.sh" install
    bash "$TSX_DIR/services/games/pocketmine.sh" install
    bash "$TSX_DIR/services/dev/code-server.sh" install
    bash "$TSX_DIR/services/dev/git.sh" install
    bash "$TSX_DIR/services/media/jellyfin.sh" install
    bash "$TSX_DIR/services/network/cloudflared.sh" install
    bash "$TSX_DIR/services/monitoring/netdata.sh" install
    success "Full stack installed!"
}

install_web() {
    log "Installing Web Stack..."
    bash "$TSX_DIR/services/web/nginx.sh" install
    bash "$TSX_DIR/services/web/php.sh" install
    bash "$TSX_DIR/services/web/node.sh" install
    bash "$TSX_DIR/services/web/python.sh" install
    bash "$TSX_DIR/services/database/sqlite.sh" install
    bash "$TSX_DIR/services/database/redis.sh" install
    bash "$TSX_DIR/services/database/mariadb.sh" install
    success "Web stack installed!"
}

install_games() {
    log "Installing Game Servers..."
    bash "$TSX_DIR/services/games/minecraft.sh" install
    bash "$TSX_DIR/services/games/pocketmine.sh" install
    success "Game servers installed!"
}

install_media() {
    log "Installing Media Stack..."
    bash "$TSX_DIR/services/media/jellyfin.sh" install
    success "Media stack installed!"
}

custom_install() {
    echo ""
    echo "Select services (comma-separated, e.g., w,d,g,v):"
    echo "  w) Web Stack | d) Databases | s) Storage"
    echo "  g) Games | v) Dev Tools | m) Media"
    echo "  n) Network | o) Monitoring"
    echo ""
    read -p "Enter: " choices
    [[ "$choices" == *"w"* ]] && bash "$TSX_DIR/services/web/nginx.sh" install && bash "$TSX_DIR/services/web/php.sh" install
    [[ "$choices" == *"d"* ]] && bash "$TSX_DIR/services/database/mariadb.sh" install && bash "$TSX_DIR/services/database/redis.sh" install
    [[ "$choices" == *"s"* ]] && bash "$TSX_DIR/services/storage/filebrowser.sh" install
    [[ "$choices" == *"g"* ]] && install_games
    [[ "$choices" == *"v"* ]] && bash "$TSX_DIR/services/dev/code-server.sh" install
    [[ "$choices" == *"m"* ]] && install_media
    [[ "$choices" == *"n"* ]] && bash "$TSX_DIR/services/network/cloudflared.sh" install
    [[ "$choices" == *"o"* ]] && bash "$TSX_DIR/services/monitoring/netdata.sh" install
}

setup_everything() {
    log "Setting up auto-start..."
    bash "$TSX_DIR/core/auto-start.sh" setup
    
    log "Setting up auto-maintenance..."
    bash "$TSX_DIR/core/maintenance.sh" setup
    
    log "Setting up watchdog..."
    bash "$TSX_DIR/core/watchdog.sh" setup
    
    log "Optimizing system..."
    bash "$TSX_DIR/core/optimize.sh"
    
    log "Creating shortcuts..."
    ln -sf "$TSX_DIR/manage" "$PREFIX/bin/tsx" 2>/dev/null || true
    ln -sf "$TSX_DIR/webui/server.py" "$PREFIX/bin/tsx-web" 2>/dev/null || true
    
    success "Everything configured!"
}

show_complete() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    Installation Complete!                         ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                                      ║${NC}"
    echo -e "${CYAN}║  Web UI:    tsx-web  or  python ~/TermuxServerX/webui/server.py ║${NC}"
    echo -e "${CYAN}║  CLI:       tsx        (or ~/TermuxServerX/manage)              ║${NC}"
    echo -e "${CYAN}║  Help:      tsx help                                            ║${NC}"
    echo -e "${CYAN}║                                                                      ║${NC}"
    echo -e "${CYAN}║  Access Web UI at: http://localhost:${TSX_WEBUI_PORT:-8080}                    ║${NC}"
    echo -e "${CYAN}║  Default login: admin / ${TSX_WEBUI_PASSWORD}                          ║${NC}"
    echo -e "${CYAN}║                                                                      ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo "  tsx              - Open management menu"
    echo "  tsx status       - Show all services"
    echo "  tsx start nginx  - Start a service"
    echo "  tsx logs nginx   - View logs"
    echo "  tsx backup       - Create backup"
    echo "  tsx optimize     - Optimize performance"
    echo ""
}

main() {
    show_banner
    check_termux
    update_packages
    install_dependencies
    create_directories
    run_detection
    install_python_deps
    show_menu
    read -p "Select [1-7]: " choice
    case $choice in
        1) install_all ;;
        2) install_web ;;
        3) install_games ;;
        4) install_media ;;
        5) bash "$TSX_DIR/services/web/nginx.sh" install ;;
        6) custom_install ;;
        7) log "Skipping installation" ;;
    esac
    setup_everything
    show_complete
}

main "$@"
