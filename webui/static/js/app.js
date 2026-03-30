let servicesData = [];
let cpuChart, ramChart, cpuMonitorChart, ramMonitorChart;
let refreshInterval;
let currentPath = '/storage/shared';
let cpuHistory = [];
let ramHistory = [];

document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    loadDashboard();
    loadSystemInfo();
    initCharts();
    startAutoRefresh();
});

function initNavigation() {
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            const page = link.dataset.page;
            showPage(page);
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        });
    });
}

function showPage(pageId) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.getElementById(`${pageId}-page`).classList.add('active');
    if (pageId === 'monitor') initMonitorCharts();
    if (pageId === 'files') loadFiles();
    if (pageId === 'backup') loadBackups();
}

async function loadDashboard() {
    try {
        const res = await fetch('/api/status');
        const data = await res.json();
        servicesData = data.services;
        updateStats(data.resources);
        updateServicesList(data.services);
        updateLogSelect(data.services);
    } catch (e) { console.error('Dashboard error:', e); }
}

function updateStats(r) {
    document.getElementById('cpu-percent').textContent = `${r.cpu.percent.toFixed(1)}%`;
    document.getElementById('cpu-cores').textContent = `${r.cpu.cores} cores`;
    
    const ramGB = { total: r.ram.total, used: r.ram.used };
    document.getElementById('ram-percent').textContent = `${r.ram.percent.toFixed(1)}%`;
    document.getElementById('ram-used').textContent = `${formatBytes(ramGB.used)} / ${formatBytes(ramGB.total)}`;
    
    document.getElementById('disk-percent').textContent = `${r.disk.percent.toFixed(1)}%`;
    document.getElementById('disk-used').textContent = `${formatBytes(r.disk.used)} / ${formatBytes(r.disk.total)}`;
    
    document.getElementById('uptime').textContent = r.uptime;
    
    const running = servicesData.filter(s => s.running).length;
    document.getElementById('services-count').textContent = `${running}/${servicesData.length} running`;
    
    updateCharts(r);
}

function updateServicesList(services) {
    const container = document.getElementById('services-list');
    if (!services.length) { container.innerHTML = '<div class="loading">No services configured</div>'; return; }
    
    container.innerHTML = services.map(s => `
        <div class="service-card">
            <div class="service-info">
                <h4>${s.name}</h4>
                <p>Port: ${s.port || 'N/A'}</p>
            </div>
            <div class="service-status">
                <span class="status-indicator ${s.running ? 'running' : 'stopped'}"></span>
                <div class="service-actions">
                    <button class="btn-start" onclick="startService('${s.name}')" title="Start">▶</button>
                    <button class="btn-stop" onclick="stopService('${s.name}')" title="Stop">■</button>
                    <button class="btn-restart" onclick="restartService('${s.name}')" title="Restart">⟳</button>
                </div>
            </div>
        </div>
    `).join('');
}

function updateLogSelect(services) {
    const select = document.getElementById('log-service-select');
    select.innerHTML = '<option value="">Select a service</option>' + 
        services.map(s => `<option value="${s.name}">${s.name}</option>`).join('');
}

async function startService(name) {
    await api(`/api/start/${name}`), showNotification(`${name} started`, 'success'), loadDashboard();
}

async function stopService(name) {
    await api(`/api/stop/${name}`), showNotification(`${name} stopped`, 'success'), loadDashboard();
}

async function restartService(name) {
    await api(`/api/restart/${name}`), showNotification(`${name} restarted`, 'success'), loadDashboard();
}

async function startAll() {
    for (const s of servicesData.filter(s => !s.running)) await startService(s.name);
}

async function stopAll() {
    for (const s of servicesData.filter(s => s.running)) await stopService(s.name);
}

async function loadLogs(service) {
    if (!service) return;
    const data = await api(`/api/logs/${service}`);
    document.getElementById('logs-content').textContent = data.logs || 'No logs';
}

async function loadFiles(path = currentPath) {
    currentPath = path;
    const data = await api(`/api/files/browse?path=${encodeURIComponent(path)}`);
    document.getElementById('file-path').textContent = data.path;
    document.getElementById('file-list').innerHTML = data.items.map(item => `
        <div class="file-item ${item.type}" onclick="${item.type === 'dir' ? `loadFiles('${data.path}/${item.name}')` : ''}">
            <span class="name">${item.name}</span>
            <span class="size">${item.type === 'file' ? formatBytes(item.size) : ''}</span>
        </div>
    `).join('');
}

function goToParent() {
    const parent = currentPath.split('/').slice(0, -1).join('/') || '/';
    loadFiles(parent);
}

function refreshFiles() { loadFiles(currentPath); }

async function loadBackups() {
    const backups = await api('/api/backup/list');
    document.getElementById('backup-list').innerHTML = backups.length ? backups.map(b => `
        <div class="backup-item">
            <span>${b.name}</span>
            <span>${formatBytes(b.size)}</span>
        </div>
    `).join('') : '<p>No backups available</p>';
}

async function createBackup() {
    showNotification('Creating backup...', 'info');
    await api('/api/backup/create');
    showNotification('Backup created!', 'success');
    loadBackups();
}

async function runOptimize() {
    showNotification('Optimizing...', 'info');
    await api('/api/optimize');
    showNotification('Optimization complete!', 'success');
}

async function runMaintenance() {
    showNotification('Running maintenance...', 'info');
    await api('/api/maintenance');
    showNotification('Maintenance complete!', 'success');
}

async function loadSystemInfo() {
    const info = await api('/api/system/info');
    document.getElementById('system-info').innerHTML = Object.entries(info).map(([k, v]) => `
        <span class="label">${k.replace(/_/g, ' ')}</span>
        <span>${v}</span>
    `).join('');
    document.getElementById('device-name').textContent = info.device;
    document.getElementById('access-urls').innerHTML = `
        <code>Local: http://${info.ip}:8080</code>
        <code>Public: ${info.public_ip || 'Not connected'}</code>
    `;
}

function initCharts() {
    const cpuCtx = document.getElementById('cpuChart').getContext('2d');
    const ramCtx = document.getElementById('ramChart').getContext('2d');
    
    cpuChart = new Chart(cpuCtx, { type: 'line', data: { labels: [], datasets: [{ label: 'CPU %', data: [], borderColor: '#00d9ff', tension: 0.4, fill: true, backgroundColor: 'rgba(0,217,255,0.1)' }] }, options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { max: 100 } } } });
    ramChart = new Chart(ramCtx, { type: 'doughnut', data: { labels: ['Used', 'Available'], datasets: [{ data: [0, 100], backgroundColor: ['#ff4757', '#00ff88'] }] }, options: { responsive: true } });
}

function initMonitorCharts() {
    const cpuCtx = document.getElementById('cpuMonitorChart').getContext('2d');
    const ramCtx = document.getElementById('ramMonitorChart').getContext('2d');
    
    cpuMonitorChart = new Chart(cpuCtx, { type: 'line', data: { labels: [], datasets: [{ label: 'CPU %', data: [], borderColor: '#00d9ff', tension: 0.4 }] }, options: { responsive: true, scales: { y: { max: 100 } } } });
    ramMonitorChart = new Chart(ramCtx, { type: 'line', data: { labels: [], datasets: [{ label: 'RAM %', data: [], borderColor: '#ff4757', tension: 0.4 }] }, options: { responsive: true, scales: { y: { max: 100 } } } });
    
    updateMonitor();
}

async function updateMonitor() {
    const data = await api('/api/status');
    const time = new Date().toLocaleTimeString();
    
    cpuMonitorChart.data.labels.push(time);
    cpuMonitorChart.data.datasets[0].data.push(data.resources.cpu.percent);
    if (cpuMonitorChart.data.labels.length > 20) { cpuMonitorChart.data.labels.shift(); cpuMonitorChart.data.datasets[0].data.shift(); }
    cpuMonitorChart.update();
    
    ramMonitorChart.data.labels.push(time);
    ramMonitorChart.data.datasets[0].data.push(data.resources.ram.percent);
    if (ramMonitorChart.data.labels.length > 20) { ramMonitorChart.data.labels.shift(); ramMonitorChart.data.datasets[0].data.shift(); }
    ramMonitorChart.update();
    
    document.getElementById('network-stats').innerHTML = `
        <p>Sent: ${formatBytes(data.resources.network.bytes_sent)}</p>
        <p>Received: ${formatBytes(data.resources.network.bytes_recv)}</p>
    `;
    
    const procs = await api('/api/processes');
    document.getElementById('process-list').innerHTML = procs.slice(0, 10).map(p => `
        <div class="process-item">
            <span>${p.name}</span>
            <span>CPU: ${p.cpu?.toFixed(1) || 0}% | RAM: ${p.memory?.toFixed(1) || 0}%</span>
        </div>
    `).join('');
    
    setTimeout(updateMonitor, 2000);
}

function updateCharts(r) {
    const time = new Date().toLocaleTimeString();
    cpuChart.data.labels.push(time);
    cpuChart.data.datasets[0].data.push(r.cpu.percent);
    if (cpuChart.data.labels.length > 15) { cpuChart.data.labels.shift(); cpuChart.data.datasets[0].data.shift(); }
    cpuChart.update();
    
    ramChart.data.datasets[0].data = [r.ram.percent, 100 - r.ram.percent];
    ramChart.update();
}

function startAutoRefresh() { refreshInterval = setInterval(loadDashboard, 30000); }

function refreshData() { loadDashboard(); loadSystemInfo(); }

function clearTerminal() { document.getElementById('terminal-output').innerHTML = ''; }

async function handleTerminal(e) {
    if (e.key !== 'Enter') return;
    const input = document.getElementById('terminal-input');
    const cmd = input.value.trim();
    if (!cmd) return;
    
    const output = document.getElementById('terminal-output');
    output.innerHTML += `<div><span style="color:#00d9ff">$</span> ${cmd}</div>`;
    input.value = '';
    
    const result = await fetch('/api/terminal', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ command: cmd }) });
    const data = await result.json();
    if (data.output) output.innerHTML += `<div>${data.output.replace(/\n/g, '<br>')}</div>`;
    if (data.error) output.innerHTML += `<div style="color:#ff4757">${data.error}</div>`;
    output.scrollTop = output.scrollHeight;
}

async function api(url) { try { const r = await fetch(url); return await r.json(); } catch (e) { console.error(e); return {}; } }

function formatBytes(b) { if (!b) return '0 B'; const u = ['B','KB','MB','GB','TB']; let i = 0; while (b >= 1024 && i < 4) { b /= 1024; i++; } return `${b.toFixed(1)} ${u[i]}`; }

function showNotification(msg, type = 'info') {
    const n = document.createElement('div');
    n.className = `notification notification-${type}`;
    n.textContent = msg;
    document.body.appendChild(n);
    setTimeout(() => n.remove(), 3000);
}

function saveSettings() {
    showNotification('Settings saved!', 'success');
}
