# TermuxServerX - Complete Game Server Guide

## Quick Start - Just Like Any Server

**To join a hosted game server, users just:**
1. Open their game
2. Click "Multiplayer" or "Join"
3. Enter: `YOUR_IP:PORT`
4. Enter password if prompted
5. Click Connect - DONE!

---

## Supported Game Servers

### Minecraft (Java Edition)
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:25565` |
| **Join** | Multiplayer → Direct Connect → Enter IP |
| **Password** | Set in server properties |

### Minecraft (Bedrock/Pocket Edition)
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:19132` |
| **Join** | Play → Servers → Add Server |
| **Port** | 19132 |

### Valheim
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:2456` |
| **Join** | Steam → Valheim → Join Game |
| **Password** | Server password required |

### Terraria
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:7777` |
| **Join** | Multiplayer → Join via IP |
| **Port** | 7777 |

### Palworld
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:8211` |
| **Join** | Steam → Palworld → Join Game |
| **Admin Password** | Set during setup |

### CS:GO / CS2
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:27015` |
| **Join** | Console → `connect ip` |
| **Password** | RCON password (don't share) |

### Rust
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:28015` |
| **Join** | Rust → Connect → Enter IP |
| **Wipe Info** | Check server announcements |

### 7 Days to Die
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:26900` |
| **Join** | F1 Console → `connect ip:26900` |
| **Password** | Server password required |

### DayZ
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:2302` |
| **Join** | Community → Favorites → Add |
| **Admin** | Type `#login password` in console |

### ARK: Survival Evolved
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:7778` |
| **Join** | Steam → ARK → Join Game |
| **Game Port** | 7778 |
| **Query Port** | 27015 |

### Garry's Mod (GMod)
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:27015` |
| **Join** | GMod → Multiplayer → Connect |

### TF2, L4D2, Other Source Games
| Info | Details |
|------|---------|
| **IP** | `your-public-ip:27015` |
| **Join** | Console → `connect ip` |

---

## How to Share Server With Friends

### Option 1: Just Share IP & Port
```
Server: your-public-ip:25565
```
Players enter this like ANY normal server.

### Option 2: With Password
```
Server: your-public-ip:25565
Password: yourpassword
```

### Option 3: Steam Invite (Some Games)
- Valheim, Palworld, ARK support Steam invites
- Right click game → Invite friends

---

## Finding Your Public IP
```bash
curl ifconfig.me
```

---

## Port Forwarding (For Local Networks)
If hosting at home, forward these ports in your router:
- Minecraft: 25565
- Valheim: 2456-2458
- All Source Games: 27015
- Terraria: 7777
- Palworld: 8211

---

## Troubleshooting

### "Connection Refused"
- Server not running → Start it
- Wrong port → Check port number
- Firewall blocking → Open port

### "Connection Timed Out"
- Device not accessible from internet
- Use Cloudflare Tunnel or Tailscale for remote access

### "Invalid Password"
- Wrong password entered
- Check server console for current password
