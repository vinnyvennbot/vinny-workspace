# WORKFLOWS.md - Event Planning Standard Operating Procedures

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

**HOW TO SEND:**
```bash
gog gmail send --to="vendor@example.com" --subject="Great Gatsby Festival Inquiry" --body="[email content]"
```

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

### **Phase 1: Initial Planning & Research (T-30 days)**
1. **Event parameters** - Confirm date, attendance, theme/vibe only (NO BUDGET DISCUSSION)
2. **Creative vendor brainstorming** - Don't default to mechanical bulls, match vendors to theme
3. **Existing relationship check** - Prioritize vendors we've hired before (check RELATIONSHIPS.md)
4. **Volume outreach strategy** - Plan to contact 20+ venues/vendors minimum
5. **Timeline creation** - Add target date to Google Calendar (venue availability not required to start)

### **Phase 2: Aggressive Information Gathering (T-21 days)**
1. **Mass outreach** - Contact 20+ relevant vendors per category
2. **Quote collection** - Gather ALL pricing first, store in database immediately
3. **Response tracking** - Continue outreach until minimum 5 responses per category
4. **Database updates** - Log every vendor interaction in Google Sheets
5. **Pattern recognition** - Apply lessons from past similar events automatically

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

### **Revised Email Template**
```
Hi [Vendor Name],

I'm reaching out regarding a [Event Type] event on [Date] for approximately [Number] guests in San Francisco.

[Brief event description with theme/vibe - 2-3 sentences max]

We're looking for [Specific Service] and would love to learn more about:
- Your availability for [Date]
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