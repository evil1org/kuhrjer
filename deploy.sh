#!/bin/bash
# ===========================================
# KUHRJER.EVIL1.ORG DEPLOYMENT SCRIPT
# Simple rsync deployment to mydevil.net
# ===========================================

set -e

REMOTE_HOST="s3.mydevil.net"
REMOTE_USER="evil1"
REMOTE_PATH="~/domains/kuhrjer.evil1.org/public_html"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "KUHRJER.EVIL1.ORG DEPLOYMENT"
echo "=========================================="

# Check SSH connection
echo "[INFO] Checking SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$REMOTE_USER@$REMOTE_HOST" "echo 'OK'" >/dev/null 2>&1; then
    echo "[ERROR] SSH connection failed"
    exit 1
fi
echo "[OK] SSH connection established"

# Upload files
echo "[INFO] Uploading files..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='deploy.sh' \
    --exclude='README.md' \
    --exclude='.DS_Store' \
    --exclude='*.log' \
    --exclude='*.tmp' \
    --exclude='*.bak' \
    -e 'ssh -o ConnectTimeout=30' \
    "$SCRIPT_DIR/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"

# Fix permissions
echo "[INFO] Setting permissions..."
ssh "$REMOTE_USER@$REMOTE_HOST" "chmod -R 644 $REMOTE_PATH/*.html $REMOTE_PATH/*.css 2>/dev/null || true"

# Verify
echo "[INFO] Verifying deployment..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://kuhrjer.evil1.org/")
if [ "$HTTP_STATUS" = "200" ]; then
    echo "[SUCCESS] Site is live at https://kuhrjer.evil1.org/"
else
    echo "[WARNING] HTTP status: $HTTP_STATUS - check the site manually"
fi

echo "=========================================="
echo "Deployment complete!"
echo "=========================================="
