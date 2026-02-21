# Venn Mission Control Workspace

**AI Agent:** Vinny  
**Team:** Venn Social Events  
**Database:** Mission Control (SQLite)

## 🚨 CRITICAL: Database-First Operations

**ALL operational data lives in the Mission Control database.**

**Database location:** `/Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db`

### What Goes in the Database
- ✅ Tasks (what needs to be done)
- ✅ Events (what's happening)
- ✅ Contacts (People, Organizations)
- ✅ CRM (Vendors, Partners, Venues)
- ✅ Financials (Expenses, PendingReceipts)
- ✅ Marketing (Campaigns)
- ✅ Outreach tracking (VendorOutreach)

### What Goes in Markdown Files
- ✅ Documentation (AGENTS.md, WORKFLOWS.md, TOOLS.md)
- ✅ Daily logs (memory/YYYY-MM-DD.md)
- ✅ Research briefs (briefs/*.md)
- ✅ Long-term memory (MEMORY.md)
- ❌ **NEVER task lists or operational tracking**

## Quick Start

### Check what needs to be done
```bash
sqlite3 venn-mission-control/dev.db "SELECT id, title, status, priority FROM Task WHERE status != 'done' ORDER BY priority DESC LIMIT 10;"
```

### Check active events
```bash
sqlite3 venn-mission-control/dev.db "SELECT id, name, date, archived FROM Event WHERE archived = 0 ORDER BY date;"
```

### Add a new task
```bash
sqlite3 venn-mission-control/dev.db "INSERT INTO Task (id, title, description, status, priority, revenueImpact, timeUrgency, riskLevel, assignee, createdAt, updatedAt) VALUES ('task-$(date +%s)', 'Title here', 'Description', 'todo', 70, 8, 7, 5, 'Vinny', datetime('now'), datetime('now'));"
```

## Key Files

### Core Documentation
- **AGENTS.md** — Daily workflow, how I operate
- **SOUL.md** — Who I am, personality, tone
- **USER.md** — About the team I'm helping
- **WORKFLOWS.md** — Email protocols, operational standards
- **TOOLS.md** — Command reference, credentials, configurations

### Database & Tasks
- **DATABASE.md** — Quick reference for database queries
- **TASK_MANAGEMENT.md** — Full task system documentation
- **HEARTBEAT.md** — What I do every heartbeat cycle

### Memory
- **MEMORY.md** — Long-term memory, lessons learned, NON-NEGOTIABLE rules
- **memory/YYYY-MM-DD.md** — Daily logs and notes
- **RELATIONSHIPS.md** — Vendor/partner relationship tracking

### Strategic
- **briefs/*.md** — Research, market analysis, strategic documents
- **events/EVT-*/** — Event-specific documentation

## Workflow

### Every Session Start
1. Read SOUL.md, USER.md, AGENTS.md
2. Read today's memory file + MEMORY.md
3. Check database for active tasks
4. Execute highest priority task

### Every Heartbeat
1. Query database for tasks: `SELECT * FROM Task WHERE status != 'done' ORDER BY priority DESC;`
2. Check emails for vendor responses
3. Execute top priority task
4. Update database as work completes
5. Generate new tasks if queue is empty

### Making Commitments
When committing to do something:
1. **Immediately insert into database** (not just chat)
2. Set appropriate priority/urgency/risk scores
3. Task is now tracked and visible in Mission Control UI

## Migration Notes

**Feb 21, 2026:** Migrated from markdown-based task tracking to database-only.

**Reason:** Markdown files for tasks were unreliable, unstructured, and not queryable. Database is structured, persistent, and powers the Mission Control UI.

See `memory/2026-02-21-database-migration.md` for full migration documentation.

## Mission Control UI

**Local:** http://localhost:3000  
**Consumer Frontend:** http://localhost:3001

Both servers monitored with auto-restart (health checks every 5 minutes).

## Getting Help

- **Database queries:** See DATABASE.md
- **Task management:** See TASK_MANAGEMENT.md
- **Daily operations:** See AGENTS.md
- **Email protocols:** See WORKFLOWS.md

---

**Last updated:** 2026-02-21 (database migration)
