# TASK_MANAGEMENT.md — Database-First Task System

## 🎯 Source of Truth: Mission Control Database

**ALL task management happens in the database. Period.**

**Database location:** `/Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db`

## Quick Reference Commands

### Check what needs to be done
```bash
# Top 10 priority tasks (excluding completed)
sqlite3 venn-mission-control/dev.db "SELECT id, title, status, priority, assignee FROM Task WHERE status != 'done' ORDER BY priority DESC LIMIT 10;"

# All my tasks (assigned to Vinny)
sqlite3 venn-mission-control/dev.db "SELECT title, status, priority, dueDate FROM Task WHERE assignee = 'Vinny' AND status != 'done' ORDER BY priority DESC;"

# Tasks by event
sqlite3 venn-mission-control/dev.db "SELECT t.title, t.status, t.priority, e.name FROM Task t JOIN Event e ON t.eventId = e.id WHERE e.archived = 0 ORDER BY t.priority DESC;"
```

### Add a new task
```bash
sqlite3 venn-mission-control/dev.db "INSERT INTO Task (id, title, description, status, priority, revenueImpact, timeUrgency, riskLevel, assignee, createdAt, updatedAt) VALUES ('task-$(date +%s)', 'Task title here', 'Description', 'todo', 70, 8, 7, 5, 'Vinny', datetime('now'), datetime('now'));"
```

### Update task status
```bash
# Mark done
sqlite3 venn-mission-control/dev.db "UPDATE Task SET status = 'done', updatedAt = datetime('now') WHERE id = 'task-id-here';"

# Start working on it
sqlite3 venn-mission-control/dev.db "UPDATE Task SET status = 'in_progress', updatedAt = datetime('now') WHERE id = 'task-id-here';"
```

### Delete task
```bash
sqlite3 venn-mission-control/dev.db "DELETE FROM Task WHERE id = 'task-id-here';"
```

## Priority Scoring

Tasks are scored 0-100 based on:
- **revenueImpact** (1-10): Direct revenue impact
- **timeUrgency** (1-10): Time sensitivity
- **riskLevel** (1-10): Risk if delayed
- **dependencyCount** (0+): How many other tasks depend on this

**Priority formula:**
```
priority = (revenueImpact * 7) + (timeUrgency * 8) + (riskLevel * 10) - (dependencyCount * 5)
```

**General guidelines:**
- 90-100: Critical, do immediately
- 70-89: High priority, do today
- 50-69: Medium priority, do this week
- 30-49: Low priority, do when possible
- 0-29: Nice to have, backlog

## Status Values
- `todo` - Not started
- `in_progress` - Currently working on it
- `blocked` - Waiting on something/someone
- `done` - Completed

## Heartbeat Protocol

Every heartbeat:
1. Query top 10 tasks by priority
2. Execute highest priority `todo` task
3. If all tasks `done` or `blocked` → generate new task from first principles
4. Update task status as work progresses

## Never Use Markdown Files for Tasks

**Why this rule exists:**
- Markdown files don't survive session restarts reliably
- No structured querying (can't filter by priority, assignee, event)
- Easy to forget what you committed to
- Database is the source of truth for Mission Control UI

**Markdown is for:**
- Documentation (AGENTS.md, WORKFLOWS.md, TOOLS.md)
- Daily logs (memory/YYYY-MM-DD.md)
- Research briefs (briefs/*.md)

**Database is for:**
- Tasks (what needs to be done)
- Events (what's happening)
- Contacts (who we know)
- Vendors/Partners (who we work with)
- Financial tracking (expenses, quotes)

## Why Database Instead of Markdown

**Wrong way:**
- Markdown files with checkbox lists
- No structure, no querying, unreliable
- Doesn't survive restarts cleanly

**Right way:**
- Structured SQLite database
- Queryable by any field
- Powers Mission Control UI
- Persistent and transactional

---

**Remember:** If it's not in the database, it doesn't exist. Use the DB for task management. Always.
