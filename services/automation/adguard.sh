#!/bin/bash
# TermuxServerX - AdGuard Home (DNS Ad Blocker)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_adguard() {
    log "Installing AdGuard Home..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm" ;;
    esac
    
    local VERSION="v0.107.48"
    
    mkdir -p "$TSX_DIR/data/adguard"
    mkdir -p "$HOME/storage/shared/adguard"
    
    wget -q -O "$TSX_DIR/data/adguard/AdGuardHome" \
        "https://github.com/AdguardTeam/AdGuardHome/releases/download/${VERSION}/AdGuardHome_linux_${ARCH}.tar.gz"
    
    tar -xzf "$TSX_DIR/data/adguard/AdGuardHome_linux_${ARCH}.tar.gz" -C "$TSX_DIR/data/adguard"
    chmod +x "$TSX_DIR/data/adguard/AdGuardHome"
    
    log "AdGuard Home installed!"
    echo "Run: cd $TSX_DIR/data/adguard && ./AdGuardHome -c AdGuardHome.yaml"
    echo "Web UI: http://localhost:3000"
}

start_adguard() {
    cd "$TSX_DIR/data/adguard"
    nohup ./AdGuardHome > "$TSX_DIR/logs/adguard.log" 2>&1 &
    log "AdGuard Home started on port 3000"
}

case "${1:-install}" in
    install) install_adguard ;;
    start) start_adguard ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
