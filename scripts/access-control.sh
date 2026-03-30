#!/data/data/com.termux/files/usr/bin/bash
# TermuxServerX Access Control Manager
# Public/Private server access management + Firewall

INSTALL_DIR="$HOME/TermuxServerX"
CONFIG_DIR="$HOME/TermuxServerX/config"
ACCESS_FILE="$CONFIG_DIR/access.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

mkdir -p "$CONFIG_DIR"

load_access_config() {
    if [ -f "$ACCESS_FILE" ]; then
        source "$ACCESS_FILE"
    else
        DEFAULT_ACCESS_CONFIG
    fi
}

DEFAULT_ACCESS_CONFIG() {
    ACCESS_MODE="private"
    PUBLIC_SERVICES=""
    ALLOWED_IPS=""
    BLOCKED_IPS=""
    WHITELIST_MODE="off"
}

save_access_config() {
    cat > "$ACCESS_FILE" << EOF
ACCESS_MODE="$ACCESS_MODE"
PUBLIC_SERVICES="$PUBLIC_SERVICES"
ALLOWED_IPS="$ALLOWED_IPS"
BLOCKED_IPS="$BLOCKED_IPS"
WHITELIST_MODE="$WHITELIST_MODE"
EOF
    echo "[+] Access configuration saved"
}

show_main_menu() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     TermuxServerX Access Control Manager                  ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  Current Mode: $( [ "$ACCESS_MODE" = "public" ] && echo "${GREEN}PUBLIC${NC} (Anyone can join)" || echo "${YELLOW}PRIVATE${NC} (Invite only)")          ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  1) Set Server Mode (Public/Private)                      ║"
    echo "║  2) Manage Public Services                               ║"
    echo "║  3) IP Whitelist Management                              ║"
    echo "║  4) IP Blacklist Management                              ║"
    echo "║  5) View Current Access Status                           ║"
    echo "║  6) Generate Connection Links                             ║"
    echo "║  7) Setup Cloudflare Tunnel (Public)                     ║"
    echo "║  8) Setup Tailscale (Public)                             ║"
    echo "║  9) Enable/Disable All Services                          ║"
    echo "║  0) Exit                                                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
}

set_access_mode() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            Set Access Mode                              ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║                                                            ║"
    echo "║  ${GREEN}PUBLIC MODE${NC}:                                          ║"
    echo "║  • Anyone with IP/link can connect                       ║"
    echo "║  • Good for public game servers                          ║"
    echo "║  • No authentication required                             ║"
    echo "║                                                            ║"
    echo "║  ${YELLOW}PRIVATE MODE${NC}:                                        ║"
    echo "║  • Only whitelisted IPs can connect                      ║"
    echo "║  • Good for personal services                             ║"
    echo "║  • Password protection recommended                        ║"
    echo "║                                                            ║"
    echo "║  ${BLUE}FRIENDS MODE${NC}:                                        ║"
    echo "║  • Allow specific friend IPs only                         ║"
    echo "║  • Best for gaming with friends                           ║"
    echo "║  • Add friend's IP to whitelist                           ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Select mode:"
    echo "1) Public - Anyone can join"
    echo "2) Private - Invite only"
    echo "3) Friends - Whitelist specific IPs"
    read -p "Choice: " mode

    case $mode in
        1) ACCESS_MODE="public"; echo "Mode set to PUBLIC" ;;
        2) ACCESS_MODE="private"; echo "Mode set to PRIVATE" ;;
        3) ACCESS_MODE="friends"; echo "Mode set to FRIENDS" ;;
    esac
    save_access_config
}

manage_public_services() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Public Services Configuration                   ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Services available for public access:"
    echo ""
    echo "  Game Servers:"
    echo "    [M] Minecraft  - Port: 25565"
    echo "    [V] Valheim   - Port: 2456"
    echo "    [P] Palworld  - Port: 8211"
    echo "    [C] CS:GO/CS2 - Port: 27015"
    echo "    [R] Rust      - Port: 28015"
    echo "    [7] 7 Days    - Port: 26900"
    echo "    [D] DayZ      - Port: 2302"
    echo "    [A] ARK       - Port: 7778"
    echo "    [T] Terraria  - Port: 7777"
    echo ""
    echo "  Web Services:"
    echo "    [N] Nginx     - Port: 80/443"
    echo "    [J] Jellyfin  - Port: 8096"
    echo "    [G] Gitea     - Port: 3000"
    echo "    [W] Vaultwarden - Port: 8080"
    echo ""
    echo "Enter service letters to toggle (e.g., MVPTC = make Minecraft, Valheim, Palworld, Terraria public): "
    read -rsn1 services
    echo

    PUBLIC_SERVICES="$services"
    save_access_config
    echo "[+] Public services updated"
}

manage_whitelist() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            IP Whitelist Manager                         ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "Current Whitelist:"
    if [ -f "$CONFIG_DIR/whitelist.txt" ]; then
        cat "$CONFIG_DIR/whitelist.txt"
    else
        echo "  (empty)"
    fi
    echo ""
    echo "1) Add IP to whitelist"
    echo "2) Remove IP from whitelist"
    echo "3) Clear whitelist"
    read -p "Choice: " choice

    case $choice in
        1)
            echo "Enter IP address: "
            read ip
            echo "$ip" >> "$CONFIG_DIR/whitelist.txt"
            echo "[+] IP added: $ip"
            ;;
        2)
            echo "Enter IP to remove: "
            read ip
            sed -i "/$ip/d" "$CONFIG_DIR/whitelist.txt"
            echo "[+] IP removed: $ip"
            ;;
        3)
            > "$CONFIG_DIR/whitelist.txt"
            echo "[+] Whitelist cleared"
            ;;
    esac
}

manage_blacklist() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            IP Blacklist Manager                         ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "Current Blacklist:"
    if [ -f "$CONFIG_DIR/blacklist.txt" ]; then
        cat "$CONFIG_DIR/blacklist.txt"
    else
        echo "  (empty)"
    fi
    echo ""
    echo "1) Add IP to blacklist"
    echo "2) Remove IP from blacklist"
    echo "3) Clear blacklist"
    read -p "Choice: " choice

    case $choice in
        1)
            echo "Enter IP to block: "
            read ip
            echo "$ip" >> "$CONFIG_DIR/blacklist.txt"
            echo "[+] IP blocked: $ip"
            ;;
        2)
            echo "Enter IP to unblock: "
            read ip
            sed -i "/$ip/d" "$CONFIG_DIR/blacklist.txt"
            echo "[+] IP unblocked: $ip"
            ;;
        3)
            > "$CONFIG_DIR/blacklist.txt"
            echo "[+] Blacklist cleared"
            ;;
    esac
}

show_access_status() {
    clear
    load_access_config
    MY_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")

    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          Current Access Status                          ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Your Public IP: $MY_IP"
    echo "  Access Mode: $ACCESS_MODE"
    echo ""
    echo "  Public Services: ${PUBLIC_SERVICES:-none}"
    echo ""
    echo "  Whitelist: $(wc -l < "$CONFIG_DIR/whitelist.txt" 2>/dev/null || echo 0) IPs"
    echo "  Blacklist: $(wc -l < "$CONFIG_DIR/blacklist.txt" 2>/dev/null || echo 0) IPs"
    echo "╚════════════════════════════════════════════════════════════╝"
}

generate_connection_links() {
    clear
    load_access_config
    MY_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_PUBLIC_IP")

    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          Connection Information                         ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  Share these with friends:"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ ${GREEN}GAME SERVERS${NC}                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Minecraft:    $MY_IP:25565                          │"
    echo "  │ Valheim:      $MY_IP:2456                           │"
    echo "  │ Palworld:     $MY_IP:8211                           │"
    echo "  │ CS:GO/CS2:    $MY_IP:27015                          │"
    echo "  │ Rust:         $MY_IP:28015                          │"
    echo "  │ 7 Days:       $MY_IP:26900                          │"
    echo "  │ DayZ:         $MY_IP:2302                           │"
    echo "  │ Terraria:     $MY_IP:7777                           │"
    echo "  │ ARK:          $MY_IP:7778                           │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ ${BLUE}WEB SERVICES${NC}                                              │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Jellyfin:     http://$MY_IP:8096                   │"
    echo "  │ Gitea:        http://$MY_IP:3000                   │"
    echo "  │ Code Server:  http://$MY_IP:8443                   │"
    echo "  │ Netdata:      http://$MY_IP:19999                  │"
    echo "  │ Vaultwarden:  http://$MY_IP:8080                   │"
    echo "  │ Navidrome:    http://$MY_IP:4533                   │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ ${YELLOW}PASSWORD PROTECTED${NC}                                        │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Add :password after IP for password-protected servers  │"
    echo "  │ Example: $MY_IP:25565:secretpassword                │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

setup_cloudflared() {
    echo "Setting up Cloudflare Tunnel for public access..."
    if ! command -v cloudflared &>/dev/null; then
        echo "Installing cloudflared..."
        curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o ~/cloudflared
        chmod +x ~/cloudflared
    fi

    echo "To create a tunnel:"
    echo "1. Go to https://dash.cloudflare.com"
    echo "2. Create a Zero Trust account"
    echo "3. Create a tunnel"
    echo "4. Run: cloudflared tunnel token <YOUR_TOKEN>"
    echo ""
    echo "Or use quick tunnel:"
    ~/cloudflared tunnel --url http://localhost:80 2>/dev/null &
    sleep 3
    echo "[+] Cloudflare tunnel started"
}

setup_tailscale() {
    echo "Setting up Tailscale for private network..."
    if ! command -v tailscale &>/dev/null; then
        echo "Installing Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh
    fi

    echo "To connect:"
    echo "1. Run: tailscale up"
    echo "2. Authenticate via the provided URL"
    echo "3. Your friends can install Tailscale and join your network"
    echo ""
    echo "Your Tailscale IP will be shown after authentication"
}

main() {
    load_access_config

    while true; do
        show_main_menu
        read -p "Select option: " choice

        case $choice in
            1) set_access_mode ;;
            2) manage_public_services ;;
            3) manage_whitelist ;;
            4) manage_blacklist ;;
            5) show_access_status ;;
            6) generate_connection_links ;;
            7) setup_cloudflared ;;
            8) setup_tailscale ;;
            9) "$INSTALL_DIR/scripts/stacks/install-stack.sh" ;;
            0) exit 0 ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

case "$1" in
    public) ACCESS_MODE="public"; save_access_config; echo "Set to PUBLIC mode" ;;
    private) ACCESS_MODE="private"; save_access_config; echo "Set to PRIVATE mode" ;;
    status) show_access_status ;;
    links) generate_connection_links ;;
    *) main ;;
esac
