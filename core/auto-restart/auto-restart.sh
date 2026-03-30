#!/data/data/com.termux/files/usr/bin/bash
# Auto-Restart Master Script
# Monitors and restarts all TermuxServerX services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/TermuxServerX"
DATA_DIR="$HOME/TermuxServerX/data"
LOG_DIR="$HOME/TermuxServerX/logs/auto-restart"
STATE_DIR="$HOME/TermuxServerX/.state"

mkdir -p "$LOG_DIR" "$STATE_DIR"

LOG_FILE="$LOG_DIR/auto-restart_$(date +%Y%m%d).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

is_running() {
    local service=$1
    case $service in
        nginx) pgrep -x nginx >/dev/null 2>&1 ;;
        php) pgrep -f "php-fpm" >/dev/null 2>&1 ;;
        mariadb|mysql) pgrep -x mariadbd >/dev/null 2>&1 ;;
        postgresql|postgres) pgrep -f "postgres" >/dev/null 2>&1 ;;
        redis) pgrep -x redis-server >/dev/null 2>&1 ;;
        mongodb) pgrep -f mongod >/dev/null 2>&1 ;;
        jellyfin) pgrep -f jellyfin >/dev/null 2>&1 ;;
        navidrome) pgrep -f navidrome >/dev/null 2>&1 ;;
        gitea) pgrep -f gitea >/dev/null 2>&1 ;;
        code-server|codeserver) pgrep -f code-server >/dev/null 2>&1 ;;
        minecraft) screen -list | grep -q minecraft ;;
        valheim) screen -list | grep -q valheim ;;
        csgo) screen -list | grep -q csgo ;;
        palworld) screen -list | grep -q palworld ;;
        rust) screen -list | grep -q rust ;;
        pocketmine) screen -list | grep -q pocketmine ;;
        terraria) screen -list | grep -q terraria ;;
        filebrowser) pgrep -f filebrowser >/dev/null 2>&1 ;;
        syncthing) pgrep -f syncthing >/dev/null 2>&1 ;;
        cloudflared) pgrep -f cloudflared >/dev/null 2>&1 ;;
        ngrok) pgrep -f ngrok >/dev/null 2>&1 ;;
        wireguard) pgrep -f wg-quick >/dev/null 2>&1 ;;
        tailscale) pgrep -f tailscaled >/dev/null 2>&1 ;;
        adguard) pgrep -f AdGuardHome >/dev/null 2>&1 ;;
        homeassistant|hass) pgrep -f hass >/dev/null 2>&1 ;;
        n8n) pgrep -f n8n >/dev/null 2>&1 ;;
        umami) pgrep -f umami >/dev/null 2>&1 ;;
        grafana) pgrep -f grafana-server >/dev/null 2>&1 ;;
        netdata) pgrep -f netdata >/dev/null 2>&1 ;;
        uptime-kuma) pgrep -f node.*uptime-kuma >/dev/null 2>&1 ;;
        nextcloud) pgrep -f apache2 >/dev/null 2>&1 || pgrep -f nginx >/dev/null 2>&1 ;;
        ghost) pgrep -f ghost >/dev/null 2>&1 ;;
        outline) pgrep -f outline >/dev/null 2>&1 ;;
        vaultwarden|bitwarden) pgrep -f vaultwarden >/dev/null 2>&1 ;;
        bookstack) pgrep -f php-fpm >/dev/null 2>&1 ;;
        matrix|synapse) pgrep -f synapse >/dev/null 2>&1 ;;
        ntfy) pgrep -f ntfy >/dev/null 2>&1 ;;
        immich) pgrep -f immich >/dev/null 2>&1 ;;
        ollama) pgrep -f ollama >/dev/null 2>&1 ;;
        *) pgrep -f "$service" >/dev/null 2>&1 ;;
    esac
}

start_service() {
    local service=$1
    log "Starting $service..."

    case $service in
        nginx) "$INSTALL_DIR/services/web/nginx.sh" start 2>/dev/null || ~/ termux-boot/nginx-start.sh 2>/dev/null ;;
        php) "$INSTALL_DIR/services/web/php.sh" start 2>/dev/null ;;
        mariadb) "$INSTALL_DIR/services/database/mariadb.sh" start 2>/dev/null ;;
        postgresql) "$INSTALL_DIR/services/database/postgresql.sh" start 2>/dev/null ;;
        redis) "$INSTALL_DIR/services/database/redis.sh" start 2>/dev/null ;;
        mongodb) "$INSTALL_DIR/services/database/mongodb.sh" start 2>/dev/null ;;
        jellyfin) "$INSTALL_DIR/services/media/jellyfin.sh" start 2>/dev/null ;;
        navidrome) "$INSTALL_DIR/services/media/navidrome.sh" start 2>/dev/null ;;
        gitea) "$INSTALL_DIR/services/dev/gitea.sh" start 2>/dev/null ;;
        code-server|codeserver) "$INSTALL_DIR/services/dev/code-server.sh" start 2>/dev/null ;;
        minecraft) screen -dmS minecraft ~/TermuxServerX/data/minecraft/start.sh ;;
        valheim) screen -dmS valheim ~/TermuxServerX/data/valheim/start-server.sh ;;
        csgo) screen -dmS csgo ~/TermuxServerX/data/csgo/start-server.sh ;;
        palworld) screen -dmS palworld ~/TermuxServerX/data/palworld/start-server.sh ;;
        rust) screen -dmS rust ~/TermuxServerX/data/rust/start-server.sh ;;
        filebrowser) "$INSTALL_DIR/services/storage/filebrowser.sh" start 2>/dev/null ;;
        syncthing) "$INSTALL_DIR/services/storage/syncthing.sh" start 2>/dev/null ;;
        cloudflared) screen -dmS cloudflared cloudflared tunnel run ;;
        adguard) "$INSTALL_DIR/services/automation/adguard.sh" start 2>/dev/null ;;
        homeassistant) screen -dmS homeassistant hass -f ;;
        n8n) screen -dmS n8n n8n ;;
        netdata) "$INSTALL_DIR/services/monitoring/netdata.sh" start 2>/dev/null ;;
        ghost) "$INSTALL_DIR/services/productivity/ghost.sh" start 2>/dev/null ;;
        vaultwarden|bitwarden) "$INSTALL_DIR/services/security/vaultwarden.sh" start 2>/dev/null ;;
        *) log "No auto-start handler for $service" ;;
    esac

    sleep 2
    if is_running "$service"; then
        log "✓ $service started successfully"
        return 0
    else
        log "✗ $service failed to start"
        return 1
    fi
}

check_and_restart() {
    local service=$1
    local max_retries=3
    local state_file="$STATE_DIR/${service}.state"

    if is_running "$service"; then
        echo "$(date)" > "$STATE_DIR/${service}.last_check"
        return 0
    fi

    log "⚠ $service is not running"

    local crash_count=$(cat "$state_file" 2>/dev/null || echo "0")
    crash_count=$((crash_count + 1))
    echo "$crash_count" > "$state_file"

    if [ "$crash_count" -gt "$max_retries" ]; then
        log "✗ $service has crashed $crash_count times, stopping auto-restart"
        log "  Manual intervention required"
        return 1
    fi

    log "Attempting restart ($crash_count/$max_retries)..."
    start_service "$service"

    if is_running "$service"; then
        log "✓ $service recovered"
        echo "0" > "$state_file"
    else
        log "✗ $service restart failed"
    fi
}

get_enabled_services() {
    local enabled=()
    for service in "$DATA_DIR"/*; do
        if [ -d "$service" ]; then
            enabled+=($(basename "$service"))
        fi
    done
    for service in nginx php mariadb postgresql redis mongodb jellyfin navidrome gitea code-server cloudflared adguard; do
        if [ -f "$INSTALL_DIR/.services/$service.enabled" ]; then
            enabled+=($service)
        fi
    done
    echo "${enabled[@]}"
}

main() {
    log "=== Auto-Restart Check Started ==="

    local services=($(get_enabled_services))

    if [ ${#services[@]} -eq 0 ]; then
        services=(nginx php mariadb postgresql redis jellyfin navidrome)
    fi

    for service in "${services[@]}"; do
        check_and_restart "$service" || true
    done

    log "=== Auto-Restart Check Completed ==="
}

if [ "$1" == "daemon" ]; then
    while true; do
        main
        sleep 60
    done
else
    main
fi
