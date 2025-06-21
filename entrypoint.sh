#!/bin/sh

# Create backup directory as root (skip lost+found)
mkdir -p /home/node/data/.n8n/backup

# Create timestamped .env backup at runtime when Fly.io env vars are available
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
printenv > /home/node/data/.n8n/backup/${TIMESTAMP}.backup.env

# Cleanup old backups - keep only the 10 most recent
BACKUP_DIR="/home/node/data/.n8n/backup"
BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    # List all backup files, sort them (oldest first), and delete all but the last 10
    ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | sort | head -n $((BACKUP_COUNT - 10)) | xargs rm -f
fi

# Set proper ownership for .n8n directory only (not lost+found)
chown -R node:node /home/node/data/.n8n

# Switch to node user and start n8n using su
exec su node -c "$*"
