#!/bin/bash

detect_all() {
    echo "=== TermuxServerX Resource Detection ==="
    
    detect_cpu
    detect_ram
    detect_storage
    detect_network
    detect_power
    detect_device
    detect_termux
    
    echo ""
    echo "=== Detection Complete ==="
    calculate_tiers
}

detect_cpu() {
    export TSX_CPU_ARCH=$(uname -m)
    export TSX_CPU_CORES=$(nproc)
    
    if [ -f /proc/cpuinfo ]; then
        export TSX_CPU_MODEL=$(grep "Hardware" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        if [ -z "$TSX_CPU_MODEL" ]; then
            TSX_CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        fi
    else
        TSX_CPU_MODEL="Unknown"
    fi
    
    case "$TSX_CPU_ARCH" in
        aarch64|arm64) export TSX_CPU_BITS=64 ;;
        armv7l) export TSX_CPU_BITS=32 ;;
        *) export TSX_CPU_BITS=64 ;;
    esac
    
    echo "[CPU] Model: $TSX_CPU_MODEL"
    echo "[CPU] Architecture: $TSX_CPU_ARCH ($TSX_CPU_BITS-bit)"
    echo "[CPU] Cores: $TSX_CPU_CORES"
}

detect_ram() {
    export TSX_TOTAL_RAM=$(free -m | awk '/^Mem:/ {print $2}')
    export TSX_AVAILABLE_RAM=$(free -m | awk '/^Mem:/ {print $7}')
    export TSX_USED_RAM=$(free -m | awk '/^Mem:/ {print $3}')
    export TSX_SWAP_TOTAL=$(free -m | awk '/^Swap:/ {print $2}')
    
    export TSX_RAM_PERCENT=$((100 - (TSX_AVAILABLE_RAM * 100 / TSX_TOTAL_RAM)))
    
    echo "[RAM] Total: ${TSX_TOTAL_RAM}MB"
    echo "[RAM] Used: ${TSX_USED_RAM}MB"
    echo "[RAM] Available: ${TSX_AVAILABLE_RAM}MB"
    echo "[RAM] Usage: ${TSX_RAM_PERCENT}%"
    echo "[RAM] Swap: ${TSX_SWAP_TOTAL}MB"
}

detect_storage() {
    export TSX_INTERNAL_PATH="$HOME/storage/shared"
    
    if [ -d "/sdcard" ]; then
        export TSX_INTERNAL_PATH="/sdcard"
        export TSX_INTERNAL_SIZE=$(df -m /sdcard | awk 'NR==2 {print $2}')
        export TSX_INTERNAL_AVAIL=$(df -m /sdcard | awk 'NR==2 {print $4}')
    elif [ -d "$HOME/storage/shared" ]; then
        export TSX_INTERNAL_SIZE=$(df -m $HOME/storage/shared | awk 'NR==2 {print $2}')
        export TSX_INTERNAL_AVAIL=$(df -m $HOME/storage/shared | awk 'NR==2 {print $4}')
    else
        export TSX_INTERNAL_PATH="/"
        export TSX_INTERNAL_SIZE=$(df -m / | awk 'NR==2 {print $2}')
        export TSX_INTERNAL_AVAIL=$(df -m / | awk 'NR==2 {print $4}')
    fi
    
    export TSX_INTERNAL_USED=$((TSX_INTERNAL_SIZE - TSX_INTERNAL_AVAIL))
    export TSX_INTERNAL_PERCENT=$((TSX_INTERNAL_USED * 100 / TSX_INTERNAL_SIZE))
    
    export TSX_EXTERNAL_PATH=""
    for dir in /storage/*/; do
        if [ -w "$dir" ] && [ "$dir" != "/storage/emulated/" ]; then
            export TSX_EXTERNAL_PATH="$dir"
            export TSX_EXTERNAL_SIZE=$(df -m "$dir" | awk 'NR==2 {print $2}')
            export TSX_EXTERNAL_AVAIL=$(df -m "$dir" | awk 'NR==2 {print $4}')
            break
        fi
    done
    
    echo "[Storage] Internal: $TSX_INTERNAL_PATH"
    echo "[Storage] Size: ${TSX_INTERNAL_SIZE}MB, Used: ${TSX_INTERNAL_USED}MB (${TSX_INTERNAL_PERCENT}%)"
    
    if [ -n "$TSX_EXTERNAL_PATH" ]; then
        echo "[Storage] External: $TSX_EXTERNAL_PATH (${TSX_EXTERNAL_SIZE}MB)"
    fi
}

detect_network() {
    export TSX_LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
    
    if [ -z "$TSX_LOCAL_IP" ]; then
        export TSX_LOCAL_IP=$(ifconfig 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
    fi
    
    if curl -s --max-time 3 ifconfig.me &>/dev/null; then
        export TSX_PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me)
    else
        export TSX_PUBLIC_IP="Unknown"
    fi
    
    export TSX_CONNECTION_TYPE="Unknown"
    if ip route | grep -q wlan0; then
        export TSX_CONNECTION_TYPE="WiFi"
        export TSX_NETWORK_IFACE="wlan0"
    elif ip route | grep -q eth0; then
        export TSX_CONNECTION_TYPE="Ethernet"
        export TSX_NETWORK_IFACE="eth0"
    fi
    
    export TSX_HAS_INTERNET="yes"
    if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        export TSX_HAS_INTERNET="no"
    fi
    
    echo "[Network] Local IP: $TSX_LOCAL_IP"
    echo "[Network] Public IP: $TSX_PUBLIC_IP"
    echo "[Network] Connection: $TSX_CONNECTION_TYPE"
    echo "[Network] Internet: $TSX_HAS_INTERNET"
}

detect_power() {
    if [ -f "/sys/class/power_supply/battery/capacity" ]; then
        export TSX_BATTERY_LEVEL=$(cat /sys/class/power_supply/battery/capacity)
    elif [ -f "/sys/class/power_supply/battery/uevent" ]; then
        export TSX_BATTERY_LEVEL=$(grep "POWER_SUPPLY_CAPACITY=" /sys/class/power_supply/battery/uevent | cut -d= -f2)
    else
        export TSX_BATTERY_LEVEL="Unknown"
    fi
    
    if [ -f "/sys/class/power_supply/battery/status" ]; then
        export TSX_CHARGING_STATUS=$(cat /sys/class/power_supply/battery/status)
    else
        export TSX_CHARGING_STATUS="Unknown"
    fi
    
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        export TSX_CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        export TSX_CPU_TEMP_C=$((TSX_CPU_TEMP / 1000))
    else
        export TSX_CPU_TEMP_C="Unknown"
    fi
    
    echo "[Power] Battery: ${TSX_BATTERY_LEVEL}%"
    echo "[Power] Status: $TSX_CHARGING_STATUS"
    echo "[Power] CPU Temp: ${TSX_CPU_TEMP_C}°C"
}

detect_device() {
    export TSX_ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    export TSX_DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    export TSX_DEVICE_MANUFACTURER=$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")
    export TSX_DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    export TSX_DEVICE_NAME=$(getprop ro.product.name 2>/dev/null || echo "Unknown")
    export TSX_KERNEL_VERSION=$(uname -r)
    export TSX_KERNEL_ARCH=$(uname -m)
    
    echo "[Device] Model: $TSX_DEVICE_MANUFACTURER $TSX_DEVICE_MODEL"
    echo "[Device] Brand: $TSX_DEVICE_BRAND"
    echo "[Device] Android: $TSX_ANDROID_VERSION"
    echo "[Device] Kernel: $TSX_KERNEL_VERSION"
}

detect_termux() {
    export TSX_TERMUX_VERSION=$(termux-version 2>/dev/null || echo "Unknown")
    export TSX_TERMUX_PREFIX="$PREFIX"
    export TSX_TERMUX_HOME="$HOME"
    
    echo "[Termux] Version: $TSX_TERMUX_VERSION"
    echo "[Termux] Prefix: $TSX_TERMUX_PREFIX"
}

calculate_tiers() {
    if [ "$TSX_TOTAL_RAM" -lt 2048 ]; then
        export TSX_RAM_TIER="minimal"
        export TSX_MAX_GAME_SERVERS=0
        export TSX_DB_RAM="128M"
        export TSX_JAVA_RAM="512M"
        export TSX_WEB_WORKERS=2
        export TSX_RECOMMENDED_SERVICES="nginx,php,sqlite,filebrowser"
    elif [ "$TSX_TOTAL_RAM" -lt 4096 ]; then
        export TSX_RAM_TIER="low"
        export TSX_MAX_GAME_SERVERS=1
        export TSX_DB_RAM="256M"
        export TSX_JAVA_RAM="1536M"
        export TSX_WEB_WORKERS=4
        export TSX_RECOMMENDED_SERVICES="nginx,php,mariadb,redis,nextcloud,minecraft"
    elif [ "$TSX_TOTAL_RAM" -lt 8192 ]; then
        export TSX_RAM_TIER="medium"
        export TSX_MAX_GAME_SERVERS=2
        export TSX_DB_RAM="512M"
        export TSX_JAVA_RAM="2048M"
        export TSX_WEB_WORKERS=8
        export TSX_RECOMMENDED_SERVICES="nginx,php,mariadb,postgresql,redis,nextcloud,minecraft,pocketmine,valheim"
    elif [ "$TSX_TOTAL_RAM" -lt 16384 ]; then
        export TSX_RAM_TIER="high"
        export TSX_MAX_GAME_SERVERS=3
        export TSX_DB_RAM="1024M"
        export TSX_JAVA_RAM="4096M"
        export TSX_WEB_WORKERS=16
        export TSX_RECOMMENDED_SERVICES="nginx,php,mariadb,postgresql,redis,mongodb,nextcloud,syncthing,minecraft,bedrock,valheim,csgo"
    else
        export TSX_RAM_TIER="excellent"
        export TSX_MAX_GAME_SERVERS=5
        export TSX_DB_RAM="2048M"
        export TSX_JAVA_RAM="6144M"
        export TSX_WEB_WORKERS=$(($TSX_CPU_CORES * 2))
        export TSX_RECOMMENDED_SERVICES="all"
    fi
    
    if [ "$TSX_INTERNAL_PERCENT" -gt 90 ]; then
        export TSX_STORAGE_TIER="critical"
    elif [ "$TSX_INTERNAL_PERCENT" -gt 75 ]; then
        export TSX_STORAGE_TIER="low"
    elif [ "$TSX_INTERNAL_PERCENT" -gt 50 ]; then
        export TSX_STORAGE_TIER="medium"
    else
        export TSX_STORAGE_TIER="good"
    fi
    
    echo ""
    echo "=== Resource Tiers ==="
    echo "RAM Tier: $TSX_RAM_TIER (Max Game Servers: $TSX_MAX_GAME_SERVERS)"
    echo "Storage Tier: $TSX_STORAGE_TIER"
    echo "Recommended Services: $TSX_RECOMMENDED_SERVICES"
}

get_json() {
    cat << EOF
{
    "cpu": {
        "model": "$TSX_CPU_MODEL",
        "arch": "$TSX_CPU_ARCH",
        "bits": $TSX_CPU_BITS,
        "cores": $TSX_CPU_CORES
    },
    "ram": {
        "total": $TSX_TOTAL_RAM,
        "used": $TSX_USED_RAM,
        "available": $TSX_AVAILABLE_RAM,
        "percent": $TSX_RAM_PERCENT,
        "tier": "$TSX_RAM_TIER"
    },
    "storage": {
        "internal": {
            "path": "$TSX_INTERNAL_PATH",
            "total": $TSX_INTERNAL_SIZE,
            "used": $TSX_INTERNAL_USED,
            "available": $TSX_INTERNAL_AVAIL,
            "percent": $TSX_INTERNAL_PERCENT
        },
        "external": {
            "path": "$TSX_EXTERNAL_PATH",
            "total": $TSX_EXTERNAL_SIZE,
            "available": $TSX_EXTERNAL_AVAIL
        },
        "tier": "$TSX_STORAGE_TIER"
    },
    "network": {
        "local_ip": "$TSX_LOCAL_IP",
        "public_ip": "$TSX_PUBLIC_IP",
        "connection": "$TSX_CONNECTION_TYPE",
        "has_internet": "$TSX_HAS_INTERNET"
    },
    "power": {
        "battery": $TSX_BATTERY_LEVEL,
        "status": "$TSX_CHARGING_STATUS",
        "cpu_temp": $TSX_CPU_TEMP_C
    },
    "device": {
        "model": "$TSX_DEVICE_MODEL",
        "manufacturer": "$TSX_DEVICE_MANUFACTURER",
        "android": "$TSX_ANDROID_VERSION",
        "kernel": "$TSX_KERNEL_VERSION"
    },
    "termux": {
        "version": "$TSX_TERMUX_VERSION"
    }
}
EOF
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    detect_all
fi
