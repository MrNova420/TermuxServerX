# TermuxServerX - Troubleshooting Guide

## Common Issues

### Game Server Won't Start

**Error: "Port already in use"**
```bash
# Check what's using the port
lsof -i :25565
# Kill the process or use a different port
```

**Error: "Not enough RAM"**
```bash
# Check available memory
free -m
# Increase swap
~/TermuxServerX/core/optimize-elite.sh
```

**Error: "SteamCMD not found"**
```bash
# Install SteamCMD
pkg install steam
mkdir -p ~/steamcmd
cd ~/steamcmd
curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxf -
```

### Can't Connect to Server

**Check if server is running:**
```bash
screen -list
# or
pgrep -f servicename
```

**Check firewall:**
```bash
# In Termux, no firewall needed usually
# But check router if hosting at home
```

**Get public IP:**
```bash
curl ifconfig.me
```

### Web Services Not Working

**Check service status:**
```bash
pgrep -f nginx
pgrep -f php-fpm
pgrep -f mariadbd
```

**Restart services:**
```bash
~/TermuxServerX/manage restart nginx
~/TermuxServerX/manage restart php
```

### Database Connection Failed

**Check if database is running:**
```bash
pgrep -f mariadbd
pgrep -f postgres
```

**Start database:**
```bash
~/TermuxServerX/manage start mariadb
~/TermuxServerX/manage start postgresql
```

**Check credentials:**
```bash
cat ~/TermuxServerX/config.env | grep -i db
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Clean logs
rm -rf ~/TermuxServerX/logs/*.log

# Clean old backups
rm ~/TermuxServerX/backups/*.tar.gz

# Run maintenance
~/TermuxServerX/core/maintenance.sh
```

### Out of Memory

```bash
# Check memory
free -m

# Enable optimization
~/TermuxServerX/core/optimize-elite.sh

# Increase swap
~/TermuxServerX/core/optimize.sh
```

### Service Keeps Crashing

**Enable watchdog:**
```bash
bash ~/TermuxServerX/core/watchdog/watchdog-daemon.sh daemon
```

**Check crash logs:**
```bash
tail -100 ~/TermuxServerX/logs/auto-restart/auto-restart_*.log
```

### Can't Access from Internet

**Method 1: Port Forwarding (Router)**
```
1. Log into router (192.168.1.1)
2. Find Port Forwarding
3. Forward port to your phone's IP
4. Port 25565 for Minecraft, etc.
```

**Method 2: Cloudflare Tunnel (No Port Forwarding)**
```bash
~/TermuxServerX/scripts/access-control.sh
# Select option 7
```

**Method 3: Tailscale (VPN)**
```bash
~/TermuxServerX/scripts/access-control.sh
# Select option 8
```

### Web Dashboard Not Loading

```bash
# Check if Python is running
pgrep -f "python.*server.py"

# Restart dashboard
cd ~/TermuxServerX/webui
python server.py
```

### Mods/Plugins Not Working

**Minecraft:**
```bash
# Check mods folder
ls ~/TermuxServerX/data/minecraft/mods/

# Verify modloader matches
# Fabric mods need Fabric, Forge mods need Forge
```

### Performance Issues

```bash
# Run optimization
~/TermuxServerX/core/optimize-elite.sh

# Check resource usage
~/TermuxServerX/core/detect.sh

# Reduce server tick rate for games
# Edit server config to lower tick rate
```

## Still Having Issues?

```bash
# Generate debug report
echo "=== System Info ===" > debug.txt
uname -a >> debug.txt
echo "=== Memory ===" >> debug.txt
free -m >> debug.txt
echo "=== Disk ===" >> debug.txt
df -h >> debug.txt
echo "=== Running Services ===" >> debug.txt
screen -list >> debug.txt
echo "=== Recent Logs ===" >> debug.txt
tail -50 ~/TermuxServerX/logs/*.log >> debug.txt

# Share debug.txt for help
```

## Emergency Recovery

**Reset all services:**
```bash
cd ~/TermuxServerX
bash install.sh --reset
```

**Complete reinstall:**
```bash
rm -rf ~/TermuxServerX
git clone https://github.com/MrNova420/TermuxServerX.git
cd TermuxServerX
bash install.sh
```
