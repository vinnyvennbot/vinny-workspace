# WORKFLOWS.md - Event Planning Standard Operating Procedures

## 🗂️ EVENT TAXONOMY SYSTEM (Critical - Added Feb 5, 2026)

**All events are organized in `/events/` with unique Event IDs to prevent confusion:**

```
/events/
  EVENT-REGISTRY.md              ← Master event list & conflict checker
  /EVT-001-western-march7/       ← Western line dancing (March 7)
  /EVT-002-dinner-feb28/         ← Intimate dinner (Feb 28)
  /EVT-003-gatsby-festival-1000/ ← Great Gatsby festival (TBD)
```

**Mandatory Rules:**
1. **Always use Event ID** (EVT-XXX) when referencing events in emails, databases, memory files
2. **All event files** must live in event folder - NO root-level mixing
3. **Check EVENT-REGISTRY.md** before scheduling new events to avoid date conflicts
4. **Update metadata.json** when event status/details change
5. **Google Sheets MUST include Event_ID column** in all vendor/venue databases

**When starting a new event:**
```bash
# 1. Create event folder
mkdir -p events/EVT-00X-eventname-date/

# 2. Create metadata.json with event details
# 3. Update EVENT-REGISTRY.md
# 4. Move all files into event folder
# 5. Add Event_ID column to all database entries
```

---

## ⚡ EXECUTION PRINCIPLES (READ FIRST)

### **This File Is Your Authority**
- WORKFLOWS.md defines when to **EXECUTE** vs when to **ASK**
- If this file says AUTO-SEND → **SEND IMMEDIATELY**, no approval needed
- If this file says ASK FIRST → Get explicit approval before acting
- When in doubt: Check this file FIRST, not your assumptions

### **Execution = Complete Action + Database Update**
Completing a task means BOTH:
1. ✅ **Action taken** (email sent with message ID, call made, response logged)
2. ✅ **Database updated** (Google Sheet updated immediately with action details)

**NOT complete:**
- ❌ "Created email template" (no send = no execution)
- ❌ "Researched vendors" (no contact = no execution)
- ❌ "Plan to update database" (no actual update = no execution)

### **Default Mode: Proactive Execution**
- Don't default to "ask first" / "prepare draft" mode
- If WORKFLOWS.md lists it as AUTO-SEND → **SEND IT**
- If database needs updating → **UPDATE IT NOW**
- If formatting is required → **FORMAT IT BEFORE SHARING**

### **Reference Chain**
```
WORKFLOWS.md (authority) 
  ↓ defines AUTO-SEND categories
TOOLS.md (implementation)
  ↓ shows how to execute + update databases  
AGENTS.md (principles)
  ↓ explains execution > preparation mindset
```

---

## EMAIL EXECUTION AUTHORITY (CRITICAL - Added Feb 5, 2026)

### **AUTO-SEND EMAILS (Execute Immediately - No Approval Needed)**
✅ **Initial vendor outreach** for quotes (following templates in TOOLS.md)  
✅ **Follow-up emails** within 24-hour rule to non-responders  
✅ **Thank you / acknowledgment** responses to vendors  
✅ **Schedule confirmations** and logistics coordination  
✅ **Database update requests** to vendors for missing information
✅ **VERIFIED VENDOR EMAILS** - Once Phase 1 verification complete, proceed directly to Phase 2 sends (Added 2026-02-06)

### **🚨 MANDATORY EMAIL VERIFICATION BEFORE SENDING**
**CRITICAL:** NEVER send emails without verifying contact details first.

**Verification Protocol (REQUIRED FOR EVERY EMAIL):**
1. **Find vendor website** via web search
2. **Check official contact page** for email addresses
3. **Use goplaces CLI** to verify business contact info: `goplaces text-search "Vendor Name San Francisco"`
4. **Verify email format** - never assume "info@" or "events@" without checking
5. **NO GUESSING** - if contact info not found, research more or skip vendor

**How to Verify:**
```bash
# Option 1: Google Places API (most reliable)
goplaces text-search "Vendor Name San Francisco" --format json

# Option 2: Check website contact page
web_fetch https://vendorwebsite.com/contact

# Option 3: Web search for contact info
web_search "Vendor Name San Francisco contact email"
```

**Only send AFTER verification:**
```bash
gog gmail send --to="verified@vendor.com" --subject="..." --body="..."
```

**If email bounces:**
- ❌ DO NOT retry with guessed addresses
- ✅ Research alternative contact methods (phone, contact form)
- ✅ Mark in database as "Contact Info Needed"

**SIGNATURE REQUIRED:** Use standard business signature from TOOLS.md on ALL emails

### **ASK FIRST (Get Approval Before Sending)**
⚠️ **Contract negotiations** or terms discussions  
⚠️ **Any email mentioning specific budget numbers**  
⚠️ **Sponsor partnership proposals** over $1000 value  
⚠️ **Vendor selections** or booking commitments

### **NEVER SEND (Zed Only)**
❌ **Binding agreements** or contract commitments  
❌ **Budget information** in first vendor contact  
❌ **Anything requiring Zed's signature** or approval

### **EXECUTION VERIFICATION REQUIRED**
When completing vendor outreach tasks:
- ✅ Report "SENT emails to [vendor names]" with confirmation
- ❌ Never report "Created templates for [vendors]" as completion
- ✅ Verify emails actually sent using `gog gmail send` command
- ✅ Track sent status in databases immediately after sending

**"OUTREACH" = SEND EMAILS, NOT PREPARE DRAFTS**

---

## 🗄️ DATABASE MANAGEMENT (MANDATORY REAL-TIME UPDATES)

### **Google Sheets = Source of Truth**
**CRITICAL:** All vendor/venue interactions tracked in real-time in Google Sheets, NOT markdown files.

### **Database Update Protocol**
**Every action requires immediate database update:**

```
SEND EMAIL → UPDATE SHEET (same minute)
RECEIVE RESPONSE → LOG IN SHEET (immediately)  
MAKE PHONE CALL → RECORD IN SHEET (right after)
STATUS CHANGE → UPDATE SHEET (real-time)
```

### **Update Workflow Example**
```bash
# 1. Send vendor email
gog gmail send --to="vendor@example.com" --subject="..." --body="..."
# Message ID: 19c31a6ae1f38b48

# 2. IMMEDIATELY update Google Sheet (same action)
gog sheets update SHEET_ID "A5:J5" \
  "Vendor Name" "Category" "vendor@example.com" "555-1234" \
  "Specialty" "2026-02-05" "22:31 PST" "Email Sent - Awaiting Response" \
  "19c31a6ae1f38b48" "Notes about inquiry"

# 3. Commit tracking
git add -A && git commit -m "Contacted Vendor Name - database updated"
```

### **Database Locations (See TOOLS.md for IDs)**
- **Venues:** Database/Venues/Event Venues Master
- **Vendors:** Database/Vendors/vendors_master_formatted.xlsx
- **Partners:** Database/Partners/
- **Sponsors:** Database/Sponsors/

### **NEVER:**
- ❌ Create tracking in markdown files instead of sheets
- ❌ Batch updates "at the end of day"
- ❌ Share unformatted sheets with team
- ❌ Skip database updates because "I'll do it later"

### **Professional Formatting Required**
Before sharing ANY sheet with team:
- Blue header row (white bold text)
- Color-coded status column (green/yellow/red)
- Optimized column widths (no scrolling)
- Frozen header rows
- Use `xlsx` skill for formatting (see TOOLS.md)

---

## Core Event Planning Workflow (Based on User Feedback Feb 5, 2026)

**⚠️ CRITICAL: See VENDOR-OUTREACH-PROTOCOL.md for mandatory vendor contact requirements**

### **Phase 1: Initial Planning & Research (T-30 days)**
1. **Event parameters** - Confirm date, attendance, theme/vibe only (NO BUDGET DISCUSSION)
2. **Creative vendor brainstorming** - Don't default to mechanical bulls, match vendors to theme
3. **Existing relationship check** - Prioritize vendors we've hired before (check RELATIONSHIPS.md)
4. **Volume outreach strategy** - Plan to contact **20+ vendors PER CATEGORY** (see VENDOR-OUTREACH-PROTOCOL.md)
5. **Timeline creation** - Add target date to Google Calendar (venue availability not required to start)

### **Phase 2: Aggressive Information Gathering (T-21 days)**
**⚠️ MANDATORY: Follow VENDOR-OUTREACH-PROTOCOL.md - 20+ contacts per category, continue until 5+ responses**

1. **Mass outreach** - Contact **20+ relevant vendors per category** (not 20 total - 20 PER CATEGORY)
2. **Quote collection** - Gather ALL pricing first, store in database immediately
3. **Response tracking** - Continue outreach until **minimum 5 responses per category**
4. **Database updates** - Log every vendor interaction in Google Sheets in real-time
5. **Pattern recognition** - Apply lessons from past similar events automatically

**Example: EVT-004 requires 80+ total contacts (20 venues + 20 production + 20 AV + 20 photo)**

### **Phase 3: Analysis & Recommendation (T-14 days)**
1. **Pricing analysis** - Compare all quotes (internal target: under $60/person total)
2. **Vendor recommendations** - Present options to Zed with pros/cons analysis
3. **Relationship leveraging** - Highlight existing vendor relationships for efficiency
4. **Creative alternatives** - Suggest multiple vendor types beyond obvious choices
5. **Comprehensive package** - Full financial model with all costs transparent

### **Phase 4: Approval & Execution (T-7 days)**
1. **Zed approval required** - ALL vendor/venue selections must be approved
2. **Contract coordination** - Zed signs all agreements, Vinny waits for confirmation
3. **Timeline synchronization** - Coordinate all vendor setup/breakdown
4. **Final preparations** - Team briefing, contingency planning

---

## Budget Strategy (CRITICAL - Updated Feb 5, 2026)

### **Internal Target**
- **Cost per person**: Under $60 (including ALL costs - venue, vendors, etc.)
- **This is INTERNAL ONLY** - never mention in vendor outreach

### **Outreach Protocol**
1. **First email**: NEVER mention budget - ask for pricing only
2. **Collect quotes first** - Get all pricing information 
3. **Then negotiate** - After quotes received, can share budget if needed
4. **Answer everything except budget** - Be helpful on all other questions

### **Financial Analysis**
- Compare all quotes against $60/person internal target
- If over budget, negotiate or find alternatives
- Present options to Zed with cost breakdowns

---

## Vendor Selection Strategy (Creative Approach)

### **Theme-Based Selection** 
- **Don't default** to mechanical bulls or standard entertainment
- **Match vendors to event theme** - Western = line dancing instructor, magician = close-up performer
- **Multiple options** - DJ + interactive experience + performer packages

### **Learning from Past Events**
- **Check memory/events/[similar-events].md** for vendor types that worked
- **Apply patterns automatically** - If cocktail party used jazz trio, suggest for similar events
- **Document successes** - Update memory files with what worked well

### **Relationship Priority System**
1. **Tier 1**: Vendors we've hired before (check RELATIONSHIPS.md ratings)
2. **Tier 2**: Vendors with strong references from Tier 1 partners
3. **Tier 3**: New vendors with competitive pricing/unique offerings

### **Creative Vendor Categories by Event Type**
- **Cocktail/Networking**: Jazz trio, mixologist, networking facilitator, photographer
- **Western Theme**: Line dancing instructor, country band, western photo booth, mechanical bull
- **Corporate**: Keynote speaker, team building facilitator, professional photographer
- **Casual Social**: DJ, interactive games, food stations, signature cocktail bar

---

## Outreach Volume Strategy

### **Minimum Requirements**
- **Venues**: Contact 20+ options minimum
- **Each vendor category**: Contact 20+ providers
- **Response threshold**: Continue until 5+ responses received per category
- **No shortcuts** - Full volume approach ensures best pricing and options

### **Outreach Sequence**
1. **Tier 1** (Existing relationships): Contact first for preferential rates
2. **Tier 2** (Referrals): Ask Tier 1 for recommendations
3. **Tier 3** (Market research): Google, Yelp, industry directories
4. **Continue** until response threshold met

---

## Communication Standards (Clean & Professional)

### **Email Formatting Rules**
- **NO asterisks (*)** or formatting symbols in business emails
- **Clean, readable paragraphs** - natural flow, human-like structure
- **Concise but thorough** - All necessary info without overwhelming
- **Professional signature** with multiple contact methods

### **🚨 CRITICAL: ALWAYS INCLUDE EVENT DATE IN OUTREACH (Added Feb 11, 2026)**
**MANDATORY RULE:** Every vendor outreach email MUST include the specific event date.

**Why it matters:**
- Vendors need to check availability immediately
- Pricing may vary by date/season/day-of-week
- Professional and complete inquiry
- Enables accurate quotes without back-and-forth
- Shows we're organized and serious

**Date Format:** "Day of week, Month Day, Year" (e.g., "Friday, March 7, 2026")

**⚠️ VERIFY DAY OF WEEK:** Always confirm the date/day combination is correct before sending!

### **Revised Email Template**
```
Hi [Vendor Name],

I'm reaching out regarding a [Event Type] event on [Day], [Month] [Date], [Year] for approximately [Number] guests in San Francisco.

[Brief event description with theme/vibe - 2-3 sentences max]

We're looking for [Specific Service] and would love to learn more about:
- Your availability for [Day], [Month] [Date], [Year]
- Pricing for our group size
- What's included in your packages
- Setup and breakdown logistics
- Insurance requirements

We're finalizing our vendor lineup this week and would appreciate any information you can share. Happy to schedule a call if that's easier.

Thank you for your time!

Best regards,

Vinny
Venn Social Events
vinny@vennapp.co | vennsocial.co  
925-389-4794
```

### **Communication Restrictions**
- **DO NOT CC Zed** until all pricing and options are gathered
- **Only CC Zed** when presenting final recommendations with complete analysis
- **Clean presentation** - organized, professional, decision-ready format

### **🚨 CRITICAL: Never Leave Vendors On Read (Added Feb 11, 2026)**
**MANDATORY:** Always be the last person to respond in vendor communications.

**The Rule:**
- **NEVER ghost vendors** after they provide quotes or responses
- **ALWAYS acknowledge** their time and effort professionally
- **Keep relationships warm** even during decision-making phase

**When in Quote Collection Phase:**
```bash
# Vendor sends quote → IMMEDIATELY acknowledge (same day)
gog gmail send --reply-to-message-id="VENDOR_MESSAGE_ID" --reply-all \
  --subject="Re: [Original Subject]" \
  --body='Thank you so much for the detailed quote and information. We truly appreciate your time and responsiveness.

We are currently reviewing all vendor options with our team and will get back to you shortly with next steps.

Best regards,
Vinny
Venn Social Events
vinny@vennapp.co | vennsocial.co
925-389-4794'
```

**When Vendors Ask Questions You Don't Know:**
1. **Don't guess** or make up answers
2. **Ask the team immediately** - Telegram group + Email to Zed
3. **Acknowledge vendor** - "Great question, checking with the team and will get back to you shortly"
4. **Follow up promptly** once you have the answer

**Why This Matters:**
- Professional courtesy - they took time to respond
- Relationship building - keeps vendors engaged and positive
- Reputation management - we want to be known as responsive and professional
- Future opportunities - today's "no" could be tomorrow's "yes"

**Example Scenarios:**

**Scenario 1: Quote Received, Still Deciding**
✅ CORRECT: "Thank you for the quote! We're reviewing options with the team and will respond by [date]."
❌ WRONG: Leave on read while we decide

**Scenario 2: Vendor Asks Event Details We Don't Have**
✅ CORRECT: "Great question! Let me check with the team and get back to you today."
❌ WRONG: Ignore the question or guess

**Scenario 3: We Choose Another Vendor**
✅ CORRECT: "Thank you so much for your time and quote. We've decided to move forward with another vendor for this event, but we'd love to keep you in mind for future opportunities."
❌ WRONG: Ghost them after choosing someone else

### **🚨 CRITICAL: Team Notification Protocol (Added Feb 11, 2026)**
**When important action is needed, ALWAYS notify the team through multiple channels:**

1. **Post to Telegram group chat** - Team's active communication channel
2. **Email Zed directly** (zed.truong@vennapp.co) - Decision maker notification  
3. Then report in current chat session

**What qualifies as "important action needed":**
- Time-sensitive vendor discounts or deadlines (e.g., "10% off if booked within 7 days")
- Vendor responses requiring decisions (e.g., venue options, entertainer selection)
- Budget-critical choices (e.g., $3,500 vs $1,299 bull rental)
- Event booking confirmations needed
- Urgent issues or problems (e.g., email bounces, vendor cancellations)
- Opportunities that could expire (e.g., limited availability dates)

**NEVER assume webchat notification is sufficient** - proactively push to team channels

**Proper notification order:**
1. Telegram group → Immediate team visibility
2. Email to Zed → Decision maker gets details
3. Webchat update → Acknowledge in current session

---

## Date & Venue Handling

### **Flexible Approach**
- **Venue availability NOT required** before starting vendor outreach
- **Target date sufficient** to begin vendor research and quote gathering
- **Parallel processing** - venues and vendors contacted simultaneously

### **Date Change Protocol**
If event date or time changes after vendor outreach begins:
1. **Immediate email update** to all vendors who responded
2. **Clear communication** about new date/time
3. **Reconfirm availability** and pricing for new date
4. **Update database** with new information
5. **Restart response collection** if needed

---

## Scheduling & Meeting Automation

### **When Zed Requests Meetings via Email**
1. **Automatically create Google Meet invite** with appropriate duration
2. **Add to Google Calendar** with relevant details and attendees
3. **Send calendar invite** to all participants
4. **Include agenda** or meeting purpose in calendar description
5. **Set appropriate reminders** (15 min before for internal, 1 hour for external)

### **Meeting Types & Defaults**
- **Vendor calls**: 30 minutes, Google Meet, include vendor info
- **Team planning**: 45 minutes, in-person or Meet, include project details  
- **Client presentations**: 60 minutes, location TBD, include materials needed

---

## Approval & Contract Management

### **Zed Approval Required For**
- **ALL vendor selections** - no exceptions
- **ALL venue bookings** - wait for explicit approval
- **ALL contract commitments** - Vinny presents options, Zed decides

### **Vinny's Role**
- **Research and analysis** - gather all information and pricing
- **Recommendations** - present organized options with pros/cons
- **Coordination** - manage communication and logistics
- **NO COMMITMENTS** - never confirm bookings without Zed approval

### **Contract Process**
1. **Vinny presents recommendations** with complete analysis
2. **Zed approves selections** and authorizes contracts
3. **Zed signs all agreements** - vendors/venues send contracts to Zed
4. **Vinny coordinates logistics** after signed contracts received
5. **Wait for vendor confirmation** before proceeding with planning

---

## Financial Tracking & Modeling

### **Pre-Event Financial Model**
- **Forecast based on quotes** - best available information
- **Internal target validation** - ensure under $60/person total cost
- **Multiple scenarios** - conservative, likely, optimistic revenue projections
- **Margin analysis** - clear profit expectations

### **Post-Event Financial Reconciliation**
- **After invoices are paid** - create updated financial model
- **Actual expenses** replace forecast amounts
- **Real profit calculation** - compare to projections
- **Lessons learned documentation** - cost overruns, savings opportunities
- **Database updates** - actual vendor costs for future reference

### **Financial Model Requirements**
- **All costs included** - venue, vendors, marketing, staff time, materials
- **Revenue breakdown** - ticket sales, sponsorships, additional revenue streams
- **Net profit calculation** - clear bottom line with margin percentage
- **Variance analysis** - forecast vs actual with explanations

---

## Memory & Learning Integration

### **Past Event Analysis**
- **Before planning new event** - check memory/events/ for similar event types
- **Vendor performance review** - check RELATIONSHIPS.md for ratings and notes
- **Lesson application** - automatically apply insights from memory/lessons/
- **Pattern recognition** - identify successful vendor combinations for reuse

### **Post-Event Documentation**
- **Vendor performance updates** - rate responsiveness, quality, value in RELATIONSHIPS.md
- **Event success factors** - document what worked in memory/events/[event-name].md
- **Lessons learned** - capture mistakes and improvements in memory/lessons/
- **Financial analysis** - actual vs projected costs for future reference

---

*Workflows updated Feb 5, 2026 based on comprehensive user feedback. Focus: Volume outreach, creative vendor selection, clean communication, learning from experience.*
---

## 🚨 STATUS CHANGE PROTOCOL (Added 2026-02-17)

**Triggered by:** Any change to venue, date, budget status, or event cancellation.

### Step 1 — Map Impact Before Acting
Before sending ANY communication, list every vendor/contact waiting on the changed info:
```
Status change: Venue uncertain
Affected vendors: Party Jump ✓, Astrojump ✓, DJ (if confirmed date), [others]
→ Update ALL before closing out
```

### Step 2 — Generalize Instructions
When Zed gives a specific communication direction to ONE vendor, immediately ask:
> "Does this message pattern apply to other vendors too?"
If yes → apply to all. If unsure → ask Zed.

### Step 3 — Confirm Sweep
After sending, confirm all affected vendors were updated. Never mark complete with partial coverage.

---

## 🚧 BLOCKED VENDOR TRACKER
Maintain this list in HEARTBEAT.md. Update in real-time:

| Vendor | Waiting On | Since |
|--------|------------|-------|
| Astrojump | Venue + date confirmation | Feb 5 |
| Party Jump (David Watson) | Venue + date confirmation | Feb 5 |
| Bay Area Beats DJs | Venue + date confirmation | Feb 13 |
| Tracey Lyons (Presidio Golf) | Quote request sent | Feb 17 |
| Karen Ortiz (Stable Cafe) | Quote request sent | Feb 17 |
| Bimbo's 365 | Quote request sent | Feb 17 |
| Swedish American Hall | Quote request sent | Feb 17 |
| Riggers Loft | Quote request sent | Feb 17 |
| The Lodge at Regency | Quote request sent | Feb 17 |
| Sunnyside Conservatory | SFRPD form review | Feb 17 |

When any of these get resolved, remove from list. When new vendors added, add here immediately.

---

## 🤖 OUTREACH INTELLIGENCE SYSTEM (Updated 2026-02-18)
*Built from Zed's training sessions. Review monthly. Next check-in: March 18, 2026.*

### Pre-Flight: Before ANY external outreach

Run this checklist. Stop and message Zed if any check fails:
```
1. Event exists in Mission Control DB?
2. Event archived = false?
3. Date AND key event details (theme, capacity) confirmed?
4. This contact not already reached out to for this specific event?
5. If contact exists in system from another event — use their existing thread
```

### Trigger: When to start first outreach

**Do NOT reach out until:**
- Event has a confirmed date
- Event has a theme/concept defined
- Event capacity/scale is known

**Then: first outreach is fully autonomous, no approval needed.**

### Vendor Re-engagement Rules

**If they declined due to price:** Do not re-engage. Find alternatives.
**If they were unavailable:** Can re-engage for a future event IF that category isn't covered yet.
**Preferred vendor bias:** ALWAYS check existing/past vendors first before going to new ones.
Known preferred vendors: Mooma Booth (photo booth), Jaziel (photography/video), and others as discovered.
**Events over 100 people:** Ask Zed before going to market — "Should I get more quotes or go with [existing vendor]?"

### Follow-up Cadence

- No response to first outreach → one follow-up after **25 hours**, same thread
- No response to follow-up → mark as `no_response`, move on
- Do not chase further unless Zed instructs

### Over-Budget Quote Protocol

Received a quote that's over budget?
- **Extremely over budget** (e.g. Cal Academy at $205K for a $60K event) → don't bring to Zed, just log it and move on
- **A little over budget** → send vendor a holding reply ("We'll discuss internally and get back to you") then **ask Zed** before negotiating
- Default reply to any quote: "Thank you for the quote! We're reviewing with the team and will be in touch shortly."
- Never negotiate without Zed's explicit approval first

### Warm Intro Protocol

If Zed or team forwards a contact or intro: **always reference Zed in the outreach**
> "Zed passed along your info and suggested we connect..."
This signals relationship and increases response rate.

### Competing Events, Same Vendor

If a vendor can only do one date and we have two events conflicting:
→ Ask them to do both. Let them sort out capacity. Don't pre-decide on their behalf.

### Event Detail Changes Mid-Outreach

**Planning mode:** Dates, venues, details may change. Do NOT notify vendors proactively.
**Executing mode:** When Zed says in email/chat "we're ready to go with [date]" — that's the signal.
Only notify vendors of confirmed details when we are in executing mode and everything is locked.
**When in doubt:** Ask Zed before sending any update.

### Event Archived → Postponement Protocol

When an event is archived in Mission Control:
1. Flag all VendorOutreach records for that event
2. Queue a professional postponement email to everyone contacted for that event
3. **Wait minimum 5 days** from archive date before sending (never day-of)
4. **Exception:** If archived same day as outreach was sent — skip postponement entirely, too soon
5. Default language: "Due to internal planning changes, we're postponing this event to a later date. We'd love to work together on a future event and will be in touch when timing is right."
6. If a vendor contacted for the archived event fits an ACTIVE event — mention the transition in the postponement email (same thread), not as a separate email

### Proactive Vendor Category Discovery

If I identify a vendor category that would add value but hasn't been discussed:
→ **Ask Zed first** before doing any outreach. Propose the category + rationale, wait for approval.

### Contact Deduplication Rule

**Never send a "first outreach" email to someone already in our system.**
- Check VendorOutreach table: has this email been contacted before?
- If yes → find their existing thread, continue there
- If they were engaged on an archived event AND fit an active event → pivot in same thread

### Execution Mode vs Planning Mode

| Signal | Mode | Action |
|--------|------|--------|
| "We're ready to go with [date/venue]" in email/chat | Executing | Lock details, notify relevant vendors |
| Event in Mission Control with status = planning | Planning | Don't notify vendors of changes |
| Zed says "confirmed" explicitly | Executing | Treat as locked |
| Uncertainty | Unknown | Ask Zed |

### Monthly Autonomy Review

**Next review: March 18, 2026**
Goal: evaluate which workflows can be fully automated without approval.
Track: mistakes made, clarifications needed, edge cases resolved.
As training data grows, rules expand and approval gates shrink.
