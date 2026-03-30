# TermuxServerX v2.0

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/Android-7.0+-green.svg" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-orange.svg" alt="License">
  <img src="https://img.shields.io/badge/Termux-Supported-purple.svg" alt="Termux">
</p>

<p align="center">
  <strong>Transform ANY Android device into a powerful server in minutes.</strong><br>
  Web hosting, game servers, media streaming, file sync, AI, and more - all from your phone!
</p>

---

## 🚀 Quick Start (30 seconds)

```bash
# 1. Install Termux from F-Droid (NOT Play Store)
# 2. Run these commands:

pkg update && pkg install git curl
git clone https://github.com/MrNova420/TermuxServerX.git
cd TermuxServerX
bash install.sh

# 3. Access Web Dashboard
tsx-web
# Open: http://localhost:8080
# Login: admin / admin
```

---

## ✨ Features

| Category | Services |
|----------|----------|
| 🌐 **Web Server** | Nginx, PHP, Node.js, Python, Caddy |
| 🗄️ **Databases** | MariaDB, PostgreSQL, Redis, SQLite |
| 🎮 **Game Servers** | Minecraft, PocketMine, Terraria |
| 📁 **File Storage** | FileBrowser, Nextcloud, Syncthing, Rclone |
| 💻 **Dev Tools** | code-server (VS Code), Git, Gitea |
| 🎬 **Media** | Jellyfin, Navidrome, Emby |
| 🔐 **Security** | SSH, Cloudflare Tunnel, WireGuard, Tailscale |
| 🤖 **AI (NEW!)** | Ollama (Self-hosted LLMs) |
| 📊 **Analytics** | Umami (Google Analytics alternative) |
| 🔔 **Automation** | n8n, Home Assistant, AdGuard, ntfy |
| 📝 **Productivity** | Ghost Blog, BookStack, Vaultwarden |

**40+ services available** - all optimized for Android/Termux

---

## 📋 Services List

### Web Hosting
| Service | Port | RAM | Description |
|---------|------|-----|-------------|
| Nginx | 8080 | 64MB | Web server |
| PHP-FPM | 9000 | 128MB | PHP interpreter |
| Caddy | 8080 | 32MB | Auto-HTTPS server |
| Node.js | 3000+ | 128MB | JavaScript runtime |
| Python | 5000+ | 128MB | Flask/Django |

### Databases
| Service | Port | RAM | Description |
|---------|------|-----|-------------|
| MariaDB | 3306 | 256MB | MySQL alternative |
| PostgreSQL | 5432 | 256MB | Advanced SQL |
| Redis | 6379 | 64MB | Cache database |
| SQLite | - | 10MB | Lightweight DB |

### Game Servers
| Service | Port | RAM | Players |
|---------|------|-----|---------|
| Minecraft Java | 25565 | 1-4GB | 10-50 |
| PocketMine | 19135 | 1GB | 20 |
| Terraria | 7777 | 1GB | 15 |

### Media
| Service | Port | RAM | Description |
|---------|------|-----|-------------|
| Jellyfin | 8096 | 2GB | Media streaming |
| Navidrome | 4533 | 256MB | Music server |
| Emby | 8096 | 2GB | Media platform |

### AI (NEW!)
| Service | Port | RAM | Description |
|---------|------|-----|-------------|
| Ollama | 11434 | 4GB+ | Local LLMs (Llama, Mistral) |

---

## 🖥️ Commands

```bash
# Main Management
tsx              # Interactive menu
tsx status       # Check all services
tsx start nginx  # Start a service
tsx stop nginx   # Stop a service
tsx logs nginx   # View logs

# Quick Actions
tsx quick-start    # Start essential services
tsx quick-stop      # Stop all services
tsx backup         # Create backup
tsx optimize       # Optimize system
tsx health         # Run health check

# Web Dashboard
tsx-web           # Start web UI (http://localhost:8080)
```

---

## 🔧 Installation Options

### 1. Full Stack (Everything)
```bash
bash install.sh
# Choose option 1
```

### 2. Web Server Only
```bash
bash install.sh
# Choose option 2
```

### 3. Game Servers Only
```bash
bash install.sh
# Choose option 3
```

### 4. Custom Selection
```bash
bash install.sh
# Choose option 6
# Select what you want (e.g., w,d,g,v)
```

---

## 📁 File Locations

```
~/TermuxServerX/     # Main installation
├── config/          # Configuration files
├── core/            # Core engine
├── services/       # Service installers
├── webui/          # Web dashboard
├── data/           # Service data
├── logs/           # Log files
└── backups/         # Backups

~/storage/shared/    # Shared storage
├── www/            # Web files
├── music/          # Music files
├── photos/         # Photo files
└── backups/        # Backup storage
```

---

## 🌐 Public Access

### Cloudflare Tunnel (Free - Recommended)
```bash
bash ~/TermuxServerX/services/network/cloudflared.sh install
bash ~/TermuxServerX/services/network/cloudflared.sh setup
```

### Quick Tunnel (Temporary URL)
```bash
bash ~/TermuxServerX/services/network/cloudflared.sh quick
```

### ngrok
```bash
bash ~/TermuxServerX/services/network/ngrok.sh install
ngrok http 8080
```

---

## 🔒 Security

- **SSH Server**: Pre-configured on port 8022
- **Web UI**: Password-protected dashboard
- **Cloudflare Tunnel**: Zero-trust security (no open ports)
- **Auto-updates**: Security patches

---

## 📊 Monitoring

Built-in monitoring includes:
- Real-time CPU/RAM/Disk usage
- Service status dashboard
- Log viewer
- Process manager
- Resource graphs

---

## 💾 Backup

```bash
# Create backup
tsx backup

# View backups
ls ~/TermuxServerX/backups/full/

# Restore
bash ~/TermuxServerX/scripts/backup.sh restore <backup-file>
```

---

## 🛠️ Hardware Requirements

| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 2 GB | 4+ GB |
| Storage | 8 GB | 32+ GB |
| Android | 7.0 | 11+ |
| CPU | 4 cores | 8+ cores |

---

## 📱 24/7 Server Tips

1. **Disable battery optimization** for Termux
2. **Keep plugged in** (disable charging limits)
3. **Use a cooling fan** (for game servers)
4. **Setup auto-start** (installer does this automatically)

---

## 🆘 Troubleshooting

### Services won't start?
```bash
tsx logs <service-name>
tsx status
```

### Out of memory?
```bash
tsx stop minecraft  # Stop heavy services
tsx optimize        # Optimize memory
```

### Web UI not loading?
```bash
pkill -f server.py
tsx-web
```

### Need help?
- [GitHub Issues](https://github.com/MrNova420/TermuxServerX/issues)
- [GitHub Discussions](https://github.com/MrNova420/TermuxServerX/discussions)

---

## 📈 Top Self-Hosted Alternatives (2026)

Replace expensive cloud services with free self-hosted alternatives:

| Cloud Service | TermuxServerX Alternative | Savings |
|--------------|---------------------------|---------|
| Netflix | Jellyfin | $180/year |
| Spotify | Navidrome | $120/year |
| Google Drive | Nextcloud | $100/year |
| 1Password | Vaultwarden | $48/year |
| Discord | Matrix/Gitea | FREE |
| Slack | Rocket.Chat | $2,500/year |
| GitHub | Gitea | FREE |

**Potential yearly savings: $7,700-$9,200**

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📜 License

MIT License - Free for personal and commercial use.

---

<p align="center">
  Made with ❤️ for the Termux community<br>
  <a href="https://github.com/MrNova420/TermuxServerX">GitHub</a> • 
  <a href="https://github.com/MrNova420/TermuxServerX/issues">Issues</a> • 
  <a href="https://github.com/MrNova420/TermuxServerX/discussions">Discussions</a>
</p>
