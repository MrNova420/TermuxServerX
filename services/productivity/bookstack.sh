#!/bin/bash
# TermuxServerX - BookStack Documentation Wiki
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_bookstack() {
    log "Installing BookStack..."
    
    pkg update -y
    pkg install -y php php-sqlite3 php-mbstring php-curl php-xml nginx
    
    mkdir -p "$TSX_DIR/data/bookstack"
    mkdir -p "$HOME/storage/shared/bookstack"
    mkdir -p "$TSX_DIR/logs/bookstack"
    
    # Download BookStack
    local VERSION="v24.02.01"
    wget -q -O "/tmp/bookstack.tar.gz" \
        "https://github.com/BookStackApp/BookStack/releases/download/${VERSION}/bookstack.tar.gz"
    
    tar -xzf "/tmp/bookstack.tar.gz" -C "$HOME/storage/shared/bookstack"
    rm "/tmp/bookstack.tar.gz"
    
    # Create .env file
    cat > "$HOME/storage/shared/bookstack/.env" << 'EOF'
APP_DEBUG=false
APP_URL=http://localhost:8080/bookstack
APP_KEY=base64:YOUR_APP_KEY_HERE

DB_TYPE=sqlite
DB_DATABASE=/data/data/com.termux/files/home/storage/shared/bookstack/database.sqlite

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
EOF
    
    chmod -R 755 "$HOME/storage/shared/bookstack"
    chmod -R 777 "$HOME/storage/shared/bookstack/storage"
    chmod -R 777 "$HOME/storage/shared/bookstack/bootstrap/cache"
    
    log "BookStack installed!"
    echo ""
    echo "Important: Generate APP_KEY using:"
    echo "php -r \"echo 'base64:'.base64_encode(random_bytes(32));\""
    echo ""
    echo "Then edit $HOME/storage/shared/bookstack/.env"
}

start_bookstack() {
    cd "$HOME/storage/shared/bookstack"
    php -S localhost:8081 > "$TSX_DIR/logs/bookstack.log" 2>&1 &
    log "BookStack started on port 8081"
}

case "${1:-install}" in
    install) install_bookstack ;;
    start) start_bookstack ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
