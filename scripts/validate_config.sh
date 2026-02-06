#!/bin/bash
# Config Validation Script - Local only validation

set -e

CONFIG_PATH="$HOME/.openclaw/openclaw.json"

echo "🔍 Validating OpenClaw configuration..."

# Check if config exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ OpenClaw config not found at $CONFIG_PATH"
    exit 1
fi

# Check if config is valid JSON
if ! jq . "$CONFIG_PATH" > /dev/null 2>&1; then
    echo "❌ Config file is not valid JSON"
    exit 1
fi

echo "✅ Config file is valid JSON"

# Run OpenClaw doctor for schema validation
if command -v openclaw > /dev/null 2>&1; then
    echo "🩺 Running OpenClaw doctor..."
    if openclaw doctor --non-interactive; then
        echo "✅ OpenClaw doctor passed"
    else
        echo "⚠️  OpenClaw doctor found issues"
        exit 1
    fi
else
    echo "⚠️  OpenClaw CLI not found, skipping doctor check"
fi

# Basic security checks (local only)
echo "🛡️  Running basic security checks..."

# Check for hardcoded keys
if jq -r 'paths(scalars) as $p | $p | join(".")' "$CONFIG_PATH" | grep -i "key\|token\|secret" | head -5; then
    echo "⚠️  Potential hardcoded secrets found (check paths above)"
else
    echo "✅ No obvious hardcoded secrets detected"
fi

# Check gateway binding
GATEWAY_BIND=$(jq -r '.gateway.bind // "127.0.0.1"' "$CONFIG_PATH")
if [ "$GATEWAY_BIND" = "0.0.0.0" ]; then
    echo "⚠️  Gateway bound to 0.0.0.0 - ensure proper authentication"
else
    echo "✅ Gateway bind setting: $GATEWAY_BIND"
fi

# Check for allowFrom restrictions
CHANNELS_WITH_ALLOWFROM=$(jq -r '.channels // {} | to_entries[] | select(.value.allowFrom) | .key' "$CONFIG_PATH" | wc -l)
TOTAL_CHANNELS=$(jq -r '.channels // {} | keys | length' "$CONFIG_PATH")

if [ "$TOTAL_CHANNELS" -gt 0 ] && [ "$CHANNELS_WITH_ALLOWFROM" -eq 0 ]; then
    echo "⚠️  No channels have allowFrom restrictions configured"
else
    echo "✅ Channel access controls: $CHANNELS_WITH_ALLOWFROM/$TOTAL_CHANNELS channels configured"
fi

echo "🎉 Validation complete"