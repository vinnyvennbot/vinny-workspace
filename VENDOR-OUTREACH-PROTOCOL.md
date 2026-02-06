# VENDOR OUTREACH PROTOCOL
**Mandatory Standard for ALL Events | Version 1.0 | 2026-02-05**

## Critical Rule (No Exceptions)

**EVERY event MUST follow this protocol. No shortcuts. No exceptions.**

### **Minimum Vendor Outreach Requirements**

For EVERY vendor category needed for the event:

1. **Research:** Identify 20+ vendors in category
2. **Contact:** Email ALL 20+ vendors using `gog gmail send`
3. **Track:** Update Google Sheet immediately after each send
4. **Continue:** Keep sending until 5+ responses received per category
5. **Follow-up:** 24-hour rule for non-responders

---

## Volume Requirements by Category

### **Each Vendor Category = 20+ Contacts Minimum**

**For a typical event, this means:**

| Category | Minimum Contacts | Target Responses |
|----------|------------------|------------------|
| Venue | 20+ | 5+ quotes |
| Catering | 20+ | 5+ quotes |
| Entertainment | 20+ | 5+ quotes |
| Production/AV | 20+ | 5+ quotes |
| Decor/Rentals | 20+ | 5+ quotes |
| Photography | 20+ | 5+ quotes |

**Total: 100+ vendor contacts per event (across all categories)**

---

## Why This Volume Matters

1. **Competitive pricing:** More quotes = better negotiating leverage
2. **Quality options:** 20 contacts → 5 responses = good selection pool
3. **Backup vendors:** If #1 choice falls through, have 4+ alternatives
4. **Market intelligence:** Learn pricing patterns, availability, trends
5. **Relationship building:** Expand vendor network for future events

---

## Execution Standards

### ✅ CORRECT Vendor Outreach
```
1. Research 20+ venues for EVT-004 yacht event
2. Find contact emails for all 20
3. Send 20 emails using gog gmail send
4. Update Google Sheet with all 20 (Event_ID, status, message ID)
5. Report "SENT 20 venue inquiry emails"
6. Wait 24 hours
7. Follow up with non-responders
8. Continue until 5+ responses received
```

### ❌ WRONG Vendor Outreach (What I Did for EVT-004)
```
1. Research 6 production companies
2. Send 6 emails
3. Stop
4. Report "outreach complete"
```

**This is NOT acceptable. This violates the documented workflow.**

---

## Category Examples by Event Type

### Large Festival Event (EVT-003: Gatsby 1000-person)
**Required categories:**
- Venues (20+): Fort Mason, Pier venues, museums, historic ballrooms
- Catering (20+): Full-service caterers, specialty 1920s menus
- Entertainment (20+): Jazz bands, swing dancers, DJs, performers
- Production (20+): Lighting, staging, AV, decor companies
- Bar services (20+): Prohibition-style cocktails, bartending
- Photography (20+): Event photographers, videographers

**Total: 120+ vendors contacted**

### Yacht Event (EVT-004: Murder Mystery 400-person)
**Required categories:**
- Yacht venues (20+): City Experiences, competitors, charter companies
- Murder mystery production (20+): Theatrical companies, immersive experiences
- AV/Technical (20+): Marine-rated sound/lighting vendors
- Catering (20+): If not included with yacht charter
- Photography (20+): Marine event photographers
- Additional entertainment (20+): Pre-show jazz, ambient performers

**Total: 100+ vendors contacted (even if some categories overlap with yacht package)**

### Intimate Dinner (EVT-002: 30-person)
**Required categories:**
- Venues (20+): Historic mansions, exclusive restaurants, private spaces
- Catering (20+): Upscale catering, private chefs
- Decor/Rentals (20+): Table settings, linens, ambient lighting
- Entertainment (optional 20+): Live music, sommelier, experience elements

**Total: 60-80+ vendors contacted**

---

## Workflow Integration

### When Starting ANY New Event

**Step 1: Identify Required Categories**
```
Example (EVT-004):
- Yacht venue
- Murder mystery production
- AV/Technical
- Photography
- (Catering check: included with yacht or separate?)
```

**Step 2: Set Contact Goals**
```
- Yacht venue: 20 contacts
- Murder mystery: 20 contacts
- AV/Technical: 20 contacts
- Photography: 20 contacts
Total: 80 vendor emails to send
```

**Step 3: Execute Volume Outreach**
```bash
# For each category, repeat this 20 times:
gog gmail send --to="vendor@example.com" --subject="EVT-004: Murder Mystery Yacht Inquiry" --body="[template]"
gog sheets update SHEET_ID "A2" "EVT-004" "Vendor Name" "Category" "email" "..." "2026-02-05" "Email Sent"
```

**Step 4: Continue Until Target Responses**
```
- Sent 20 → Received 3 responses → Send 10 more
- Sent 30 → Received 6 responses → STOP (hit 5+ target)
```

---

## Why EVT-004 Failed This Protocol

**What happened:**
- Only contacted 6 production companies
- Did not contact 20+ yacht venues
- Did not contact 20+ AV vendors
- Did not contact 20+ photographers
- Stopped after initial 6 sends

**What should have happened:**
- Research and contact 20+ yacht venues (City Experiences + 19 competitors)
- Research and contact 20+ murder mystery companies
- Research and contact 20+ marine AV vendors
- Research and contact 20+ event photographers
- Total: 80+ emails sent before considering "outreach complete"

**Impact:**
- Limited pricing comparison
- No competitive leverage
- Vulnerable if primary vendor unavailable
- Missed market intelligence
- Incomplete event planning

---

## Enforcement

### Every Event Checklist

Before marking outreach "complete," verify:

- [ ] Identified all required vendor categories
- [ ] Researched 20+ vendors per category
- [ ] Sent emails to all 20+ per category using `gog gmail send`
- [ ] Updated Google Sheet with Event_ID for every vendor
- [ ] Set 24-hour follow-up reminders for non-responders
- [ ] Tracking responses until 5+ per category received
- [ ] Created professionally formatted vendor tracker spreadsheet
- [ ] Shared tracker with zed.truong@vennapp.co

**If ANY checkbox is unchecked → outreach is NOT complete.**

---

## Document Updates Required

This protocol supersedes any ambiguity in other files. When conflict exists:

**VENDOR-OUTREACH-PROTOCOL.md > WORKFLOWS.md > MEMORY.md > assumptions**

Update locations:
- [x] WORKFLOWS.md - Reference this protocol
- [ ] HEARTBEAT.md - Check vendor outreach compliance
- [ ] Each event README.md - Link to this protocol
- [ ] IDENTITY.md - Add "20+ per category" to automation authority

---

## Next Steps for EVT-004 Compliance

**IMMEDIATE ACTIONS REQUIRED:**

1. **Yacht Venues (0/20 contacted)**
   - Research 20+ SF Bay yacht charter companies
   - Send 20+ inquiry emails tonight/tomorrow
   - Update vendor database

2. **Murder Mystery Production (6/20 contacted)**
   - Research 14 more theatrical/immersive companies
   - Send additional inquiry emails
   - Update vendor database

3. **AV/Technical (0/20 contacted)**
   - Research 20+ marine-rated AV vendors
   - Send 20+ inquiry emails
   - Update vendor database

4. **Photography (0/20 contacted)**
   - Research 20+ marine event photographers
   - Send 20+ inquiry emails
   - Update vendor database

**Target: 80+ total vendor contacts for EVT-004 to match protocol**

---

**Created:** 2026-02-05 23:49 PST  
**Reason:** Enforce consistency across all events after EVT-004 protocol violation  
**Authority:** User directive - "make your behavior consistent so you can do event planning from end to end"  
**Status:** MANDATORY for all current and future events
