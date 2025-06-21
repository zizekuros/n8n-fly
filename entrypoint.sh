#!/bin/sh

# Switch to root to ensure we have permissions for backup operations
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

# Create backup directory as root
mkdir -p /home/node/data/.n8n/backup

# Create timestamped .env backup at runtime when Fly.io env vars are available
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
printenv > /home/node/data/.n8n/backup/${TIMESTAMP}.backup.env

# Set proper ownership for the node user
chown -R node:node /home/node/data/.n8n/backup

# Switch back to node user and start n8n
exec su-exec node "$@"
