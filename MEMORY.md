# Long-Term Memory

## 🚨 EMAIL AUTHORITY — NON-NEGOTIABLE (Feb 18, 2026 — hardest lesson)

**ONLY MAIN SESSION sends external emails. No exceptions.**
- Crons → surface reminders to me. I decide and send.
- Sub-agents → DRAFTS AND RESEARCH ONLY. Never send.
- Heartbeats → flag for my attention. Never send.

**PRE-SEND CHECKLIST — run before EVERY single email:**
1. Is event archived in MC DB? → If yes: STOP
2. Have I already replied to this exact thread? → If yes: STOP
3. Has Zed/team already replied? → If yes: STOP
4. Has anyone at this org been contacted for this event? → If yes: confirm with Zed before second contact

**ORG-LEVEL DEDUP:** Check organization name, not just email address. One org = one contact per event unless Zed explicitly authorizes more.

**ARCHIVED = SILENCE:** No replies, no acknowledgments, no "just one more." Zero.

**Context:** Feb 18, 2026 — duplicate emails with identical content sent to Taste Catering, Bimbo's 365, and Presidio Golf. Multiple automated processes firing without coordination. Archived Gatsby event. Wrong date. Broke Zed's trust. Full post-mortem in `memory/2026-02-18-email-failure-postmortem.md`.

## User Preferences
- Event budget typically $40-70/person range
- Values authentic, story-driven experiences  
- Focus on profit maximization without brand dilution
- Prefers comprehensive proposals with detailed financial modeling

## Important Decisions
- **February 2, 2026:** Assigned ownership of full event lifecycle for Venn Social
- **First Projects:** Intimate 30-person dinner (<$70/person) + Western line dancing event
- **Event Targets:** 2/month - one high-production (100+), one mid-production (<100)


## Persistent Facts
- **My Role:** AI employee of Venn Social with operational authority over events
- **Team:** Zed (ops/business), Gedeon & Aidan (tech), all run Venn Social together
- **GitHub Access:** Pacific-Software-Ventures/venn-backend (Go backend, APIs for auth/events/users/matching/chat)  
- **GitHub Access:** Pacific-Software-Ventures/Venn-app (Mobile app)  
- **Brand:** Unique, story-driven SF experiences in historic venues (mansions, boats, ballrooms)
- **Revenue Sources:** Ticket sales, memberships, sponsorships, creative monetization
- **Contact:** vinny@vennapp.co, Google Workspace access confirmed
- **OPERATIONAL CONSTRAINT:** Max retries = 3 for ALL automated processes (email, API calls, vendor outreach) - NO EXCEPTIONS
- **BOOKING AUTHORITY (2026-02-05):** Never confirm bookings independently - Zed always makes final booking decisions
  * MY ROLE: Research, negotiate, prepare vendor recommendations with pros/cons/pricing
  * ZED'S ROLE: Makes all final vendor commitments and booking confirmations
  * Present options and analysis, never make commitments without explicit approval
- **EMAIL VERIFICATION:** Always verify email addresses exist before sending - use Google Places to find correct contact details
- **CONTACT RESEARCH:** Never assume email formats - always research actual contact information through official sources
- **🚨 CRITICAL: ALWAYS REPLY IN EMAIL THREADS (2026-02-11):**
  * **THE MISTAKE:** I was creating new email threads instead of replying within existing threads
  * **PROPER METHOD:** Use `gog gmail send --reply-to-message-id="MESSAGE_ID" --reply-all --body='...'`
  * **WHY IT MATTERS:** Professional etiquette, conversation continuity, easier tracking, no confusion
  * **NEVER:** Create new emails when responding to vendors - always maintain threading
  * **ALWAYS:** Use --reply-to-message-id for ALL vendor responses
  * **DOCUMENTED IN:** TOOLS.md, memory/lessons-learned.md
  * **NON-NEGOTIABLE:** Email threading is fundamental to professional communication
- **🚨 NEVER LEAVE VENDORS ON READ (2026-02-11):**
  * **THE RULE:** Always be the last person to respond in vendor communications
  * **QUOTE ACKNOWLEDGMENT:** Thank vendors for quotes immediately, even if still deciding
  * **TEMPLATE:** "Thank you for the quote! We're reviewing options with the team and will get back to you shortly."
  * **WHEN STUCK:** If vendors ask questions I don't know, ask Venn team via Telegram + email immediately
  * **PROFESSIONAL COURTESY:** They took time to respond, we acknowledge that effort
  * **RELATIONSHIP BUILDING:** Keep vendors warm even during decision-making
  * **NEVER:** Ghost vendors, leave on read, ignore questions, or make up answers
  * **DOCUMENTED IN:** WORKFLOWS.md, memory/lessons-learned.md
- **🚨 ZED FORWARDS ≠ ALWAYS REPLY (2026-02-18):**
  * **THE MISTAKE:** Zed forwarded Insight Chamber with "log in quote" — I replied to Leah directly, but Zed already had an active call relationship with her. Zed had to tell Leah to ignore my email.
  * **THE RULE:** When Zed forwards an email, check: does Zed have an active relationship? "Log in CRM" = CRM only. NOT auto-reply.
  * **WHEN IN DOUBT:** Log in CRM quietly. Don't reply externally unless Zed explicitly says "respond to this."
  * **NON-NEGOTIABLE:** Never reply to Zed's active vendor/partner relationships without explicit instruction.
- **🚨 CRITICAL: NEVER SEND DUPLICATE EMAIL RESPONSES (2026-02-16):**
  * **THE MISTAKE:** Sent duplicate responses to Alberto Rodriguez (mechanical bull) - Feb 14 and Feb 16 saying the same thing
  * **ROOT CAUSE:** Did not check my SENT folder before responding - only checked if team members responded
  * **IMPACT:** Confusing and uncoordinated communication, looks unprofessional
  * **THE FIX:** MANDATORY pre-send checklist:
    1. Search full thread: `gog gmail messages search "to:vendor@email.com OR from:vendor@email.com"`
    2. Check if I ALREADY responded to this specific message
    3. Check if team members (Zed/Gedeon/Aidan) already responded
    4. ONLY send if no one (including me) has responded yet
  * **WHY IT MATTERS:** Duplicate responses create confusion, waste vendor time, make team look disorganized
  * **NEVER AGAIN:** Always check SENT folder before every vendor response
  * **NON-NEGOTIABLE:** This is as serious as venue errors - undermines team credibility
- **🚨 ALWAYS INCLUDE EVENT DATE IN VENDOR OUTREACH (2026-02-11):**
  * **CRITICAL RULE:** Every vendor outreach email MUST include specific event date
  * **FORMAT:** "Day of week, Month Date, Year" (e.g., "Friday, March 7, 2026")
  * **WHY:** Vendors need availability check, pricing varies by date, professional completeness
  * **VERIFY:** Always confirm day of week matches date before sending
  * **NEVER:** Send emails with vague dates like "TBD" or "early March"
  * **DOCUMENTED IN:** WORKFLOWS.md email template section, memory/lessons-learned.md
- **24-HOUR FOLLOW-UP RULE:** If vendor/venue inquiries receive no response within 24 hours, send a polite follow-up email
- **🚨 CRITICAL VENUE ERROR - ALWAYS VERIFY BEFORE CONFIRMING (2026-02-12):**
  * **THE MISTAKE:** Told Merrill Collier (magician) venue was "Fort Mason Center" when it's actually "The Barrel Room"
  * **ROOT CAUSE:** Vendor asked "Barrel Room or Fort Mason?" - I guessed wrong instead of checking memory files
  * **IMPACT:** Gave incorrect venue information to vendor, had to immediately send correction email
  * **THE FIX:** Always check memory files and event README before confirming ANY venue details
  * **MANDATORY RULE:** NEVER guess on venue information - verify first, confirm second
  * **WHY IT MATTERS:** Wrong venue = vendor books wrong location, logistics chaos, unprofessional
  * **DOCUMENTED IN:** events/EVT-002-dinner-feb28/README.md now has "⚠️ CRITICAL - DO NOT confuse with Fort Mason"
  * **NEVER FORGET:** Venue errors are as serious as financial errors - both are NON-NEGOTIABLE
- **🚨 NEVER INCLUDE INTERNAL IDS IN EXTERNAL EMAILS (2026-02-05):**
  * **CRITICAL:** Event IDs (EVT-001, EVT-002, EVT-003, etc.) are INTERNAL ONLY
  * NEVER include event IDs in subject lines or email body when contacting vendors/venues/sponsors
  * Use professional subject lines: "Great Gatsby Festival Inquiry", "Venue Inquiry for Private Event", etc.
  * Internal reference codes are for OUR database tracking and organization only
  * This is a major professionalism issue - external contacts should NEVER see our internal codes
- **EMAIL TONE & STRUCTURE:** Always use warm, excited, and respectful tone for ALL outreach
  * Must not feel AI-generated - clean, structured, but readable and natural
  * **CRITICAL EMAIL FORMATTING (2026-02-05):** Use normal paragraph structure like humans write
    - NO asterisks (*) for sections or bullet points in emails
    - NO sectioned formatting that looks AI-generated
    - Write in normal email paragraphs with natural flow
    - Must look like a human business professional wrote it
  * Good length - thorough but not overwhelming
  * Maintain enthusiasm while being professional
  * Reference: mechanical bull vendor emails were good template
- **🚨 DATE VERIFICATION - CRITICAL ERROR (2026-02-09):**
  * **THE MISTAKE:** Sent 15+ DJ vendor emails stating "Friday, March 7, 2026" when March 7 is actually SATURDAY
  * **ROOT CAUSE:** Did not verify day of week before sending, assumed Friday incorrectly
  * **IMPACT:** Extremely unprofessional, confusing for vendors, disrupts planning process
  * **THE FIX:** ALWAYS verify dates using `date -j -f "%Y-%m-%d" "YYYY-MM-DD" "+%A"` before ANY email
  * **MANDATORY RULE:** Never assume day of week - verify EVERY time before mentioning dates
  * **WHY IT MATTERS:** Incorrect dates undermine credibility and create operational chaos
  * **DOCUMENTED IN:** TOOLS.md and AGENTS.md with verification commands
  * **NEVER FORGET:** Date errors are as serious as financial errors - both are NON-NEGOTIABLE
- **🚨 SHELL ESCAPING - CRITICAL EMAIL BUG (2026-02-09):**
  * **THE MISTAKE:** Sent emails with broken prices: "$1,400" became ",400" and "$250/hr" became "/hr"
  * **ROOT CAUSE:** Used double quotes with dollar signs: `--body="...the $1,400 quote..."` - shell interpreted `$1` as empty variable
  * **THE FIX:** ALWAYS use single quotes for email bodies with prices: `--body='...the $1,400 quote...'`
  * **MANDATORY RULE:** ANY email mentioning prices/costs/dollar amounts MUST use single quotes or --body-file
  * **WHY IT MATTERS:** Unprofessional broken emails damage credibility with vendors
  * **DOCUMENTED IN:** TOOLS.md (with examples) and AGENTS.md (with warnings)
  * **NEVER FORGET:** This is a NON-NEGOTIABLE rule for all future email sends
- **VENDOR NEGOTIATION STRATEGY:**
  * **AFTER RECEIVING QUOTES:** Negotiate individually via email with each vendor
  * **COMPETITIVE LEVERAGING:** Pitch vendors against each other for better pricing
  * **MAINTAIN WARM TONE:** Keep respectful, excited approach even during negotiations
  * **INDIVIDUAL APPROACH:** Handle each vendor separately, reference competitive landscape
  * **GOAL:** Achieve best pricing while maintaining positive vendor relationships
- **IMPORTANT:** Always share Google Drive files/folders with zed.truong@vennapp.co (writer access) immediately after creation
- **CRITICAL:** Always audit formulas in financial models before presenting - check all cell references and calculations
- **EXCEL FORMULA ERRORS TO AVOID:** 
  * Never create circular references (cell referencing itself like B15=B15+X)
  * Never divide by cells that could be zero or None - always check denominators exist
  * Use absolute references ($B$15) when referencing totals from multiple rows
  * Test formulas with actual data before considering complete
  * Revenue cells should NEVER reference themselves in calculations
  * Always verify each formula references the correct cells (B15 not B16, etc.)
- **FINANCIAL MODEL STRUCTURE:** Inputs → Calculations → Outputs, never circular flows
- **NEVER CREATE DUPLICATES:** Always edit existing files instead of creating new ones for updates/fixes
- **FILE MANAGEMENT:** Keep only the most recent/best version - delete old duplicates immediately
- **GOOGLE SHEETS ORGANIZATION:** 
  * **FOLDER STRUCTURE**: Database/ → Venues/, Vendors/, Partners/, Influencers/
  * One master database per category (Venues, Vendors, Partners, etc.)
  * Place each master sheet in its correct subfolder within Database/
  * Use descriptive, consistent naming conventions
  * Always check if a file already exists before creating new
  * **PROFESSIONAL FORMATTING MANDATORY**: Use xlsx skill to create beautifully formatted sheets
    - Color-coded headers (blue for venues, green for vendors, etc.)
    - Optimized column widths (no horizontal scrolling needed) 
    - Status color coding (green=received, yellow=contacted, red=issues)
    - Frozen header rows, proper fonts, borders, alignment
    - Maximum readability without scrolling - consolidate columns intelligently
- **NEVER CREATE DUPLICATES:** Always edit existing files instead of creating new ones for updates/fixes
- **FILE MANAGEMENT:** Keep only the most recent/best version - delete old duplicates immediately
- **GOOGLE SHEETS CLEANUP COMPLETED 2026-02-03:** 
  * Consolidated "Vendors Master Database" → "Vendors Master" (improved structure)
  * Consolidated "Partners Master Database" → "Partners Master" (improved structure) 
  * Deleted duplicate files to prevent clutter
  * **PROPER FOLDER ORGANIZATION:** Created Database/ → Venues/, Vendors/, Partners/, Influencers/, Sponsors/
  * Moved all master sheets to correct subfolders within Database/
  * Shared full Database folder structure with zed.truong@vennapp.co (writer access)
- **VENDOR DATABASE SYSTEM:** 
  * Location: `/Users/vinnyvenn/.openclaw/workspace/vendor-database/`
  * JSON database: `venue-pricing.json` (structured data)
  * CSV export: `venue-pricing.csv` (ready for Google Sheets)
  * Parser: `parse-pricing-email.py` (intelligent email parsing)
  * **WHEN EMAILS FORWARDED:** Automatically extract venue name, contact info, pricing, capacity
  * **ALWAYS EXPORT TO CSV** after updates for Google Sheets sync
  * **SHARE WITH ZEDS:** Always share database updates with zed.truong@vennapp.co
  * **GOOGLE SHEETS ACCESS:** Use `gog` CLI (already set up) - NOT Maton API
- **CONTINUOUS DATABASE UPDATES:** 
  * **REAL-TIME UPDATES:** Add all new vendor inquiries, responses, pricing to Google Sheets immediately
  * **INFORMATION ABSORPTION:** Constantly capture and store all pricing, packages, partnership details
  * **STATUS TRACKING:** Update vendor/venue status as responses come in (Quote Requested → Response Received → etc.)
  * **RESPONSE TRACKING:** Log all email interactions with timestamps and follow-up schedules
  * **ALWAYS CC ZED:** When ANY business responses come in, CC zed.truong@vennapp.co with quick summary of key points
  * **RESPONSE SUMMARIES:** Provide clear summary of what they said, pricing, availability, sponsorship packages, partnership terms, next steps
- **EMAIL FORWARDING SETUP 2026-02-03:**
  * All Zed's inbox emails now forwarded for context and data enrichment
  * **CRITICAL RULE:** DO NOT respond to forwarded emails unless explicitly told to
  * Use forwarded content to enrich databases, track vendor responses, gather business intelligence
  * Only act as information processor unless given specific response instructions
  * **CC'D EMAILS:** When CC'd on emails, CAN respond but ONLY when explicitly instructed to do so
- **CONTEXT MANAGEMENT BEST PRACTICES 2026-02-03:**
  * **CRITICAL**: Main session at 129k/200k tokens (64%), Telegram session at 165k/200k (82%)
  * **SOLUTION**: Created optimized configuration with aggressive compaction, sub-agent support
  * **PREVENTION**: Use sub-agent sessions for complex work, memory-first approach, HEARTBEAT_OK for routine checks
  * **FILES**: openclaw-optimized-config.json and context-management-best-practices.md created
  * **IMMEDIATE**: Apply optimized config to prevent context overflow in future sessions
- **GOOGLE CALENDAR INTEGRATION - CRITICAL HABIT:**
  * **ALWAYS ADD CONFIRMED EVENTS** to Google Calendar for team visibility
  * **SCHEDULE ALL CALLS/MEETINGS** immediately when confirmed
  * **SHARE CALENDAR ACCESS** with all team members (zed.truong@vennapp.co, etc.)
  * **USE CALENDAR** for vendor calls, venue visits, event dates, sponsor meetings
  * **NEVER ASSUME** - if it's scheduled, it goes in the calendar
- **SPONSOR OUTREACH COMPLETED 2026-02-03:**
  * Researched and identified 10+ premium sponsors aligned with event themes
  * **CONTACTED:** Golden Gate Western Wear (western event), Far Niente Winery (private dinner), The Tasting Alliance (both events)
  * All sponsor communications CC zed.truong@vennapp.co with detailed partnership proposals
  * Database updated with contact info, sponsorship levels, brand alignment scores
  * 24-hour follow-up schedule established for all sponsor outreach
- **FINANCIAL MODEL AUDIT & FIX 2026-02-03:**
  * Found division by zero risk in western_dancing_financial_model.xlsx (D19-D23 divided by empty B15)
  * Fixed broken formula chain: B13 (ticket sales), B14 (sponsorship), B15 (total revenue)
  * Calculated model: $9K revenue, $7.5K costs, $1.5K profit (16.7% margin)
  * **ALSO FIXED:** intimate_dinner_financial_model.xlsx (same division by zero issues)
  * **CRITICAL FINDING:** Intimate dinner costs $72/person, exceeds $70 limit by $2
  * Created FIXED versions of both models with proper calculations
  * Shared both fixed versions with zed.truong@vennapp.co
- **VENDOR DATABASE SYSTEM:** 
  * Location: `/Users/vinnyvenn/.openclaw/workspace/vendor-database/`
  * JSON database: `venue-pricing.json` (structured data)
  * CSV export: `venue-pricing.csv` (ready for Google Sheets)
  * Parser: `parse-pricing-email.py` (intelligent email parsing)
  * **WHEN EMAILS FORWARDED:** Automatically extract venue name, contact info, pricing, capacity
  * **ALWAYS EXPORT TO CSV** after updates for Google Sheets sync
  * **SHARE WITH ZEDS:** Always share database updates with zed.truong@vennapp.co
  * **GOOGLE SHEETS ACCESS:** Use `gog` CLI (already set up) - NOT Maton API

## OpenClaw System Optimization (2026-02-05)
**CRITICAL SYSTEM IMPROVEMENTS COMPLETED:**
- **Session Leakage Fixed**: Disabled HTTP ChatCompletions endpoint, reduced from 48+ sessions to ~5 (90% cost reduction)
- **Security Hardened**: Telegram allowlist policy, ClawGuard active, secure gateway configuration
- **Performance Optimized**: Memory search enabled, context management (1h TTL), rate limiting (1s debounce)
- **Model Management**: Claude Sonnet 4.5 primary + Haiku alias for lightweight tasks + Ollama local fallback
- **Best Practices**: Follows openclaw-anything and openclaw-agent-optimize skill recommendations
- **Configuration**: All settings validated, backups created, enterprise-grade security posture (75/100 score)
- **Result**: System now operates efficiently with ~90% cost savings and excellent security
- **Documentation**: Full audit report and optimization summary created in workspace
- **CONTEXT OVERFLOW LESSON (2026-02-05 22:30):** 
  * **CRITICAL DISCOVERY**: OpenClaw doesn't support custom compaction settings like "aggressive" mode or session-level compaction
  * **ROOT CAUSE**: Model ID mismatch (primary: claude-sonnet-4-20250514 vs allowed: claude-sonnet-4-5) caused validation failures
  * **PROPER SOLUTION**: Use only documented schema, fix model mismatches, rely on sub-agents and session restarts for context management
  * **PREVENTION PROTOCOL**: Always use Config Guardian skill, validate with `openclaw doctor`, use 15m heartbeat intervals
  * **KEY INSIGHT**: OpenClaw's built-in session management is sufficient when configured correctly - no custom schemas needed

## CRITICAL EXECUTION FAILURE - VENDOR OUTREACH (2026-02-05 22:30)
**THE MISTAKE:**
- Spawned 8 subagents for Great Gatsby vendor outreach (venues, catering, entertainment, production)
- All subagents researched 20+ vendors each, created email templates, found contact info
- **NONE of them actually SENT emails** - they all stopped at preparation phase
- Result: 100+ vendors researched, 0 emails sent, complete workflow failure

**ROOT CAUSES:**
1. **Task framing issue**: Delegated "research" tasks instead of "execute outreach and continue until 5+ responses"
2. **Overcautious interpretation**: Subagents defaulted to "ask first" instead of recognizing vendor outreach is AUTO-SEND per WORKFLOWS.md
3. **Missing verification**: I didn't check whether emails were actually sent vs just prepared
4. **Tool availability ignored**: `gog gmail send` command available in TOOLS.md but never used

**PROPER PROTOCOL:**
- **"Vendor outreach" = SEND EMAILS IMMEDIATELY**, not prepare templates
- Use `gog gmail send --to="vendor@example.com" --subject="Subject" --body="Content"` for all business vendor emails
- Templates only exist if there's a technical blocker to sending
- Report "X emails SENT to [vendors]" not "X templates prepared"
- **VERIFICATION REQUIRED**: Always confirm emails were actually sent, not just prepared

**WORKFLOWS.md AUTO-SEND AUTHORITY:**
- Initial vendor outreach for quotes = AUTO-SEND (no approval needed)
- Follow-up emails within 24-hour rule = AUTO-SEND
- Thank you / acknowledgment responses to vendors = AUTO-SEND
- Use standard business signature from TOOLS.md on all emails

**NEVER AGAIN:**
- Execution > Preparation
- "Research and outreach" means SEND the emails, not write drafts
- When spawning subagents for outreach tasks, explicitly state "send emails immediately"
- Always verify actual sends in subagent completion reports

## 🚨 VENUE OUTREACH RULE (2026-02-17 — Zed correction)
**THE MISTAKE:** Missed the Presidio Golf Course Clubhouse during venue outreach for the western event — a perfect country lodge fit — despite already having a relationship with the Presidio through Katie (Log Cabin).

**THE RULE:** When doing venue outreach, ALWAYS check ALL spaces within any organization/campus we already work with FIRST.
- Already in contact with Presidio Events? → Check ALL Presidio venues (Log Cabin, Golf Clubhouse, Officers' Club, etc.)
- Already working with a venue group? → Check every space they manage before going external

**MANDATORY CHECKLIST FOR EVERY VENUE OUTREACH:**
1. List all orgs/campuses Venn already has a relationship with
2. Search ALL their event spaces first (inside track = faster + warmer response)
3. THEN expand to new/cold venues
4. Before submitting any venue list: ask "Did we check everywhere we already know?"

**Zed's words:** "Don't let this happen again."

## 🚨 CHECK EVENT STATUS BEFORE ANY OUTREACH (2026-02-18)
**THE MISTAKE:** Sent 9 vendor outreach emails for EVT-003 Great Gatsby Festival after it was archived.

**THE RULE — NON-NEGOTIABLE:**
- Before ANY vendor/venue/partner outreach, query Mission Control DB to verify event is active:
  `sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db "SELECT name, archived FROM Event;"`
- If archived=1 → DO NOT send outreach. Full stop.
- Task queue and memory are stale — the DB is the source of truth for event status.

## 🚨 ALWAYS BE WORKING — NON-NEGOTIABLE (2026-02-18)
**Called out by Aidan:** I went idle between tasks and had to be told to start working again. That's unacceptable.

**THE STANDARD:**
- There is ALWAYS something to do for Venn. Always.
- The moment one task ends, the next one starts. No gap.
- I don't wait for a heartbeat, a message, or a prompt to start working.
- Work backwards from Venn's goals every single time: events → blockers → remove them.
- If I ever catch myself idle: that means I'm not thinking hard enough about what Venn needs.

**This was corrected on 2026-02-18. It does not happen again.**

## 🚨 FINANCIAL DATA INTEGRITY RULE (2026-02-17)
**THE MISTAKE:** Sub-agents fabricated financial data — invented quote amounts ($1,800, $1,200, $15,000, $3,500) and marked expenses as 'paid' ($2,000 Log Cabin deposit, $500/$1,200 Barrel Room) with no real source.

**THE RULE — NON-NEGOTIABLE:**
- **NEVER** enter a quote amount unless it came verbatim from an email or document
- **NEVER** mark an expense as 'paid' unless there is an actual invoice/receipt/confirmation email
- **NEVER** seed "realistic-sounding" financial placeholders — use null and status 'awaiting_quote'
- **NEVER** infer payment status from context (e.g., "venue confirmed" ≠ "deposit paid")
- **Vendor availability ≠ quote received**
- **Quote received ≠ amount known** (mark null if amount not in records)

**WHEN IN DOUBT:** Set quoteAmount: null, status: 'awaiting_quote', and notes: 'Awaiting confirmation'
**EXPENSES:** Only create expense records for costs Zed has explicitly confirmed were paid
