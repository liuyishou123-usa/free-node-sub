#!/bin/bash
set -e
echo "================================================"
echo "  Auto VPN Node Deployer"
echo "================================================"
echo "[$(date)] Starting deployment..."

# Install Docker
echo "[1/4] Installing Docker..."
if ! command -v docker &>/dev/null; then
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker $USER
fi

# Run the deployment script
echo "[2/4] Deploying VPN node..."
cd /workspaces/free-node-sub
vmpt="" argo="vmpt" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh) 2>&1 | tee /workspaces/free-node-sub/deploy_output.txt

# Extract VMess links
echo ""
echo "[3/4] Extracting subscription links..."
grep -oP '(vmess://[a-zA-Z0-9+/=]+|vless://[^ ]+|trojan://[^ ]+|ss://[^ ]+)' /workspaces/free-node-sub/deploy_output.txt > /workspaces/free-node-sub/v2ray_links.txt 2>/dev/null || true

cat /workspaces/free-node-sub/v2ray_links.txt 2>/dev/null && echo "Links saved" || echo "No links extracted"

# Also extract Clash config if any
grep -A 200 'proxies:' /workspaces/free-node-sub/deploy_output.txt > /workspaces/free-node-sub/clash_config.yaml 2>/dev/null || true

# Commit and push results back to repo
echo "[4/4] Committing results..."
cd /workspaces/free-node-sub
git config user.email "deployer@github.com"
git config user.name "Auto Deployer"
git add deploy_output.txt v2ray_links.txt clash_config.yaml 2>/dev/null || true
git commit -m "Auto-deploy VPN node results [$(date +%Y-%m-%d_%H:%M:%S)]" 2>/dev/null || echo "Nothing new to commit"
git push origin main 2>/dev/null || echo "Push skipped (may need auth)"

echo ""
echo "================================================"
echo "  DEPLOYMENT COMPLETE"
echo "================================================"
echo "Check the repo for outputs:"
echo "  - deploy_output.txt (full log)"
echo "  - v2ray_links.txt (extracted VMess/VLess/Trojan/SS links)"
echo "  - clash_config.yaml (Clash config if generated)"
cat /workspaces/free-node-sub/deploy_output.txt 2>/dev/null | tail -50
