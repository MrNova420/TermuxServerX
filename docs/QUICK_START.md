# TermuxServerX - Quick Start Guide

## What is TermuxServerX?
Turn your Android phone into a powerful server with 40+ services including game servers, web hosting, databases, media servers, and more.

## Installation

```bash
cd ~
git clone https://github.com/MrNova420/TermuxServerX.git
cd TermuxServerX
bash install.sh
```

## Main Menu
```bash
~/TermuxServerX/tsx
```

## Quick Service Install

### Game Servers (One Command)
```bash
# Minecraft
~/TermuxServerX/scripts/stacks/install-stack.sh minecraft

# All Game Servers
~/TermuxServerX/scripts/stacks/install-stack.sh games
```

### Web Stack
```bash
~/TermuxServerX/scripts/stacks/install-stack.sh lemp
```

### Media Server
```bash
~/TermuxServerX/scripts/stacks/install-stack.sh media
```

## Service Management

```bash
# Start a service
~/TermuxServerX/manage start minecraft

# Stop a service  
~/TermuxServerX/manage stop minecraft

# Check status
~/TermuxServerX/manage status

# View all services
~/TermuxServerX/manage-all
```

## Web Dashboard
```bash
cd ~/TermuxServerX/webui
python server.py
# Access at http://localhost:5000
```

## Game Server Connection

**Players join like any normal server:**
1. Open game → Multiplayer
2. Enter: `YOUR_IP:PORT`
3. Connect!

## Common Ports

| Service | Port |
|---------|------|
| Minecraft | 25565 |
| Web Server | 80 |
| HTTPS | 443 |
| Jellyfin | 8096 |
| Valheim | 2456 |
| PostgreSQL | 5432 |
| Redis | 6379 |
| Gitea | 3000 |

## Auto-Start on Boot

```bash
~/TermuxServerX/core/auto-start.sh enable
```

## Auto Maintenance

```bash
# Run cleanup
~/TermuxServerX/core/maintenance.sh

# Enable watchdog monitoring
bash ~/TermuxServerX/core/watchdog/watchdog-daemon.sh daemon
```

## Backup

```bash
# Simple backup
~/TermuxServerX/scripts/backup.sh

# Elite backup with compression
~/TermuxServerX/scripts/backup-elite.sh
```

## Troubleshooting

```bash
# Check if service is running
pgrep -f servicename

# View logs
tail -f ~/TermuxServerX/logs/service.log

# Restart service
~/TermuxServerX/manage restart servicename
```
