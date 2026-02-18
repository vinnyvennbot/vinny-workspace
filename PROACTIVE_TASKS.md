# PROACTIVE_TASKS.md — Self-Generated Work Queue

When idle (no urgent emails, no active fires), pick from this list and execute.
Mark done with ✅ and date. Add new tasks at the bottom as they're identified.

## Mental Model — How to Stay Proactive
The list is a buffer, not the system. When it's empty, don't wait — think:
1. What does Venn need to move forward RIGHT NOW? (active events, revenue, vendor pipeline, brand)
2. What's blocking that? (missing quote, no venue, no outreach, missing data)
3. Go remove that blocker.

Always work backwards from Venn's goals. There is always something useful to do:
research, outreach, build, analyze, write, follow up, improve Mission Control, find new partners,
draft content, study the market, improve existing workflows. Idle = not thinking hard enough.

## Standing Rules
- Never sit idle more than one heartbeat cycle without doing something useful
- The list is a starting point — generate new tasks from first principles when it runs out
- Prioritize by revenue / event impact first, then ops, then improvements
- **🚨 BEFORE ANY VENDOR/VENUE OUTREACH:** Query Mission Control DB to confirm event is NOT archived
  ```bash
  sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db "SELECT name, archived FROM Event WHERE name LIKE '%EventName%';"
  ```
  If archived=1 → DO NOT send any outreach. Remove task from queue.

---

## 🔴 High Priority (Revenue / Event Impact)

- [ ] Follow up with Bimbo's 365 and Swedish American Hall naturally when they respond (correct date to March 28 in context, don't send standalone correction — unprofessional)
- [ ] Follow up with Tracey Lyons (Presidio Golf Clubhouse) — no response yet on western event inquiry
- ✅ 2026-02-18: Riggers Loft CLOSED (Richmond City Council issues) — removed from venue list
- [ ] Follow up with Stable Cafe (Karen Ortiz) — no response yet
- [ ] Get JustINtertainment actual quote amount (pricing received Feb 12 but amount not confirmed)
- [ ] Follow up on 8 overdue partner relationships (SF Social Club, Silver Cloud, Best Day Brewing, etc.)
- [ ] Remind Zed: Log Cabin contract hold expires ~Thu Feb 19 — decision needed

## 🟡 Medium Priority (Operations / Databases)

- [ ] Add all new vendor quote data to Google Sheets as responses come in
- ✅ 2026-02-18: Researched backup western venues (see below) — 5 options compiled
  **BACKUP WESTERN VENUES (if Log Cabin falls through):**
  1. **Sundance Saloon SF** — 550 Barneveld Ave, SF. Actual country-western dance venue. (415) 820-1403. LGBTQ+ bar, Sundays 5-10:30 PM. Potential private buyout or co-host. Contact: sundancesaloon.org
  2. **Presidio Golf Clubhouse** — Already in contact via Tracey Lyons (Presidio Events / Wedgewood). Follow-up email sent Feb 17, 24h hits ~11:30 AM today.
  3. **Pie Ranch Barn** — Half Moon Bay, 150-person barn capacity. Great rustic/farm aesthetic. pieranch.org - site rentals available.
  4. **Fox Haven Ranch (Peerspace)** — "Old western town" with saloon bar, pool table, shuffleboard. Direct Peerspace booking. peerspace.com/spaces/san-francisco--ca/barn-venue
  5. **Swedish American Hall** — Already outreached Feb 17. 24h follow-up due ~10 AM today.
  ❌ **Riggers Loft** — CLOSED. Richmond City Council issues. Facebook shows "Opening Soon." Remove from all lists.
  ❌ **Long Branch Saloon & Farms (Half Moon Bay)** — $17K-$20K minimum. Too expensive.
- ✅ 2026-02-18: EVT-003 Gatsby — 9 vendors contacted (3 catering, 4 photo, 3 AV/lighting). 5 more need email verification before outreach (call first: KC Catering, Above & Beyond, Drew Altizer, Impact SF, AVT Productions)
- [ ] Confirm EVT-004 yacht date — Red & White Fleet ($10,800) still waiting on date to finalize
- [ ] Draft EVT-001 marketing copy for when venue is confirmed
- [ ] Research SF community orgs for EVT-003 Gatsby partnership opportunities
- [ ] Find correct emails for Volo, No Days Wasted, Persona, Foundess (no contact info yet)

## 🔵 Improvements / Strategic

- [ ] Build "Email Sync" button for Mission Control Financials tab
- [ ] Add outreach pipeline view to Mission Control (track % contacted → responded → quoted → booked)
- [ ] Research SF event permit requirements (SFRPD vs private venue differences)
- [ ] Compile western line dancing instructor leads for EVT-001 (lesson = engagement + entertainment)
- [ ] Analyze ticket pricing benchmarks for SF social events ($40-70/person range)
- [ ] Draft Venn partnership one-pager template for sponsor outreach

## ✅ Completed
- ✅ 2026-02-17: CRM People tab populated with 35 contacts from email scan
- ✅ 2026-02-17: CRM People filter UI cleaned up (chip rows → clean dropdowns)
- ✅ 2026-02-17: Financials tab redesigned (3-tab system)
- ✅ 2026-02-17: All fabricated financial data removed and corrected
- ✅ 2026-02-17: CRM Venues/Vendors/Partners populated from email scan (in progress)
