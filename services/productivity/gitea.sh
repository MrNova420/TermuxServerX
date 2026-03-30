#!/bin/bash
# TermuxServerX - Gitea Self-Hosted Git Service
set -e

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_gitea() {
    log "Installing Gitea..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm-7" ;;
    esac
    
    local VERSION="1.21.11"
    
    mkdir -p "$TSX_DIR/data/gitea"
    mkdir -p "$HOME/storage/shared/gitea"
    mkdir -p "$TSX_DIR/logs/gitea"
    
    wget -q -O "$TSX_DIR/data/gitea/gitea" \
        "https://github.com/go-gitea/gitea/releases/download/v${VERSION}/gitea-${VERSION}-linux-${ARCH}"
    
    chmod +x "$TSX_DIR/data/gitea/gitea"
    
    # Create database first
    log "Creating SQLite database..."
    mkdir -p "$HOME/storage/shared/gitea/data"
    
    log "Gitea installed!"
    echo ""
    echo "To start:"
    echo "cd $TSX_DIR/data/gitea && ./gitea web"
    echo ""
    echo "First-time setup: http://localhost:3000"
    echo "Database: SQLite at $HOME/storage/shared/gitea/data/gitea.db"
}

start_gitea() {
    cd "$TSX_DIR/data/gitea"
    nohup ./gitea web --config "$HOME/storage/shared/gitea/custom/conf/app.ini" > "$TSX_DIR/logs/gitea.log" 2>&1 &
    log "Gitea started on port 3000"
}

case "${1:-install}" in
    install) install_gitea ;;
    start) start_gitea ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
