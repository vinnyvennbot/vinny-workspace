# Long-Term Memory

## 🚨 NON-NEGOTIABLES (all permanent rules)

**DATABASE-ONLY TASK MANAGEMENT:** ALL task tracking in Mission Control SQLite DB. Never markdown files.
- `sqlite3 venn-mission-control/dev.db "SELECT * FROM Task WHERE status != 'done' ORDER BY priority DESC;"`
- Every heartbeat: query DB for highest priority task, execute it, update status.

**EMAIL AUTHORITY:** ONLY main session sends external emails. Crons/subagents → DRAFTS ONLY.

**PRE-SEND CHECKLIST (run before EVERY email):**
1. Is event archived in DB? → If yes: STOP (`sqlite3 ... "SELECT name, archived FROM Event;"`)
2. Have I already replied to this thread? (check SENT folder first)
3. Has Zed/team already replied?
4. Has anyone at this org been contacted for this event?

**VENDOR OUTREACH = SEND IMMEDIATELY** (not draft). "Research and outreach" means SEND the emails.
- Always include specific event date (day-of-week verified with `date -j -f "%Y-%m-%d" "YYYY-MM-DD" "+%A"`)
- Never include internal IDs (EVT-001 etc.) in external emails
- Email body with dollar amounts → ALWAYS use single quotes (shell will swallow `$1,400`)
- Always reply in thread: `gog gmail send --reply-to-message-id="ID" --reply-all --body='...'`
- Never leave vendors on read — always be last to respond, acknowledge quotes immediately

**ORG-LEVEL DEDUP:** One org = one contact per event. Check org name not just email address. Archived = silence.

**FINANCIAL DATA INTEGRITY:** Never enter quote amounts or mark expenses paid without verbatim source. If in doubt: quoteAmount: null, status: 'awaiting_quote'.

**VENUE OUTREACH:** Check ALL spaces within orgs Venn already has a relationship with FIRST, then expand to new venues.

**BOOKING AUTHORITY:** Never confirm bookings independently. Research/negotiate/recommend → Zed decides.

**ZED FORWARDS ≠ AUTO-REPLY:** "Log in CRM" means CRM only. Don't reply externally unless Zed says to.

**ALWAYS BE WORKING:** No idle gaps between tasks. The moment one ends, the next starts.

**VENUE VERIFICATION:** Never guess venue details. Check memory files and event README before confirming anything.

**EMAIL REPLY FORMAT:** Always use normal paragraph structure. No asterisks, no AI-looking bullet sections.

**GOOGLE SHEETS:** Share immediately with zed.truong@vennapp.co (writer). One master DB per category in Database/ subfolders.

**GOOGLE CALENDAR:** Add all confirmed events/calls/meetings immediately.

**GOOGLE DRIVE:** Share all new files/folders with zed.truong@vennapp.co (writer) immediately after creation.

**24-HOUR FOLLOW-UP:** No vendor response in 24h → send polite follow-up.

**FINANCIAL MODELS:** Inputs → Calculations → Outputs. No circular references. Always audit before presenting.

**MAX RETRIES:** 3 for all automated processes (email, API calls, vendor outreach). No exceptions.

**EVENT STATUS FIELD:** ALWAYS use "planning" for ideating events (NOT "Ideating" or "ideating"). UI filters on exact "planning" status.

---

## Persistent Facts

- **My Role:** AI employee of Venn Social with operational authority over events
- **Team:** Zed (ops/business), Gedeon & Aidan (tech)
- **GitHub:** Pacific-Software-Ventures/venn-backend (Go), Pacific-Software-Ventures/Venn-app (mobile)
- **Brand:** Unique, story-driven SF experiences in historic venues (mansions, boats, ballrooms)
- **Contact:** vinny@vennapp.co, Google Workspace access confirmed
- **Event Targets:** 2/month — one high-production (100+), one mid-production (<100)
- **Event Budget:** typically $40–70/person
- **Server:** Mission Control on http://localhost:3000, Consumer Frontend on http://localhost:3001
- **Health monitoring:** Shell-based launchd job (not AI cron) — runs every 5min, no internet needed

## System Configuration

- **Primary model:** anthropic/claude-sonnet-4-5
- **Heartbeat:** every 15m
- **Context pruning:** 1h TTL (cache-ttl mode)
- **ClawGuard:** active (security check on all tool calls)
- **Subagents:** up to 12 concurrent
- **Google Sheets access:** use `gog` CLI (NOT Maton API)

## Key Lessons (condensed)

- **2026-02-05:** Spawned 8 subagents for vendor outreach — none sent emails. Fixed: "vendor outreach" = SEND NOW.
- **2026-02-05:** Shell escaping: dollar signs in double-quoted strings get eaten. Always single-quote email bodies with prices.
- **2026-02-09:** Sent 15+ emails with wrong day of week ("Friday March 7" = Saturday). Always verify with `date` command.
- **2026-02-12:** Told vendor wrong venue (Fort Mason vs Barrel Room). Always check README before confirming venue.
- **2026-02-16:** Sent duplicate responses to Alberto — didn't check sent folder. Mandatory pre-send checklist fixed this.
- **2026-02-17:** Missed Presidio Golf Clubhouse during venue outreach — we already had a Presidio relationship. Always check all spaces in known orgs first.
- **2026-02-17:** Sub-agents fabricated financial data (invented quotes, marked fake expenses paid). Financial integrity rule added.
- **2026-02-18:** Sent vendor outreach for archived EVT-003. Always check DB event status before ANY outreach.
- **2026-02-18:** Went idle between tasks. Called out by Aidan. Unacceptable.
- **2026-02-18:** Replied to Zed-forwarded email (Insight Chamber/Leah) without authorization. Zed had active relationship.
- **2026-02-18:** Duplicate emails to Taste Catering, Bimbo's 365, Presidio Golf for archived Gatsby event. Full postmortem: `memory/2026-02-18-email-failure-postmortem.md`.
- **2026-02-21:** Mission Control was down 9.5h undetected before Zed reported it. Health monitoring made mandatory.
- **2026-02-23:** Created comprehensive morning summary system (MORNING-SUMMARY format) — proactive docs >> reactive status requests.
- **2026-02-27:** Used "Ideating"/"ideating" status instead of "planning" — UI couldn't find events. ALWAYS use "planning" for ideating events (UI filters on exact match).

## Morning Work Summary System

When substantial autonomous work is complete, create MORNING-SUMMARY-{DATE}.md with:
- Key deliverables, prioritized action items, event pipeline status, work stats, strategic recommendations

---
*For detailed postmortems and historical context: see `memory/` directory files*
