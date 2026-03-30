#!/bin/bash
# TermuxServerX - n8n Workflow Automation
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_n8n() {
    log "Installing n8n (Workflow Automation)..."
    
    pkg update -y
    pkg install -y nodejs npm
    
    npm install -g n8n
    
    mkdir -p "$HOME/storage/shared/n8n"
    mkdir -p "$TSX_DIR/logs/n8n"
    
    log "n8n installed!"
    echo ""
    echo "Run: n8n"
    echo "Web UI: http://localhost:5678"
}

start_n8n() {
    cd "$HOME/storage/shared/n8n"
    nohup n8n > "$TSX_DIR/logs/n8n.log" 2>&1 &
    log "n8n started on port 5678"
}

case "${1:-install}" in
    install) install_n8n ;;
    start) start_n8n ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
