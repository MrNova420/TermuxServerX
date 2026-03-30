#!/bin/bash
# TermuxServerX - Umami Analytics (Privacy-focused Google Analytics alternative)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_umami() {
    log "Installing Umami Analytics..."
    
    pkg update -y
    pkg install -y nodejs npm postgresql
    
    mkdir -p "$TSX_DIR/data/umami"
    mkdir -p "$HOME/storage/shared/umami"
    mkdir -p "$TSX_DIR/logs/umami"
    
    cd "$TSX_DIR/data/umami"
    
    git clone https://github.com/umami-software/umami.git .
    npm install
    npm run build
    
    log "Umami installed!"
    echo ""
    echo "Run: npm start"
    echo "Web UI: http://localhost:3000"
    echo "Default login: admin / umami"
}

case "${1:-install}" in
    install) install_umami ;;
    *) echo "Usage: $0 install" ;;
esac
