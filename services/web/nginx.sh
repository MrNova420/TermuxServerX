#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/core/utils.sh"

log_info "Installing Nginx..."

install_nginx() {
    pkg update -y
    pkg install -y nginx
    
    mkdir -p "$TSX_DIR/logs/nginx"
    mkdir -p "$TSX_DIR/data/www"
    
    if [ -f "$TSX_DIR/templates/nginx/optimized.conf" ]; then
        cp "$TSX_DIR/templates/nginx/optimized.conf" "$PREFIX/etc/nginx/nginx.conf"
    else
        create_default_config
    fi
    
    create_vhost_template
    test_and_enable
    
    log_success "Nginx installed successfully!"
    echo "Web root: $HOME/storage/shared/www"
}

create_default_config() {
    cat > "$PREFIX/etc/nginx/nginx.conf" << 'EOF'
worker_processes auto;
error_log logs/error.log warn;
pid logs/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log logs/access.log main;
    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 500M;
    gzip on;
    
    server {
        listen 8080;
        server_name localhost;
        root ~/storage/shared/www;
        index index.html index.php;
        
        location / {
            try_files $uri $uri/ =404;
        }
        
        location ~ \.php$ {
            fastcgi_pass unix:/tmp/php-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
EOF
}

create_vhost_template() {
    mkdir -p "$TSX_DIR/templates/nginx"
    
    cat > "$TSX_DIR/templates/nginx/vhost.conf" << 'EOF'
server {
    listen 8080;
    server_name {{domain}};
    
    root {{root}};
    index index.html index.php;
    
    access_log {{logs_dir}}/access.log;
    error_log {{logs_dir}}/error.log;
    
    client_max_body_size 500M;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/tmp/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
EOF
}

test_and_enable() {
    nginx -t && log_success "Nginx configuration valid"
}

create_site() {
    local domain=$1
    local root=$2
    
    local site_config="$PREFIX/etc/nginx/sites-available/$domain.conf"
    local enabled_link="$PREFIX/etc/nginx/sites-enabled/$domain.conf"
    
    mkdir -p "$PREFIX/etc/nginx/sites-available"
    mkdir -p "$PREFIX/etc/nginx/sites-enabled"
    
    sed -e "s/{{domain}}/$domain/g" \
        -e "s|{{root}}|$root|g" \
        -e "s|{{logs_dir}}|$TSX_DIR/logs/nginx/$domain|g" \
        "$TSX_DIR/templates/nginx/vhost.conf" > "$site_config"
    
    ln -sf "$site_config" "$enabled_link"
    nginx -t && nginx -s reload
    
    log_success "Site created: $domain"
}

case "${1:-install}" in
    install)
        install_nginx
        ;;
    create)
        create_site "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {install|create <domain> <root>}"
        ;;
esac
