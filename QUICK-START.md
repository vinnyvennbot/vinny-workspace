# Quick Start - Workspace Navigation

**Last Updated:** March 13, 2026, 6:35 AM PST

## 🚀 First Things First

**New Session Checklist:**
1. Read `SOUL.md` - who you are
2. Read `USER.md` - who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday)
4. Read `MEMORY.md` (if main session only)
5. Read `WORKFLOWS.md` - operational authority
6. Check Mission Control database for active tasks

## 📁 Directory Structure

```
/workspace/
├── AGENTS.md          - Operational guidelines
├── SOUL.md            - Personality & tone
├── USER.md            - Team information
├── WORKFLOWS.md       - Email authority, protocols
├── TOOLS.md           - Command syntax, credentials
├── HEARTBEAT.md       - Autonomous work protocols
├── MEMORY.md          - Long-term memory (main session only)
├── IDENTITY.md        - Decision framework
│
├── briefs/            - Strategic analysis & decision support
│   └── INDEX.md       - Catalog of 30+ strategic documents
│
├── templates/         - Email templates & planning frameworks
│   └── INDEX.md       - Catalog of 20 communication workflows
│
├── memory/            - Daily logs & research documentation
│   ├── 2026-03-13-early-morning.md
│   └── YYYY-MM-DD.md files
│
├── venn-mission-control/  - Task/event/vendor database (SQLite)
│   └── dev.db
│
└── vennconsumer/      - Frontend application
```

## 🗄️ Mission Control Database

**Location:** `venn-mission-control/dev.db`

**Quick Queries:**
```bash
# Top priority tasks
sqlite3 dev.db "SELECT id, title, priority FROM Task WHERE status != 'done' ORDER BY priority DESC LIMIT 10;"

# Events with dates assigned
sqlite3 dev.db "SELECT id, name, date FROM Event WHERE date IS NOT NULL;"

# Vendor contact status
sqlite3 dev.db "SELECT status, COUNT(*) FROM VendorOutreach GROUP BY status;"
```

## 📧 Email Protocols (Critical)

**BEFORE sending ANY email:**
1. Check event archived status in database
2. Check if already replied to thread (SENT folder)
3. Verify day-of-week for dates: `date -j -f "%Y-%m-%d" "YYYY-MM-DD" "+%A"`
4. Use **single quotes** for --body if mentioning prices ($)

**Auto-Send Authority:** Initial vendor outreach, 24h follow-ups, acknowledgments  
**Ask First:** Contract negotiations, budget mentions, sponsor proposals >$1K  
**Never:** Binding commitments, budget in first contact

## 🎯 Morning Handoff Pattern

**Check these files first:**
- `briefs/MORNING-SUMMARY-[DATE]-6AM.md` - Overnight work compilation
- `memory/[DATE]-early-morning.md` - Session details
- `HEARTBEAT.md` - Current active issues list

## 🔥 Critical Commands

**Email:**
```bash
gog gmail send --to="vendor@example.com" --subject="Subject" --body='Single quotes for $prices'
gog gmail messages search "in:inbox newer_than:12h" --max 30
```

**Calendar:**
```bash
gog calendar create primary --summary="Event" --from="2026-03-13T10:00:00-08:00" --to="..." --with-meet
```

**Database:**
```bash
sqlite3 venn-mission-control/dev.db "SELECT * FROM Task WHERE priority > 85;"
```

**Git:**
```bash
git -C /Users/vinnyvenn/.openclaw/workspace log --since="today" --oneline
```

## 🚨 Common Mistakes to Avoid

1. **Dollar signs in emails:** Use single quotes or escape `\$1,400`
2. **Wrong day-of-week:** Always verify dates with `date` command
3. **Duplicate vendor contact:** Check org name, not just email
4. **Archived events:** NEVER send outreach for archived events
5. **No threading:** Always use `--reply-to-message-id` for vendor responses

## 📊 Key Metrics (March 13 Snapshot)

- **Events in database:** 59 (non-archived)
- **Events with dates:** 2 (3.4%)
- **Vendors researched:** 692
- **Vendors contacted:** 6 (0.9%)
- **Active tasks:** 71

## 🔍 Finding Information

**Strategic Analysis:** `briefs/INDEX.md` - catalog of 30+ documents  
**Email Templates:** `templates/INDEX.md` - catalog of 20 workflows  
**Past Decisions:** `memory/` - daily logs and research  
**Lessons Learned:** `MEMORY.md` - long-term memory

## ⚡ Emergency Protocols

**Mission Control Down:**
```bash
cd /Users/vinnyvenn/.openclaw/workspace/venn-mission-control && npm run dev
```

**Consumer Frontend Down:**
```bash
cd /Users/vinnyvenn/.openclaw/workspace/vennconsumer && npm run dev -- -p 3001
```

---

*This is a living document - update as workflows evolve*
