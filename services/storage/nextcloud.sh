#!/bin/bash
set -e

TSX_DIR="$HOME/TermuxServerX"

log_info "Installing Nextcloud..."

install_nextcloud() {
    pkg update -y
    pkg install -y wget php php-curl php-gd php-mbstring php-xml php-zip php-sqlite3 nginx
    
    mkdir -p "$TSX_DIR/data/nextcloud"
    
    local nextcloud_url="https://download.nextcloud.com/server/releases/latest.tar.bz2"
    
    if [ ! -f "$TSX_DIR/data/nextcloud/nextcloud.tar.bz2" ]; then
        wget -q -O "$TSX_DIR/data/nextcloud/nextcloud.tar.bz2" "$nextcloud_url"
    fi
    
    tar -xjf "$TSX_DIR/data/nextcloud/nextcloud.tar.bz2" -C "$TSX_DIR/data/nextcloud" --strip-components=1
    
    mkdir -p "$TSX_DIR/data/nextcloud/data"
    mkdir -p "$TSX_DIR/logs/nextcloud"
    
    chown -R u0_$(id -u): everybody "$TSX_DIR/data/nextcloud" 2>/dev/null || true
    
    log_success "Nextcloud installed!"
    echo "Access at: http://localhost:8081/nextcloud"
}

install_nextcloud
