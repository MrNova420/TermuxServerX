#!/data/data/com.termux/files/usr/bin/bash
# Quick-Install Stack Scripts
# One-command setup for popular service combinations

INSTALL_DIR="$HOME/TermuxServerX"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

show_stack_menu() {
    clear
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║         Quick-Install Stacks                       ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "║                                                      ║"
    echo "║  Web Stacks:                                        ║"
    echo "║    1) LAMP Stack (Linux + Apache + MySQL + PHP)     ║"
    echo "║    2) LEMP Stack (Linux + Nginx + MySQL + PHP)     ║"
    echo "║    3) LLSMP (Linux + LinuxDo + MySQL + PHP)       ║"
    echo "║                                                      ║"
    echo "║  Database Stacks:                                   ║"
    echo "║    4) PostgreSQL Full (Postgres + PgAdmin + Redis) ║"
    echo "║    5) MongoDB Stack (MongoDB + Adminer)            ║"
    echo "║                                                      ║"
    echo "║  Media Stacks:                                      ║"
    echo "║    6) Media Server (Jellyfin + Sonarr + Radarr)    ║"
    echo "║    7) Music Server (Navidrome + Subsonic)          ║"
    echo "║                                                      ║"
    echo "║  Development Stacks:                                ║"
    echo "║    8) Dev Environment (Node + Python + Redis)      ║"
    echo "║    9) Git Server (Gitea + Drone CI)               ║"
    echo "║   10) Code Server (VS Code in browser)             ║"
    echo "║                                                      ║"
    echo "║  Game Stacks:                                       ║"
    echo "║   11) Minecraft Server (with mods support)          ║"
    echo "║   12) Game Server Suite (MC + Valheim + Palworld)  ║"
    echo "║                                                      ║"
    echo "║  Automation Stacks:                                 ║"
    echo "║   13) Home Automation (HomeAssistant + ESPHome)    ║"
    echo "║   14) Productivity (Outline + Vaultwarden + n8n)  ║"
    echo "║                                                      ║"
    echo "║  Monitoring Stacks:                                 ║"
    echo "║   15) Full Monitoring (Netdata + Grafana + Uptime) ║"
    echo "║   16) Analytics Stack (Umami + Plausible)         ║"
    echo "║                                                      ║"
    echo "║  0) Exit                                            ║"
    echo "╚══════════════════════════════════════════════════════╝"
}

install_lamp_stack() {
    log "Installing LAMP Stack..."
    "$INSTALL_DIR/install.sh" --service nginx
    "$INSTALL_DIR/install.sh" --service mariadb
    "$INSTALL_DIR/install.sh" --service php
    success "LAMP Stack installed!"
    echo "Access: http://localhost:80"
}

install_lemp_stack() {
    log "Installing LEMP Stack..."
    "$INSTALL_DIR/install.sh" --service nginx
    "$INSTALL_DIR/install.sh" --service mariadb
    "$INSTALL_DIR/install.sh" --service php
    success "LEMP Stack installed!"
    echo "Access: http://localhost:80"
}

install_llsmp_stack() {
    log "Installing LLSMP Stack..."
    "$INSTALL_DIR/install.sh" --service nginx
    "$INSTALL_DIR/install.sh" --service mariadb
    "$INSTALL_DIR/install.sh" --service php
    "$INSTALL_DIR/install.sh" --service filebrowser
    success "LLSMP Stack installed!"
}

install_postgres_stack() {
    log "Installing PostgreSQL Stack..."
    "$INSTALL_DIR/install.sh" --service postgresql
    "$INSTALL_DIR/install.sh" --service redis
    "$INSTALL_DIR/install.sh" --service adminer
    success "PostgreSQL Stack installed!"
    echo "PgAdmin: http://localhost:5050"
}

install_mongodb_stack() {
    log "Installing MongoDB Stack..."
    "$INSTALL_DIR/install.sh" --service mongodb
    "$INSTALL_DIR/install.sh" --service adminer
    success "MongoDB Stack installed!"
}

install_media_server() {
    log "Installing Media Server Stack..."
    "$INSTALL_DIR/install.sh" --service jellyfin
    "$INSTALL_DIR/install.sh" --service filebrowser
    "$INSTALL_DIR/install.sh" --service rclone
    success "Media Server installed!"
    echo "Jellyfin: http://localhost:8096"
}

install_music_server() {
    log "Installing Music Server Stack..."
    "$INSTALL_DIR/install.sh" --service navidrome
    "$INSTALL_DIR/install.sh" --service filebrowser
    success "Music Server installed!"
    echo "Navidrome: http://localhost:4533"
}

install_dev_environment() {
    log "Installing Development Stack..."
    "$INSTALL_DIR/install.sh" --service node
    "$INSTALL_DIR/install.sh" --service python
    "$INSTALL_DIR/install.sh" --service redis
    "$INSTALL_DIR/install.sh" --service git
    "$INSTALL_DIR/install.sh" --service code-server
    success "Dev Environment installed!"
    echo "Code Server: http://localhost:8443"
}

install_git_server() {
    log "Installing Git Server Stack..."
    "$INSTALL_DIR/install.sh" --service gitea
    "$INSTALL_DIR/install.sh" --service nginx
    success "Git Server installed!"
    echo "Gitea: http://localhost:3000"
}

install_code_server() {
    log "Installing Code Server..."
    "$INSTALL_DIR/install.sh" --service code-server
    success "Code Server installed!"
    echo "Access: https://localhost:8443"
}

install_minecraft_stack() {
    log "Installing Minecraft Server with Mods Support..."
    "$INSTALL_DIR/install.sh" --service minecraft
    "$INSTALL_DIR/install.sh" --service filebrowser
    success "Minecraft Server installed!"
    cp "$INSTALL_DIR/templates/minecraft/modpack-manager.sh" ~/TermuxServerX/
    chmod +x ~/TermuxServerX/modpack-manager.sh
    echo "Use: ~/TermuxServerX/modpack-manager.sh for mod management"
}

install_game_server_suite() {
    log "Installing Game Server Suite..."
    "$INSTALL_DIR/install.sh" --service minecraft
    "$INSTALL_DIR/install.sh" --service valheim
    "$INSTALL_DIR/install.sh" --service palworld
    "$INSTALL_DIR/install.sh" --service filebrowser
    success "Game Server Suite installed!"
    echo "MC: localhost:25565 | Valheim: localhost:2456 | Palworld: localhost:8211"
}

install_home_automation() {
    log "Installing Home Automation Stack..."
    "$INSTALL_DIR/install.sh" --service homeassistant
    "$INSTALL_DIR/install.sh" --service nginx
    "$INSTALL_DIR/install.sh" --service mosquitto
    success "Home Automation installed!"
    echo "Home Assistant: http://localhost:8123"
}

install_productivity_stack() {
    log "Installing Productivity Stack..."
    "$INSTALL_DIR/install.sh" --service outline
    "$INSTALL_DIR/install.sh" --service vaultwarden
    "$INSTALL_DIR/install.sh" --service n8n
    "$INSTALL_DIR/install.sh" --service nginx
    success "Productivity Stack installed!"
}

install_monitoring_stack() {
    log "Installing Monitoring Stack..."
    "$INSTALL_DIR/install.sh" --service netdata
    "$INSTALL_DIR/install.sh" --service grafana
    "$INSTALL_DIR/install.sh" --service uptime-kuma
    success "Monitoring Stack installed!"
    echo "Netdata: http://localhost:19999 | Grafana: http://localhost:3000"
}

install_analytics_stack() {
    log "Installing Analytics Stack..."
    "$INSTALL_DIR/install.sh" --service umami
    "$INSTALL_DIR/install.sh" --service nginx
    success "Analytics Stack installed!"
}

main() {
    if [ -n "$1" ]; then
        case "$1" in
            lamp) install_lamp_stack ;;
            lemp) install_lemp_stack ;;
            llmp) install_llsmp_stack ;;
            postgres) install_postgres_stack ;;
            mongodb) install_mongodb_stack ;;
            media) install_media_server ;;
            music) install_music_server ;;
            dev) install_dev_environment ;;
            git) install_git_server ;;
            code) install_code_server ;;
            minecraft) install_minecraft_stack ;;
            games) install_game_server_suite ;;
            homeassistant|hass) install_home_automation ;;
            productivity) install_productivity_stack ;;
            monitoring) install_monitoring_stack ;;
            analytics) install_analytics_stack ;;
            all)
                warn "Installing ALL services..."
                bash "$INSTALL_DIR/install.sh" --install-all
                ;;
            *) echo "Unknown stack: $1" ;;
        esac
        exit 0
    fi

    while true; do
        show_stack_menu
        read -p "Select stack to install: " choice

        case $choice in
            1) install_lamp_stack ;;
            2) install_lemp_stack ;;
            3) install_llsmp_stack ;;
            4) install_postgres_stack ;;
            5) install_mongodb_stack ;;
            6) install_media_server ;;
            7) install_music_server ;;
            8) install_dev_environment ;;
            9) install_git_server ;;
            10) install_code_server ;;
            11) install_minecraft_stack ;;
            12) install_game_server_suite ;;
            13) install_home_automation ;;
            14) install_productivity_stack ;;
            15) install_monitoring_stack ;;
            16) install_analytics_stack ;;
            0) exit 0 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

main "$@"
