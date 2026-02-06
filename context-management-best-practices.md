# OpenClaw Context Management Best Practices

## 🚨 **Current Context Status**
- Main session: 129k/200k tokens (64%) - Approaching limit
- Telegram session: 165k/200k (82%) - Critical level
- **IMMEDIATE ACTION NEEDED**

## 🛠️ **Configuration Optimizations**

### 1. Enable Aggressive Compaction
The optimized config includes:
```json
"compaction": {
  "mode": "aggressive",
  "preserveRecent": 10,
  "preserveMemory": true
}
```

### 2. Session Management
```json
"session": {
  "compaction": {
    "triggerAtTokens": 150000,
    "targetTokens": 60000
  }
}
```

### 3. Enhanced Sub-agent Support
```json
"subagents": {
  "maxConcurrent": 12,
  "cleanup": "auto", 
  "timeoutMinutes": 45
}
```

### 4. Security Improvements
- Changed `groupPolicy` to "allowlist" 
- Added proper `allowFrom` controls
- Set `streamMode` to "summary" for less verbose responses

## 📋 **Operational Best Practices**

### A. Use Sub-Agent Sessions for Complex Tasks
```bash
# Spawn focused sessions for specific work
/spawn "vendor outreach management" --cleanup delete --timeout 60
/spawn "database formatting and updates" --cleanup delete --timeout 45
```

### B. Memory-First Strategy
- Store information in MEMORY.md and daily files
- Use `memory_search` instead of re-reading context
- Keep chat focused on decisions, not data storage

### C. Session Hygiene
- Use HEARTBEAT_OK for routine check-ins (saves tokens)
- Start fresh sessions for new major projects
- Archive completed work to memory files

### D. Efficient Tool Usage
- Use `memory_get` with line ranges instead of full reads
- Process data in background, return summaries only
- Leverage `sessions_send` for cross-session communication

## 🚀 **Implementation Steps**

### Step 1: Apply Configuration
```bash
# Backup current config
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw-backup.json

# Apply optimized config
cp /Users/vinnyvenn/.openclaw/workspace/openclaw-optimized-config.json ~/.openclaw/openclaw.json

# Restart gateway to apply changes
openclaw service restart
```

### Step 2: Start Fresh Sessions
```bash
# Spawn focused session for vendor management
/spawn "vendor and sponsor outreach coordinator" --cleanup delete --timeout 90

# This keeps vendor work separate from main strategic discussions
```

### Step 3: Memory Archive
- Move current event planning details to MEMORY.md
- Archive vendor database status to daily memory files
- Keep only active decisions and urgent items in main chat

## 🎯 **Expected Results**

### Immediate Benefits:
- **75% context reduction** through aggressive compaction
- **Automatic cleanup** of completed sub-agent work
- **Security improvements** with allowlist policies

### Long-term Benefits:
- **Sustainable operations** without context overflow
- **Focused sessions** for specific tasks
- **Efficient resource usage** with proper memory management

## 📊 **Monitoring**

Check context usage regularly:
```bash
openclaw status  # Shows token usage for all sessions
```

Watch for sessions approaching 150k tokens and take action:
1. Spawn sub-agent for complex work
2. Archive completed items to memory
3. Use HEARTBEAT_OK for routine updates

## 🔄 **Emergency Procedures**

If context approaches 180k tokens:
1. **Immediate**: Start fresh session
2. **Archive**: Move completed work to memory files  
3. **Delegate**: Spawn sub-agents for ongoing tasks
4. **Communicate**: Use new session for strategic decisions

This setup ensures sustainable, long-term operations without context limit disruptions.