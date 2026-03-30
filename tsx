#!/bin/bash
# TermuxServerX v2.0 - User-Friendly Manager
# Easy management for all services

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

is_running() { pgrep -f "$1" > /dev/null 2>&1; }
ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
err() { echo -e "${RED}✗${NC} $1"; }

banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║   ██████╗  ██████╗  ██████╗ ███╗   ███╗███████╗           ║"
    echo "║   ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║██╔════╝           ║"
    echo "║   ██████╔╝██║   ██║██║   ██║██╔████╔██║███████╗           ║"
    echo "║   ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║╚════██║           ║"
    echo "║   ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║███████║           ║"
    echo "║   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝           ║"
    echo "║                                                              ║"
    echo "║           ServerX v2.0 - Android Server Platform            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

menu() {
    echo ""
    echo -e "${BOLD}┌─────────────────────────────────────┐${NC}"
    echo -e "${BOLD}│           Main Menu                   │${NC}"
    echo -e "${BOLD}├─────────────────────────────────────┤${NC}"
    echo -e "${BOLD}│${NC}  [1] 🚀 Start Essential Services   ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [2] ⏹️  Stop All Services        ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [3] 📊 View Service Status      ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [4] 📝 View Logs               ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [5] 🌐 Start Web Dashboard      ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [6] 💾 Create Backup            ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [7] ⚡ Optimize System          ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [8] 📦 Install New Service       ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [9] 📖 Help & Commands          ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  [0] 🚪 Exit                     ${BOLD}│${NC}"
    echo -e "${BOLD}└─────────────────────────────────────┘${NC}"
    echo ""
}

status_display() {
    echo ""
    echo -e "${BOLD}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}│               Service Status                             │${NC}"
    echo -e "${BOLD}├──────────────────────────────────────────────────────────┤${NC}"
    
    local services=(
        "nginx:8080:Web Server"
        "php-fpm:9000:PHP"
        "mariadb:3306:Database"
        "redis:6379:Cache"
        "minecraft:25565:Minecraft"
        "filebrowser:8081:File Manager"
        "code-server:8443:VS Code"
        "sshd:8022:SSH"
    )
    
    for entry in "${services[@]}"; do
        IFS=':' read -r svc port desc <<< "$entry"
        if is_running "$svc"; then
            echo -e "${BOLD}│${NC} ${GREEN}●${NC} $desc${BOLD}........................................${GREEN}RUNNING${NC} ${BOLD}│${NC}"
        else
            echo -e "${BOLD}│${NC} ${RED}○${NC} $desc${BOLD}........................................${RED}STOPPED${NC} ${BOLD}│${NC}"
        fi
    done
    
    echo -e "${BOLD}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo ""
    echo -e "${BOLD}System Resources:${NC}"
    echo "  CPU: $(top -bn1 | grep 'Cpu' | awk '{print $2}')% used"
    echo "  RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "  Disk: $(df -h ~ | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
}

quick_start() {
    echo -e "\n${CYAN}Starting essential services...${NC}"
    bash "$TSX_DIR/services/web/nginx.sh" start 2>/dev/null && ok "Nginx" || warn "Nginx"
    bash "$TSX_DIR/services/web/php.sh" start 2>/dev/null && ok "PHP-FPM" || warn "PHP-FPM"
    bash "$TSX_DIR/services/database/redis.sh" start 2>/dev/null && ok "Redis" || warn "Redis"
    bash "$TSX_DIR/services/storage/filebrowser.sh" start 2>/dev/null && ok "FileBrowser" || warn "FileBrowser"
    echo -e "${GREEN}Done!${NC}"
}

quick_stop() {
    echo -e "\n${YELLOW}Stopping all services...${NC}"
    pkill -f nginx 2>/dev/null && ok "Nginx stopped" || true
    pkill -f php-fpm 2>/dev/null && ok "PHP-FPM stopped" || true
    pkill -f redis 2>/dev/null && ok "Redis stopped" || true
    pkill -f filebrowser 2>/dev/null && ok "FileBrowser stopped" || true
    echo -e "${YELLOW}Done!${NC}"
}

install_service() {
    echo ""
    echo -e "${BOLD}Available Services to Install:${NC}"
    echo ""
    echo "  [1] Nginx Web Server"
    echo "  [2] PHP + MariaDB"
    echo "  [3] Minecraft Server"
    echo "  [4] FileBrowser"
    echo "  [5] code-server (VS Code)"
    echo "  [6] Jellyfin Media"
    echo "  [7] Nextcloud"
    echo "  [8] SSH Server"
    echo "  [9] Cloudflare Tunnel"
    echo "  [0] Back to menu"
    echo ""
    read -p "Select [0-9]: " choice
    
    case $choice in
        1) bash "$TSX_DIR/services/web/nginx.sh" install ;;
        2) bash "$TSX_DIR/services/web/php.sh" install && bash "$TSX_DIR/services/database/mariadb.sh" install ;;
        3) bash "$TSX_DIR/services/games/minecraft.sh" install ;;
        4) bash "$TSX_DIR/services/storage/filebrowser.sh" install ;;
        5) bash "$TSX_DIR/services/dev/code-server.sh" install ;;
        6) bash "$TSX_DIR/services/media/jellyfin.sh" install ;;
        7) bash "$TSX_DIR/services/storage/nextcloud.sh" install ;;
        8) bash "$TSX_DIR/services/security/ssh.sh" install ;;
        9) bash "$TSX_DIR/services/network/cloudflared.sh" install ;;
    esac
}

show_help() {
    echo -e "\n${BOLD}═══ TermuxServerX Commands ═══${NC}\n"
    echo -e "${GREEN}tsx${NC}              - This menu"
    echo -e "${GREEN}tsx status${NC}      - Show all services"
    echo -e "${GREEN}tsx start <svc>${NC}  - Start service"
    echo -e "${GREEN}tsx stop <svc>${NC}   - Stop service"
    echo -e "${GREEN}tsx logs${NC}        - View logs"
    echo -e "${GREEN}tsx-web${NC}         - Start web dashboard"
    echo -e "${GREEN}tsx backup${NC}      - Create backup"
    echo -e "${GREEN}tsx optimize${NC}    - Optimize system"
    echo ""
    echo -e "${BOLD}Quick Commands:${NC}"
    echo "  tsx quick-start   - Start all essential services"
    echo "  tsx quick-stop    - Stop all services"
    echo ""
    echo -e "${BOLD}Services:${NC} nginx, php, mariadb, redis, minecraft, filebrowser, code-server"
    echo ""
}

view_logs() {
    echo ""
    echo "Services with logs:"
    echo "  [1] nginx  [2] php  [3] mariadb  [4] redis"
    echo "  [5] minecraft  [6] webui"
    echo ""
    read -p "Select [1-6]: " choice
    
    case $choice in
        1) tail -50 "$TSX_DIR/logs/nginx/error.log" 2>/dev/null || echo "No logs" ;;
        2) tail -50 "$TSX_DIR/logs/php/error.log" 2>/dev/null || echo "No logs" ;;
        3) tail -50 "$TSX_DIR/logs/mariadb/error.log" 2>/dev/null || echo "No logs" ;;
        4) tail -50 "$TSX_DIR/logs/redis/redis.log" 2>/dev/null || echo "No logs" ;;
        5) tail -50 "$TSX_DIR/logs/minecraft/latest.log" 2>/dev/null || echo "No logs" ;;
        6) tail -50 "$TSX_DIR/logs/webui/server.log" 2>/dev/null || echo "No logs" ;;
    esac
}

case "${1:-menu}" in
    menu|interactive|-i)
        while true; do
            banner
            status_display
            menu
            read -p "Select [0-9]: " choice
            
            case $choice in
                1) quick_start; read -p "Press Enter..." ;;
                2) quick_stop; read -p "Press Enter..." ;;
                3) banner; status_display; read -p "Press Enter..." ;;
                4) view_logs; read -p "Press Enter..." ;;
                5) 
                    echo -e "\n${CYAN}Starting Web Dashboard...${NC}"
                    echo "Access: http://localhost:${TSX_WEBUI_PORT:-8080}"
                    python "$TSX_DIR/webui/server.py" &
                    read -p "Press Enter..." ;;
                6) bash "$TSX_DIR/scripts/backup.sh"; read -p "Press Enter..." ;;
                7) bash "$TSX_DIR/core/optimize.sh"; read -p "Press Enter..." ;;
                8) install_service; read -p "Press Enter..." ;;
                9) show_help; read -p "Press Enter..." ;;
                0) clear; exit 0 ;;
                start) bash "$TSX_DIR/manage" start "${2:-nginx}" ;;
                stop) bash "$TSX_DIR/manage" stop "${2:-nginx}" ;;
                status) banner; status_display ;;
                *) echo "Invalid option" ;;
            esac
        done
        ;;
    start) bash "$TSX_DIR/manage" start "$2" ;;
    stop) bash "$TSX_DIR/manage" stop "$2" ;;
    status) banner; status_display ;;
    logs) view_logs ;;
    quick-start) quick_start ;;
    quick-stop) quick_stop ;;
    help|--help|-h) show_help ;;
    *) show_help ;;
esac
