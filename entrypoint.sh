#!/bin/sh

# Create backup directory as root
mkdir -p /home/node/data/.n8n/backup

# Create timestamped .env backup at runtime when Fly.io env vars are available
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
printenv > /home/node/data/.n8n/backup/${TIMESTAMP}.backup.env

# Set proper ownership for the node user
chown -R node:node /home/node/data

# Switch to node user and start n8n
exec gosu node "$@"
