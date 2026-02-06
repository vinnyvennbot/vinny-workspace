# Context Overflow Prevention Guide

## What Happened
The system was hitting the 200k token context limit with errors like:
```
LLM request rejected: input length and `max_tokens` exceed context limit: 170941 + 34048 > 200000
```

## Root Cause
1. **Configuration Mismatch**: Primary model was set to `anthropic/claude-sonnet-4-20250514` but allowed models only included `anthropic/claude-sonnet-4-5`
2. **Invalid Schema**: Attempted to use unsupported configuration options for compaction
3. **Large Session History**: Extended outreach work accumulated significant context

## Proper Solution

### ✅ What Actually Works
1. **Fix Model Configuration**: Ensure `agents.defaults.model.primary` matches an entry in `agents.defaults.models`
2. **Valid Configuration Schema**: Use only documented OpenClaw configuration options
3. **Shorter Heartbeat Interval**: Set to 15m instead of 30m for more frequent cleanup
4. **Use Sub-agents**: Delegate complex work to isolated sessions to keep main context clean
5. **Session Management**: Use `/compact` or `/new` commands when approaching limits

### ❌ What Doesn't Work
- Custom compaction modes like "aggressive" 
- Unrecognized keys like `preserveRecent`, `preserveMemory`, `compactOnHeartbeat`
- Session-level compaction configuration
- Manual schema extensions

### 🛠️ Configuration Management Protocol
1. **Always use Config Guardian skill** for configuration changes
2. **Create backups** before making changes
3. **Validate configuration** with `openclaw doctor` before restarting
4. **Use only documented schema** - check against validation errors

### 🔄 Prevention Strategy
- **Monitor context usage** during long-running tasks
- **Use sub-agents** for vendor outreach, research, and complex workflows  
- **Restart sessions** proactively when approaching 150k+ tokens
- **Keep heartbeat interval short** (15m) for regular maintenance

## Commands Used
```bash
# Backup config
cd /Users/vinnyvenn/.openclaw/workspace/skills/config-guardian
bash scripts/backup_config.sh

# Validate config  
bash scripts/validate_config.sh

# Fix model mismatch
# Edit primary model to match available models

# Restart gateway
openclaw gateway restart
```

## Current Valid Configuration
- **Primary Model**: `anthropic/claude-sonnet-4-5` 
- **Heartbeat**: Every 15 minutes
- **Model Alias**: `sonnet` → `anthropic/claude-sonnet-4-5`
- **Security**: Telegram DMs disabled, allowlist-based access

---
*Updated: 2026-02-05 22:30 PST*