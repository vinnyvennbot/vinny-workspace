# Daily Operations Quick Reference

**Purpose:** Fast command reference for common Venn Social operations

**Usage:** Copy/paste commands for routine tasks - no need to remember syntax

---

## 📧 EMAIL OPERATIONS

### Search Recent Vendor Responses
```bash
gog gmail messages search "in:inbox newer_than:24h" --max 20
```

### Check Unread Important Emails
```bash
gog gmail messages search "in:inbox is:unread is:important" --max 10
```

### Send Vendor Email (WITH PRICE VERIFICATION)
```bash
# CRITICAL: Use single quotes for body with dollar amounts!
gog gmail send --to="vendor@example.com" \
  --subject="Event Inquiry - [Event Name]" \
  --body='Professional email text with $1,400 pricing'
```

### Reply in Thread (PREFERRED)
```bash
gog gmail send --reply-to-message-id="MESSAGE_ID" \
  --reply-all \
  --subject="Re: Original Subject" \
  --body='Reply text'
```

---

## 🗄️ DATABASE OPERATIONS

### Check Event Status
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT id, name, date, status, archived FROM Event WHERE id = 'EVT-XXX';"
```

### List Active Events
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT id, name, status, readinessScore FROM Event 
   WHERE status = 'planning' AND archived = 0 
   ORDER BY readinessScore DESC LIMIT 10;"
```

### Check Vendor Responses
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT contactName, contactEmail, status, respondedAt 
   FROM VendorOutreach 
   WHERE eventId = 'EVT-XXX' AND respondedAt IS NOT NULL 
   ORDER BY respondedAt DESC;"
```

### Update Vendor Status
```bash
sqlite3 venn-mission-control/dev.db \
  "UPDATE VendorOutreach 
   SET status = 'contacted', contactedAt = CURRENT_TIMESTAMP 
   WHERE id = 'vo-xxx';"
```

### High Priority Tasks
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT id, title, status, priority FROM Task 
   WHERE status IN ('todo', 'in_progress') 
   ORDER BY priority DESC LIMIT 10;"
```

---

## ✅ DATE VERIFICATION (MANDATORY)

### Verify Day-of-Week Before Emailing
```bash
# Check specific date
date -j -f "%Y-%m-%d" "2026-03-29" "+%A, %B %d, %Y"
# Output: Sunday, March 29, 2026

# View calendar for month
cal 3 2026  # March 2026

# Quick date math
date -v+7d "+%A, %B %d, %Y"  # 7 days from now
date -v+1w "+%A, %B %d, %Y"  # 1 week from now
```

---

## 🔍 VENDOR RESEARCH

### Search Google Drive for Vendor Docs
```bash
gog drive ls --query "name contains 'vendor'" --parent FOLDER_ID
```

### Check RELATIONSHIPS.md for Vendor History
```bash
grep -A 10 "vendor@example.com" RELATIONSHIPS.md
grep -A 10 "Vendor Name" RELATIONSHIPS.md
```

---

## 📊 REPORTING

### Task Completion Rate
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT status, COUNT(*) as count, 
   ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Task), 1) as percentage 
   FROM Task GROUP BY status ORDER BY count DESC;"
```

### Vendor Response Rate by Category
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT category, COUNT(*) as contacted, 
   SUM(CASE WHEN respondedAt IS NOT NULL THEN 1 ELSE 0 END) as responded,
   ROUND(SUM(CASE WHEN respondedAt IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as rate
   FROM VendorOutreach GROUP BY category HAVING contacted >= 3;"
```

### Events by Status
```bash
sqlite3 venn-mission-control/dev.db \
  "SELECT status, COUNT(*) as count, archived 
   FROM Event GROUP BY status, archived 
   ORDER BY archived, status;"
```

---

## 🔄 GIT OPERATIONS

### Standard Commit After Work
```bash
cd /Users/vinnyvenn/.openclaw/workspace
git add -A
git commit -m "Heartbeat XX:XX PM: [brief description of work]"
```

### Check Recent Activity
```bash
git log --oneline -10
git status
```

---

## 🏥 SERVER HEALTH

### Quick Status Check
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 && echo " Mission Control"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 && echo " Consumer Frontend"
```

### Restart Mission Control (if down)
```bash
cd /Users/vinnyvenn/.openclaw/workspace/venn-mission-control
npm run dev &
```

### Restart Consumer Frontend (if down)
```bash
cd /Users/vinnyvenn/.openclaw/workspace/vennconsumer
npm run dev -- -p 3001 &
```

---

## 📅 CALENDAR OPERATIONS

### Create Event (Google Calendar)
```bash
gog calendar create primary \
  --summary="Meeting Title" \
  --from="2026-03-05T10:00:00-08:00" \
  --to="2026-03-05T11:00:00-08:00" \
  --attendees="person@example.com" \
  --with-meet
```

### List Upcoming Events
```bash
gog calendar events list --max 10
```

---

## 🔎 FILE OPERATIONS

### Find Event Research Files
```bash
find research/ -name "*event-name*" -type f
ls -lt research/*.md | head -10  # 10 most recent
```

### Search for Vendor Name Across All Files
```bash
grep -r "Vendor Name" --include="*.md" .
```

### Count Lines in Daily Log
```bash
wc -l memory/2026-03-04.md
```

---

## 🎯 COMMON WORKFLOWS

### After Sending Vendor Email
```bash
# 1. Update database
sqlite3 dev.db "UPDATE VendorOutreach SET status='contacted', contactedAt=CURRENT_TIMESTAMP WHERE id='vo-xxx';"

# 2. Update RELATIONSHIPS.md (if new vendor)
# Open RELATIONSHIPS.md, add vendor entry

# 3. Git commit
git add -A && git commit -m "Vendor outreach: [vendor name] for [event]"

# 4. Update daily log
echo "## HH:MM - Vendor Outreach: [details]" >> memory/YYYY-MM-DD.md
```

### After Receiving Vendor Response
```bash
# 1. Flag in daily log
echo "🚨 VENDOR RESPONSE: [vendor] - [thread ID]" >> memory/YYYY-MM-DD.md

# 2. Update database
sqlite3 dev.db "UPDATE VendorOutreach SET status='response_received', respondedAt=CURRENT_TIMESTAMP WHERE contactEmail='vendor@example.com';"

# 3. Update RELATIONSHIPS.md confidence score (if applicable)

# 4. Git commit
git add -A && git commit -m "Vendor response: [vendor name]"
```

### New Event Activation (After Approval)
```bash
# 1. Update event status
sqlite3 dev.db "UPDATE Event SET status='confirmed', readinessScore=50 WHERE id='EVT-XXX';"

# 2. Follow event-activation-playbook.md Phase 1
# - Lock venue within 48 hours
# - 20+ vendor contacts per category
# - Quote collection

# 3. Create event folder
mkdir events/EVT-XXX/
cp templates/event-budget-template.md events/EVT-XXX/budget.md

# 4. Git commit
git add -A && git commit -m "Event activation: [event name]"
```

---

## 🚨 ERROR RECOVERY

### Sent Email with Wrong Date
```bash
# 1. Send immediate correction (within 60 seconds)
gog gmail send --reply-to-message-id="ORIGINAL_MESSAGE_ID" \
  --subject="CORRECTION: Event Date" \
  --body='Correction: Event is [correct day], [date]. Apologies for the confusion.'

# 2. Document in postmortem
echo "ERROR: Wrong date sent to [vendor]" >> memory/YYYY-MM-DD-error-postmortem.md

# 3. Update database with error note
sqlite3 dev.db "UPDATE VendorOutreach SET notes='ERROR: Initial email had wrong date, correction sent' WHERE id='vo-xxx';"
```

### Contacted Archived Event Vendor
```bash
# DO NOT send correction - creates more confusion
# 1. Document in daily log
echo "❌ ERROR: Contacted vendor for archived event EVT-XXX" >> memory/YYYY-MM-DD.md

# 2. Update MEMORY.md with lesson learned

# 3. Review archived event check in pre-send checklist
cat briefs/vendor-outreach-protocol-checklist.md
```

---

## 📱 INSTAGRAM ENGAGEMENT

### Log Engagement Session
```bash
# Update engagement log
echo "$(date '+%Y-%m-%d %H:%M') - Session: X likes, Y story views" \
  >> memory/instagram-engagement-log.md
```

---

## 🔧 UTILITY COMMANDS

### Current Time
```bash
date "+%H:%M %Z"
date "+%Y-%m-%d %H:%M:%S %Z"
```

### Disk Space Check
```bash
df -h | grep /Users
```

### Recent Memory Files
```bash
ls -lt memory/*.md | head -5
```

---

## 📚 REFERENCE FILE LOCATIONS

**Key Files:**
- Event Playbook: `briefs/event-activation-playbook.md`
- Budget Template: `templates/event-budget-template.md`
- Vendor Protocol: `briefs/vendor-outreach-protocol-checklist.md`
- Vendor Relationships: `RELATIONSHIPS.md`
- Daily Logs: `memory/YYYY-MM-DD.md`
- Long-term Memory: `MEMORY.md`
- Tools Config: `TOOLS.md`

**Database:**
- Mission Control: `venn-mission-control/dev.db`

**Servers:**
- Mission Control: http://localhost:3000
- Consumer Frontend: http://localhost:3001

---

**Last Updated:** 2026-03-04 16:01 PM PST  
**Created By:** Vinny (AI Operations, Venn Social)
