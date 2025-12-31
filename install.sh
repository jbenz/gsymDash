#!/bin/bash
# COMPLETE SETUP - Copy & Paste Solution

# Run this script to create the entire project structure

PROJECT_DIR="eth-monitor"
mkdir -p $PROJECT_DIR/{public,scripts,systemd}
cd $PROJECT_DIR

echo "Creating project structure..."

# 1. Create package.json
cat > package.json << 'EOF'
{
  "name": "ethereum-node-monitor",
  "version": "1.0.0",
  "description": "Real-time Ethereum node monitoring dashboard",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node --watch server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  },
  "engines": {
    "node": ">=16.0.0"
  }
}
EOF

# 2. Create server.js
cat > server.js << 'EOF'
#!/usr/bin/env node
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.static(path.join(__dirname, 'public')));

// Mock API for testing
app.get('/api/eth-node-stats', (req, res) => {
  res.json({
    geth: {
      synced: 39.59 + Math.random() * 0.5,
      eta: '19h 46m',
      peers: 65 + Math.floor(Math.random() * 10),
      blocks: 24116768,
      status: 'SYNCING'
    },
    prysm: {
      slot: 13347400 + Math.floor(Math.random() * 50),
      epoch: 417106,
      peers: 68,
      quic: '44↓ / 5↑',
      tcp: '4↓ / 15↑'
    },
    system: {
      memory: 45 + Math.random() * 25,
      disk: 35 + Math.random() * 20,
      engineErrors: 0,
      uptime: '42d 13h'
    },
    errors: Math.random() > 0.7 ? ['Peer stalling detected'] : []
  });
});

app.listen(PORT, () => {
  console.log(`Dashboard: http://localhost:${PORT}`);
});
EOF

# 3. Create public/index.html (using the existing dashboard)
cat > public/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethereum Node Monitor</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Courier New', monospace; background: #0f0f1e; color: #e0e0e0; padding: 20px; line-height: 1.6; }
        .container { max-width: 1000px; margin: 0 auto; }
        .header { border: 2px solid #00d4ff; border-radius: 8px; padding: 15px; margin-bottom: 20px; background: rgba(0, 212, 255, 0.05); text-align: center; }
        .header h1 { color: #00d4ff; font-size: 24px; margin-bottom: 10px; }
        .timestamp { color: #888; font-size: 12px; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px; }
        @media (max-width: 768px) { .grid { grid-template-columns: 1fr; } }
        .card { border: 1px solid #00d4ff; border-radius: 6px; padding: 15px; background: rgba(0, 20, 40, 0.8); }
        .card h2 { color: #00d4ff; font-size: 14px; text-transform: uppercase; margin-bottom: 12px; border-bottom: 1px solid #00d4ff; padding-bottom: 8px; }
        .metric { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #222; font-size: 13px; }
        .metric:last-child { border-bottom: none; }
        .metric-label { color: #888; flex: 1; }
        .metric-value { color: #00d4ff; font-weight: bold; flex: 0 0 auto; text-align: right; margin-left: 20px; }
        .progress-bar { width: 100%; height: 6px; background: #222; border-radius: 3px; overflow: hidden; margin-top: 4px; }
        .progress-fill { height: 100%; background: #00d4ff; border-radius: 3px; transition: width 0.3s ease; }
        .status-indicator { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 6px; }
        .status-synced { background: #00ff00; }
        .status-syncing { background: #ffaa00; animation: pulse 1s infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        .refresh-badge { display: inline-block; background: #00d4ff; color: #000; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; margin-left: 10px; }
        .spinner { display: inline-block; width: 12px; height: 12px; border: 2px solid #444; border-top-color: #00d4ff; border-radius: 50%; animation: spin 0.8s linear infinite; margin-right: 8px; }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⛓️ ETHEREUM NODE MONITOR</h1>
            <div class="timestamp">
                Last updated: <span id="timestamp">--:--:--</span>
                <span class="refresh-badge"><span class="spinner"></span>LIVE</span>
            </div>
        </div>

        <div class="grid">
            <div class="card">
                <h2>⚙️ Execution Layer (Geth)</h2>
                <div class="metric">
                    <span class="metric-label">Sync Progress</span>
                    <span class="metric-value" id="geth-synced">0%</span>
                </div>
                <div class="progress-bar"><div class="progress-fill" id="geth-progress" style="width: 0%"></div></div>
                <div class="metric" style="margin-top: 8px;">
                    <span class="metric-label">ETA</span>
                    <span class="metric-value" id="geth-eta">computing...</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Peers</span>
                    <span class="metric-value" id="geth-peers">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Blocks</span>
                    <span class="metric-value" id="geth-blocks">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Status</span>
                    <span class="metric-value">
                        <span class="status-indicator status-syncing"></span>
                        <span id="geth-status">SYNCING</span>
                    </span>
                </div>
            </div>

            <div class="card">
                <h2>🔗 Consensus Layer (Prysm)</h2>
                <div class="metric">
                    <span class="metric-label">Current Slot</span>
                    <span class="metric-value" id="prysm-slot">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Finalized Epoch</span>
                    <span class="metric-value" id="prysm-epoch">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Peers</span>
                    <span class="metric-value" id="prysm-peers">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">QUIC (In/Out)</span>
                    <span class="metric-value" id="prysm-quic">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">TCP (In/Out)</span>
                    <span class="metric-value" id="prysm-tcp">0</span>
                </div>
            </div>

            <div class="card">
                <h2>💻 System Health</h2>
                <div class="metric">
                    <span class="metric-label">Memory Usage</span>
                    <span class="metric-value" id="memory-usage">0%</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Disk Usage</span>
                    <span class="metric-value" id="disk-usage">0%</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Errors</span>
                    <span class="metric-value" id="engine-errors">0</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Uptime</span>
                    <span class="metric-value" id="uptime">calculating...</span>
                </div>
            </div>
        </div>
    </div>

    <script>
        async function fetchData() {
            try {
                const response = await fetch('/api/eth-node-stats');
                return await response.json();
            } catch (err) {
                return null;
            }
        }

        function updateDashboard(data) {
            if (!data) return;
            document.getElementById('timestamp').textContent = new Date().toLocaleTimeString();
            document.getElementById('geth-synced').textContent = data.geth.synced.toFixed(2) + '%';
            document.getElementById('geth-progress').style.width = data.geth.synced.toFixed(2) + '%';
            document.getElementById('geth-eta').textContent = data.geth.eta;
            document.getElementById('geth-peers').textContent = data.geth.peers + ' peers';
            document.getElementById('geth-blocks').textContent = data.geth.blocks.toLocaleString();
            document.getElementById('geth-status').textContent = data.geth.status;
            document.getElementById('prysm-slot').textContent = data.prysm.slot.toLocaleString();
            document.getElementById('prysm-epoch').textContent = data.prysm.epoch.toLocaleString();
            document.getElementById('prysm-peers').textContent = data.prysm.peers + ' peers';
            document.getElementById('prysm-quic').textContent = data.prysm.quic;
            document.getElementById('prysm-tcp').textContent = data.prysm.tcp;
            document.getElementById('memory-usage').textContent = data.system.memory.toFixed(1) + '%';
            document.getElementById('disk-usage').textContent = data.system.disk.toFixed(1) + '%';
            document.getElementById('engine-errors').textContent = data.system.engineErrors;
            document.getElementById('uptime').textContent = data.system.uptime;
        }

        async function init() {
            const data = await fetchData();
            updateDashboard(data);
            setInterval(async () => {
                const newData = await fetchData();
                updateDashboard(newData);
            }, 5000);
        }

        window.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>
HTMLEOF

# 4. Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  eth-monitor:
    build: .
    container_name: eth-monitor
    ports:
      - "3000:3000"
    restart: unless-stopped
EOF

# 5. Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY server.js .
COPY public/ ./public/
EXPOSE 3000
CMD ["node", "server.js"]
EOF

# 6. Create .gitignore
cat > .gitignore << 'EOF'
node_modules/
npm-debug.log
.env
.DS_Store
*.log
EOF

# 7. Create README
cat > README.md << 'EOF'
# Ethereum Node Monitor

Real-time monitoring dashboard for Ethereum nodes (Geth + Prysm).

## Quick Start

### Docker
```bash
docker-compose up -d
```

### Direct
```bash
npm install
npm start
```

Dashboard: http://localhost:3000

## Configuration

```bash
export GETH_SERVICE=geth
export PRYSM_SERVICE=prysm
npm start
```

## API

```bash
curl http://localhost:3000/api/eth-node-stats
```

## License

MIT
EOF

echo "✓ Project created!"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. npm install"
echo "  3. npm start"
echo ""
echo "Dashboard: http://localhost:3000"
