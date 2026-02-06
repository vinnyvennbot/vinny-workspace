#!/bin/bash
# Config Restore Script - Restore from backup

set -e

CONFIG_PATH="$HOME/.openclaw/openclaw.json"
BACKUP_DIR="$HOME/.openclaw/backups"

# List available backups
echo "📂 Available config backups:"
if ls "$BACKUP_DIR"/openclaw_config_*.json >/dev/null 2>&1; then
    ls -lht "$BACKUP_DIR"/openclaw_config_*.json | nl
else
    echo "❌ No backups found in $BACKUP_DIR"
    exit 1
fi

# If backup specified as argument, use it
if [ "$1" ]; then
    BACKUP_FILE="$1"
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ Backup file not found: $BACKUP_FILE"
        exit 1
    fi
else
    # Otherwise, use most recent backup
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/openclaw_config_*.json | head -1)
    echo ""
    echo "🔄 Using most recent backup: $(basename "$BACKUP_FILE")"
fi

# Confirm restore
echo ""
read -p "⚠️  Restore config from $(basename "$BACKUP_FILE")? This will overwrite current config. [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restore cancelled"
    exit 0
fi

# Create backup of current config before restore
RESTORE_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
PRE_RESTORE_BACKUP="$BACKUP_DIR/pre_restore_$RESTORE_TIMESTAMP.json"

if [ -f "$CONFIG_PATH" ]; then
    cp "$CONFIG_PATH" "$PRE_RESTORE_BACKUP"
    echo "💾 Current config backed up as: $(basename "$PRE_RESTORE_BACKUP")"
fi

# Restore from backup
cp "$BACKUP_FILE" "$CONFIG_PATH"

# Validate restored config
if jq . "$CONFIG_PATH" > /dev/null 2>&1; then
    echo "✅ Config restored successfully and validated"
    echo "🔄 Remember to restart OpenClaw gateway if needed"
else
    echo "❌ Restored config is invalid! Restoring pre-restore backup..."
    if [ -f "$PRE_RESTORE_BACKUP" ]; then
        cp "$PRE_RESTORE_BACKUP" "$CONFIG_PATH"
        echo "🔙 Pre-restore backup restored"
    fi
    exit 1
fi