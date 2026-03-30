#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

ARCH=$(uname -m)
CLOUDFLARED_VERSION="2024.1.5"
TUNNEL_NAME="termux-server"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_architecture() {
    case "$ARCH" in
        aarch64|arm64) echo "arm64" ;;
        armv7l|arm) echo "arm" ;;
        x86_64|amd64) echo "amd64" ;;
        i686|i386) echo "386" ;;
        *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}

download_cloudflared() {
    log_info "Downloading cloudflared..."
    
    local arch=$(detect_architecture)
    local download_url="https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${arch}"
    
    mkdir -p "$TSX_DIR/data/cloudflared"
    
    curl -fsSL -o "$TSX_DIR/data/cloudflared/cloudflared" "$download_url" || {
        log_error "Failed to download cloudflared"
        log_info "Trying alternative download method..."
        wget -q -O "$TSX_DIR/data/cloudflared/cloudflared" "$download_url"
    }
    
    chmod +x "$TSX_DIR/data/cloudflared/cloudflared"
    
    ln -sf "$TSX_DIR/data/cloudflared/cloudflared" "$PREFIX/bin/cloudflared"
    
    log_success "cloudflared installed"
}

install_dependencies() {
    pkg install -y curl wget 2>/dev/null || true
}

setup_tunnel() {
    log_info "Setting up Cloudflare Tunnel..."
    
    local token=""
    
    echo ""
    echo -e "${BLUE}=== Cloudflare Tunnel Setup ===${NC}"
    echo ""
    echo "You need a Cloudflare account and a domain managed by Cloudflare."
    echo ""
    echo "Steps:"
    echo "1. Go to https://dash.cloudflare.com"
    echo "2. Select your domain"
    echo "3. Go to Zero Trust > Networks > Tunnels"
    echo "4. Create a new tunnel (Cloudflared)"
    echo "5. Copy the tunnel token"
    echo ""
    echo -n "Paste your tunnel token here: "
    read token
    
    if [ -z "$token" ]; then
        log_error "Token is required"
        return 1
    fi
    
    echo ""
    echo "Available services to expose:"
    echo "1. All services (Web UI, game servers, etc)"
    echo "2. Web UI only"
    echo "3. Custom"
    echo ""
    echo -n "Select [1]: "
    read service_choice
    
    create_tunnel_config
    create_cloudflared_service
    
    log_success "Cloudflare Tunnel configured!"
    log_info "Run 'cloudflared service install $token' to start the tunnel"
}

create_tunnel_config() {
    mkdir -p "$TSX_DIR/data/cloudflared"
    
    cat > "$TSX_DIR/data/cloudflared/config.yml" << EOF
tunnel: $TUNNEL_NAME
credentials-file: $TSX_DIR/data/cloudflared/credentials.json

ingress:
  - hostname: tsx-$(date +%s).trycloudflare.com
    service: http://localhost:8080
  - hostname: mc-$(date +%s).trycloudflare.com
    service: tcp://localhost:25565
  - service: http_status:404
EOF
}

create_cloudflared_service() {
    mkdir -p "$PREFIX/etc/service/cloudflared"
    
    cat > "$PREFIX/etc/service/cloudflared/run" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
exec 2>&1

export HOME="/data/data/com.termux/files/home"
export PATH="$HOME/TermuxServerX/data/cloudflared:$PATH"

cd "$HOME/TermuxServerX/data/cloudflared"

exec ./cloudflared --config config.yml tunnel run
EOF
    
    chmod +x "$PREFIX/etc/service/cloudflared/run"
}

quick_tunnel() {
    log_info "Starting quick tunnel (trycloudflare.com)..."
    log_info "You'll get a temporary URL to share"
    echo ""
    
    cd "$TSX_DIR/data/cloudflared"
    ./cloudflared tunnel --url http://localhost:8080
}

install_tunnel_service() {
    local token=$1
    
    log_info "Installing cloudflared as a service..."
    
    cd "$TSX_DIR/data/cloudflared"
    ./cloudflared service install "$token"
    
    update_config "TSX_TUNNEL_ENABLED" "true"
    
    log_success "Tunnel service installed and started"
}

update_config() {
    local key=$1
    local value=$2
    
    if [ -f "$TSX_DIR/config.env" ]; then
        if grep -q "^$key=" "$TSX_DIR/config.env"; then
            sed -i "s|^$key=.*|$key=\"$value\"|" "$TSX_DIR/config.env"
        else
            echo "$key=\"$value\"" >> "$TSX_DIR/config.env"
        fi
    fi
}

uninstall_tunnel() {
    log_info "Uninstalling Cloudflare Tunnel..."
    
    cloudflared service uninstall 2>/dev/null || true
    rm -rf "$PREFIX/etc/service/cloudflared"
    update_config "TSX_TUNNEL_ENABLED" "false"
    
    log_success "Cloudflare Tunnel uninstalled"
}

show_status() {
    if cloudflared tunnel list &>/dev/null; then
        echo -e "${GREEN}Cloudflared is installed${NC}"
        cloudflared tunnel list
    else
        echo -e "${RED}Cloudflared is not installed${NC}"
    fi
}

case "${1:-install}" in
    install)
        install_dependencies
        download_cloudflared
        ;;
    setup)
        setup_tunnel
        ;;
    quick)
        quick_tunnel
        ;;
    start)
        cd "$TSX_DIR/data/cloudflared" && ./cloudflared --config config.yml tunnel run &
        ;;
    stop)
        pkill -f cloudflared
        ;;
    status)
        show_status
        ;;
    uninstall)
        uninstall_tunnel
        ;;
    *)
        echo "Usage: $0 {install|setup|quick|start|stop|status|uninstall}"
        echo ""
        echo "Commands:"
        echo "  install  - Download and install cloudflared"
        echo "  setup    - Configure a named tunnel"
        echo "  quick    - Start a temporary tunnel (trycloudflare.com)"
        echo "  start    - Start the tunnel service"
        echo "  stop     - Stop the tunnel"
        echo "  status   - Show tunnel status"
        echo "  uninstall - Remove tunnel"
        ;;
esac
