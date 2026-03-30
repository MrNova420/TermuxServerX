#!/bin/bash

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }
log_success() { echo -e "${CYAN}[OK]${NC} $1"; }

is_installed() {
    command -v "$1" &>/dev/null
}

is_service_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

get_service_pid() {
    pgrep -f "$1" | head -1
}

get_port_status() {
    local port=$1
    nc -z localhost "$port" 2>/dev/null && echo "open" || echo "closed"
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
}

get_memory_usage() {
    free -m | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}'
}

get_disk_usage() {
    df -h "$TSX_DIR" | awk 'NR==2 {print $5}' | cut -d'%' -f1
}

get_uptime_formatted() {
    uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | sed 's/,//'
}

get_service_status() {
    local service=$1
    
    if is_service_running "$service"; then
        echo -e "${GREEN}running${NC}"
    else
        echo -e "${RED}stopped${NC}"
    fi
}

get_all_services() {
    local services=()
    
    for dir in "$TSX_DIR/services"/*; do
        if [ -d "$dir" ]; then
            services+=($(basename "$dir"))
        fi
    done
    
    echo "${services[@]}"
}

download_file() {
    local url=$1
    local dest=$2
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if curl -fsSL -o "$dest" "$url"; then
            return 0
        fi
        retry=$((retry + 1))
        sleep 2
    done
    
    return 1
}

extract_archive() {
    local archive=$1
    local dest=$2
    
    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$dest"
            ;;
        *.tar)
            tar -xf "$archive" -C "$dest"
            ;;
        *.zip)
            unzip -q "$archive" -d "$dest"
            ;;
        *.tar.xz)
            tar -xJf "$archive" -C "$dest"
            ;;
        *)
            return 1
            ;;
    esac
}

create_directory() {
    local dir=$1
    local owner=${2:-$USER}
    
    mkdir -p "$dir"
    chmod 755 "$dir"
}

create_user() {
    local username=$1
    local password=$2
    
    echo "$username:$(openssl passwd -1 "$password")" >> "$TSX_DIR/config/users.txt"
    log_success "User created: $username"
}

delete_user() {
    local username=$1
    
    sed -i "/^$username:/d" "$TSX_DIR/config/users.txt"
    log_success "User deleted: $username"
}

generate_password() {
    local length=${1:-16}
    openssl rand -base64 "$length" | tr -d '/+=' | head -c "$length"
}

get_external_ip() {
    curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "Unknown"
}

get_local_ip() {
    ip route get 1 2>/dev/null | awk '{print $7}' | head -1
}

check_internet() {
    ping -c 1 -W 3 8.8.8.8 &>/dev/null
}

ensure_directory_structure() {
    mkdir -p "$TSX_DIR"/{core,services,webui,scripts,templates,data,logs,backups,config}
    mkdir -p "$TSX_DIR/services"/{web,database,storage,games,dev,media,productivity,network,monitoring}
    mkdir -p "$TSX_DIR/backups"/{configs,databases,full}
    mkdir -p "$TSX_DIR/logs"/{nginx,php,mariadb,minecraft,webui}
    
    chmod -R 755 "$TSX_DIR"
}

backup_config() {
    local backup_name="config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$TSX_DIR/backups/configs/$backup_name"
    
    tar -czf "$backup_path" -C "$TSX_DIR" config/ 2>/dev/null
    log_success "Config backed up to: $backup_path"
}

restore_config() {
    local backup_file=$1
    
    if [ -f "$backup_file" ]; then
        tar -xzf "$backup_file" -C "$TSX_DIR"
        log_success "Config restored from: $backup_file"
    else
        log_error "Backup file not found: $backup_file"
    fi
}

send_notification() {
    local title=$1
    local message=$2
    
    if [ -f "$TSX_DIR/config/pushover_token" ]; then
        curl -s -F "token=$(cat $TSX_DIR/config/pushover_token)" \
             -F "user=$(cat $TSX_DIR/config/pushover_user)" \
             -F "title=$title" \
             -F "message=$message" \
             https://api.pushover.net/1/messages.json &>/dev/null || true
    fi
}

cleanup_old_logs() {
    local days=${1:-7}
    
    find "$TSX_DIR/logs" -name "*.log" -mtime +$days -delete 2>/dev/null
    find "$TSX_DIR/logs" -name "*.log" -size +100M -exec truncate -s 50M {} \; 2>/dev/null || true
    
    log_info "Cleaned up logs older than $days days"
}

format_bytes() {
    local bytes=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    while [ $bytes -ge 1024 ] && [ $unit -lt 4 ]; do
        bytes=$((bytes / 1024))
        unit=$((unit + 1))
    done
    
    echo "$bytes${units[$unit]}"
}

check_dependencies() {
    local missing=()
    local deps=("bash" "curl" "wget" "git" "tar" "gzip" "python")
    
    for dep in "${deps[@]}"; do
        if ! is_installed "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing[*]}"
        echo "Run: pkg install ${missing[*]}"
        return 1
    fi
    
    return 0
}

source_if_exists() {
    local file=$1
    if [ -f "$file" ]; then
        source "$file"
    fi
}

export -f log_info log_warn log_error log_debug log_success
export -f is_installed is_service_running get_service_pid
export -f get_port_status get_cpu_usage get_memory_usage get_disk_usage
export -f get_uptime_formatted get_service_status get_all_services
export -f download_file extract_archive create_directory
export -f generate_password get_external_ip get_local_ip check_internet
export -f ensure_directory_structure backup_config restore_config
export -f cleanup_old_logs format_bytes check_dependencies source_if_exists
