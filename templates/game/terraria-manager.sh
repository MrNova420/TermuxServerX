#!/data/data/com.termux/files/usr/bin/bash
# Terraria Server Manager
# Full connection info, configs, credentials

SERVICE_NAME="terraria"
INSTALL_DIR="$HOME/TermuxServerX/data/terraria"
BACKUP_DIR="$HOME/TermuxServerX/backups/terraria"

show_connection_info() {
    clear
    MY_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_PUBLIC_IP")
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Terraria Server Connection Info                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: Terraria"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Your Public IP: ${GREEN}$MY_IP${NC}                       │"
    echo "  │ Game Port:     7777                                    │"
    echo "  │ Query Port:    7778                                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open Terraria                                        │"
    echo "  │ 2. Click 'Multiplayer'                                 │"
    echo "  │ 3. Click 'Join via IP'                                 │"
    echo "  │ 4. Enter IP: $MY_IP                            │"
    echo "  │ 5. Port: 7777                                         │"
    echo "  │ 6. Click OK                                           │"
    echo "  │                                                        │"
    echo "  │ If server needs password, enter: $SERVER_PASSWORD        │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ SERVER PASSWORD: $SERVER_PASSWORD                        │"
    echo "  │ Admin Password: $ADMIN_PASSWORD                          │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_config_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Terraria Configuration Guide                    ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    cat << 'CONFIGEOF'
  CONFIG FILE:
  ~/TermuxServerX/data/terraria/serverconfig.txt

  KEY SETTINGS:
  port=7777
  world=worlds/myworld.wld
  maxplayers=8
  password=YOUR_PASSWORD
  motd=Welcome to my Terraria server!
  worldpath=worlds/
  worldname=myworld

  DIFFICULTY:
  difficulty=0 (Normal)
  difficulty=1 (Expert)
  difficulty=2 (Master)
  difficulty=3 (Journey)

  ADMIN COMMANDS (in-game chat):
  /password [pass]     - Set server password
  /kick [player]      - Kick player
  /ban [player]       - Ban player
  /op [player]        - Make player operator
  /tp [p1] [p2]      - Teleport player
  /heal [player]      - Heal player
  /spawnnpc [type]    - Spawn NPC

  STEAM APP ID: 105600 (Terraria Server)
CONFIGEOF
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_secrets_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Terraria Secrets & Security                     ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  CREDENTIALS FILE:"
    echo "  ~/TermuxServerX/data/terraria/serverconfig.txt"
    echo ""
    echo "  WORLD FILES:"
    echo "  ~/TermuxServerX/data/terraria/worlds/"
    echo ""
    echo "  BACKUP LOCATION:"
    echo "  ~/TermuxServerX/backups/terraria/"
    echo ""
    echo "  ⚠️  SECURITY:"
    echo "  • Change password in serverconfig.txt"
    echo "  • Use /op command carefully (full control)"
    echo "  • Regular world backups recommended"
    echo "  • Backup before major events (Blood Moon, etc)"
    echo ""
    echo "  TO BECOME ADMIN:"
    echo "  1. In-game chat, type: /password [adminpassword]"
    echo "  2. Type: /op [yourname]"
    echo "  3. Remove password if you want server open"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_terraria() {
    mkdir -p "$INSTALL_DIR"/{server,worlds,backups}
    cd "$INSTALL_DIR/server"

    curl -sL https://terraria.org/api/download -o server.zip 2>/dev/null || \
    wget -q https://terraria.org/api/download -O server.zip

    if [ -f "terraria-server-*.zip" ]; then
        unzip -o terraria-server-*.zip
        rm server.zip
    fi

    cat > "$INSTALL_DIR/serverconfig.txt" << 'EOF'
port=7777
world=worlds/myworld.wld
maxplayers=8
password=changeme
motd=Welcome to Terraria Server!
worldpath=worlds/
worldname=myworld
difficulty=0
autocreate=1
secure=1
language=en-US
upnp=0
npcstream=60
EOF

    cat > "$INSTALL_DIR/start-server.sh" << 'EOF'
#!/bin/bash
cd ~/TermuxServerX/data/terraria/server
./TerrariaServer.bin.x86_64 -config serverconfig.txt
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"

    echo "[+] Terraria installed"
}

start_terraria() {
    screen -dmS terraria "$INSTALL_DIR/start-server.sh"
    echo "[+] Terraria started"
}

stop_terraria() {
    screen -S terraria -X quit 2>/dev/null
    echo "[+] Terraria stopped"
}

backup_terraria() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/terraria_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR" worlds serverconfig.txt 2>/dev/null || true
    echo "[+] Backup created"
}

case "$1" in
    install) install_terraria ;;
    start) start_terraria ;;
    stop) stop_terraria ;;
    restart) stop_terraria; sleep 2; start_terraria ;;
    backup) backup_terraria ;;
    info) show_connection_info ;;
    config) show_config_info ;;
    secrets) show_secrets_info ;;
    *) echo "Usage: $0 {install|start|stop|restart|backup|info|config|secrets}" ;;
esac
