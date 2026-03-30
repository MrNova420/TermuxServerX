#!/usr/bin/env python3
"""
TermuxServerX - Web UI Server
Flask-based management dashboard for TermuxServerX
"""

import os
import sys
import json
import time
import secrets
import hashlib
import subprocess
import threading
from datetime import datetime
from functools import wraps
from pathlib import Path

from flask import Flask, render_template, request, jsonify, session, redirect, url_for, Response, send_file
import psutil

TSX_DIR = Path.home() / "TermuxServerX"
CONFIG_FILE = TSX_DIR / "config.env"
sys.path.insert(0, str(TSX_DIR))

app = Flask(__name__, template_folder=str(TSX_DIR / "webui" / "templates"), 
             static_folder=str(TSX_DIR / "webui" / "static"))
app.secret_key = secrets.token_hex(32)

def log(msg):
    """Log to file"""
    log_dir = TSX_DIR / "logs" / "webui"
    log_dir.mkdir(parents=True, exist_ok=True)
    with open(log_dir / "server.log", "a") as f:
        f.write(f"[{datetime.now()}] {msg}\n")

def load_config():
    """Load configuration from config.env"""
    config = {}
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE) as f:
            for line in f:
                line = line.strip()
                if '=' in line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    config[key.strip()] = value.strip().strip('"')
    return config

def is_service_running(service_name):
    """Check if a service process is running"""
    for proc in psutil.process_iter(['name', 'cmdline']):
        try:
            cmdline = ' '.join(proc.info.get('cmdline') or [])
            if service_name.lower() in cmdline.lower():
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return False

def get_system_resources():
    """Get comprehensive system resource information"""
    cpu_percent = psutil.cpu_percent(interval=1)
    cpu_count = psutil.cpu_count()
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    swap = psutil.swap_memory()
    
    network_io = psutil.net_io_counters()
    
    try:
        uptime_seconds = float(open('/proc/uptime').read().split()[0])
        days = int(uptime_seconds // 86400)
        hours = int((uptime_seconds % 86400) // 3600)
        minutes = int((uptime_seconds % 3600) // 60)
        uptime_str = f"{days}d {hours}h {minutes}m"
    except:
        uptime_str = "Unknown"
    
    return {
        'cpu': {
            'percent': cpu_percent,
            'cores': cpu_count,
            'arch': os.uname().machine,
            'freq': psutil.cpu_freq().current if psutil.cpu_freq() else 0
        },
        'ram': {
            'total': memory.total,
            'used': memory.used,
            'available': memory.available,
            'percent': memory.percent,
            'swap_total': swap.total,
            'swap_used': swap.used
        },
        'disk': {
            'total': disk.total,
            'used': disk.used,
            'free': disk.free,
            'percent': disk.percent
        },
        'network': {
            'bytes_sent': network_io.bytes_sent,
            'bytes_recv': network_io.bytes_recv,
            'packets_sent': network_io.packets_sent,
            'packets_recv': network_io.packets_recv
        },
        'uptime': uptime_str,
        'timestamp': datetime.now().isoformat()
    }

def get_services_status():
    """Get status of all configured services"""
    services_file = TSX_DIR / "config" / "services.conf"
    services = []
    
    if services_file.exists():
        with open(services_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    parts = line.split(':')
                    service = parts[0]
                    port = parts[1] if len(parts) > 1 else ''
                    services.append({
                        'name': service,
                        'port': port,
                        'running': is_service_running(service),
                        'pid': get_service_pid(service)
                    })
    
    return services

def get_service_pid(service_name):
    """Get PID of a service"""
    for proc in psutil.process_iter(['pid', 'cmdline']):
        try:
            cmdline = ' '.join(proc.info.get('cmdline') or [])
            if service_name.lower() in cmdline.lower():
                return proc.info['pid']
        except:
            pass
    return None

def get_cpu_per_core():
    """Get CPU usage per core"""
    return psutil.cpu_percent(interval=0.5, percpu=True)

def get_memory_details():
    """Get detailed memory information"""
    vm = psutil.virtual_memory()
    swap = psutil.swap_memory()
    
    return {
        'virtual': {
            'total': vm.total,
            'available': vm.available,
            'used': vm.used,
            'free': vm.free,
            'percent': vm.percent,
            'active': getattr(vm, 'active', 0),
            'inactive': getattr(vm, 'inactive', 0),
            'buffers': getattr(vm, 'buffers', 0),
            'cached': getattr(vm, 'cached', 0)
        },
        'swap': {
            'total': swap.total,
            'used': swap.used,
            'free': swap.free,
            'percent': swap.percent
        }
    }

def get_disk_details():
    """Get detailed disk information"""
    partitions = []
    for partition in psutil.disk_partitions():
        try:
            usage = psutil.disk_usage(partition.mountpoint)
            partitions.append({
                'device': partition.device,
                'mountpoint': partition.mountpoint,
                'fstype': partition.fstype,
                'total': usage.total,
                'used': usage.used,
                'free': usage.free,
                'percent': usage.percent
            })
        except PermissionError:
            continue
    return partitions

def login_required(f):
    """Decorator for routes that require login"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
@login_required
def index():
    """Main dashboard"""
    config = load_config()
    return render_template('index.html', 
                         version=config.get('TSX_VERSION', '2.0.0'),
                         device=config.get('TSX_DEVICE_MODEL', 'Android'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if request.method == 'POST':
        username = request.form.get('username', '')
        password = request.form.get('password', '')
        
        config = load_config()
        valid_user = config.get('TSX_WEBUI_USER', 'admin')
        valid_pass = config.get('TSX_WEBUI_PASSWORD', 'admin')
        
        if username == valid_user and password == valid_pass:
            session['logged_in'] = True
            session['username'] = username
            log(f"User {username} logged in")
            return redirect(url_for('index'))
        else:
            return render_template('login.html', error='Invalid credentials')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    """Logout"""
    session.clear()
    return redirect(url_for('login'))

@app.route('/api/status')
@login_required
def api_status():
    """Get full system status"""
    return jsonify({
        'services': get_services_status(),
        'resources': get_system_resources(),
        'cpu_per_core': get_cpu_per_core(),
        'memory_details': get_memory_details(),
        'disk_details': get_disk_details()
    })

@app.route('/api/resources')
@login_required
def api_resources():
    """Get system resources"""
    return jsonify(get_system_resources())

@app.route('/api/cpu-usage')
@login_required
def api_cpu_usage():
    """Get CPU usage data for charts"""
    return jsonify({
        'overall': psutil.cpu_percent(interval=0.5),
        'per_core': psutil.cpu_percent(interval=0.5, percpu=True)
    })

@app.route('/api/memory-usage')
@login_required
def api_memory_usage():
    """Get memory usage data"""
    return jsonify(get_memory_details())

@app.route('/api/disk-usage')
@login_required
def api_disk_usage():
    """Get disk usage data"""
    return jsonify(get_disk_details())

@app.route('/api/services')
@login_required
def api_services():
    """Get services list"""
    return jsonify(get_services_status())

@app.route('/api/start/<service>')
@login_required
def api_start(service):
    """Start a service"""
    try:
        result = subprocess.run(
            f'bash {TSX_DIR}/manage start {service}',
            shell=True, capture_output=True, text=True, timeout=30
        )
        time.sleep(2)
        log(f"Service {service} start requested")
        return jsonify({
            'success': True, 
            'message': f'{service} started',
            'running': is_service_running(service)
        })
    except Exception as e:
        log(f"Error starting {service}: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/stop/<service>')
@login_required
def api_stop(service):
    """Stop a service"""
    try:
        result = subprocess.run(
            f'bash {TSX_DIR}/manage stop {service}',
            shell=True, capture_output=True, text=True, timeout=30
        )
        time.sleep(2)
        log(f"Service {service} stop requested")
        return jsonify({
            'success': True, 
            'message': f'{service} stopped',
            'running': is_service_running(service)
        })
    except Exception as e:
        log(f"Error stopping {service}: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/restart/<service>')
@login_required
def api_restart(service):
    """Restart a service"""
    try:
        subprocess.run(f'bash {TSX_DIR}/manage stop {service}', shell=True, timeout=30)
        time.sleep(2)
        subprocess.run(f'bash {TSX_DIR}/manage start {service}', shell=True, timeout=30)
        time.sleep(2)
        log(f"Service {service} restarted")
        return jsonify({
            'success': True, 
            'message': f'{service} restarted',
            'running': is_service_running(service)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/logs/<service>')
@login_required
def api_logs(service):
    """Get service logs"""
    log_file = TSX_DIR / "logs" / f"{service}.log"
    if not log_file.exists():
        log_file = TSX_DIR / "logs" / "system" / f"{service}.log"
    
    if log_file.exists():
        with open(log_file) as f:
            lines = f.readlines()
            return jsonify({
                'logs': ''.join(lines[-200:]),
                'lines': len(lines)
            })
    return jsonify({'logs': 'No logs available', 'lines': 0})

@app.route('/api/logs/<service>/tail')
@login_required
def api_logs_tail(service):
    """Stream live logs"""
    log_file = TSX_DIR / "logs" / f"{service}.log"
    if not log_file.exists():
        log_file = TSX_DIR / "logs" / "system" / f"{service}.log"
    
    def generate():
        if log_file.exists():
            with open(log_file) as f:
                f.seek(0, 2)
                while True:
                    line = f.readline()
                    if not line:
                        time.sleep(0.5)
                        continue
                    yield f"data: {line}\n\n"
        else:
            yield "data: No logs available\n\n"
    
    return Response(generate(), mimetype='text/event-stream')

@app.route('/api/backup/create')
@login_required
def api_backup():
    """Create backup"""
    try:
        result = subprocess.run(
            f'bash {TSX_DIR}/scripts/backup.sh create',
            shell=True, capture_output=True, text=True, timeout=300
        )
        return jsonify({
            'success': True,
            'output': result.stdout,
            'error': result.stderr if result.returncode != 0 else None
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/backup/list')
@login_required
def api_backup_list():
    """List available backups"""
    backup_dir = TSX_DIR / "backups" / "full"
    backups = []
    if backup_dir.exists():
        for f in sorted(backup_dir.glob("*.tar.gz"), reverse=True)[:10]:
            backups.append({
                'name': f.name,
                'size': f.stat().st_size,
                'date': datetime.fromtimestamp(f.stat().st_mtime).isoformat()
            })
    return jsonify(backups)

@app.route('/api/optimize')
@login_required
def api_optimize():
    """Run system optimization"""
    try:
        result = subprocess.run(
            f'bash {TSX_DIR}/core/optimize.sh',
            shell=True, capture_output=True, text=True, timeout=60
        )
        return jsonify({
            'success': True,
            'output': result.stdout
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/maintenance')
@login_required
def api_maintenance():
    """Run maintenance"""
    try:
        result = subprocess.run(
            f'bash {TSX_DIR}/core/maintenance.sh full',
            shell=True, capture_output=True, text=True, timeout=120
        )
        return jsonify({
            'success': True,
            'output': result.stdout
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/terminal', methods=['POST'])
@login_required
def api_terminal():
    """Execute terminal command"""
    command = request.json.get('command', '')
    
    if command.strip() in ('exit', 'quit'):
        return jsonify({'output': '', 'error': ''})
    
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=30,
            cwd=str(TSX_DIR)
        )
        return jsonify({
            'output': result.stdout,
            'error': result.stderr,
            'returncode': result.returncode
        })
    except subprocess.TimeoutExpired:
        return jsonify({'output': '', 'error': 'Command timed out', 'returncode': -1}), 500
    except Exception as e:
        return jsonify({'output': '', 'error': str(e), 'returncode': -1}), 500

@app.route('/api/system/info')
@login_required
def api_system_info():
    """Get system information"""
    config = load_config()
    return jsonify({
        'device': config.get('TSX_DEVICE_MODEL', 'Unknown'),
        'manufacturer': config.get('TSX_DEVICE_MANUFACTURER', 'Unknown'),
        'android': config.get('TSX_ANDROID_VERSION', 'Unknown'),
        'ram': config.get('TSX_TOTAL_RAM', 'Unknown'),
        'cpu': config.get('TSX_CPU_MODEL', 'Unknown'),
        'cores': config.get('TSX_CPU_CORES', 'Unknown'),
        'version': config.get('TSX_VERSION', '2.0.0'),
        'ip': config.get('TSX_LOCAL_IP', get_local_ip()),
        'public_ip': config.get('TSX_PUBLIC_IP', 'Unknown'),
        'install_date': config.get('TSX_INSTALL_DATE', 'Unknown')
    })

@app.route('/api/processes')
@login_required
def api_processes():
    """Get running processes"""
    processes = []
    for proc in sorted(psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']), 
                       key=lambda x: x.info['cpu_percent'] or 0, reverse=True)[:20]:
        try:
            processes.append({
                'pid': proc.info['pid'],
                'name': proc.info['name'],
                'cpu': proc.info['cpu_percent'],
                'memory': proc.info['memory_percent']
            })
        except:
            pass
    return jsonify(processes)

@app.route('/api/files/browse')
@login_required
def api_files_browse():
    """Browse files"""
    path = request.args.get('path', str(Path.home() / "storage" / "shared"))
    browse_path = Path(path).resolve()
    
    if not str(browse_path).startswith(str(Path.home())):
        return jsonify({'error': 'Access denied'}), 403
    
    items = []
    try:
        for item in sorted(browse_path.iterdir()):
            items.append({
                'name': item.name,
                'type': 'dir' if item.is_dir() else 'file',
                'size': item.stat().st_size if item.is_file() else 0,
                'modified': datetime.fromtimestamp(item.stat().st_mtime).isoformat()
            })
    except PermissionError:
        return jsonify({'error': 'Permission denied'}), 403
    
    return jsonify({
        'path': str(browse_path),
        'parent': str(browse_path.parent),
        'items': items
    })

@app.route('/api/settings', methods=['GET', 'POST'])
@login_required
def api_settings():
    """Update settings"""
    if request.method == 'POST':
        settings = request.json
        config = load_config()
        config.update(settings)
        
        with open(CONFIG_FILE, 'w') as f:
            for key, value in config.items():
                f.write(f'{key}="{value}"\n')
        
        return jsonify({'success': True})
    
    return jsonify(load_config())

def get_local_ip():
    """Get local IP address"""
    try:
        import socket
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return '127.0.0.1'

def initialize():
    """Initialize the web server"""
    log("Web UI starting...")
    
    config = load_config()
    port = int(config.get('TSX_WEBUI_PORT', '8080'))
    
    log(f"Web UI configured for port {port}")
    return port

if __name__ == '__main__':
    port = initialize()
    log(f"Starting Web UI on port {port}")
    
    print(f"""
╔══════════════════════════════════════════════════════════════╗
║                    TermuxServerX Web UI                     ║
╠══════════════════════════════════════════════════════════════╣
║  Access: http://localhost:{port}                               ║
║  Default: admin / {load_config().get('TSX_WEBUI_PASSWORD', 'admin')}                                   ║
╚══════════════════════════════════════════════════════════════╝
    """)
    
    app.run(host='0.0.0.0', port=port, debug=False, threaded=True)
