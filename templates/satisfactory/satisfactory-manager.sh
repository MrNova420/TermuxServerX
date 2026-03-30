#!/data/data/com.termux/files/usr/bin/bash
# Satisfactory Server Manager

SERVICE_NAME="satisfactory"
INSTALL_DIR="$HOME/TermuxServerX/data/satisfactory"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/satisfactory"

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Satisfactory Server Connection Info                ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: Satisfactory (Coffee Stain)"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     7777                                    │"
    echo "  │ Query Port:    15777                                   │"
    echo "  │ Beacon Port:   15000                                   │"
    echo "  │ RCON Port:     9999                                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open Satisfactory                                    │"
    echo "  │ 2. Click 'Host Game'                                    │"
    echo "  │ 3. Select 'Join Game'                                   │"
    echo "  │ 4. Enter IP: $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP')                     │"
    echo "  │ 5. Enter Password: $SERVER_PASSWORD                     │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Admin Password: $ADMIN_PASSWORD                          │"
    echo "  │ RCON Password:  $RCON_PASSWORD                           │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_satisfactory() {
    mkdir -p "$INSTALL_DIR"/{server,backups}
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 1698042 validate +quit
    echo "[+] Satisfactory installed"
}

start_satisfactory() {
    screen -dmS satisfactory "$INSTALL_DIR/server/FactoryServer.sh"
    echo "[+] Satisfactory started"
}

stop_satisfactory() {
    screen -S satisfactory -X quit 2>/dev/null
    echo "[+] Satisfactory stopped"
}

case "$1" in
    install) install_satisfactory ;;
    start) start_satisfactory ;;
    stop) stop_satisfactory ;;
    info) show_connection_info ;;
    *) echo "Usage: $0 {install|start|stop|info}" ;;
esac
