#!/bin/bash
set -e
echo "================================================"
echo "  Auto VPN Node Deployer"
echo "================================================"
echo "[$(date)] Starting deployment..."

# Check system
echo "[1/4] System info:"
echo "  CPU: $(nproc) cores"
echo "  RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "  Disk: $(df -h / | tail -1 | awk '{print $4}') free"

# Install Docker if needed
echo "[2/4] Checking Docker..."
if ! command -v docker &>/dev/null; then
    echo "  Installing Docker..."
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker $USER
fi
echo "  Docker: $(docker --version 2>/dev/null || echo 'installing...')"

# Run the deployment script
echo "[3/4] Deploying VPN node..."
cd /workspaces/free-node-sub
vmpt="" argo="vmpt" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh) 2>&1 | tee /workspaces/free-node-sub/deploy_output.txt

# Save result
echo "[4/4] Saving node links..."
echo ""
echo "================================================"
echo "  DEPLOYMENT COMPLETE"
echo "================================================"
echo "Results saved to: /workspaces/free-node-sub/deploy_output.txt"
cat /workspaces/free-node-sub/deploy_output.txt 2>/dev/null || echo "No output file found"
echo ""
echo "The VMess/Clash links are above. Copy them to your client."
