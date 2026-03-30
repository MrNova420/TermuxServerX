#!/bin/bash

OPT_DIR="$HOME/TermuxServerX"
source "$OPT_DIR/config.env" 2>/dev/null || true
source "$OPT_DIR/core/detect.sh" 2>/dev/null

optimize_all() {
    echo "Optimizing system for TermuxServerX..."
    
    optimize_kernel
    optimize_termux
    optimize_services
    
    echo "Optimization complete!"
}

optimize_kernel() {
    echo "[Optimize] Kernel parameters..."
    
    if [ -w /proc/sys/vm/swappiness ]; then
        echo 10 > /proc/sys/vm/swappiness
    fi
    
    if [ -w /proc/sys/vm/dirty_ratio ]; then
        echo 5 > /proc/sys/vm/dirty_ratio
    fi
    
    if [ -w /proc/sys/vm/dirty_background_ratio ]; then
        echo 3 > /proc/sys/vm/dirty_background_ratio
    fi
    
    echo "[OK] Kernel optimized"
}

optimize_termux() {
    echo "[Optimize] Termux settings..."
    
    mkdir -p "$HOME/.termux"
    
    cat > "$HOME/.termux/termux.properties" << EOF
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','LEFT','DOWN','RIGHT','PGDN','BKSP']]
back-hook=exit
background-opaque=true
terminal-utf=true
EOF
    
    mkdir -p "$HOME/.config"
    cat > "$HOME/.bashrc" << 'BASHRC'
export TERMUX_SERVERX="$HOME/TermuxServerX"
export PATH="$HOME/TermuxServerX:$PATH"
alias tsx="$HOME/TermuxServerX/manage"
alias ll="ls -la"
alias la="ls -a"
export PS1="\[\e[1;32m\]tsx\[\e[0m\]@\[\e[1;34m\]\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]\\$ "
BASHRC
    
    echo "[OK] Termux optimized"
}

optimize_services() {
    echo "[Optimize] Service configurations..."
    
    mkdir -p "$OPT_DIR/logs"
    mkdir -p "$OPT_DIR/data"
    mkdir -p "$OPT_DIR/backups"
    
    apply_nginx_optimization
    apply_java_optimization
    apply_database_optimization
    
    echo "[OK] Services optimized"
}

apply_nginx_optimization() {
    cat > "$OPT_DIR/templates/nginx/optimized.conf" << 'EOF'
worker_processes auto;
worker_rlimit_nofile 65535;
error_log logs/error.log warn;

events {
    worker_connections 4096;
    multi_accept on;
    use epoll;
}

http {
    include mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log logs/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    client_max_body_size 500M;
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 16k;
    
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;
    
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    
    fastcgi_buffer_size 32k;
    fastcgi_buffers 16 32k;
    fastcgi_busy_buffers_size 256k;
}
EOF
}

apply_java_optimization() {
    local JAVA_HEAP=${TSX_JAVA_RAM:-1536M}
    
    cat > "$OPT_DIR/templates/minecraft/java_opts.txt" << EOF
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:TargetSurvivorRatio=15
-XX:MaxMetaspaceSize=512M
-XX:ParallelGCThreads=$(nproc)
-XX:ConcGCThreads=$(nproc)
-Xms${JAVA_HEAP}
-Xmx${JAVA_HEAP}
-XX:+UseStringDeduplication
EOF
    
    echo "[OK] Java optimized for ${JAVA_HEAP} heap"
}

apply_database_optimization() {
    local DB_RAM=${TSX_DB_RAM:-256M}
    local DB_MEM_KB=$(( $(echo "$DB_RAM" | sed 's/M$//') * 1024 ))
    
    cat > "$OPT_DIR/templates/mariadb/optimized.cnf" << EOF
[mysqld]
max_connections = 100
key_buffer_size = 32M
query_cache_size = 0
query_cache_type = 0
tmp_table_size = 32M
max_heap_table_size = 32M
innodb_buffer_pool_size = ${DB_MEM_KB}
innodb_log_file_size = 16M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
sync_binlog = 0
slow_query_log = 1
slow_query_log_file = slow.log
long_query_time = 2
EOF
    
    cat > "$OPT_DIR/templates/redis/optimized.conf" << EOF
maxmemory ${DB_RAM}
maxmemory-policy allkeys-lru
save ""
stop-writes-on-bgsave-error no
rdbcompression yes
rdbchecksum yes
appendonly no
EOF
    
    echo "[OK] Database optimized for ${DB_RAM} memory"
}

apply_swap_if_needed() {
    local SWAP_SIZE_MB=${1:-1024}
    local SWAP_FILE="/data/local/swapfile"
    
    if [ "$TSX_SWAP_TOTAL" -eq 0 ] && [ -w "/data/local" ]; then
        echo "[Swap] Creating ${SWAP_SIZE_MB}MB swap file..."
        dd if=/dev/zero of=$SWAP_FILE bs=1M count=$SWAP_SIZE_MB status=progress
        chmod 600 $SWAP_FILE
        mkswap $SWAP_FILE
        swapon $SWAP_FILE
        echo "[OK] Swap created"
    fi
}

set_cpu_governor() {
    if [ -w "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
        echo "performance" > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
        echo "[OK] CPU governor set to performance"
    fi
}

apply_android_tweaks() {
    echo "[Optimize] Applying Android tweaks..."
    
    if [ -w "/proc/sys/kernel/random/urandom_min_entropy_ca" ]; then
        echo 1024 > /proc/sys/kernel/random/urandom_min_entropy_ca
    fi
    
    mkdir -p "$HOME/.cache"
    export XDG_CACHE_HOME="$HOME/.cache"
    
    echo "[OK] Android tweaks applied"
}

generate_service_limits() {
    cat > "$OPT_DIR/config.d/service-limits.sh" << EOF
declare -A SERVICE_RAM_LIMITS=(
    ["nginx"]="128M"
    ["php"]="256M"
    ["mariadb"]="${TSX_DB_RAM:-256M}"
    ["postgresql"]="512M"
    ["redis"]="64M"
    ["minecraft"]="${TSX_JAVA_RAM:-1536M}"
    ["pocketmine"]="512M"
    ["valheim"]="2048M"
    ["jellyfin"]="1024M"
    ["nextcloud"]="256M"
)

declare -A SERVICE_CPU_LIMITS=(
    ["nginx"]="2"
    ["php"]="4"
    ["mariadb"]="4"
    ["redis"]="2"
    ["minecraft"]="6"
    ["jellyfin"]="4"
)

get_service_ram_limit() {
    local service=\$1
    echo \${SERVICE_RAM_LIMITS[\$service]:-256M}
}

get_service_cpu_limit() {
    local service=\$1
    echo \${SERVICE_CPU_LIMITS[\$service]:=4}
}
EOF
    chmod +x "$OPT_DIR/config.d/service-limits.sh"
    echo "[OK] Service limits generated"
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    optimize_all
fi
