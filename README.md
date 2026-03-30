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

## Quick Start (30 seconds)

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

## Game Servers - Ready to Play!

**Users just join like ANY normal server:**
1. Open game → Multiplayer → Enter IP:Port → Connect!

| Game | Port | Join Command |
|------|------|--------------|
| **Minecraft Java** | 25565 | Multiplayer → Direct → `your-ip:25565` |
| **Minecraft Bedrock** | 19132 | Play → Servers → `your-ip:19132` |
| **Valheim** | 2456 | Steam → Join → `your-ip:2456` |
| **Terraria** | 7777 | Multiplayer → Join IP → `your-ip:7777` |
| **Palworld** | 8211 | Steam → Join → `your-ip:8211` |
| **Rust** | 28015 | Connect → `your-ip:28015` |
| **CS:GO / CS2** | 27015 | Console → `connect your-ip` |
| **7 Days to Die** | 26900 | F1 → `connect your-ip:26900` |
| **DayZ** | 2302 | Community → Favorites → `your-ip:2302` |
| **ARK** | 7778 | Steam → Join → `your-ip:7778` |
| **Garry's Mod** | 27015 | Multiplayer → `your-ip:27015` |
| **TF2 / L4D2** | 27015 | Console → `connect your-ip` |
| **Conan Exiles** | 7777 | Join → `your-ip:7777` |
| **Satisfactory** | 7777 | Host → `your-ip:7777` |
| **StarMade** | 4242 | Connect → `your-ip:4242` |
| **Eco** | 3000 | Join → `your-ip:3000` |

---

## All Services (40+)

| Category | Services |
|----------|----------|
| **Game Servers** | Minecraft, Valheim, Terraria, Palworld, Rust, CS:GO/CS2, 7DTD, DayZ, ARK, GMod, TF2, L4D2, Conan, Satisfactory, StarMade, Eco |
| 🌐 **Web Server** | Nginx, PHP, Node.js, Python, Caddy |
| 🗄️ **Databases** | MariaDB, PostgreSQL, Redis, SQLite, MongoDB |
| 🎬 **Media** | Jellyfin, Navidrome, Emby, Immich |
| 📁 **Storage** | Nextcloud, FileBrowser, Syncthing |
| 💻 **Dev Tools** | code-server (VS Code), Git, Gitea |
| 🔐 **Security** | Vaultwarden, AdGuard, SSH, Cloudflare Tunnel, WireGuard |
| 🤖 **AI** | Ollama (Local LLMs) |
| 🔔 **Automation** | n8n, Home Assistant, AdGuard |
| 📊 **Monitoring** | Netdata, Grafana, Uptime Kuma, Umami |
| 📝 **Productivity** | Ghost Blog, BookStack, Outline |

---

## Quick Install Game Servers

```bash
# Install all game servers
~/TermuxServerX/scripts/stacks/install-stack.sh games

# Install specific game server
~/TermuxServerX/install.sh --service minecraft

# View all games with connection info
~/TermuxServerX/scripts/game-servers.sh
```

---

## Commands

```bash
# Main Management
tsx              # Interactive menu
tsx status       # Check all services
tsx start nginx  # Start a service
tsx stop nginx   # Stop a service

# Game Servers
~/TermuxServerX/scripts/game-servers.sh   # All games menu
~/TermuxServerX/templates/minecraft/minecraft-manager.sh info   # Show connection info

# Quick Actions
tsx backup         # Create backup
tsx optimize       # Optimize system
tsx health         # Run health check

# Web Dashboard
tsx-web           # Start web UI
```

---

## How to Share Your Server

**For Friends to Join:**

```
1. Give them your public IP:Port
2. Give them the server password (if set)
3. They connect like any normal server!

Example: 123.45.67.89:25565
         password: mysecretpw
```

**Finding Your Public IP:**
```bash
curl ifconfig.me
```

**Private/Friends-Only Server:**
```bash
~/TermuxServerX/scripts/access-control.sh
# Set to "Friends" mode and add their IPs
```

---

## Installation Options

### 1. Full Stack (Everything)
```bash
bash install.sh
# Choose option 1
```

### 2. Game Servers Only
```bash
bash install.sh
# Choose option 3
```

### 3. Custom Selection
```bash
bash install.sh
# Choose option 6
# Select what you want (e.g., games, web, media)
```

### 4. Quick Stacks
```bash
# Web stack
~/TermuxServerX/scripts/stacks/install-stack.sh lemp

# Media stack  
~/TermuxServerX/scripts/stacks/install-stack.sh media

# Dev stack
~/TermuxServerX/scripts/stacks/install-stack.sh dev

# Game servers
~/TermuxServerX/scripts/stacks/install-stack.sh games
```

---

## Game Server Management

```bash
# Start a game server
~/TermuxServerX/manage start minecraft
~/TermuxServerX/manage start valheim
~/TermuxServerX/manage start terraria

# View connection info (IP, Port, Password)
~/TermuxServerX/templates/minecraft/minecraft-manager.sh info
~/TermuxServerX/templates/valheim/valheim-manager.sh info

# Backup game saves
~/TermuxServerX/templates/minecraft/minecraft-manager.sh backup

# Manage mods
~/TermuxServerX/templates/game/mod-manager.sh
```

---

## File Locations

```
~/TermuxServerX/     # Main installation
├── config/          # Configuration files
├── core/            # Core engine (auto-start, watchdog, etc.)
├── services/       # Service installers
├── templates/      # Game server configs & managers
├── webui/          # Web dashboard
├── scripts/        # Backup, stacks, access control
├── data/           # Service data (games, databases, etc.)
├── logs/           # Log files
└── backups/        # Backups

# Game saves locations:
~/TermuxServerX/data/minecraft/     # Minecraft worlds
~/TermuxServerX/data/valheim/        # Valheim worlds
~/TermuxServerX/data/terraria/       # Terraria worlds
~/TermuxServerX/backups/games/       # Game backups
```

---

## Game Server Mods Support

```bash
# Install mods for any game
~/TermuxServerX/templates/game/mod-manager.sh

# Minecraft modpack manager
~/TermuxServerX/templates/minecraft/modpack-manager.sh create
```

---

## Public Access (No Port Forwarding)

### Cloudflare Tunnel (Recommended)
```bash
bash ~/TermuxServerX/services/network/cloudflared.sh install
bash ~/TermuxServerX/services/network/cloudflared.sh setup
```

### Quick Tunnel (Temporary URL)
```bash
bash ~/TermuxServerX/services/network/cloudflared.sh quick
```

### Tailscale (VPN)
```bash
bash ~/TermuxServerX/services/network/tailscale.sh install
```

---

## Security

- **Server Passwords**: Set strong passwords for each game
- **Private Servers**: Use access-control.sh for IP whitelisting
- **SSH**: Pre-configured on port 8022
- **Web UI**: Password-protected dashboard
- **Cloudflare Tunnel**: Zero-trust security (no open ports)

---

## Auto Features

```bash
# Enable auto-start on boot
~/TermuxServerX/core/auto-start.sh enable

# Enable watchdog (auto-restart crashed services)
bash ~/TermuxServerX/core/watchdog/watchdog-daemon.sh daemon

# Run auto maintenance
~/TermuxServerX/core/maintenance.sh
```

---

## Monitoring

Built-in monitoring includes:
- Real-time CPU/RAM/Disk usage
- Service status dashboard
- Game server online/offline status
- Log viewer
- Process manager

---

## Backup

```bash
# Create backup
tsx backup

# Elite backup with compression
~/TermuxServerX/scripts/backup-elite.sh

# Backup specific game
~/TermuxServerX/templates/minecraft/minecraft-manager.sh backup
~/TermuxServerX/templates/valheim/valheim-manager.sh backup
```

---

## Hardware Requirements

| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 2 GB | 4+ GB |
| Storage | 8 GB | 32+ GB |
| Android | 7.0 | 11+ |
| CPU | 4 cores | 8+ cores |

---

## Troubleshooting

### Can't connect to game server?
```bash
# 1. Check if server is running
screen -list

# 2. Get your public IP
curl ifconfig.me

# 3. Check logs
tail ~/TermuxServerX/logs/minecraft.log
```

### Server keeps crashing?
```bash
# Enable watchdog
bash ~/TermuxServerX/core/watchdog/watchdog-daemon.sh daemon
```

### Out of memory?
```bash
tsx stop minecraft  # Stop heavy services
tsx optimize        # Optimize memory
```

---

## Top Self-Hosted Alternatives (2026)

| Cloud Service | TermuxServerX Alternative | Savings |
|--------------|---------------------------|---------|
| Minecraft Realms ($7/mo) | Self-hosted | $84/year |
| Nitrado | Self-hosted | $120/year |
| Netflix | Jellyfin | $180/year |
| Spotify | Navidrome | $120/year |
| Google Drive | Nextcloud | $100/year |
| 1Password | Vaultwarden | $48/year |

---

## Documentation

- [Quick Start](docs/QUICK_START.md)
- [Game Servers Guide](docs/GAME_SERVERS.md)
- [All Services List](docs/SERVICES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

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
  <a href="https://github.com/MrNova420/TermuxServerX/issues">Issues</a>
</p>
