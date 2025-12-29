#!/bin/bash

# Ethereum Node Monitor - Quick Setup Script
# Downloads and deploys the complete package

set -e

echo "╔════════════════════════════════════════════╗"
echo "║   Ethereum Node Monitor - Quick Setup      ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Option 1: Clone from GitHub (if you have a repo)
# Uncomment and modify the URL below
# REPO_URL="https://github.com/yourusername/eth-monitor.git"
# git clone $REPO_URL eth-monitor-package
# cd eth-monitor-package

# Option 2: Download as ZIP from GitHub Release
REPO_URL="https://github.com/yourusername/eth-monitor/archive/refs/heads/main.zip"
echo "📥 Downloading package..."
curl -L -o eth-monitor.zip "$REPO_URL"
unzip -q eth-monitor.zip
mv eth-monitor-main eth-monitor-package
cd eth-monitor-package

echo "✓ Package downloaded"
echo ""
echo "Choose deployment method:"
echo ""
echo "1) Docker Compose (Fastest)"
echo "   docker-compose up -d"
echo ""
echo "2) Systemd Service (Production)"
echo "   sudo bash scripts/setup.sh prod"
echo ""
echo "3) Direct Node.js"
echo "   npm install && npm start"
echo ""
echo "Dashboard will be at: http://localhost:3000"
