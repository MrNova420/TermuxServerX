#!/data/data/com.termux/files/usr/bin/bash
# StarMade Server Manager

SERVICE_NAME="starmade"
INSTALL_DIR="$HOME/TermuxServerX/data/starmade"
BACKUP_DIR="$HOME/TermuxServerX/backups/starmade"

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          StarMade Server Connection Info                  ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: StarMade"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     4242                                    │"
    echo "  │ UI Port:        4243                                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open StarMade                                        │"
    echo "  │ 2. Click 'Connect to Server'                           │"
    echo "  │ 3. Enter: $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP')                             │"
    echo "  │ 4. Port: 4242                                          │"
    echo "  │ 5. Password: $SERVER_PASSWORD                           │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_starmade() {
    mkdir -p "$INSTALL_DIR"/{server,backups}
    cd "$INSTALL_DIR/server"

    curl -sL https://storage.googleapis.com/starmade-servers/server.zip -o server.zip
    unzip -o server.zip
    rm server.zip

    echo "[+] StarMade installed"
}

start_starmade() {
    screen -dmS starmade java -jar StarMadeServer.jar
    echo "[+] StarMade started"
}

stop_starmade() {
    screen -S starmade -X quit 2>/dev/null
    echo "[+] StarMade stopped"
}

backup_starmade() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/starmade_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR" database Schematics 2>/dev/null || true
    echo "[+] Backup created"
}

case "$1" in
    install) install_starmade ;;
    start) start_starmade ;;
    stop) stop_starmade ;;
    backup) backup_starmade ;;
    info) show_connection_info ;;
    *) echo "Usage: $0 {install|start|stop|backup|info}" ;;
esac
