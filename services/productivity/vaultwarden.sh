#!/bin/bash
# TermuxServerX - Vaultwarden Password Manager
set -e

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_vaultwarden() {
    log "Installing Vaultwarden..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="aarch64" ;;
        x86_64|amd64) ARCH="x86_64" ;;
        *) ARCH="aarch64" ;;
    esac
    
    mkdir -p "$TSX_DIR/data/vaultwarden"
    mkdir -p "$HOME/storage/shared/vaultwarden"
    mkdir -p "$TSX_DIR/logs/vaultwarden"
    
    # Download pre-built binary
    local VERSION="1.30.5"
    wget -q -O "$TSX_DIR/data/vaultwarden/vaultwarden" \
        "https://github.com/dani-garcia/vaultwarden/releases/download/${VERSION}/vaultwarden-${ARCH}-unknown-linux-musleabihf.tar.gz" 2>/dev/null || \
    wget -q -O "$TSX_DIR/data/vaultwarden/vaultwarden" \
        "https://github.com/dani-garcia/vaultwarden/releases/download/${VERSION}/vaultwarden-${ARCH}-unknown-linux-musl.tar.gz"
    
    chmod +x "$TSX_DIR/data/vaultwarden/vaultwarden"
    
    # Create env file
    cat > "$HOME/storage/shared/vaultwarden/.env" << 'EOF'
DATA_FOLDER=/data/data/com.termux/files/home/storage/shared/vaultwarden/data
WEB_VAULT_FOLDER=/data/data/com.termux/files/home/TermuxServerX/data/vaultwarden/web-vault
DATABASE_URL=/data/data/com.termux/files/home/storage/shared/vaultwarden/data/vaultwarden.db
ROCKET_ADDRESS=0.0.0.0
ROCKET_PORT=8080
WEB_VAULT_ENABLED=true
EOF
    
    log "Vaultwarden installed!"
    echo ""
    echo "To start:"
    echo "cd $TSX_DIR/data/vaultwarden && ./vaultwarden"
    echo ""
    echo "Web UI: http://localhost:8080"
    echo "Important: Set SIGNUP_ALLOWED=false after creating admin account!"
}

start_vaultwarden() {
    cd "$TSX_DIR/data/vaultwarden"
    export $(cat "$HOME/storage/shared/vaultwarden/.env" | xargs)
    nohup ./vaultwarden > "$TSX_DIR/logs/vaultwarden.log" 2>&1 &
    log "Vaultwarden started on port 8080"
}

case "${1:-install}" in
    install) install_vaultwarden ;;
    start) start_vaultwarden ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
