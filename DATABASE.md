# DATABASE.md — Quick Reference

## 🎯 Mission Control Database

**Location:** `/Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db`

**Quick alias for commands:**
```bash
# Add to shell for convenience
DB="/Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db"
sqlite3 $DB "SELECT * FROM Task WHERE status != 'done' ORDER BY priority DESC;"
```

## Most Common Queries

### Tasks
```bash
# What needs to be done?
sqlite3 venn-mission-control/dev.db "SELECT id, title, status, priority FROM Task WHERE status != 'done' ORDER BY priority DESC LIMIT 10;"

# My tasks
sqlite3 venn-mission-control/dev.db "SELECT title, status, dueDate FROM Task WHERE assignee = 'Vinny' AND status != 'done' ORDER BY priority DESC;"

# Add new task
sqlite3 venn-mission-control/dev.db "INSERT INTO Task (id, title, description, status, priority, revenueImpact, timeUrgency, riskLevel, assignee, createdAt, updatedAt) VALUES ('task-$(date +%s)', 'Title', 'Description', 'todo', 70, 8, 7, 5, 'Vinny', datetime('now'), datetime('now'));"

# Mark done
sqlite3 venn-mission-control/dev.db "UPDATE Task SET status = 'done', updatedAt = datetime('now') WHERE id = 'task-id-here';"
```

### Events
```bash
# Active events
sqlite3 venn-mission-control/dev.db "SELECT id, name, date, archived FROM Event WHERE archived = 0 ORDER BY date;"

# Check if event is archived
sqlite3 venn-mission-control/dev.db "SELECT name, archived FROM Event WHERE id = 'evt-001';"
```

### CRM (Contacts, Vendors, Partners)
```bash
# Recent contacts
sqlite3 venn-mission-control/dev.db "SELECT name, email, role FROM Person ORDER BY createdAt DESC LIMIT 20;"

# Top vendors by reliability
sqlite3 venn-mission-control/dev.db "SELECT name, category, reliability FROM Vendor ORDER BY reliability DESC LIMIT 20;"

# Vendors by category
sqlite3 venn-mission-control/dev.db "SELECT name, reliability, notes FROM Vendor WHERE category = 'dj' ORDER BY reliability DESC;"

# All partners
sqlite3 venn-mission-control/dev.db "SELECT name, partnerType, category FROM Partner;"

# Search vendors
sqlite3 venn-mission-control/dev.db "SELECT name, category, cost, reliability FROM Vendor WHERE name LIKE '%search%' OR notes LIKE '%search%';"
```

## Tables

Run `.schema` to see full table definitions:
```bash
sqlite3 venn-mission-control/dev.db ".schema Task"
sqlite3 venn-mission-control/dev.db ".schema Event"
sqlite3 venn-mission-control/dev.db ".schema Vendor"
```

## Key Files

- **TASK_MANAGEMENT.md** — Full task system documentation
- **AGENTS.md** — Database usage in daily workflow
- **HEARTBEAT.md** — Database checks every heartbeat

## Rules

1. **Tasks = Database ONLY** (never markdown files)
2. **Check database FIRST** before making decisions about events/tasks
3. **Update database IMMEDIATELY** when things change (vendor responses, task completion, new contacts)
4. **Database is source of truth** for Mission Control UI and all operational work

---

**Created:** 2026-02-21 (database-only migration)  
**Updated:** 2026-02-21
