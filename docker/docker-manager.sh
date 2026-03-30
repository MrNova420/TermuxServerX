#!/data/data/com.termux/files/usr/bin/bash
# Docker Support for TermuxServerX
# Provides containerized service deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/TermuxServerX"
DOCKER_DIR="$INSTALL_DIR/docker"
DATA_DIR="$HOME/TermuxServerX/data/docker"

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

check_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Docker not found. Install with:"
        echo "  pkg install docker"
        return 1
    fi
    return 0
}

setup_docker() {
    log "Setting up Docker environment..."
    mkdir -p "$DOCKER_DIR" "$DATA_DIR"

    cat > "$DOCKER_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  # Services will be added dynamically
EOF

    success "Docker directory initialized"
}

pull_image() {
    local image=$1
    log "Pulling $image..."
    docker pull "$image"
    success "Pulled $image"
}

start_container() {
    local name=$1
    local image=$2
    local port=$3
    local volumes=$4

    log "Starting $name..."

    docker run -d \
        --name "$name" \
        --restart unless-stopped \
        -p "$port:$port" \
        $volumes \
        "$image"

    success "$name started on port $port"
}

stop_container() {
    local name=$1
    docker stop "$name" 2>/dev/null && success "$name stopped" || echo "$name not running"
}

remove_container() {
    local name=$1
    docker rm -f "$name" 2>/dev/null && success "$name removed" || echo "$name not found"
}

show_container_status() {
    echo "=== Docker Container Status ==="
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

docker_nginx() {
    mkdir -p "$DATA_DIR/nginx"
    docker run -d \
        --name tsx-nginx \
        --restart unless-stopped \
        -p 80:80 -p 443:443 \
        -v "$DATA_DIR/nginx/html:/usr/share/nginx/html" \
        nginx:alpine
    success "Nginx started"
}

docker_mariadb() {
    read -p "MySQL root password: " password
    mkdir -p "$DATA_DIR/mariadb"
    docker run -d \
        --name tsx-mariadb \
        --restart unless-stopped \
        -p 3306:3306 \
        -e MYSQL_ROOT_PASSWORD="$password" \
        -v "$DATA_DIR/mariadb:/var/lib/mysql" \
        mariadb:latest
    success "MariaDB started"
}

docker_postgres() {
    read -p "PostgreSQL password: " password
    mkdir -p "$DATA_DIR/postgres"
    docker run -d \
        --name tsx-postgres \
        --restart unless-stopped \
        -p 5432:5432 \
        -e POSTGRES_PASSWORD="$password" \
        -v "$DATA_DIR/postgres:/var/lib/postgresql/data" \
        postgres:alpine
    success "PostgreSQL started"
}

docker_redis() {
    mkdir -p "$DATA_DIR/redis"
    docker run -d \
        --name tsx-redis \
        --restart unless-stopped \
        -p 6379:6379 \
        -v "$DATA_DIR/redis:/data" \
        redis:alpine redis --appendonly yes
    success "Redis started"
}

docker_jellyfin() {
    mkdir -p "$DATA_DIR/jellyfin"/{config,cache,media}
    docker run -d \
        --name tsx-jellyfin \
        --restart unless-stopped \
        -p 8096:8096 \
        -v "$DATA_DIR/jellyfin/config:/config" \
        -v "$DATA_DIR/jellyfin/cache:/cache" \
        -v "$DATA_DIR/jellyfin/media:/media" \
        jellyfin/jellyfin:latest
    success "Jellyfin started"
}

docker_gitea() {
    mkdir -p "$DATA_DIR/gitea"
    docker run -d \
        --name tsx-gitea \
        --restart unless-stopped \
        -p 3000:3000 -p 2222:22 \
        -v "$DATA_DIR/gitea:/data" \
        gitea/gitea:latest
    success "Gitea started"
}

docker_vaultwarden() {
    mkdir -p "$DATA_DIR/vaultwarden"
    docker run -d \
        --name tsx-vaultwarden \
        --restart unless-stopped \
        -p 8080:80 \
        -e WEBSOCKET_ENABLED=true \
        -v "$DATA_DIR/vaultwarden:/data" \
        vaultwarden/server:latest
    success "Vaultwarden started"
}

docker_navidrome() {
    mkdir -p "$DATA_DIR/navidrome"/{config,music,cache}
    docker run -d \
        --name tsx-navidrome \
        --restart unless-stopped \
        -p 4533:4533 \
        -v "$DATA_DIR/navidrome/config:/config" \
        -v "$DATA_DIR/navidrome/music:/music" \
        navidrome/navidrome:latest
    success "Navidrome started"
}

docker_portainer() {
    mkdir -p "$DATA_DIR/portainer"
    docker run -d \
        --name tsx-portainer \
        --restart unless-stopped \
        -p 9000:9000 -p 8000:8000 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$DATA_DIR/portainer:/data" \
        portainer/portainer-ce:latest
    success "Portainer started"
}

docker_adguard() {
    mkdir -p "$DATA_DIR/adguard"
    docker run -d \
        --name tsx-adguard \
        --restart unless-stopped \
        -p 53:53/tcp -p 53:53/udp \
        -p 3000:3000/tcp \
        -v "$DATA_DIR/adguard/work:/opt/adguardhome/work" \
        -v "$DATA_DIR/adguard/conf:/opt/adguardhome/conf" \
        adguard/adguardhome:latest
    success "AdGuard Home started"
}

show_docker_menu() {
    clear
    echo "╔════════════════════════════════════════════════╗"
    echo "║         Docker Container Manager              ║"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  1) nginx        - Web Server                 ║"
    echo "║  2) mariadb      - MySQL Database             ║"
    echo "║  3) postgresql   - PostgreSQL Database        ║"
    echo "║  4) redis        - Cache/Queue                ║"
    echo "║  5) jellyfin     - Media Server              ║"
    echo "║  6) gitea        - Git Server                ║"
    echo "║  7) vaultwarden  - Password Manager           ║"
    echo "║  8) navidrome    - Music Server              ║"
    echo "║  9) portainer    - Docker GUI                ║"
    echo "║ 10) adguard      - DNS/Ad blocker            ║"
    echo "║ 11) Status       - Show all containers       ║"
    echo "║ 12) Stop All     - Stop all containers        ║"
    echo "║ 13) Remove All   - Remove all containers      ║"
    echo "║  0) Exit                                 ║"
    echo "╚════════════════════════════════════════════════╝"
}

main() {
    if ! check_docker; then
        exit 1
    fi

    if [ -n "$1" ]; then
        case "$1" in
            nginx) docker_nginx ;;
            mariadb) docker_mariadb ;;
            postgres) docker_postgresql ;;
            redis) docker_redis ;;
            jellyfin) docker_jellyfin ;;
            gitea) docker_gitea ;;
            vaultwarden) docker_vaultwarden ;;
            navidrome) docker_navidrome ;;
            portainer) docker_portainer ;;
            adguard) docker_adguard ;;
            status) show_container_status ;;
            *) echo "Usage: $0 {service|status}" ;;
        esac
        exit 0
    fi

    while true; do
        show_docker_menu
        read -p "Select service: " choice

        case $choice in
            1) docker_nginx ;;
            2) docker_mariadb ;;
            3) docker_postgres ;;
            4) docker_redis ;;
            5) docker_jellyfin ;;
            6) docker_gitea ;;
            7) docker_vaultwarden ;;
            8) docker_navidrome ;;
            9) docker_portainer ;;
            10) docker_adguard ;;
            11) show_container_status ;;
            12) docker stop $(docker ps -aq) ;;
            13) docker rm -f $(docker ps -aq) ;;
            0) exit 0 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

main "$@"
