# TermuxServerX - Complete Service List

## Web & Hosting
| Service | Port | Description |
|---------|------|-------------|
| nginx | 80/443 | Web server |
| PHP | 9000 | PHP-FPM |
| Apache | 8080 | Alternative web server |
| Node.js | 3000 | JavaScript runtime |
| Python | 8000 | Python runtime |

## Databases
| Service | Port | Description |
|---------|------|-------------|
| MariaDB | 3306 | MySQL fork |
| PostgreSQL | 5432 | Advanced SQL database |
| Redis | 6379 | In-memory cache |
| MongoDB | 27017 | NoSQL database |
| SQLite | - | File-based DB |

## Media & Streaming
| Service | Port | Description |
|---------|------|-------------|
| Jellyfin | 8096 | Media server (Netflix alternative) |
| Navidrome | 4533 | Music streaming |
| Emby | 8096 | Media server |
| Immich | 8081 | Photo backup |

## Game Servers
| Service | Port | Description |
|---------|------|-------------|
| Minecraft Java | 25565 | Vanilla/Custom |
| Minecraft Bedrock | 19132 | Pocket edition |
| PocketMine | 19132 | Bedrock server |
| Valheim | 2456 | Viking survival |
| Terraria | 7777 | 2D adventure |
| Palworld | 8211 | Creature collection |
| Rust | 28015 | Survival game |
| CS:GO/CS2 | 27015 | FPS game |
| TF2 | 27015 | Team Fortress |
| L4D2 | 27015 | Left 4 Dead |
| Garry's Mod | 27015 | Sandbox |
| 7 Days to Die | 26900 | Zombie survival |
| DayZ | 2302 | Zombie apocalypse |
| ARK | 7778 | Dinosaur survival |
| Conan Exiles | 7777 | Survival |
| Satisfactory | 7777 | Factory building |
| StarMade | 4242 | Space sandbox |
| Eco | 3000 | Economy simulation |

## Development
| Service | Port | Description |
|---------|------|-------------|
| Code Server | 8443 | VS Code in browser |
| Gitea | 3000 | Git hosting |
| Drone CI | 8080 | CI/CD pipeline |
| VS Code Server | 8443 | IDE in browser |

## Productivity
| Service | Port | Description |
|---------|------|-------------|
| Outline | 8080 | Wiki/documentation |
| Ghost | 2368 | Blog platform |
| BookStack | 8080 | Book/wiki |
| Vaultwarden | 8080 | Password manager |
| n8n | 5678 | Automation |
| HomeAssistant | 8123 | Home automation |

## Monitoring
| Service | Port | Description |
|---------|------|-------------|
| Netdata | 19999 | Real-time monitoring |
| Grafana | 3000 | Metrics dashboard |
| Uptime Kuma | 3001 | Uptime monitoring |
| Umami | 3000 | Analytics |

## Storage & Files
| Service | Port | Description |
|---------|------|-------------|
| Nextcloud | 8080 | Cloud storage |
| FileBrowser | 8080 | File manager |
| Syncthing | 8384 | File sync |
| Rclone | 5572 | Cloud sync |

## Communication
| Service | Port | Description |
|---------|------|-------------|
| Matrix/Synapse | 8008 | Chat protocol |
| Ntfy | 80 | Notifications |
| Element | 8080 | Matrix client |

## Network & Proxy
| Service | Port | Description |
|---------|------|-------------|
| Cloudflared | - | Tunnel/ngrok alternative |
| Ngrok | - | Tunnel (needs account) |
| WireGuard | 51820 | VPN |
| Tailscale | - | Easy VPN |
| SSH | 8022 | Remote access |

## Security
| Service | Port | Description |
|---------|------|-------------|
| AdGuard Home | 53 | DNS/Ad blocker |
| Vaultwarden | 8080 | Password manager |
| Uptime Kuma | 3001 | Monitoring |

## Automation
| Service | Port | Description |
|---------|------|-------------|
| Home Assistant | 8123 | Smart home |
| n8n | 5678 | Workflow automation |
| ESPHome | 6052 | IoT devices |

## AI & ML
| Service | Port | Description |
|---------|------|-------------|
| Ollama | 11434 | Local AI models |
| OpenWebUI | 8080 | Chat interface |

## How to Install
```bash
# Interactive menu
~/TermuxServerX/tsx

# Quick install stack
~/TermuxServerX/scripts/stacks/install-stack.sh media

# Install specific service
~/TermuxServerX/install.sh --service minecraft
```
