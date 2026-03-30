#!/data/data/com.termux/files/usr/bin/bash
# Watchdog Daemon - Continuous monitoring for all services

INSTALL_DIR="$HOME/TermuxServerX"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
LOG_DIR="$HOME/TermuxServerX/logs/watchdog"
STATE_DIR="$HOME/TermuxServerX/.state"

mkdir -p "$LOG_DIR" "$STATE_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_DIR/watchdog_$(date +%Y%m%d).log"
}

get_service_pid() {
    local service=$1
    pgrep -f "$service" 2>/dev/null | head -1
}

check_screen_service() {
    local screen_name=$1
    screen -list | grep -q "$screen_name"
}

is_service_up() {
    local service=$1
    case $service in
        minecraft|valheim|csgo|palworld|rust|pocketmine|terraria)
            check_screen_service "$service"
            ;;
        *)
            [ -n "$(get_service_pid "$service")" ]
            ;;
    esac
}

notify_restart() {
    local service=$1
    local notification_file="$STATE_DIR/notifications/${service}_restart_$(date +%Y%m%d)"

    if [ -f "$notification_file" ]; then
        return
    fi

    mkdir -p "$STATE_DIR/notifications"
    touch "$notification_file"

    if command -v termux-notification &>/dev/null; then
        termux-notification \
            --title "TermuxServerX" \
            --content "$service restarted" \
            --id "tsx-$service" \
            --priority low
    fi

    log "${YELLOW}RESTART${NC}: $service was restarted"
}

restart_service() {
    local service=$1
    local crash_file="$STATE_DIR/${service}.crashes"

    log "${YELLOW}Service down:${NC} $service - attempting restart..."

    case $service in
        minecraft)
            screen -dmS minecraft ~/TermuxServerX/data/minecraft/start.sh
            ;;
        valheim)
            screen -dmS valheim ~/TermuxServerX/data/valheim/start-server.sh
            ;;
        csgo)
            screen -dmS csgo ~/TermuxServerX/data/csgo/start-server.sh
            ;;
        palworld)
            screen -dmS palworld ~/TermuxServerX/data/palworld/start-server.sh
            ;;
        rust)
            screen -dmS rust ~/TermuxServerX/data/rust/start-server.sh
            ;;
        nginx)
            nginx 2>/dev/null || true
            ;;
        php)
            php-fpm 2>/dev/null || true
            ;;
        *)
            screen -dmS "$service" "$INSTALL_DIR/services/${service}.sh start" 2>/dev/null || true
            ;;
    esac

    sleep 3

    if is_service_up "$service"; then
        log "${GREEN}OK${NC}: $service recovered"
        rm -f "$crash_file"
        notify_restart "$service"
    else
        local crashes=$(($(cat "$crash_file" 2>/dev/null || echo 0) + 1))
        echo "$crashes" > "$crash_file"
        log "${RED}FAILED${NC}: $service restart failed (crash #$crashes)"

        if [ "$crashes" -ge 5 ]; then
            log "${RED}CRITICAL${NC}: $service has crashed 5+ times"
            if command -v termux-notification &>/dev/null; then
                termux-notification \
                    --title "TermuxServerX ALERT" \
                    --content "$service requires manual intervention" \
                    --priority high \
                    --ongoing
            fi
        fi
    fi
}

check_service() {
    local service=$1

    if ! is_service_up "$service"; then
        restart_service "$service"
    else
        local pid=$(get_service_pid "$service" 2>/dev/null || echo "screen")
        log "${GREEN}OK${NC}: $service (PID: $pid)"
    fi
}

get_active_services() {
    local services=(
        "nginx" "php" "mariadb" "postgresql" "redis" "mongodb"
        "jellyfin" "navidrome" "gitea" "code-server"
        "minecraft" "valheim" "csgo" "palworld" "rust"
        "filebrowser" "syncthing" "cloudflared" "ngrok"
        "adguard" "homeassistant" "n8n" "netdata"
        "ghost" "vaultwarden" "bookstack" "matrix" "ntfy"
        "immich" "ollama" "umami" "grafana"
    )

    local active=()
    for svc in "${services[@]}"; do
        if [ -f "$STATE_DIR/service_${svc}.enabled" ] || \
           [ -d "$HOME/TermuxServerX/data/$svc" ]; then
            active+=("$svc")
        fi
    done

    echo "${active[@]:-${services[@]}}"
}

show_status() {
    clear
    echo "╔══════════════════════════════════════════════════╗"
    echo "║         TermuxServerX Service Status            ║"
    echo "╠══════════════════════════════════════════════════╣"

    local services=($(get_active_services))
    local running=0
    local stopped=0

    for service in "${services[@]}"; do
        if is_service_up "$service"; then
            printf "║ ${GREEN}●${NC} %-40s ${GREEN}RUNNING${NC} ║\n" "$service"
            running=$((running + 1))
        else
            printf "║ ${RED}○${NC} %-40s ${RED}STOPPED${NC} ║\n" "$service"
            stopped=$((stopped + 1))
        fi
    done

    echo "╠══════════════════════════════════════════════════╣"
    echo "║  Running: $running  |  Stopped: $stopped                   ║"
    echo "╚══════════════════════════════════════════════════╝"
}

daemon_mode() {
    log "=== Watchdog Daemon Started ==="
    log "Check interval: ${CHECK_INTERVAL}s"

    while true; do
        show_status > /dev/tty 2>/dev/null || true

        local services=($(get_active_services))
        for service in "${services[@]}"; do
            check_service "$service"
        done

        sleep "$CHECK_INTERVAL"
    done
}

single_check() {
    local services=($(get_active_services))
    for service in "${services[@]}"; do
        check_service "$service"
    done
}

case "${1:-daemon}" in
    daemon) daemon_mode ;;
    check) single_check ;;
    status) show_status ;;
    *)
        echo "Usage: $0 {daemon|check|status}"
        ;;
esac
