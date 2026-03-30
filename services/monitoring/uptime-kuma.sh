#!/bin/bash
# TermuxServerX - Uptime Kuma - Self-hosted Monitoring
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_uptimekuma() {
    log "Installing Uptime Kuma..."
    
    pkg update -y
    pkg install -y nodejs npm
    
    npm install -g uptime-kuma
    
    mkdir -p "$HOME/storage/shared/uptime-kuma"
    
    log "Uptime Kuma installed!"
    echo ""
    echo "Run: uptime-kuma"
    echo "Web UI: http://localhost:3001"
    echo "Default login: admin / admin123"
}

start_uptimekuma() {
    cd "$HOME/storage/shared/uptime-kuma"
    nohup node server/index.js > "$TSX_DIR/logs/uptime-kuma.log" 2>&1 &
    log "Uptime Kuma started on port 3001"
}

case "${1:-install}" in
    install) install_uptimekuma ;;
    start) start_uptimekuma ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
