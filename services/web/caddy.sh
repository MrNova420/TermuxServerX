#!/bin/bash
# TermuxServerX - Caddy Web Server Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_caddy() {
    log "Installing Caddy..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm" ;;
    esac
    
    local VERSION="2.7.6"
    
    wget -q -O "$PREFIX/bin/caddy" \
        "https://github.com/caddyserver/caddy/releases/download/v${VERSION}/caddy_${VERSION}_linux_${ARCH}/caddy"
    
    chmod +x "$PREFIX/bin/caddy"
    
    mkdir -p "$HOME/.config/caddy"
    mkdir -p "$TSX_DIR/logs/caddy"
    
    cat > "$HOME/.config/caddy/Caddyfile" << 'EOF'
:8080 {
    root * ~/storage/shared/www
    file_server
    encode gzip
    
    php_fastcgi localhost:9000
    
    log {
        output file ~/TermuxServerX/logs/caddy/access.log
    }
}
EOF
    
    log "Caddy installed!"
    echo "Run: caddy run"
    echo "Config: $HOME/.config/caddy/Caddyfile"
}

start_caddy() {
    cd "$HOME/.config/caddy"
    nohup caddy run > "$TSX_DIR/logs/caddy.log" 2>&1 &
    log "Caddy started on port 8080"
}

case "${1:-install}" in
    install) install_caddy ;;
    start) start_caddy ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
