#!/bin/bash

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

setup_autostart() {
    echo "Setting up auto-start for TermuxServerX..."
    
    install_termux_boot
    create_startup_script
    create_service_configs
    setup_watchdog_cron
    
    echo "Auto-start configured!"
}

install_termux_boot() {
    echo "[1/4] Checking termux-boot..."
    
    if [ ! -d "$PREFIX/etc/service" ]; then
        pkg install -y termux-services 2>/dev/null || {
            echo "Warning: termux-services not available, using alternative method"
            setup_alternative_autostart
            return
        }
    fi
    
    mkdir -p "$PREFIX/etc/service"
}

create_startup_script() {
    echo "[2/4] Creating startup script..."
    
    cat > "$PREFIX/etc/service/tsxserver/start" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
exec 2>&1

export HOME="/data/data/com.termux/files/home"
export PREFIX="/data/data/com.termux/files/usr"
export TERM="xterm-256color"

cd "$HOME/TermuxServerX" || exit

if [ -f config.env ]; then
    source config.env
fi

bash core/optimize.sh

bash core/watchdog.sh start

if [ "$TSX_WEBUI_ENABLED" != "false" ]; then
    nohup python webui/server.py > logs/webui.log 2>&1 &
fi

if [ "$TSX_TUNNEL_ENABLED" = "true" ]; then
    bash services/network/cloudflared.sh start
fi

while true; do
    sleep 3600
done
EOF
    
    chmod +x "$PREFIX/etc/service/tsxserver/start"
    mkdir -p "$PREFIX/var/service"
    ln -sf "$PREFIX/etc/service/tsxserver" "$PREFIX/var/service/"
    
    echo "[OK] Startup script created"
}

create_service_configs() {
    echo "[3/4] Creating service configurations..."
    
    mkdir -p "$TSX_DIR/config"
    
    cat > "$TSX_DIR/config/services.conf" << EOF
nginx:80
php-fpm:9000
mariadb:3306
redis:6379
minecraft:25565
pocketmine:19135
jellyfin:8096
filebrowser:8081
code-server:8443
netdata:19999
EOF
    
    cat > "$TSX_DIR/config/startup.conf" << EOF
STARTUP_SERVICES="nginx,php-fpm,redis"
ENABLE_WEBUI=true
ENABLE_TUNNEL=false
ENABLE_WATCHDOG=true
EOF
    
    echo "[OK] Service configs created"
}

setup_watchdog_cron() {
    echo "[4/4] Setting up watchdog cron..."
    
    if command -v crond &>/dev/null; then
        pkg install -y cronie termux-services 2>/dev/null || true
        
        mkdir -p "$HOME/.termux/boot"
        
        cat > "$HOME/.termux/boot/10-termux-boot.sh" << 'BOOTSCRIPT'
#!/data/data/com.termux/files/usr/bin/sh
if [ ! -f /data/data/com.termux/files/usr/var/run/services_started ]; then
    touch /data/data/com.termux/files/usr/var/run/services_started
    /system/bin/am start --user 0 -n com.termux/.HomeActivity 2>/dev/null || true
fi
BOOTSCRIPT
        
        chmod +x "$HOME/.termux/boot/10-termux-boot.sh"
    fi
    
    echo "[OK] Watchdog cron configured"
}

setup_alternative_autostart() {
    echo "[Alternative] Setting up alternative auto-start method..."
    
    mkdir -p "$HOME/.termux/boot"
    
    cat > "$HOME/.termux/boot/tsx-init.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
export HOME="/data/data/com.termux/files/home"
export PREFIX="/data/data/com.termux/files/usr"

cd "$HOME/TermuxServerX" || exit

nohup bash core/watchdog.sh start > /dev/null 2>&1 &
nohup python webui/server.py > logs/webui.log 2>&1 &

exit 0
EOF
    
    chmod +x "$HOME/.termux/boot/tsx-init.sh"
    
    echo "[OK] Alternative auto-start configured"
}

remove_autostart() {
    echo "Removing auto-start configuration..."
    
    rm -f "$PREFIX/etc/service/tsxserver/start"
    rmdir "$PREFIX/etc/service/tsxserver" 2>/dev/null
    rm -f "$PREFIX/var/service/tsxserver"
    rm -f "$HOME/.termux/boot/tsx-init.sh"
    
    echo "Auto-start removed!"
}

show_status() {
    echo "=== Auto-Start Status ==="
    
    if [ -f "$PREFIX/etc/service/tsxserver/start" ]; then
        echo "[OK] Termux service installed"
        echo "    Path: $PREFIX/etc/service/tsxserver/start"
    else
        echo "[--] Using alternative method"
    fi
    
    if [ -f "$HOME/.termux/boot/tsx-init.sh" ]; then
        echo "[OK] Boot script installed"
        echo "    Path: $HOME/.termux/boot/tsx-init.sh"
    fi
    
    if pgrep -f "watchdog.sh" > /dev/null; then
        echo "[OK] Watchdog is running"
    else
        echo "[--] Watchdog is not running"
    fi
    
    if pgrep -f "webui/server.py" > /dev/null; then
        echo "[OK] Web UI is running"
    else
        echo "[--] Web UI is not running"
    fi
}

case "${1:-setup}" in
    setup) setup_autostart ;;
    remove) remove_autostart ;;
    status) show_status ;;
    *) echo "Usage: $0 {setup|remove|status}" ;;
esac
