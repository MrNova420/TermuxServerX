#!/bin/bash
# TermuxServerX - SSH Server Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_ssh() {
    log "Installing SSH server..."
    pkg update -y
    pkg install -y openssh
    
    mkdir -p "$TSX_DIR/logs/ssh"
    
    log "Configuring SSH..."
    
    # Generate host keys if they don't exist
    [ ! -f "$PREFIX/etc/ssh/ssh_host_rsa_key" ] && ssh-keygen -A 2>/dev/null || true
    
    # Create SSH config
    cat > "$PREFIX/etc/ssh/sshd_config" << 'EOF'
Port 8022
PasswordAuthentication yes
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
AllowTcpForwarding yes
X11Forwarding yes
PrintMotd yes
Subsystem sftp /data/data/com.termux/files/usr/lib/sftp-subsystem
EOF
    
    # Set default username/password hint
    local user=$(whoami)
    local pass="termux"
    
    log "SSH installed!"
    echo ""
    echo "=== SSH Access ==="
    echo "Port: 8022"
    echo "User: $user"
    echo ""
    echo "To set password, run: passwd"
    echo "To connect: ssh $user@<your-ip> -p 8022"
}

start_ssh() {
    log "Starting SSH server..."
    sshd 2>/dev/null && log "SSH started on port 8022" || log "SSH may already be running"
}

stop_ssh() {
    pkill sshd 2>/dev/null && log "SSH stopped" || true
}

setup_keys() {
    log "Setting up SSH keys..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    echo "# Add your public keys here" > ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    
    log "Edit ~/.ssh/authorized_keys to add your public key"
}

case "${1:-install}" in
    install) install_ssh ;;
    start) start_ssh ;;
    stop) stop_ssh ;;
    keys) setup_keys ;;
    *) echo "Usage: $0 {install|start|stop|keys}" ;;
esac
