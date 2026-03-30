#!/bin/bash
# TermuxServerX - PocketMine-MP Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_pocketmine() {
    log "Installing PocketMine-MP..."
    
    pkg update -y
    pkg install -y php curl wget unzip
    
    mkdir -p "$TSX_DIR/data/pocketmine"
    cd "$TSX_DIR/data/pocketmine"
    
    if [ ! -f "PocketMine-MP.phar" ]; then
        wget -q -O PocketMine-MP.phar https://github.com/pmmp/PocketMine-MP/releases/latest/download/PocketMine-MP.phar
    fi
    
    cat > start.sh << 'EOF'
#!/bin/bash
while true; do
    ./PocketMine-MP.phar
    echo "Restarting in 5 seconds..."
    sleep 5
done
EOF
    chmod +x start.sh PocketMine-MP.phar
    
    log "PocketMine-MP installed!"
}

start_pocketmine() {
    cd "$TSX_DIR/data/pocketmine"
    screen -dmS pocketmine ./start.sh
}

case "${1:-install}" in
    install) install_pocketmine ;;
    start) start_pocketmine ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
