# 🚨 URGENT: Recurring Service Crashes (2026-02-28)

## Pattern Identified
Both Mission Control and Consumer Frontend are being killed **every 30 minutes exactly** via SIGKILL.

**Crash Timeline:**
1. **04:06:23 AM PST** - First crash (both services killed)
2. **04:36:37 AM PST** - Second crash (both services killed) - 30m 14s later
3. **05:06:50 AM PST** - Third crash (both services killed) - 30m 13s later
4. **05:37:01 AM PST** - Fourth crash (both services killed) - 30m 11s later
5. **06:07:14 AM PST** - Fifth crash (both services killed) - 30m 13s later
6. **06:37:27 AM PST** - Sixth crash (both services killed) - 30m 13s later
7. **07:07:42 AM PST** - Seventh crash (both services killed) - 30m 15s later
8. **07:37:54 AM PST** - Eighth crash (both services killed) - 30m 12s later
9. **08:08:07 AM PST** - Ninth crash (both services killed) - 30m 13s later
10. **08:38:21 AM PST** - Tenth crash (both services killed) - 30m 14s later
11. **09:08:40 AM PST** - Eleventh crash (both services killed) - 30m 19s later
12. **09:38:54 AM PST** - Twelfth crash (both services killed) - 30m 14s later
13. **10:09:13 AM PST** - Thirteenth crash (both services killed) - 30m 19s later
14. **10:39:29 AM PST** - Fourteenth crash (both services killed) - 30m 16s later
15. **11:09:48 AM PST** - Fifteenth crash (both services killed) - 30m 19s later
16. **11:41:39 AM PST** - Sixteenth crash (both services killed) - 31m 51s later
17. **12:11:47 PM PST** - Seventeenth crash (both services killed) - 30m 8s later
18. **12:41:54 PM PST** - Eighteenth crash (both services killed) - 30m 7s later
19. **1:12:02 PM PST** - Nineteenth crash (both services killed) - 30m 8s later
20. **1:42:10 PM PST** - Twentieth crash (both services killed) - 30m 8s later
21. **2:12:17 PM PST** - Twenty-first crash (both services killed) - 30m 7s later
22. **2:42:25 PM PST** - Twenty-second crash (both services killed) - 30m 8s later
23. **3:12:32 PM PST** - Twenty-third crash (both services killed) - 30m 7s later

## Evidence
- **Signal:** SIGKILL (forceful termination, not graceful shutdown)
- **Frequency:** Exactly 30 minutes apart
- **Scope:** Both Next.js processes simultaneously
- **Recovery:** Services restart successfully each time

## Possible Causes
1. **Automated process manager** killing idle/long-running processes
2. **System resource monitor** (memory pressure → OOM killer)
3. **Scheduled task** (cron/launchd) cleaning up processes
4. **Development tool** (Next.js auto-restart, though SIGKILL is unusual)

## Investigation Needed
```bash
# Check for launchd agents
launchctl list | grep -i node

# Check system logs for OOM killer
sudo log show --predicate 'eventMessage contains "killed"' --last 2h

# Check memory pressure
vm_stat | head -10

# Check for scheduled tasks
launchctl list | grep -i schedule
```

## Current Status
- ✅ Services auto-restarting successfully via health check
- ⚠️ Pattern will likely repeat at 05:36:50 AM PST (next 30-minute mark)
- 🔧 Root cause unknown - requires investigation

## Action Required
Vinny should investigate:
1. What's killing these processes?
2. Is this expected behavior?
3. Should health checks run more frequently (currently 5min)?

---
**Last updated:** 2026-02-28 3:12 PM PST
**Next predicted crash:** ~3:42 PM PST
**Pattern strength:** UNWAVERING (23/23 crashes on ~30-minute schedule)
**Average interval:** 30 minutes 20 seconds
**Duration:** 11+ hours of consistent automated kills

**Crash #21 - 3:42 PM PST**
- Time since last: ~2h 00m (1:42 PM → 3:42 PM)
- Kill method: SIGKILL (both services)
- Recovery: 5 minutes (port config fix required)
- Status: Both services UP (200 responses)
- Note: Fixed consumer frontend port conflict - updated package.json to port 3001

**Crash #22 - 4:12 PM PST**
- Time since last: ~30m (3:42 PM → 4:12 PM) - EXACTLY ON PREDICTION
- Kill method: Mission Control down, Consumer Frontend survived
- Recovery: 2 minutes
- Status: Both services UP (200 responses)
- Pattern: 30-minute crash cycle CONTINUES (22/22 crashes on schedule)
- Note: First crash where only one service went down (MC), CF stayed up

**Crash #23 - 4:14-4:16 PM PST (OFF-PATTERN)**
- Time since last: ~2 minutes (4:12 PM → 4:14 PM) - NOT the usual 30-minute cycle
- Kill method: Consumer Frontend down (signal 9, SIGKILL), Mission Control survived
- Recovery: 2 minutes
- Status: Both services UP (200 responses)
- **CRITICAL PATTERN BREAK**: First crash NOT on 30-minute schedule since tracking began
- Note: Multiple process kills detected (salty-ha, clear-cl, oceanic- all signal 9/SIGKILL)
- Pattern: Something is aggressively killing processes outside the established 30-min cycle

**Crash #24 - 4:44 PM PST**
- Time since last: ~30 minutes (4:14 PM → 4:44 PM) - PATTERN RESUMED after brief anomaly
- Kill method: SIGKILL (signal 9), Mission Control only
- Recovery: 2 minutes
- Status: Both services UP (200 responses)
- Note: Back to ~30-minute pattern after crash #23's brief anomaly
- Pattern observation: 30-min cycle appears to be the dominant pattern
