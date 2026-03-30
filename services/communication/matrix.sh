#!/bin/bash
# TermuxServerX - Matrix/Element Chat Server
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_matrix() {
    log "Installing Matrix (Element) Chat..."
    
    pkg update -y
    pkg install -y nodejs npm postgresql redis
    
    mkdir -p "$TSX_DIR/data/matrix"
    mkdir -p "$HOME/storage/shared/matrix"
    
    cd "$TSX_DIR/data/matrix"
    
    npm install -g matrix-synapse
    
    cat > "$HOME/storage/shared/matrix/homeserver.yaml" << 'EOF'
server_name: your-server.local
port: 8008
no_tls: true
database_name: synapse
database_path: $HOME/storage/shared/matrix/synapse.db
log_config: $HOME/storage/shared/matrix/log.config
media_store_path: $HOME/storage/shared/matrix/media
EOF
    
    log "Matrix Synapse installed!"
    echo ""
    echo "Run: synapse-generate-config -c $HOME/storage/shared/matrix/homeserver.yaml -f $HOME/storage/shared/matrix"
    echo "Then: python -m synapse.app.homeserver -c $HOME/storage/shared/matrix/homeserver.yaml"
}

case "${1:-install}" in
    install) install_matrix ;;
    *) echo "Usage: $0 install" ;;
esac
