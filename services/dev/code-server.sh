#!/bin/bash
# TermuxServerX - code-server Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_codeserver() {
    log "Installing code-server..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in aarch64|arm64) ARCH="arm64" ;; x86_64|amd64) ARCH="amd64" ;; esac
    
    VERSION="4.93.1"
    mkdir -p "$TSX_DIR/data/code-server"
    
    wget -q -O /tmp/code-server.tar.gz "https://github.com/coder/code-server/releases/download/v${VERSION}/code-server-${VERSION}-linux-${ARCH}.tar.gz"
    tar -xzf /tmp/code-server.tar.gz -C "$TSX_DIR/data/code-server" --strip-components=1
    rm /tmp/code-server.tar.gz
    
    mkdir -p ~/.config/code-server
    PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)
    
    cat > ~/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8443
auth: password
password: ${PASS}
cert: false
EOF
    
    log "code-server installed!"
    echo "Access: https://localhost:8443 | User: codeserver | Pass: $PASS"
}

start_codeserver() {
    cd "$TSX_DIR/data/code-server"
    nohup ./bin/code-server > "$TSX_DIR/logs/code-server.log" 2>&1 &
}

case "${1:-install}" in
    install) install_codeserver ;;
    start) start_codeserver ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
