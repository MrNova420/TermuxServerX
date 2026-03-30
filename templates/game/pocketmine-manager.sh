#!/data/data/com.termux/files/usr/bin/bash
# PocketMine Server Manager
# Minecraft PE/bedrock server

SERVICE_NAME="pocketmine"
INSTALL_DIR="$HOME/TermuxServerX/data/pocketmine"
BACKUP_DIR="$HOME/TermuxServerX/backups/pocketmine"

show_connection_info() {
    clear
    MY_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_PUBLIC_IP")
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         PocketMine Server Connection Info               ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: Minecraft Bedrock Edition"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Your Public IP: ${GREEN}$MY_IP${NC}                       │"
    echo "  │ Bedrock Port:   19132                                   │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open Minecraft Bedrock Edition                      │"
    echo "  │ 2. Click 'Play' > 'Servers'                           │"
    echo "  │ 3. Click 'Add Server'                                 │"
    echo "  │ 4. Server Name: My PocketMine Server                   │"
    echo "  │ 5. Server IP: $MY_IP                          │"
    echo "  │ 6. Port: 19132                                        │"
    echo "  │ 7. Click 'Play'                                       │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Server Password: $SERVER_PASSWORD                        │"
    echo "  │                                                        │"
    echo "  │ Note: Bedrock uses XBOX LIVE for auth                  │"
    echo "  │ Enable offline mode in config for cracked clients       │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_config_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         PocketMine Configuration                        ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    cat << 'CONFIGEOF'
  CONFIG FILES:
  ~/TermuxServerX/data/pocketmine/server.properties
  ~/TermuxServerX/data/pocketmine/plugin_data/

  KEY SETTINGS IN server.properties:
  server-name=My PocketMine Server
  server-port=19132
  server-ip=0.0.0.0
  max-players=20
  gamemode=survival
  difficulty=normal
  white-list=false
  spawn-protection=10

  ALLOW CRACKED CLIENTS:
  Set in pocketmine.yml:
  settings > allow-invite: true
  settings > xbox-auth: false

  COMMANDS:
  /op [player]     - Make operator
  /deop [player]   - Remove operator
  /ban [player]    - Ban player
  /kick [player]   - Kick player
  /whitelist       - Manage whitelist
  /plugins         - List plugins
  /version         - Server version
CONFIGEOF
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_secrets_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         PocketMine Secrets & Security                   ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  CONFIG LOCATION:"
    echo "  ~/TermuxServerX/data/pocketmine/server.properties"
    echo "  ~/TermuxServerX/data/pocketmine/pocketmine.yml"
    echo ""
    echo "  BACKUP LOCATION:"
    echo "  ~/TermuxServerX/backups/pocketmine/"
    echo ""
    echo "  ⚠️  SECURITY:"
    echo "  • Disable xbox-auth for cracked clients"
    echo "  • Use whitelist for private servers"
    echo "  • Monitor plugin_data/ for malicious plugins"
    echo "  • Regular backups of worlds/ folder"
    echo ""
    echo "  OP PLAYERS FILE:"
    echo "  ~/TermuxServerX/data/pocketmine/ops.txt"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_pocketmine() {
    mkdir -p "$INSTALL_DIR"/{server,backups,worlds,plugin_data}
    cd "$INSTALL_DIR/server"

    curl -fsSL https://get.pmmp.io -o install.sh
    bash install.sh

    cat > "$INSTALL_DIR/start-server.sh" << 'EOF'
#!/bin/bash
cd ~/TermuxServerX/data/pocketmine/server
php bin/php7/start.sh
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"

    echo "[+] PocketMine installed"
}

start_pocketmine() {
    screen -dmS pocketmine "$INSTALL_DIR/start-server.sh"
    echo "[+] PocketMine started"
}

stop_pocketmine() {
    screen -S pocketmine -X quit 2>/dev/null
    echo "[+] PocketMine stopped"
}

backup_pocketmine() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/pocketmine_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR" worlds plugin_data 2>/dev/null || true
    echo "[+] Backup created"
}

case "$1" in
    install) install_pocketmine ;;
    start) start_pocketmine ;;
    stop) stop_pocketmine ;;
    backup) backup_pocketmine ;;
    info) show_connection_info ;;
    config) show_config_info ;;
    secrets) show_secrets_info ;;
    *) echo "Usage: $0 {install|start|stop|backup|info|config|secrets}" ;;
esac
