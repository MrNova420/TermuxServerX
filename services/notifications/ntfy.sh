#!/bin/bash
# TermuxServerX - ntfy Notifications (Push Notifications)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_ntfy() {
    log "Installing ntfy (Push Notifications)..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="linux-arm64" ;;
        x86_64|amd64) ARCH="linux-amd64" ;;
        *) ARCH="linux-arm" ;;
    esac
    
    local VERSION="2.10.0"
    
    mkdir -p "$TSX_DIR/data/ntfy"
    mkdir -p "$HOME/storage/shared/ntfy"
    
    wget -q -O "$TSX_DIR/data/ntfy/ntfy" \
        "https://github.com/binwiederhier/ntfy/releases/download/v${VERSION}/ntfy_${ARCH}.zip"
    
    unzip -q "$TSX_DIR/data/ntfy/ntfy_${ARCH}.zip" -d "$TSX_DIR/data/ntfy"
    chmod +x "$TSX_DIR/data/ntfy/ntfy"
    
    log "ntfy installed!"
    echo ""
    echo "Run: ntfy serve --config-file $HOME/storage/shared/ntfy/ntfy.yml"
    echo "Web UI: http://localhost:2586"
    echo ""
    echo "Send notifications:"
    echo "  curl -d 'Hello from TermuxServerX!' ntfy.sh/YOUR_TOPIC"
}

start_ntfy() {
    cd "$TSX_DIR/data/ntfy"
    nohup ./ntfy serve \
        --cache-file "$HOME/storage/shared/ntfy/cache.db" \
        --attachment-cache-dir "$HOME/storage/shared/ntfy/attachments" \
        > "$TSX_DIR/logs/ntfy.log" 2>&1 &
    log "ntfy started on port 2586"
}

case "${1:-install}" in
    install) install_ntfy ;;
    start) start_ntfy ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
