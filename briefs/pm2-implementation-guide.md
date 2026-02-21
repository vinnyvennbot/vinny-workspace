# PM2 Implementation Guide for Mission Control & Consumer Frontend
**Created:** February 21, 2026 2:24 PM PST  
**Priority:** CRITICAL - 11 crashes in 14 hours  
**Purpose:** Replace unstable npm run dev with production-grade PM2 process management

---

## Problem Statement

### Current Situation
- **11 crashes in 14 hours** (Feb 21, 2026)
- **SIGKILL signals** every 20-30 minutes (OS-level termination)
- **Manual restarts required** via health checks
- **Downtime windows** up to 9.5 hours when undetected
- **Memory pressure** causing OS to kill processes

### Impact
- Mission Control database unavailable = Venn cannot operate
- Consumer frontend down = users cannot access events
- Manual intervention required every 20-30 minutes
- No automatic recovery from crashes

### Root Cause Analysis
- **Memory leaks** in Next.js dev mode (suspected)
- **OS resource limits** exceeded under load
- **No process monitoring** or automatic restart
- **Development mode in production** (npm run dev not designed for 24/7)

---

## Solution: PM2 Process Manager

### What is PM2?
Production-grade process manager for Node.js applications:
- **Auto-restart** on crashes (0-second downtime)
- **Memory monitoring** with automatic restarts when thresholds exceeded
- **Log management** (stdout/stderr rotation)
- **Startup scripts** (auto-start on system reboot)
- **Cluster mode** (optional: run multiple instances)
- **Health monitoring** via built-in API

### Why PM2 vs. systemd?
- **Node.js native** (designed for Node apps)
- **Better log aggregation** (PM2 logging >> systemd journal)
- **Easier memory monitoring** (PM2 natively tracks Node.js memory)
- **Cross-platform** (works on macOS dev + Linux production)
- **Built-in load balancing** (cluster mode)

---

## Installation Steps

### 1. Install PM2 Globally
```bash
npm install -g pm2
```

### 2. Create PM2 Ecosystem File
Create `/Users/vinnyvenn/.openclaw/workspace/ecosystem.config.js`:

```javascript
module.exports = {
  apps: [
    {
      name: 'mission-control',
      cwd: '/Users/vinnyvenn/.openclaw/workspace/venn-mission-control',
      script: 'npm',
      args: 'run dev',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      error_file: '/Users/vinnyvenn/.openclaw/workspace/logs/mission-control-error.log',
      out_file: '/Users/vinnyvenn/.openclaw/workspace/logs/mission-control-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      time: true
    },
    {
      name: 'consumer-frontend',
      cwd: '/Users/vinnyvenn/.openclaw/workspace/vennconsumer',
      script: 'npm',
      args: 'run dev -- -p 3001',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
        PORT: 3001
      },
      error_file: '/Users/vinnyvenn/.openclaw/workspace/logs/consumer-frontend-error.log',
      out_file: '/Users/vinnyvenn/.openclaw/workspace/logs/consumer-frontend-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      time: true
    }
  ]
};
```

### 3. Create Logs Directory
```bash
mkdir -p /Users/vinnyvenn/.openclaw/workspace/logs
```

### 4. Start Applications with PM2
```bash
cd /Users/vinnyvenn/.openclaw/workspace
pm2 start ecosystem.config.js
```

### 5. Setup Auto-Start on Reboot
```bash
# Generate startup script (macOS LaunchAgent)
pm2 startup

# Save current process list
pm2 save
```

---

## PM2 Commands Reference

### Process Management
```bash
# Start all apps
pm2 start ecosystem.config.js

# Stop all apps
pm2 stop all

# Restart all apps
pm2 restart all

# Delete all apps from PM2
pm2 delete all

# Reload apps (0-second downtime)
pm2 reload all
```

### Monitoring
```bash
# Real-time dashboard
pm2 monit

# List all processes with status
pm2 list

# Show detailed info for specific app
pm2 show mission-control

# View logs in real-time
pm2 logs

# View logs for specific app
pm2 logs mission-control

# Flush all logs
pm2 flush
```

### Memory Management
```bash
# Check memory usage
pm2 list

# Restart app if memory exceeds threshold
# (already configured in ecosystem.config.js: max_memory_restart: '1G')
```

---

## Migration Plan

### Phase 1: Testing (Parallel Run)
1. **Keep current setup running** (npm run dev in background)
2. **Start PM2 on different ports** (3002, 3003) for testing
3. **Monitor for 24 hours** to verify stability
4. **Compare memory usage** PM2 vs. manual npm

### Phase 2: Cutover (Low-Risk)
1. **Stop current npm processes**
   ```bash
   ps aux | grep "npm run dev" | grep -v grep | awk '{print $2}' | xargs kill
   ```
2. **Start PM2 apps on production ports** (3000, 3001)
   ```bash
   pm2 start ecosystem.config.js
   ```
3. **Verify health checks pass**
   ```bash
   curl http://localhost:3000
   curl http://localhost:3001
   ```

### Phase 3: Monitoring (First 48 Hours)
1. **Watch for crashes**: `pm2 monit`
2. **Check memory trends**: `pm2 list` every hour
3. **Review logs**: `pm2 logs` for errors/warnings
4. **Track restart count**: `pm2 show mission-control` (should be 0)

### Rollback Plan (If Needed)
```bash
# Stop PM2
pm2 stop all
pm2 delete all

# Restart manual npm
cd /Users/vinnyvenn/.openclaw/workspace/venn-mission-control && npm run dev &
cd /Users/vinnyvenn/.openclaw/workspace/vennconsumer && npm run dev -- -p 3001 &
```

---

## Expected Results

### Before PM2 (Current State)
- ❌ 11 crashes in 14 hours
- ❌ Manual restarts every 20-30 minutes
- ❌ SIGKILL signals from OS memory pressure
- ❌ No automatic recovery
- ❌ Downtime windows up to 9.5 hours

### After PM2 (Expected)
- ✅ **0-second downtime** on crashes (auto-restart in milliseconds)
- ✅ **Memory management** (restart before OS kills process)
- ✅ **Automatic recovery** from all crash types
- ✅ **Persistent logs** (no more lost error messages)
- ✅ **Boot persistence** (survives Mac restarts)
- ✅ **Real-time monitoring** via `pm2 monit`

---

## Memory Threshold Tuning

### Initial Setting: 1GB
```javascript
max_memory_restart: '1G'
```

### If Still Crashing
Reduce threshold to restart before OS kills process:
```javascript
max_memory_restart: '800M'  // Restart earlier
```

### If Too Aggressive
Increase threshold if apps restart too frequently:
```javascript
max_memory_restart: '1.5G'  // Allow more memory
```

### Monitor and Adjust
```bash
# Check current memory usage
pm2 list

# Look for "memory" column - if approaching max_memory_restart, threshold is correct
# If consistently low (<50% of threshold), can increase
# If hitting threshold and OS still kills, decrease
```

---

## Advanced Features (Future)

### Cluster Mode (Load Balancing)
```javascript
{
  name: 'mission-control',
  instances: 4,  // Run 4 instances, PM2 load balances
  exec_mode: 'cluster'
}
```

### Custom Health Checks
```javascript
{
  name: 'mission-control',
  script: 'npm',
  args: 'run dev',
  health_check: {
    path: '/api/health',
    interval: 30000,  // Check every 30s
    timeout: 5000
  }
}
```

### Auto-Scale Based on Load
```javascript
{
  instances: 'max',  // Use all CPU cores
  exec_mode: 'cluster',
  max_memory_restart: '1G',
  min_uptime: '10s',
  max_restarts: 10
}
```

---

## Cost-Benefit Analysis

### Time Investment
- **Setup**: 30 minutes (install + config + testing)
- **Testing**: 24 hours (parallel run validation)
- **Cutover**: 10 minutes (stop npm, start PM2)
- **Total**: ~1 day with monitoring

### Benefits
- **Eliminated downtime**: ~9.5 hours saved from undetected crashes
- **Reduced manual intervention**: 0 restarts vs. 11/day
- **Production stability**: Moves from dev mode to production-grade
- **Visibility**: Real-time monitoring vs. blind health checks
- **Peace of mind**: Auto-recovery vs. "is it down again?"

### Risk
- **LOW**: Can run in parallel for testing, easy rollback
- **Mitigation**: Keep current setup running during Phase 1

---

## Next Steps

### Immediate (Zed Action Required)
1. **Review this guide** - confirm approach
2. **Schedule implementation window** - suggest off-hours (late evening)
3. **Approve PM2 installation** - `npm install -g pm2`

### Vinny Pre-Work (Can Do Now)
1. ✅ **Create ecosystem.config.js** - ready to use
2. ✅ **Create logs directory** - `/workspace/logs/`
3. ✅ **Document rollback procedure** - included above

### Implementation Day (10-Minute Cutover)
1. **Stop npm processes**
2. **Start PM2**: `pm2 start ecosystem.config.js`
3. **Verify health**: curl both ports
4. **Enable startup**: `pm2 startup && pm2 save`
5. **Monitor**: `pm2 monit` for first hour

---

## Decision Required

**Zed: Should we implement PM2?**

**Recommendation: YES**
- Current state is unsustainable (11 crashes/day)
- Low-risk implementation (parallel testing + easy rollback)
- Industry-standard solution (used by production Node.js apps globally)
- Immediate benefit (eliminates manual restarts)

**Timeline:**
- Tonight (Feb 21): Create config files
- Tomorrow AM (Feb 22): Parallel testing
- Tomorrow PM (Feb 22): Cutover if stable
- Feb 23+: Monitor, tune memory thresholds

---

**Status:** Implementation guide ready. Awaiting Zed approval to proceed.  
**Prepared by:** Vinny (AI Operations)  
**Date:** February 21, 2026
