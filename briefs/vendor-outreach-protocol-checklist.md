# Vendor Outreach Protocol - Pre-Send Checklist

**Purpose:** Prevent errors in vendor communications (date mistakes, wrong events, duplicate contacts)

**Mandatory:** Run this checklist BEFORE every vendor email. No exceptions.

---

## 🚨 CRITICAL PRE-SEND CHECKLIST (MANDATORY)

### 1. EVENT STATUS CHECK
```bash
# Check if event is archived (NO CONTACT POLICY)
sqlite3 venn-mission-control/dev.db "SELECT name, archived FROM Event WHERE id = 'EVT-XXX';"
```

**RULE:** If `archived = 1` → STOP. DO NOT SEND. NO EXCEPTIONS.

**Violations:**
- Feb 18: Sent vendor emails for archived EVT-003 (Gatsby) → 3 duplicate vendor contacts
- Lesson: ALWAYS check database status before ANY outreach

---

### 2. DATE VERIFICATION (DAY-OF-WEEK)
```bash
# Verify any date mentioned in email
date -j -f "%Y-%m-%d" "2026-03-29" "+%A, %B %d, %Y"
# Output: Sunday, March 29, 2026
```

**RULE:** NEVER assume day-of-week. ALWAYS verify with `date` command.

**Violations:**
- Feb 9: Told DJs "Friday, March 7, 2026" → Actually Saturday
- Mar 4: Told line dancing instructor "Saturday, March 29, 2026" → Actually Sunday
- **Impact:** Extremely unprofessional, confuses vendors, damages credibility

**Fix:** Always run verification command before sending ANY email with dates.

---

### 3. SHELL ESCAPING (DOLLAR SIGNS IN EMAIL)
```bash
# WRONG - shell will strip $1,400
gog gmail send --body="Quote for $1,400"

# CORRECT - use single quotes
gog gmail send --body='Quote for $1,400'

# ALTERNATIVE - escape with backslash
gog gmail send --body="Quote for \$1,400"

# SAFEST - use file for complex emails
echo 'Quote for $1,400' > /tmp/email.txt
gog gmail send --body-file=/tmp/email.txt
```

**RULE:** ANY email mentioning prices/costs → ALWAYS use single quotes or --body-file

**Why:** Shell interprets `$1` as variable and strips it, leaving ",400" instead of "$1,400"

---

### 4. ORG-LEVEL DEDUPLICATION
```bash
# Check if ANYONE at this org was contacted for this event
sqlite3 venn-mission-control/dev.db "
SELECT contactEmail, contactName, contactedAt 
FROM VendorOutreach 
WHERE eventId = 'EVT-XXX' 
AND (contactEmail LIKE '%@orgdomain.com%' OR contactName LIKE '%Org Name%');"
```

**RULE:** One org = one contact per event. Don't email multiple people at same company.

**Violations:**
- Feb 18: Contacted multiple people at Presidio, Bimbo's for archived event
- Lesson: Check organization, not just individual email addresses

---

### 5. THREAD CONTINUITY CHECK
```bash
# Check if this is a follow-up (search for prior thread)
gog gmail messages search "to:vendor@example.com subject:event" --max 10
```

**RULE:** If prior thread exists → use `--reply-to-message-id=MESSAGE_ID`

**Why:** Maintains professional threading, shows organized communication

**Example:**
```bash
# WRONG - creates new thread
gog gmail send --to="vendor@example.com" --subject="Follow-up" --body="..."

# CORRECT - replies in existing thread
gog gmail send --reply-to-message-id="19cba123456" --reply-all --body="..."
```

---

### 6. VENUE VERIFICATION
```bash
# If email mentions venue details, verify from README
ls events/*/README.md
cat events/EVT-XXX/README.md | grep -i venue
```

**RULE:** Never guess venue details. Always check event documentation first.

**Violations:**
- Feb 12: Told vendor wrong venue (Fort Mason vs Barrel Room)
- Lesson: Verify from source documentation before confirming ANY venue details

---

### 7. TEAM RESPONSE CHECK
```bash
# Check if Zed/team already responded
gog gmail messages search "from:zed.truong@vennapp.co to:vendor@example.com" --max 5
```

**RULE:** If team member already replied → DO NOT respond again (avoid duplicate/conflicting responses)

**Violations:**
- Feb 16: Replied to Zed-forwarded email (Insight Chamber) without authorization
- Feb 18: Multiple team responses to same vendor causing confusion
- Lesson: One team response per vendor communication is sufficient

---

### 8. EMAIL BODY FORMATTING
**RULE:** Normal paragraph structure. NO asterisks. NO AI-looking bullet sections.

**WRONG:**
```
Hi there,

**We're excited to work with you!** Here's what we need:

* Venue capacity: 150-200 guests
* Date: March 29, 2026
* Budget: $5,000-7,000

Looking forward to your response!
```

**CORRECT:**
```
Hi there,

We're excited to work with you! We're planning an event for 150-200 guests on March 29, 2026, and our budget is $5,000-7,000.

Could you provide availability and pricing for that date?

Looking forward to your response!
```

**Why:** Asterisks and bullets make emails look AI-generated and unprofessional.

---

### 9. BUDGET DISCLOSURE
**RULE:** NEVER mention budget in first vendor outreach.

**Why:** Collect quotes first, then compare. Mentioning budget anchors pricing.

**Exception:** After receiving initial quote, budget can be disclosed if negotiating.

---

### 10. SENT FOLDER VERIFICATION
```bash
# Before replying, check if I already sent something
gog gmail messages search "from:vinny@vennapp.co to:vendor@example.com subject:event" --max 5
```

**RULE:** If I already replied to this thread → DO NOT send duplicate response.

**Violations:**
- Feb 16: Sent duplicate responses to Alberto (didn't check sent folder)
- Lesson: Mandatory pre-send sent folder check prevents duplicate replies

---

## 📋 COMPLETE PRE-SEND WORKFLOW

**For EVERY vendor email, execute in order:**

1. ✅ Event archived check (database query)
2. ✅ Date verification (if email mentions date)
3. ✅ Shell escaping check (if email mentions $ amounts)
4. ✅ Org-level dedup (database query)
5. ✅ Thread continuity (search for prior emails)
6. ✅ Venue verification (if email mentions venue)
7. ✅ Team response check (search for Zed/team replies)
8. ✅ Format check (no asterisks/bullets)
9. ✅ Budget disclosure check (first contact = no budget)
10. ✅ Sent folder check (avoid duplicate sends)

**Only after ALL 10 checks pass → Send email**

---

## 🔄 POST-SEND REQUIREMENTS

**Immediately after sending:**

1. Update VendorOutreach database
```bash
sqlite3 venn-mission-control/dev.db "
UPDATE VendorOutreach 
SET status = 'contacted', contactedAt = CURRENT_TIMESTAMP 
WHERE id = 'vo-xxx';"
```

2. Update RELATIONSHIPS.md if new vendor
3. Git commit tracking files
4. Update daily log (memory/YYYY-MM-DD.md)

---

## 🚨 ERROR RECOVERY PROTOCOL

**If error discovered AFTER sending:**

1. **Date error:** Send correction within 60 seconds (like Mar 4 line dancing example)
2. **Wrong event/archived:** DO NOT send correction - creates more confusion
3. **Duplicate send:** Acknowledge briefly if vendor responds confused
4. **Wrong venue:** Send immediate correction with apology

**Document ALL errors in:**
- Daily log (memory/YYYY-MM-DD.md)
- Postmortem file if serious (memory/YYYY-MM-DD-error-postmortem.md)
- Update MEMORY.md with lesson learned

---

## 📊 METRICS TO TRACK

**Measure outreach quality:**
- Zero date verification errors (target: 0 per month)
- Zero archived event contacts (target: 0 per month)
- Zero duplicate org contacts (target: 0 per month)
- Response rate from vendors (target: >60%)

**Monthly review:** Analyze errors, update protocol if new patterns emerge

---

**Last Updated:** 2026-03-04 14:21 PM PST  
**Status:** MANDATORY PROTOCOL - No vendor email without running checklist
