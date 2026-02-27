#!/bin/bash
# Health monitor for Mission Control (3000) and Consumer Frontend (3001)
# Runs via launchd — no internet required, no AI agent involved

TELEGRAM_BOT_TOKEN="8410403087:AAFa6-22vvsaNezKBIw7EB_N2Dj8qhvN7wg"
TELEGRAM_CHAT_ID="-5157705859"
MC_DIR="/Users/vinnyvenn/.openclaw/workspace/venn-mission-control"
CONSUMER_DIR="/Users/vinnyvenn/.openclaw/workspace/vennconsumer"
LOG_FILE="/Users/vinnyvenn/.openclaw/logs/health-monitor.log"

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

log() { echo "[$(timestamp)] $1" >> "$LOG_FILE"; }

send_telegram() {
  local msg="$1"
  # Best-effort — silently skip if network is down
  curl -s --max-time 5 \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${msg}" \
    > /dev/null 2>&1 || true
}

check_service() {
  local name="$1"
  local port="$2"
  local dir="$3"
  local start_cmd="$4"

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://localhost:${port}" 2>/dev/null)

  if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ] || [ "$status" = "304" ]; then
    log "${name} (port ${port}): UP (HTTP ${status})"
    return 0
  fi

  log "${name} (port ${port}): DOWN (HTTP ${status:-no response}) — restarting"

  # Restart
  cd "$dir" && eval "$start_cmd" >> "$LOG_FILE" 2>&1 &

  # Wait up to 30s for it to come up
  local waited=0
  while [ $waited -lt 30 ]; do
    sleep 3
    waited=$((waited + 3))
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://localhost:${port}" 2>/dev/null)
    if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ]; then
      log "${name}: recovered after ${waited}s"
      send_telegram "✅ ${name} recovered (was down, auto-restarted)"
      return 0
    fi
  done

  log "${name}: FAILED to recover after 30s"
  send_telegram "🚨 ${name} is DOWN and failed to restart. Manual intervention needed."
  return 1
}

log "--- Health check starting ---"
check_service "Mission Control" 3000 "$MC_DIR" "nohup npm run dev > /tmp/mc-dev.log 2>&1"
check_service "Consumer Frontend" 3001 "$CONSUMER_DIR" "nohup npm run dev -- -p 3001 > /tmp/consumer-dev.log 2>&1"
log "--- Health check complete ---"
