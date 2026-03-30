# TermuxServerX - Complete Project Documentation

**Version 1.0 | March 2026**

---

## Table of Contents
1. [Overview](#1-overview)
2. [Vision & Goals](#2-vision--goals)
3. [Architecture](#3-architecture)
4. [Installation](#4-installation)
5. [Web UI Management](#5-web-ui-management)
6. [Service Modules](#6-service-modules)
7. [Security](#7-security)
8. [Backup & Recovery](#8-backup--recovery)
9. [Hardware Requirements](#9-hardware-requirements)
10. [Command Reference](#10-command-reference)
11. [File Structure](#11-file-structure)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Overview

**TermuxServerX** transforms ANY Android device into a production-grade, self-hosted hosting platform with zero configuration. Run one command, access everything via web UI. Free forever, runs on anything from a 2016 phone to flagship.

### Key Features
- One-command auto-setup
- Resource-aware optimization
- 40+ services available
- Full web UI management
- Cloudflare Tunnel for public access (no port forwarding)
- Auto-start on boot
- Encrypted backups
- Future-proof modular design

---

## 2. Vision & Goals

### 2.1 Primary Objectives
| Objective | Description |
|-----------|-------------|
| **Zero Config** | Plug in, run script, fully operational |
| **Universal** | Works on any Android 7.0+ device |
| **Modular** | Install what you need, skip what you don't |
| **Production-Ready** | SSL, security, monitoring out-of-box |
| **Self-Hosted** | No vendor lock-in, your data stays yours |
| **Web-Manageable** | Full GUI from any browser |

### 2.2 What Makes It "Production Grade"
- Auto SSL certificates (Let's Encrypt)
- Cloudflare Tunnel (zero-trust security)
- Real-time monitoring dashboards
- Automated encrypted backups
- Service watchdog (auto-restart)
- Resource scaling based on device
- Multi-user access control

---

## 3. Architecture

### 3.1 System Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    Android Device                           │
├─────────────────────────────────────────────────────────────┤
│  Termux App                                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  TermuxServerX                                           ││
│  │  ┌──────────────┬──────────────┬────────────────────────┐││
│  │  │  Auto-Detect │  Resource    │  Service              │││
│  │  │  Module      │  Optimizer   │  Installer            │││
│  │  └──────────────┴──────────────┴────────────────────────┘││
│  │                        │                                 ││
│  │              ┌─────────▼─────────┐                      ││
│  │              │   Service Hub     │                      ││
│  │              │                   │                      ││
│  │              │ • Nginx Proxy     │                      ││
│  │              │ • PHP-FPM         │                      ││
│  │              │ • Databases       │                      ││
│  │              │ • Game Servers    │                      ││
│  │              │ • Cloud Storage  │                      ││
│  │              │ • Dev Tools      │                      ││
│  │              │ • Media Servers  │                      ││
│  │              └───────────────────┘                      ││
│  │                        │                                 ││
│  │              ┌─────────▼─────────┐                      ││
│  │              │   Web UI         │                      ││
│  │              │   Dashboard      │                      ││
│  │              │   Port: 8080    │                      ││
│  │              └───────────────────┘                      ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌──────────────────────────────────────────────────────────┐│
│  │  Cloudflare Tunnel (cloud.example.com)                  ││
│  │  └── Public access without port forwarding              ││
│  └──────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Resource Detection
```bash
Auto-Detect Outputs:
├── CPU: Architecture, Cores, Model
├── RAM: Total, Available, Swap
├── Storage: Internal, External paths
├── Network: Local IP, Connection type
├── Power: Battery %, Charging state
└── Device: Model, Android version
```

---

## 4. Installation

### 4.1 Prerequisites
- Android 7.0 or higher
- Termux app (F-Droid recommended)
- Internet connection
- Minimum 2GB RAM, 8GB storage

### 4.2 One-Command Install
```bash
curl -fsSL https://TermuxServerX/install | bash
```

### 4.3 Installation Flow
```
1. Welcome + System Check
2. Auto-detect resources
3. Install core packages
4. Clone repo
5. Generate config.env
6. Install Web UI dependencies
7. Service selection menu
8. Install selected services
9. Setup Cloudflare Tunnel
10. Configure auto-start
11. Display access URLs
```

---

## 5. Web UI Management

### 5.1 Dashboard Features
| Feature | Description |
|---------|-------------|
| Service Toggle | One-click start/stop |
| Real-time Logs | Live streaming per service |
| Resource Monitor | Live CPU/RAM/Disk graphs |
| File Manager | Browser file editing |
| Config Editor | Syntax-highlighted editor |
| Web Terminal | Full bash in browser |
| Backup Manager | Schedule/restore backups |
| User Manager | Multi-user access |

### 5.2 API Endpoints
```
GET  /api/status           - All services status
POST /api/start/<service>  - Start service
POST /api/stop/<service>   - Stop service
GET  /api/logs/<service>   - Get service logs
GET  /api/resources       - System resources
POST /api/backup/create   - Create backup
```

---

## 6. Service Modules

### 6.1 Web Hosting Stack
| Service | Ports | Auto-Config |
|---------|-------|-------------|
| Nginx | 80, 443, 8080 | Yes |
| PHP-FPM | Socket | Yes |
| Node.js | Custom | Yes |
| Python | Custom | Yes |
| Caddy | 80, 443 | Yes |

### 6.2 Database Stack
| Database | Port | RAM Usage |
|----------|------|-----------|
| MariaDB | 3306 | 512MB-4GB |
| PostgreSQL | 5432 | 256MB-2GB |
| Redis | 6379 | 64MB-1GB |
| SQLite | N/A | Minimal |

### 6.3 Cloud Storage & Sync
| Service | Description |
|---------|-------------|
| Nextcloud | Full cloud suite |
| Syncthing | P2P file sync |
| FileBrowser | Web file manager |
| Rclone | Cloud sync (30+ providers) |

### 6.4 Game Servers
| Game | Port | RAM | Players |
|------|------|-----|---------|
| Minecraft Java | 25565 | 2-4GB | 10-50 |
| Minecraft Bedrock | 19132 | 1-2GB | 10-30 |
| PocketMine-MP | 19135 | 1GB | 20 |
| Valheim | 2456-2458 | 4GB | 10 |
| CS2/CS:GO | 27015 | 2GB | 10 |
| Terraria | 7777 | 1GB | 15 |
| Rust | 28015 | 4GB | 20 |
| Ark | 27015 | 8GB | 20 |

### 6.5 Developer Tools
| Tool | Description |
|------|-------------|
| code-server | VS Code in browser |
| Git | Version control |
| Docker | Containers |

### 6.6 Media Servers
| Service | Port | RAM |
|---------|------|-----|
| Jellyfin | 8096 | 2GB |
| Plex | 32400 | 2GB |
| Emby | 8096 | 2GB |
| Owncast | 8080 | 2GB |

### 6.7 Productivity Tools
| Service | Description |
|---------|-------------|
| Gitea | Self-hosted GitHub |
| Vaultwarden | Password manager |
| Outline | Team wiki |
| BookStack | Documentation |

### 6.8 Networking Tools
| Service | Cost | Protocol |
|---------|------|----------|
| Cloudflare Tunnel | FREE | Argo |
| ngrok | Free tier | Proprietary |
| WireGuard | FREE | VPN |
| Tailscale | Free tier | Mesh VPN |

### 6.9 Monitoring Tools
| Tool | Port | Description |
|------|------|-------------|
| Netdata | 19999 | Real-time monitoring |
| Grafana | 3030 | Metrics visualization |
| Uptime Kuma | 3001 | Uptime monitoring |

---

## 7. Security

### 7.1 Security Stack
| Layer | Components |
|-------|------------|
| Network | Firewall, Fail2ban, Cloudflare |
| Auth | bcrypt, Sessions, 2FA (optional) |
| Data | Encrypted backups, SSL/TLS |
| Updates | Auto-security patches |

### 7.2 Auto-Security Features
- SSH hardening
- Firewall rules auto-generated
- SSL cert auto-renew
- Fail2ban brute force protection
- Encrypted backups (GPG)

---

## 8. Backup & Recovery

### 8.1 Backup Targets
| Target | Protocol | Cost |
|--------|----------|------|
| Local SD Card | File path | Free |
| USB OTG | /storage/* | Free |
| Google Drive | rclone | 15GB free |
| OneDrive | rclone | 5GB free |
| Dropbox | rclone | 2GB free |
| S3-compatible | rclone | Pay |

### 8.2 Backup Types
- **Full**: Complete system, weekly
- **Incremental**: Changes only, daily
- **Per-service**: Hourly database dumps
- **Snapshots**: Before updates

---

## 9. Hardware Requirements

| Spec | Minimum | Recommended | Excellent |
|------|---------|-------------|-----------|
| RAM | 2 GB | 4 GB | 8+ GB |
| Storage | 16 GB | 64 GB | 256+ GB |
| Android | 7.0 | 11+ | 13+ |
| CPU | 4 cores | 8 cores | 12+ |

---

## 10. Command Reference

```bash
tsx                    # Interactive menu
tsx start <service>   # Start service
tsx stop <service>    # Stop service
tsx restart <service> # Restart service
tsx status            # All services status
tsx logs <service>    # Tail service logs
tsx update            # Update all
tsx backup            # Run backup
```

---

## 11. File Structure

```
~/TermuxServerX/
├── README.md
├── install.sh
├── setup.sh
├── config.env
├── manage
│
├── core/
│   ├── detect.sh
│   ├── optimize.sh
│   ├── watchdog.sh
│   ├── auto-start.sh
│   └── utils.sh
│
├── services/
│   ├── web/         (nginx, php, node, python, caddy)
│   ├── database/    (mariadb, postgresql, redis, sqlite)
│   ├── storage/     (nextcloud, syncthing, filebrowser)
│   ├── games/       (minecraft, valheim, csgo, etc)
│   ├── dev/         (code-server, git, docker)
│   ├── media/        (jellyfin, plex, emby)
│   ├── productivity/ (gitea, vaultwarden, etc)
│   ├── network/     (cloudflared, wireguard)
│   └── monitoring/  (netdata, grafana)
│
├── webui/
│   ├── server.py
│   ├── api/
│   ├── templates/
│   └── static/
│
├── templates/
├── scripts/
├── data/
├── logs/
└── backups/
```

---

## 12. Troubleshooting

### Common Issues
1. **Services not starting** - Check logs, port conflicts, resource availability
2. **Cloudflare Tunnel issues** - Verify token, recreate tunnel
3. **Web UI not accessible** - Check server status, port

### Service Ports Reference
| Port | Service |
|------|---------|
| 80, 443 | HTTP/HTTPS |
| 8080 | Custom / Cloudflare |
| 3306 | MariaDB |
| 5432 | PostgreSQL |
| 25565 | Minecraft Java |
| 8096 | Jellyfin/Emby |

---

**End of Documentation**
