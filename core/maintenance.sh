#!/bin/bash
# TermuxServerX - Auto Maintenance System
# Handles cleanup, updates, health checks, and optimizations

set -euo pipefail

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

LOG_DIR="$TSX_DIR/logs/cron"
mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/maintenance.log"; }

cleanup_logs() {
    log "Starting log cleanup..."
    
    find "$TSX_DIR/logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    find "$TSX_DIR/logs" -name "*.log" -size +100M -exec truncate -s 50M {} \; 2>/dev/null || true
    
    find /tmp -name "termux-*" -mtime +1 -delete 2>/dev/null || true
    find /tmp -name "npm-*" -mtime +1 -delete 2>/dev/null || true
    
    log "Log cleanup complete"
}

cleanup_cache() {
    log "Starting cache cleanup..."
    
    rm -rf "$HOME/.cache"/* 2>/dev/null || true
    rm -rf "$HOME/.local/share/trash"/* 2>/dev/null || true
    
    find "$TSX_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find "$TSX_DIR" -type f -name "*.pyc" -delete 2>/dev/null || true
    find "$TSX_DIR" -type f -name "*.pyo" -delete 2>/dev/null || true
    
    log "Cache cleanup complete"
}

cleanup_temp() {
    log "Starting temp file cleanup..."
    
    rm -rf /data/data/com.termux/files/usr/tmp/* 2>/dev/null || true
    rm -f /tmp/*.tmp /tmp/*.bak /tmp/*.swp 2>/dev/null || true
    
    log "Temp cleanup complete"
}

cleanup_old_backups() {
    log "Starting old backup cleanup..."
    
    find "$TSX_DIR/backups" -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true
    find "$TSX_DIR/backups" -name "*.sql" -mtime +30 -delete 2>/dev/null || true
    find "$TSX_DIR/backups" -name "*.gz" -mtime +30 -delete 2>/dev/null || true
    
    log "Old backup cleanup complete"
}

check_disk_space() {
    local threshold=90
    local usage=$(df "$TSX_DIR" | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    
    if [ "$usage" -gt "$threshold" ]; then
        log "WARNING: Disk usage at ${usage}% - running aggressive cleanup"
        cleanup_logs
        cleanup_cache
        cleanup_old_backups
    fi
}

check_memory() {
    local available=$(free -m | awk '/^Mem:/ {print $7}')
    
    if [ "$available" -lt 256 ]; then
        log "WARNING: Low memory (${available}MB available) - clearing caches"
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    fi
}

health_check_services() {
    log "Running service health check..."
    
    local services=("nginx" "mariadb" "redis" "php-fpm")
    
    for service in "${services[@]}"; do
        if ! pgrep -x "$service" > /dev/null 2>&1; then
            log "Service $service is not running, attempting restart..."
            "$TSX_DIR/manage" start "$service" 2>/dev/null || true
        fi
    done
    
    log "Health check complete"
}

optimize_database() {
    log "Optimizing databases..."
    
    if pgrep -x mysqld > /dev/null 2>&1; then
        mysqlcheck -o --all-databases 2>/dev/null || true
    fi
    
    log "Database optimization complete"
}

update_packages() {
    log "Checking for package updates..."
    pkg update -y 2>/dev/null || true
    pkg upgrade -y 2>/dev/null || true
    log "Package update complete"
}

run_full_maintenance() {
    log "=== Starting full maintenance cycle ==="
    
    cleanup_logs
    cleanup_cache
    cleanup_temp
    cleanup_old_backups
    check_disk_space
    check_memory
    health_check_services
    optimize_database
    
    log "=== Maintenance cycle complete ==="
}

setup_cron() {
    log "Setting up maintenance cron jobs..."
    
    mkdir -p "$HOME/.termux/boot"
    
    cat > "$HOME/.termux/boot/20-maintenance.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
exec >> /data/data/com.termux/files/home/TermuxServerX/logs/cron/boot_maintenance.log 2>&1
echo "=== Boot Maintenance Started $(date) ==="
bash /data/data/com.termux/files/home/TermuxServerX/core/maintenance.sh cleanup
echo "=== Boot Maintenance Complete ==="
EOF
    chmod +x "$HOME/.termux/boot/20-maintenance.sh"
    
    if command -v crond &>/dev/null; then
        cat > "$HOME/.crontab" << 'EOF'
# TermuxServerX Maintenance Cron
0 */6 * * * bash ~/TermuxServerX/core/maintenance.sh cleanup >> ~/TermuxServerX/logs/cron/maintenance.log 2>&1
0 */12 * * * bash ~/TermuxServerX/core/maintenance.sh backup >> ~/TermuxServerX/logs/cron/backup.log 2>&1
0 3 * * * bash ~/TermuxServerX/scripts/update.sh packages >> ~/TermuxServerX/logs/cron/update.log 2>&1
EOF
        crontab "$HOME/.crontab"
        log "Crontab installed"
    fi
    
    log "Cron setup complete"
}

case "${1:-run}" in
    cleanup) cleanup_logs && cleanup_cache && cleanup_temp && cleanup_old_backups ;;
    health) health_check_services ;;
    optimize) optimize_database ;;
    full|run) run_full_maintenance ;;
    setup) setup_cron ;;
    *) echo "Usage: $0 {cleanup|health|optimize|full|setup}" ;;
esac
