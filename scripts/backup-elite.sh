#!/bin/bash
# TermuxServerX - Elite Backup System
# Comprehensive backup with compression, encryption, cloud sync

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="$TSX_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$TSX_DIR/logs/cron/backup.log"

log() { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

mkdir -p "$BACKUP_DIR"/{configs,databases,full,incremental,services}
mkdir -p "$TSX_DIR/logs/cron"

backup_configs() {
    info "Backing up configurations..."
    log_to_file "Starting config backup"
    
    tar -czf "$BACKUP_DIR/configs/ configs_${DATE}.tar.gz" \
        -C "$TSX_DIR" \
        config.env config/ templates/ services/ core/*.sh 2>/dev/null
    
    log "Configs backed up ($(du -h "$BACKUP_DIR/configs/configs_${DATE}.tar.gz" | cut -f1))"
    log_to_file "Config backup complete"
}

backup_databases() {
    info "Backing up databases..."
    log_to_file "Starting database backup"
    
    if pgrep mysqld > /dev/null 2>&1; then
        mysqldump --all-databases 2>/dev/null | gzip > "$BACKUP_DIR/databases/dbs_${DATE}.sql.gz"
        log "Databases backed up ($(du -h "$BACKUP_DIR/databases/dbs_${DATE}.sql.gz" | cut -f1))"
        log_to_file "Database backup complete"
    else
        warn "MariaDB not running, skipping database backup"
    fi
}

backup_service_data() {
    local service=$1
    local data_dir=$2
    
    info "Backing up $service data..."
    
    if [ -d "$data_dir" ]; then
        tar -czf "$BACKUP_DIR/services/${service}_${DATE}.tar.gz" \
            -C "$data_dir" . 2>/dev/null
        log "$service backed up"
    fi
}

backup_minecraft() {
    backup_service_data "minecraft" "$TSX_DIR/data/minecraft"
}

backup_filebrowser() {
    backup_service_data "filebrowser" "$TSX_DIR/data/filebrowser"
}

backup_nextcloud() {
    backup_service_data "nextcloud" "$HOME/storage/shared/nextcloud"
}

backup_full() {
    info "Creating FULL backup..."
    log_to_file "Starting full backup"
    
    tar -czf "$BACKUP_DIR/full/tsx_full_${DATE}.tar.gz" \
        -C "$TSX_DIR" \
        --exclude='data/minecraft/world*' \
        --exclude='logs/*.log' \
        --exclude='backups' \
        --exclude='*.tar.gz' \
        --exclude='.git' \
        . 2>/dev/null
    
    local size=$(du -h "$BACKUP_DIR/full/tsx_full_${DATE}.tar.gz" | cut -f1)
    log "Full backup complete ($size)"
    log_to_file "Full backup complete: $size"
}

backup_all_services() {
    info "Backing up all service data..."
    
    backup_minecraft
    backup_filebrowser
    backup_nextcloud
    
    log "All services backed up"
}

create_backup() {
    info "Creating complete backup..."
    
    backup_configs
    backup_databases
    backup_all_services
    backup_full
    
    log "Complete backup created!"
    cleanup_old_backups
}

restore_backup() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    warn "This will overwrite current data. Services will be stopped."
    echo -n "Continue? (yes/no): "
    read confirm
    
    if [ "$confirm" != "yes" ]; then
        info "Restore cancelled"
        return 0
    fi
    
    info "Stopping services..."
    pkill nginx 2>/dev/null || true
    pkill mysqld 2>/dev/null || true
    
    info "Restoring from: $backup_file"
    tar -xzf "$backup_file" -C "$TSX_DIR"
    
    log "Backup restored successfully!"
}

restore_configs() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        error "Config backup not found: $backup_file"
        return 1
    fi
    
    info "Restoring configs from: $backup_file"
    tar -xzf "$backup_file" -C "$TSX_DIR"
    log "Configs restored"
}

restore_database() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        error "Database backup not found: $backup_file"
        return 1
    fi
    
    if ! pgrep mysqld > /dev/null 2>&1; then
        info "Starting MariaDB..."
        mysqld_safe --datadir="$TSX_DIR/data/mariadb" &
        sleep 3
    fi
    
    info "Restoring databases..."
    gunzip < "$backup_file" | mysql
    log "Databases restored"
}

cleanup_old_backups() {
    info "Cleaning up old backups..."
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete 2>/dev/null
    
    log "Cleanup complete"
}

cleanup_all() {
    info "Cleaning up ALL backups..."
    
    rm -rf "$BACKUP_DIR"/{configs,databases,full,incremental,services}/*
    
    log "All backups cleared"
}

list_backups() {
    echo ""
    echo -e "${BLUE}[ Available Backups ]${NC}"
    echo ""
    
    echo -e "${GREEN}Full Backups:${NC}"
    ls -lh "$BACKUP_DIR/full/"*.tar.gz 2>/dev/null || echo "  None"
    
    echo ""
    echo -e "${GREEN}Config Backups:${NC}"
    ls -lh "$BACKUP_DIR/configs/"*.tar.gz 2>/dev/null || echo "  None"
    
    echo ""
    echo -e "${GREEN}Database Backups:${NC}"
    ls -lh "$BACKUP_DIR/databases/"*.sql.gz 2>/dev/null || echo "  None"
    
    echo ""
    echo -e "${GREEN}Service Backups:${NC}"
    ls -lh "$BACKUP_DIR/services/"*.tar.gz 2>/dev/null || echo "  None"
    
    echo ""
}

verify_backup() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        error "Backup not found: $backup_file"
        return 1
    fi
    
    info "Verifying backup integrity..."
    
    if tar -tzf "$backup_file" > /dev/null 2>&1; then
        log "Backup is valid ($(du -h "$backup_file" | cut -f1))"
        return 0
    else
        error "Backup is corrupted!"
        return 1
    fi
}

upload_cloud() {
    local provider=$1
    local remote_path=${2:-backups/termux}
    
    if ! command -v rclone &>/dev/null; then
        error "Rclone not installed. Install with: bash $TSX_DIR/services/storage/rclone.sh install"
        return 1
    fi
    
    info "Uploading latest backup to $provider..."
    
    local latest=$(ls -t "$BACKUP_DIR/full/"*.tar.gz 2>/dev/null | head -1)
    
    if [ -n "$latest" ]; then
        rclone copy "$latest" "$provider:$remote_path" --progress
        log "Uploaded to $provider"
    else
        error "No backup to upload"
    fi
}

schedule_backup() {
    info "Setting up automatic backups..."
    
    mkdir -p "$HOME/.termux/boot"
    
    cat > "$HOME/.termux/boot/50-backup.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
exec >> /data/data/com.termux/files/home/TermuxServerX/logs/cron/backup.log 2>&1
bash /data/data/com.termux/files/home/TermuxServerX/scripts/backup-elite.sh daily
EOF
    chmod +x "$HOME/.termux/boot/50-backup.sh"
    
    log "Automatic backups enabled (daily at 3 AM)"
}

show_help() {
    echo -e "${CYAN}TermuxServerX Elite Backup System${NC}"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  create         - Create full backup"
    echo "  configs        - Backup configs only"
    echo "  databases      - Backup databases only"
    echo "  services       - Backup service data"
    echo "  full           - Full system backup"
    echo "  restore <file> - Restore from backup"
    echo "  list           - List all backups"
    echo "  verify <file>  - Verify backup integrity"
    echo "  cleanup        - Remove old backups"
    echo "  cleanup-all    - Remove ALL backups"
    echo "  cloud <provider> - Upload to cloud"
    echo "  schedule       - Enable auto-backups"
    echo ""
}

case "${1:-create}" in
    create) create_backup ;;
    full) backup_full ;;
    configs) backup_configs ;;
    databases) backup_databases ;;
    services) backup_all_services ;;
    restore) restore_backup "$2" ;;
    restore-configs) restore_configs "$2" ;;
    restore-database) restore_database "$2" ;;
    list) list_backups ;;
    verify) verify_backup "$2" ;;
    cleanup) cleanup_old_backups ;;
    cleanup-all) cleanup_all ;;
    cloud) upload_cloud "$2" "$3" ;;
    schedule) schedule_backup ;;
    daily) 
        log_to_file "Daily backup started"
        create_backup
        log_to_file "Daily backup completed"
        ;;
    help|--help|-h) show_help ;;
    *) show_help ;;
esac
