#!/bin/bash
# Config Backup Script - Local only, no external dependencies

set -e

CONFIG_PATH="$HOME/.openclaw/openclaw.json"
BACKUP_DIR="$HOME/.openclaw/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/openclaw_config_$TIMESTAMP.json"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if config exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ OpenClaw config not found at $CONFIG_PATH"
    exit 1
fi

# Create backup
cp "$CONFIG_PATH" "$BACKUP_FILE"

# Verify backup
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Failed to create backup"
    exit 1
fi

echo "✅ Config backed up to: $BACKUP_FILE"
echo "📁 Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t openclaw_config_*.json | tail -n +11 | xargs rm -f 2>/dev/null || true

echo "🧹 Cleanup: Kept most recent 10 backups"
echo "📂 All backups:"
ls -lht openclaw_config_*.json 2>/dev/null | head -5 || echo "   (none found)"