# TermuxServerX - Agent Guidelines

> Documentation for AI agents working on TermuxServerX

---

## Project Overview

**TermuxServerX** transforms any Android device into a production-grade server using Termux.
- **Language**: Bash scripts (primary), Python (web UI)
- **Platform**: Android/Termux (no root required)
- **License**: MIT

---

## Quick Commands

```bash
# Installation
bash install.sh                    # Full installer
bash install.sh 2                # Web stack only
bash install.sh 6                # Custom selection

# Management
tsx                               # Interactive menu
tsx status                        # All services
tsx start <service>              # Start service
tsx stop <service>               # Stop service
tsx logs <service>               # View logs

# Web Dashboard
python webui/server.py           # Start web UI
# Access: http://localhost:8080

# System
tsx optimize                     # Optimize system
tsx backup                       # Create backup
tsx health                       # Health check
```

---

## Directory Structure

```
TermuxServerX/
├── install.sh           # Main installer
├── tsx                  # User-friendly manager
├── manage              # CLI manager
├── config.env          # Auto-generated config
├── config/services.conf
│
├── core/               # Core infrastructure
│   ├── detect.sh      # Resource detection
│   ├── optimize.sh    # System optimization
│   ├── auto-start.sh  # Boot startup
│   ├── maintenance.sh # Auto cleanup
│   ├── watchdog.sh    # Service monitor
│   └── utils.sh       # Shared functions
│
├── services/           # Service installers (45+)
│   ├── web/           # Nginx, PHP, Node, Python
│   ├── database/      # MariaDB, PostgreSQL, Redis
│   ├── games/        # Minecraft, PocketMine, Terraria
│   ├── storage/       # FileBrowser, Nextcloud
│   ├── dev/          # code-server, Git
│   ├── media/        # Jellyfin, Navidrome
│   ├── network/      # Cloudflare, ngrok, WireGuard
│   ├── monitoring/   # Netdata, Uptime Kuma
│   ├── ai/           # Ollama (LLMs)
│   └── ...
│
├── webui/              # Flask web dashboard
│   ├── server.py
│   ├── templates/
│   └── static/
│
├── scripts/           # Backup, update scripts
└── templates/         # Config templates
```

---

## Code Style Guidelines

### Bash Scripts

```bash
# Variables: UPPERCASE with TSX_ prefix for project vars
TSX_DIR="$HOME/TermuxServerX"
TSX_WEBUI_PORT="8080"

# Functions: snake_case with descriptive names
install_nginx() {
    log "Installing Nginx..."
    # ...
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Error handling
set -euo pipefail

# Service installers follow pattern:
install_<service>() {
    log "Installing <service>..."
    pkg update -y
    pkg install -y <package>
    # configure...
    log "<service> installed!"
}

case "${1:-install}" in
    install) install_<service> ;;
    start) start_<service> ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
```

### Python (Web UI)

```python
# Standard imports
import os
import sys
import json
from datetime import datetime
from flask import Flask, render_template, jsonify

# Path handling
TSX_DIR = Path.home() / "TermuxServerX"

# Flask pattern
app = Flask(__name__)

@app.route('/api/status')
@login_required
def api_status():
    return jsonify({'services': get_services_status()})
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | UPPERCASE | `TSX_DIR`, `MC_PORT` |
| Functions | snake_case | `install_nginx()` |
| Files | kebab-case | `auto-start.sh` |
| Services | lowercase | `nginx`, `minecraft` |

---

## Service Installer Template

```bash
#!/bin/bash
# TermuxServerX - <Service Name>
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_service() {
    log "Installing <service>..."
    pkg update -y
    pkg install -y <packages>
    # Configure...
    log "<service> installed!"
}

start_service() {
    log "Starting <service>..."
    nohup <command> > "$TSX_DIR/logs/<service>.log" 2>&1 &
}

case "${1:-install}" in
    install) install_service ;;
    start) start_service ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
```

---

## Adding New Services

1. Create file: `services/<category>/<service>.sh`
2. Follow service template above
3. Add to `config/services.conf`: `<service>:<port>:<description>`
4. Update `manage` and `tsx` scripts
5. Update README.md

---

## Testing

```bash
# Test a service installer
bash ~/TermuxServerX/services/<category>/<service>.sh install

# Check syntax
bash -n ~/TermuxServerX/services/<category>/<service>.sh

# View logs
tail -f ~/TermuxServerX/logs/<service>.log
```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Service won't start | Check logs: `tsx logs <service>` |
| Port conflict | Change port in config |
| Out of memory | Stop heavy services, optimize |
| Web UI not loading | `pkill -f server.py && python webui/server.py` |

---

## Git Workflow

```bash
# Make changes
git add -A
git commit -m "Description"
git push origin main

# Update from remote
git pull origin main
```

---

## Key Resources

- Termux: https://termux.com
- Cloudflare Tunnel: https://cloudflare.com
- PaperMC: https://papermc.io
- Jellyfin: https://jellyfin.org

---

## Notes

- All scripts must be executable: `chmod +x <file>.sh`
- Test on real Termux/Android before committing
- Keep configs in `templates/` for reference
- User data goes in `~/storage/shared/`
- App data goes in `~/TermuxServerX/data/`
