# vennconsumer Port Configuration Fix - Feb 21, 2026

## The Problem
Zed reported localhost:3001 not working (consumer frontend down)

## Root Cause
- vennconsumer package.json had `"dev": "next dev -p 3000"`
- .env.local correctly set NEXT_PUBLIC_URL=http://localhost:3001
- Conflict: Mission Control already running on 3000
- Result: vennconsumer couldn't start (EADDRINUSE)

## The Fix
Started with explicit port override: `npm run dev -- -p 3001`

## Services Running
- **Port 3000**: Mission Control (internal CRM/database)
- **Port 3001**: vennconsumer (consumer-facing frontend)

## Health Monitoring Added
- Cron job: Check port 3001 every 5 minutes
- Auto-restart if down
- Alert system configured

## Recommended: Fix package.json
Should update vennconsumer/package.json to use 3001 by default:
```json
"dev": "next dev -p 3001"
```

This prevents future confusion between Mission Control (3000) and Consumer Frontend (3001).

## Status
✅ vennconsumer running on http://localhost:3001
✅ Mission Control running on http://localhost:3000
✅ Both monitored with auto-restart
