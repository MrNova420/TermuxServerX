#!/bin/bash
# TermuxServerX - Navidrome Music Server Installer
# Most popular self-hosted music server (2026)

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_navidrome() {
    log "Installing Navidrome (Music Server)..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm" ;;
    esac
    
    local VERSION="0.52.5"
    
    mkdir -p "$TSX_DIR/data/navidrome"
    mkdir -p "$HOME/storage/shared/music"
    mkdir -p "$TSX_DIR/logs/navidrome"
    
    wget -q -O "$TSX_DIR/data/navidrome/navidrome" \
        "https://github.com/navidrome/navidrome/releases/download/v${VERSION}/navidrome_${VERSION}_linux_${ARCH}.tar.gz"
    
    tar -xzf "$TSX_DIR/data/navidrome/navidrome_${VERSION}_linux_${ARCH}.tar.gz" -C "$TSX_DIR/data/navidrome" 2>/dev/null || \
    wget -q -O "$TSX_DIR/data/navidrome/navidrome" \
        "https://github.com/navidrome/navidrome/releases/download/v${VERSION}/navidrome_${VERSION}_linux_${ARCH}.zip"
    
    chmod +x "$TSX_DIR/data/navidrome/navidrome"
    
    cat > "$HOME/storage/shared/navidrome.toml" << 'EOF'
# Navidrome Configuration
MusicFolder = "/data/data/com.termux/files/home/storage/shared/music"
Port = 4533
DataFolder = "/data/data/com.termux/files/home/TermuxServerX/data/navidrome"
Log = "/data/data/com.termux/files/home/TermuxServerX/logs/navidrome/nd.log"

# Authentication
DefaultAdminUser = "admin"
DefaultAdminPassword = "admin123"

# UI
EnableGravatar = true
CoverArtPriority = "cover.jpg folder.jpg album.jpg front.jpg embedded"
EOF
    
    log "Navidrome installed!"
    echo ""
    echo "Run: cd $TSX_DIR/data/navidrome && ./navidrome"
    echo "Web UI: http://localhost:4533"
    echo "Login: admin / admin123"
    echo "Music folder: $HOME/storage/shared/music"
}

start_navidrome() {
    cd "$TSX_DIR/data/navidrome"
    nohup ./navidrome > "$TSX_DIR/logs/navidrome.log" 2>&1 &
    log "Navidrome started on port 4533"
}

case "${1:-install}" in
    install) install_navidrome ;;
    start) start_navidrome ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
