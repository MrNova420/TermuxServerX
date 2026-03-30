#!/data/data/com.termux/files/usr/bin/bash
# Eco Server Manager
# Collaborative world simulation game

SERVICE_NAME="eco"
INSTALL_DIR="$HOME/TermuxServerX/data/eco"
BACKUP_DIR="$HOME/TermuxServerX/backups/eco"

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            Eco Server Connection Info                      ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: Eco"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     3000                                    │"
    echo "  │ Web Port:      3001                                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open Eco                                            │"
    echo "  │ 2. Click 'Join Game'                                   │"
    echo "  │ 3. Enter IP: $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP')                           │"
    echo "  │ 4. Port: 3000                                          │"
    echo "  │ 5. Click Connect                                      │"
    echo "  │                                                        │"
    echo "  │ WEB DASHBOARD:                                         │"
    echo "  │ Browser: http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP'):3001              │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Admin Password: $ADMIN_PASSWORD                          │"
    echo "  │ Portal Password: $SERVER_PASSWORD                        │"
    echo "  │                                                        │"
    echo "  │ BECOME ADMIN:                                           │"
    echo "  │ 1. In-game type: /register [password]                  │"
    echo "  │ 2. Type: /login [password]                             │"
    echo "  │ 3. Type: /makeadmin                                     │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_eco() {
    mkdir -p "$INSTALL_DIR"/{server,backups}
    cd "$INSTALL_DIR/server"

    wget -q https://eco-game.org/files/EcoServer.tar.gz
    tar -xzf EcoServer.tar.gz
    rm EcoServer.tar.gz

    echo "[+] Eco installed"
}

start_eco() {
    screen -dmS eco "$INSTALL_DIR/server/EcoServer.sh"
    echo "[+] Eco started"
}

stop_eco() {
    screen -S eco -X quit 2>/dev/null
    echo "[+] Eco stopped"
}

backup_eco() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/eco_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR" 2>/dev/null || true
    echo "[+] Backup created"
}

case "$1" in
    install) install_eco ;;
    start) start_eco ;;
    stop) stop_eco ;;
    backup) backup_eco ;;
    info) show_connection_info ;;
    *) echo "Usage: $0 {install|start|stop|backup|info}" ;;
esac
