#!/bin/sh

# Backup configuration flags
BACKUP_ENV=true
BACKUP_CREDENTIALS=true
BACKUP_WORKFLOWS=true

# Current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup directories if they don't exist
mkdir -p /home/node/data/backup/env
mkdir -p /home/node/data/backup/workflows
mkdir -p /home/node/data/backup/credentials
chown -R node:node /home/node/data/backup

# Function to cleanup old backups in a directory
cleanup_backups() {
    local backup_dir="$1"
    local count=$(ls -1 ${backup_dir}/*.json 2>/dev/null | wc -l)
    if [ "$count" -gt 10 ]; then
        ls -1 ${backup_dir}/*.json 2>/dev/null | sort | head -n $((count - 10)) | xargs rm -f
    fi
}

# ENV backup
if [ "$BACKUP_ENV" = "true" ]; then
    echo "$(date): Creating environment backup..."
    printenv > /home/node/data/backup/env/${TIMESTAMP}.backup.env
    BACKUP_DIR="/home/node/data/backup/env"
    BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | sort | head -n $((BACKUP_COUNT - 10)) | xargs rm -f
    fi
fi

# Check if we need to export n8n data
if [ "$BACKUP_WORKFLOWS" = "true" ] || [ "$BACKUP_CREDENTIALS" = "true" ]; then
    # Check if n8n is running
    if ! su node -c "curl -s http://localhost:5678/healthz" >/dev/null 2>&1; then
        echo "$(date): n8n is not ready, skipping n8n data backup"
        exit 0
    fi

    # Export workflows if enabled
    if [ "$BACKUP_WORKFLOWS" = "true" ]; then
        echo "$(date): Exporting workflows..."
        su node -c "cd /home/node/data && n8n export:workflow --all --output=/home/node/data/backup/workflows/${TIMESTAMP}.workflows.json" 2>/dev/null || echo "$(date): No workflows to export or n8n not ready"
        cleanup_backups "/home/node/data/backup/workflows"
    fi

    # Export credentials if enabled
    if [ "$BACKUP_CREDENTIALS" = "true" ]; then
        echo "$(date): Exporting credentials..."
        su node -c "cd /home/node/data && n8n export:credentials --all --output=/home/node/data/backup/credentials/${TIMESTAMP}.credentials.json" 2>/dev/null || echo "$(date): No credentials to export or n8n not ready"
        cleanup_backups "/home/node/data/backup/credentials"
    fi
fi

echo "$(date): Backup completed" 