#!/bin/bash
set -e

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/core/utils.sh"

log_info "Installing PHP..."

install_php() {
    pkg update -y
    pkg install -y php php-fpm
    
    configure_php
    configure_php_fpm
    install_extensions
    
    log_success "PHP installed successfully!"
}

configure_php() {
    local php_ini="$PREFIX/etc/php.ini"
    
    if [ ! -f "$php_ini" ]; then
        cp "$PREFIX/etc/php.ini-production" "$php_ini" 2>/dev/null || true
    fi
    
    cat >> "$php_ini" << 'EOF'

[TermuxServerX]
upload_max_filesize = 500M
post_max_size = 500M
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
</EOF
}

configure_php_fpm() {
    mkdir -p "$PREFIX/etc/php-fpm.d"
    
    cat > "$PREFIX/etc/php-fpm.conf" << 'EOF'
[global]
error_log = ~/TermuxServerX/logs/php/error.log
daemonize = no
log_level = notice

[www]
listen = /tmp/php-fpm.sock
listen.owner = u0_aXXX
listen.group = everybody
listen.mode = 0660

pm = dynamic
pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 5
pm.max_requests = 500

php_admin_value[error_log] = ~/TermuxServerX/logs/php/fpm-error.log
php_admin_flag[log_errors] = on
EOF
}

install_extensions() {
    pkg install -y php-curl php-gd php-mbstring php-xml php-zip php-sqlite3 php-bz2 phpSodium
    log_info "PHP extensions installed"
}

start_php() {
    log_info "Starting PHP-FPM..."
    php-fpm
}

install_php
