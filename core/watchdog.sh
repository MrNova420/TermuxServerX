#!/bin/bash

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

WATCHDOG_LOG="$TSX_DIR/logs/watchdog.log"
CHECK_INTERVAL=${CHECK_INTERVAL:-30}
MAX_RESTART_ATTEMPTS=5
declare -A RESTART_COUNT

log_watchdog() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$WATCHDOG_LOG"
}

is_service_running() {
    local service=$1
    pgrep -f "$service" > /dev/null 2>&1
    return $?
}

start_service() {
    local service=$1
    local service_dir="$TSX_DIR/services"
    
    log_watchdog "Starting service: $service"
    
    case $service in
        nginx)
            nginx -t && nginx
            ;;
        php|php-fpm)
            pkill -f php-fpm 2>/dev/null
            sleep 1
            php-fpm
            ;;
        mariadb)
            pg_ctlcluster 10 mysql start 2>/dev/null || $PREFIX/bin/mysqld_safe &
            ;;
        redis)
            redis-server --daemonize yes --logfile "$TSX_DIR/logs/redis.log"
            ;;
        minecraft)
            cd "$TSX_DIR/data/minecraft" && bash start.sh &
            ;;
        *)
            if [ -f "$service_dir/$service/start.sh" ]; then
                bash "$service_dir/$service/start.sh" &
            fi
            ;;
    esac
    
    sleep 2
    
    if is_service_running "$service"; then
        log_watchdog "Service started: $service"
        return 0
    else
        log_watchdog "Failed to start: $service"
        return 1
    fi
}

stop_service() {
    local service=$1
    
    log_watchdog "Stopping service: $service"
    
    case $service in
        nginx)
            nginx -s stop 2>/dev/null || pkill -f nginx
            ;;
        php|php-fpm)
            pkill -f php-fpm
            ;;
        mariadb)
            mysqladmin shutdown 2>/dev/null || pkill -f mysqld
            ;;
        redis)
            redis-cli shutdown 2>/dev/null || pkill -f redis-server
            ;;
        minecraft)
            screen -S minecraft -X stuff 'stop\n' 2>/dev/null
            ;;
        *)
            pkill -f "$service"
            ;;
    esac
}

check_service() {
    local service=$1
    local check_port=$2
    local check_file=$3
    
    if is_service_running "$service"; then
        if [ -n "$check_port" ]; then
            nc -z localhost "$check_port" 2>/dev/null
            return $?
        fi
        return 0
    fi
    return 1
}

monitor_service() {
    local service=$1
    local check_port=$2
    local restart_script=$3
    
    if ! check_service "$service" "$check_port"; then
        log_watchdog "Service DOWN: $service"
        
        if [ -n "${RESTART_COUNT[$service]}" ]; then
            RESTART_COUNT[$service]=$((RESTART_COUNT[$service] + 1))
        else
            RESTART_COUNT[$service]=1
        fi
        
        if [ "${RESTART_COUNT[$service]}" -le "$MAX_RESTART_ATTEMPTS" ]; then
            log_watchdog "Restarting $service (attempt ${RESTART_COUNT[$service]})"
            start_service "$service"
        else
            log_watchdog "Max restart attempts reached for $service"
            notify_failure "$service"
        fi
    fi
}

notify_failure() {
    local service=$1
    log_watchdog "CRITICAL: $service failed to restart after $MAX_RESTART_ATTEMPTS attempts"
}

monitor_all() {
    log_watchdog "=== Watchdog Check Started ==="
    
    check_resources
    
    if [ -f "$TSX_DIR/config/services.conf" ]; then
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            [[ "$line" =~ ^# ]] && continue
            
            service=$(echo "$line" | cut -d: -f1)
            port=$(echo "$line" | cut -d: -f2)
            
            monitor_service "$service" "$port"
        done < "$TSX_DIR/config/services.conf"
    fi
    
    log_watchdog "=== Watchdog Check Complete ==="
}

check_resources() {
    local mem_available=$(free -m | awk '/^Mem:/ {print $7}')
    local disk_available=$(df -m "$TSX_DIR" | awk 'NR==2 {print $4}')
    
    if [ "$mem_available" -lt 256 ]; then
        log_watchdog "WARNING: Low memory (${mem_available}MB available)"
        handle_low_memory
    fi
    
    if [ "$disk_available" -lt 1000 ]; then
        log_watchdog "WARNING: Low disk space (${disk_available}MB available)"
    fi
}

handle_low_memory() {
    log_watchdog "Attempting to free memory..."
    
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    
    local biggest_service=""
    case $TSX_RAM_TIER in
        minimal) biggest_service="minecraft" ;;
        low) biggest_service="minecraft" ;;
    esac
    
    if [ -n "$biggest_service" ] && is_service_running "$biggest_service"; then
        log_watchdog "Stopping $biggest_service to free memory"
        stop_service "$biggest_service"
    fi
}

watchdog_loop() {
    log_watchdog "Watchdog started (interval: ${CHECK_INTERVAL}s)"
    
    mkdir -p "$TSX_DIR/logs"
    
    while true; do
        monitor_all
        sleep "$CHECK_INTERVAL"
    done
}

status_report() {
    echo "=== TermuxServerX Watchdog Status ==="
    echo "Log: $WATCHDOG_LOG"
    echo "Check Interval: ${CHECK_INTERVAL}s"
    echo ""
    echo "Restart Counts:"
    for service in "${!RESTART_COUNT[@]}"; do
        echo "  $service: ${RESTART_COUNT[$service]}"
    done
    echo ""
    echo "Recent Log Entries:"
    tail -20 "$WATCHDOG_LOG" 2>/dev/null || echo "No log entries"
}

case "${1:-loop}" in
    start)
        watchdog_loop &
        echo "Watchdog started (PID: $!)"
        ;;
    stop)
        pkill -f "watchdog.sh"
        echo "Watchdog stopped"
        ;;
    status)
        status_report
        ;;
    check)
        monitor_all
        ;;
    *)
        echo "Usage: $0 {start|stop|status|check}"
        ;;
esac
