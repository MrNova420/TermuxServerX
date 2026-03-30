#!/bin/bash
# TermuxServerX - Elite System Optimizer
# Maximum performance tuning for 24/7 server use

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

detect_and_optimize() {
    info "Detecting hardware..."
    
    local ram=$(free -m | awk '/^Mem:/ {print $2}')
    local cores=$(nproc)
    local arch=$(uname -m)
    
    info "RAM: ${ram}MB | Cores: $cores | Arch: $arch"
    
    case 1 in
        $(($ram < 2048))  ) optimize_minimal ;;
        $(($ram < 4096))  ) optimize_low ;;
        $(($ram < 8192))  ) optimize_medium ;;
        $(($ram >= 8192)) ) optimize_high ;;
    esac
}

optimize_minimal() {
    info "Optimizing for minimal RAM (${ram}MB)..."
    
    export TSX_JAVA_RAM="512M"
    export TSX_DB_RAM="128M"
    export TSX_WEB_WORKERS=2
    export TSX_MAX_GAME_SERVERS=0
    
    optimize_kernel
    optimize_termux_minimal
    optimize_services_light
}

optimize_low() {
    info "Optimizing for low RAM (${ram}MB)..."
    
    export TSX_JAVA_RAM="1024M"
    export TSX_DB_RAM="256M"
    export TSX_WEB_WORKERS=4
    export TSX_MAX_GAME_SERVERS=1
    
    optimize_kernel
    optimize_termux
    optimize_services_light
}

optimize_medium() {
    info "Optimizing for medium RAM (${ram}MB)..."
    
    export TSX_JAVA_RAM="2048M"
    export TSX_DB_RAM="512M"
    export TSX_WEB_WORKERS=8
    export TSX_MAX_GAME_SERVERS=2
    
    optimize_kernel
    optimize_termux
    optimize_services
}

optimize_high() {
    info "Optimizing for high RAM (${ram}MB)..."
    
    export TSX_JAVA_RAM="4096M"
    export TSX_DB_RAM="1024M"
    export TSX_WEB_WORKERS=$(($cores * 2))
    export TSX_MAX_GAME_SERVERS=3
    
    optimize_kernel
    optimize_termux
    optimize_services_full
}

optimize_kernel() {
    info "Optimizing kernel parameters..."
    
    [ -w /proc/sys/vm/swappiness ] && echo 10 > /proc/sys/vm/swappiness 2>/dev/null || true
    [ -w /proc/sys/vm/dirty_ratio ] && echo 5 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
    [ -w /proc/sys/vm/dirty_background_ratio ] && echo 3 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
    [ -w /proc/sys/vm/vfs_cache_pressure ] && echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
    
    log "Kernel optimized"
}

optimize_termux() {
    info "Optimizing Termux environment..."
    
    mkdir -p "$HOME/.termux"
    
    cat > "$HOME/.termux/termux.properties" << 'EOF'
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','LEFT','DOWN','RIGHT','PGDN','BKSP']]
back-hook=exit
background-opaque=true
terminal-utf=true
enable-bracketed-paste=true
cursor-style=block
bell-character=ignore
EOF

    if ! grep -q "TermuxServerX" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'EOF'

# TermuxServerX Aliases
export TSX_DIR="$HOME/TermuxServerX"
alias tsx="$TSX_DIR/tsx"
alias tsx-web="cd $TSX_DIR && python webui/server.py"
alias ll="ls -la"
PS1="\[\e[1;32m\]tsx\[\e[0m\]@\[\e[1;34m\]\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]\\$ "
EOF
    fi
    
    log "Termux optimized"
}

optimize_termux_minimal() {
    optimize_termux
}

optimize_services_light() {
    info "Optimizing services for light usage..."
    
    optimize_nginx_light
    optimize_php_light
    optimize_java_light
}

optimize_services() {
    info "Optimizing services for balanced usage..."
    
    optimize_nginx
    optimize_php
    optimize_java
    optimize_mysql
}

optimize_services_full() {
    info "Optimizing services for maximum performance..."
    
    optimize_nginx_full
    optimize_php_full
    optimize_java_full
    optimize_mysql_full
}

optimize_nginx_light() {
    mkdir -p "$PREFIX/etc/nginx"
    cat > "$PREFIX/etc/nginx/nginx.conf" << 'EOF'
worker_processes 1;
events { worker_connections 256; }
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    client_max_body_size 100M;
    gzip on;
}
EOF
    log "Nginx (light) configured"
}

optimize_nginx() {
    mkdir -p "$PREFIX/etc/nginx"
    cat > "$PREFIX/etc/nginx/nginx.conf" << 'EOF'
worker_processes auto;
worker_rlimit_nofile 65535;
events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    client_max_body_size 500M;
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
}
EOF
    log "Nginx configured"
}

optimize_nginx_full() {
    optimize_nginx
}

optimize_php_light() {
    mkdir -p "$PREFIX/etc"
    cat >> "$PREFIX/etc/php.ini" << 'EOF'
memory_limit=128M
upload_max_filesize=100M
post_max_size=100M
max_execution_time=60
EOF
    log "PHP (light) configured"
}

optimize_php() {
    mkdir -p "$PREFIX/etc"
    cat >> "$PREFIX/etc/php.ini" << 'EOF'
memory_limit=256M
upload_max_filesize=500M
post_max_size=500M
max_execution_time=300
opcache.enable=1
opcache.memory_consumption=128
EOF
    log "PHP configured"
}

optimize_php_full() {
    optimize_php
}

optimize_java_light() {
    mkdir -p "$TSX_DIR/data/minecraft"
    cat > "$TSX_DIR/data/minecraft/start.sh" << 'EOF'
#!/bin/bash
JAVA_OPTS="-Xms256M -Xmx512M -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
java $JAVA_OPTS -jar server.jar nogui
EOF
    chmod +x "$TSX_DIR/data/minecraft/start.sh"
    log "Java (light) configured"
}

optimize_java() {
    mkdir -p "$TSX_DIR/data/minecraft"
    cat > "$TSX_DIR/data/minecraft/start.sh" << 'EOF'
#!/bin/bash
JAVA_OPTS="-Xms1G -Xmx2G"
JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC -XX:+ParallelRefProcEnabled"
JAVA_OPTS="$JAVA_OPTS -XX:MaxGCPauseMillis=200"
JAVA_OPTS="$JAVA_OPTS -XX:+DisableExplicitGC"
JAVA_OPTS="$JAVA_OPTS -XX:G1NewSizePercent=30"
JAVA_OPTS="$JAVA_OPTS -XX:G1MaxNewSizePercent=40"
JAVA_OPTS="$JAVA_OPTS -XX:G1HeapRegionSize=8M"
JAVA_OPTS="$JAVA_OPTS -XX:G1ReservePercent=20"
java $JAVA_OPTS -jar server.jar nogui
EOF
    chmod +x "$TSX_DIR/data/minecraft/start.sh"
    log "Java configured"
}

optimize_java_full() {
    optimize_java
}

optimize_mysql() {
    mkdir -p "$PREFIX/etc/my.cnf.d"
    cat > "$PREFIX/etc/my.cnf.d/optimized.cnf" << 'EOF'
[mysqld]
max_connections=100
key_buffer_size=32M
max_allowed_packet=64M
innodb_buffer_pool_size=256M
innodb_log_file_size=16M
sync_binlog=0
EOF
    log "MySQL configured"
}

optimize_mysql_full() {
    optimize_mysql
}

save_config() {
    info "Saving optimization config..."
    cat > "$TSX_DIR/config.env" << EOF
TSX_JAVA_RAM="$TSX_JAVA_RAM"
TSX_DB_RAM="$TSX_DB_RAM"
TSX_WEB_WORKERS="$TSX_WEB_WORKERS"
TSX_MAX_GAME_SERVERS="$TSX_MAX_GAME_SERVERS"
EOF
    log "Config saved"
}

show_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Optimization Complete!                       ║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║                                                          ║${NC}"
    echo -e "${GREEN}║  Java RAM: ${TSX_JAVA_RAM}                                       ║${NC}"
    echo -e "${GREEN}║  DB RAM:   ${TSX_DB_RAM}                                        ║${NC}"
    echo -e "${GREEN}║  Workers:  ${TSX_WEB_WORKERS}                                           ║${NC}"
    echo -e "${GREEN}║  Game Servers: ${TSX_MAX_GAME_SERVERS}                                   ║${NC}"
    echo -e "${GREEN}║                                                          ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main() {
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}     TermuxServerX - Elite System Optimizer v2.0         ${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    detect_and_optimize
    save_config
    show_summary
    
    info "Reboot Termux for full effect, or restart services."
}

main "$@"
