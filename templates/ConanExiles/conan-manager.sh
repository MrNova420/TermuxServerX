#!/data/data/com.termux/files/usr/bin/bash
# Conan Exiles Server Manager

SERVICE_NAME="conan"
INSTALL_DIR="$HOME/TermuxServerX/data/conan"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/conan"

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Conan Exiles Server Connection Info               ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: Conan Exiles"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     7777                                    │"
    echo "  │ Query Port:    27015                                   │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open Conan Exiles                                    │"
    echo "  │ 2. Press ESC > Browse Servers                          │"
    echo "  │ 3. Search for your server or enter IP                  │"
    echo "  │ 4. Enter: $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP'):7777                    │"
    echo "  │ 5. Password: $SERVER_PASSWORD                           │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Admin Password: $ADMIN_PASSWORD                          │"
    echo "  │ Server Password: $SERVER_PASSWORD                        │"
    echo "  │                                                        │"
    echo "  │ BECOME ADMIN:                                           │"
    echo "  │ Type in server chat: /admin [password]                 │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_config_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Conan Exiles Configuration                         ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    cat << 'CONFIGEOF'
  CONFIG FILES:
  ~/TermuxServerX/data/conan/ConanSandbox/Saved/Config/WindowsServer/Game.ini
  ~/TermuxServerX/data/conan/ConanSandbox/Saved/Config/WindowsServer/GameUserSettings.ini

  KEY SETTINGS:
  [/script/conansandbox.conansandboxmode]
  ServerPassword="PASSWORD"
  ServerAdminPassword="ADMIN_PASSWORD"
  MaxPlayers=40

  STEAM APP ID: 443030
CONFIGEOF
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_conan() {
    mkdir -p "$INSTALL_DIR"/{server,backups}
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 443030 validate +quit
    echo "[+] Conan Exiles installed"
}

start_conan() {
    screen -dmS conan "$INSTALL_DIR/server/ConanSandboxServer.sh"
    echo "[+] Conan Exiles started"
}

stop_conan() {
    screen -S conan -X quit 2>/dev/null
    echo "[+] Conan Exiles stopped"
}

case "$1" in
    install) install_conan ;;
    start) start_conan ;;
    stop) stop_conan ;;
    info) show_connection_info ;;
    config) show_config_info ;;
    *) echo "Usage: $0 {install|start|stop|info|config}" ;;
esac
