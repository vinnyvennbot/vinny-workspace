# Event Activation Playbook - Venn Social

**Purpose:** Step-by-step guide for activating an approved event from ideation to launch

**When to Use:** Immediately after event concept receives approval from Zed

**Timeline:** Typically 4-8 weeks from approval to event day (adjust based on event size/complexity)

---

## 📋 ACTIVATION PHASES OVERVIEW

**Phase 1: Foundation (Week 1)** - Venue lock, date confirmation, vendor outreach begins  
**Phase 2: Build (Weeks 2-4)** - Vendor contracts, marketing launch, ticket sales open  
**Phase 3: Polish (Weeks 5-6)** - Final confirmations, marketing push, logistics lock  
**Phase 4: Execution (Week 7-8)** - Event week prep, day-of coordination, post-event wrap

---

## PHASE 1: FOUNDATION (Week 1 - Days 1-7)

### Day 1: Event Approval Confirmation
- [ ] Update Event status in database: `planning` → `confirmed`
- [ ] Update readinessScore to 50+ (event now active)
- [ ] Set confirmed event date in database
- [ ] Create event-specific folder: `/events/EVT-XXX/`
- [ ] Copy budget template and customize for this event
- [ ] Create README.md with event overview

### Day 1-2: Venue Selection & Lock
- [ ] Review venue options from research phase (typically 3-5 researched)
- [ ] Verify venue availability for confirmed date
- [ ] Request hold on preferred venue (24-48 hour hold typical)
- [ ] Review contract terms (cancellation policy, deposit, insurance requirements)
- [ ] Negotiate pricing if applicable
- [ ] Submit venue deposit (typically 25-50% of total)
- [ ] Obtain signed contract
- [ ] Update database: Venue vendor status → `contracted`
- [ ] Add venue details to event README

**Venue Checklist:**
- Capacity confirmed for expected attendance
- Includes: tables, chairs, basic AV, bar access
- Load-in/load-out times negotiated
- Parking/transit access confirmed
- Insurance requirements documented
- Cancellation terms understood

### Day 2-3: Core Vendor Outreach (Volume Phase)
**MANDATORY: Follow VENDOR-OUTREACH-PROTOCOL.md checklist for EVERY email**

**Priority 1 - Critical Path Vendors (48-hour turnaround target):**
- [ ] DJ / Live Music (20+ contacts per VENDOR-OUTREACH-PROTOCOL)
- [ ] Catering (20+ SF caterers, theme-appropriate)
- [ ] Photography (10+ event photographers)

**Priority 2 - Theme-Specific Vendors:**
- [ ] Special entertainment (mechanical bull, games, performers, etc.)
- [ ] Decor rentals (if venue doesn't include)
- [ ] AV/Production (if venue doesn't include)

**Outreach Volume Rules:**
- 20+ contacts per major category (DJ, catering, venue alternatives)
- Continue until 5+ responses received per category
- Track in VendorOutreach database in real-time
- Update RELATIONSHIPS.md with new vendor interactions

**Outreach Tracking:**
```bash
# Check response rate
sqlite3 dev.db "SELECT category, COUNT(*) as contacted, 
SUM(CASE WHEN respondedAt IS NOT NULL THEN 1 ELSE 0 END) as responded 
FROM VendorOutreach WHERE eventId = 'EVT-XXX' GROUP BY category;"
```

### Day 3-4: Quote Collection & Analysis
- [ ] Review all vendor quotes as they arrive
- [ ] Create comparison spreadsheet (use budget template)
- [ ] Flag quotes that exceed budget allocation
- [ ] Identify top 2-3 options per category
- [ ] Check RELATIONSHIPS.md for confidence scores
- [ ] Prepare vendor recommendation brief for Zed

**Quote Analysis Framework:**
- Does quote include all needed services?
- Hidden fees or surprise costs?
- Vendor confidence score (from RELATIONSHIPS.md)
- References or portfolio available?
- Cancellation/refund policy acceptable?

### Day 5-6: Vendor Selection & Contracting
- [ ] Present top vendor options to Zed with recommendations
- [ ] Get approval on vendor selections
- [ ] Send contracts to approved vendors
- [ ] Negotiate final terms if needed
- [ ] Collect signed agreements
- [ ] Submit deposits (typically 25-50%)
- [ ] Update database: Vendor status → `contracted`
- [ ] Add vendor details to event README

### Day 6-7: Sponsor & Partner Outreach
- [ ] Review sponsor opportunities from research phase
- [ ] Create sponsor deck (tiers, benefits, pricing)
- [ ] Identify 10-15 potential sponsors aligned with theme
- [ ] Send sponsor outreach emails (follow protocol checklist)
- [ ] Track sponsor responses in database

**Sponsor Priorities:**
- Brand alignment with event theme
- Budget contribution potential ($500-$5,000 range)
- Mutual benefit (their audience + ours)
- Existing relationships (check RELATIONSHIPS.md first)

### Day 7: Week 1 Checkpoint
- [ ] Venue locked: ✅
- [ ] Date confirmed: ✅  
- [ ] Core vendors contracted (DJ, catering, photo): ✅ or in progress
- [ ] Budget model updated with actual quotes: ✅
- [ ] Sponsor outreach initiated: ✅
- [ ] Event README complete: ✅

**If Week 1 goals not met:** Escalate blockers immediately. Foundation delays compound quickly.

---

## PHASE 2: BUILD (Weeks 2-4 - Days 8-28)

### Week 2: Marketing Foundation

#### Day 8-9: Marketing Assets Creation
- [ ] Review Instagram content draft (from marketing prep)
- [ ] Review Eventbrite page draft (from marketing prep)
- [ ] Customize content for confirmed venue/date/vendors
- [ ] Design event poster (Canva or hire designer)
- [ ] Create Instagram Stories templates (5-slide series)
- [ ] Write email announcement for Venn list
- [ ] Prepare Reel script and B-roll shot list

#### Day 10-11: Eventbrite Setup
- [ ] Create event page with full description
- [ ] Upload hero image (2160x1080px, branded)
- [ ] Set up ticket tiers (Early Bird, GA, VIP, Group)
- [ ] Configure pricing and release schedule
- [ ] Set up automated email sequence (confirmation, reminders)
- [ ] Test ticket purchase flow
- [ ] Get Eventbrite link: `eventbrite.com/e/[event-name]`

#### Day 12-13: Marketing Launch
- [ ] Instagram announcement post (use drafted content)
- [ ] Instagram Stories series (5 slides)
- [ ] Email blast to Venn list
- [ ] Post to Venn website/blog
- [ ] Share to Facebook event page
- [ ] Tag venue, vendors, partners in posts
- [ ] Respond to comments/DMs within 2 hours

#### Day 14: Week 2 Checkpoint
- [ ] Eventbrite live: ✅
- [ ] Instagram announcement posted: ✅
- [ ] Email sent to list: ✅
- [ ] Early bird tickets selling: ✅ (monitor daily)
- [ ] Vendor contracts 100% signed: ✅

### Week 3: Ticket Sales & Partner Activation

#### Day 15-17: Sales Monitoring
- [ ] Check Eventbrite sales daily (morning)
- [ ] Track conversion rate (page views → sales)
- [ ] Identify drop-off points in purchase flow
- [ ] Adjust marketing if sales below target
- [ ] Update Mission Control database with sales data

**Sales Benchmarks (by week before event):**
- 6 weeks out: 20-30% sold (Early Bird period)
- 4 weeks out: 40-50% sold (GA opens)
- 2 weeks out: 60-75% sold (late push)
- 1 week out: 80-95% sold (near sellout)

#### Day 17-19: Sponsor Finalization
- [ ] Follow up with sponsors (24-hour rule)
- [ ] Lock sponsor agreements (signed contracts + payment)
- [ ] Deliver sponsor assets (logos, booth materials, etc.)
- [ ] Add sponsor logos to marketing materials
- [ ] Thank sponsors publicly (social media shoutout)

#### Day 20-21: Mid-Campaign Marketing Push
- [ ] Instagram Reel (30-45 sec teaser)
- [ ] Behind-the-scenes Stories (vendor prep, setup planning)
- [ ] Countdown posts ("4 weeks until...")
- [ ] Partner cross-promotion (tagged posts)
- [ ] Consider paid ads if sales below target ($50-200 budget)

### Week 4: Logistics Lock

#### Day 22-24: Vendor Confirmations
- [ ] Email all vendors: final headcount estimate
- [ ] Confirm arrival times (load-in schedule)
- [ ] Verify equipment needs (power, staging, etc.)
- [ ] Request vendor insurance certificates
- [ ] Create day-of vendor contact sheet

**Vendor Confirmation Template:**
"Hi [Vendor], event is [X] weeks away! Current attendance: [XX] guests. Confirming you're locked in for [date/time]. Please reply with: (1) Arrival time (2) Equipment needs (3) Final invoice amount. Thanks!"

#### Day 25-26: Permits & Insurance
- [ ] Verify all permits obtained (alcohol, noise, fire safety)
- [ ] Confirm event insurance active
- [ ] Submit final headcount to venue
- [ ] Review venue rules (sound curfew, decorations, cleanup)
- [ ] Obtain venue contact for day-of emergencies

#### Day 27-28: Week 4 Checkpoint
- [ ] All vendors confirmed: ✅
- [ ] Permits/insurance complete: ✅
- [ ] Ticket sales at 40-50%: ✅ or adjust marketing
- [ ] Sponsor partnerships locked: ✅

---

## PHASE 3: POLISH (Weeks 5-6 - Days 29-42)

### Week 5: Marketing Acceleration

#### Day 29-31: Content Blitz
- [ ] Daily Instagram Stories (event countdown)
- [ ] Carousel post: "What to Expect" (6-slide guide)
- [ ] Testimonials from past Venn events
- [ ] Venue tour video/photos
- [ ] "Meet the Vendors" spotlight posts
- [ ] Email reminder to list (for those who haven't bought)

#### Day 32-34: Influencer/Creator Partnerships
- [ ] Reach out to 5-10 SF creators for comp tickets
- [ ] Offer affiliate code (they earn $X per ticket sold)
- [ ] Request Instagram Story shoutouts
- [ ] Tag creators in event posts
- [ ] Track affiliate sales (Eventbrite analytics)

#### Day 35: Week 5 Checkpoint
- [ ] Ticket sales at 60-75%: ✅ or escalate marketing
- [ ] Influencer posts live: ✅
- [ ] Social engagement high (likes, comments, shares): ✅

### Week 6: Final Preparations

#### Day 36-38: Attendee Communications
- [ ] Email all ticket holders: event details & logistics
- [ ] What to wear / bring / expect
- [ ] Parking/transit instructions
- [ ] COVID/health policies (if applicable)
- [ ] Excitement-building content (sneak peeks)

#### Day 39-40: Day-Of Planning
- [ ] Create minute-by-minute event timeline
- [ ] Assign roles (who greets, who manages vendors, etc.)
- [ ] Create emergency contact sheet
- [ ] Prepare check-in system (tablets, printed list, QR codes)
- [ ] Plan setup/breakdown logistics

#### Day 41-42: Final Vendor Check-Ins
- [ ] Call all vendors: "See you in [X] days, everything confirmed?"
- [ ] Verify final headcount with catering
- [ ] Confirm photographer arrival time
- [ ] Double-check DJ equipment needs
- [ ] Review venue access (keys, codes, parking)

#### Day 42: Week 6 Checkpoint (Event Week!)
- [ ] Ticket sales at 80-95%: ✅
- [ ] All attendees emailed logistics: ✅
- [ ] Vendor confirmations 100%: ✅
- [ ] Day-of plan finalized: ✅
- [ ] Team briefed on roles: ✅

---

## PHASE 4: EXECUTION (Week 7+ - Event Week)

### 3 Days Before Event

#### Final Marketing Push
- [ ] Instagram Stories: 72-hour countdown
- [ ] "Last chance" email to list
- [ ] Final social media push
- [ ] Tag all partners/vendors for shares

#### Logistics Finalization
- [ ] Confirm final headcount with all vendors
- [ ] Print check-in list (backup for tech failures)
- [ ] Charge tablets for check-in
- [ ] Pack emergency supplies (tape, scissors, chargers, first aid)
- [ ] Confirm weather forecast (outdoor events)

### 1 Day Before Event

#### Setup Coordination
- [ ] Venue walkthrough (if possible)
- [ ] Review load-in schedule with venue
- [ ] Confirm vendor arrival times (text each vendor)
- [ ] Prepare signage (welcome, directional, sponsors)
- [ ] Test sound system (if arriving early)

#### Team Briefing
- [ ] Walk through timeline with all staff
- [ ] Assign emergency contacts
- [ ] Review check-in process
- [ ] Clarify roles (greeter, vendor liaison, tech support)

### Day-Of Event

#### Morning (8AM-12PM)
- [ ] Arrive at venue 2-3 hours early
- [ ] Oversee vendor load-in
- [ ] Set up check-in table
- [ ] Hang signage and decorations
- [ ] Test AV equipment
- [ ] Prep photo backdrop
- [ ] Confirm catering setup

#### Pre-Event (Doors -1 Hour)
- [ ] Final venue walkthrough
- [ ] Test lighting
- [ ] Ensure bathrooms stocked
- [ ] Charge devices
- [ ] Brief staff on last-minute changes
- [ ] Take venue photos (before guests arrive)

#### During Event
- [ ] Greet early arrivals
- [ ] Manage check-in flow
- [ ] Troubleshoot issues in real-time
- [ ] Capture content (photos, videos for socials)
- [ ] Monitor vendor performance
- [ ] Engage with guests (be visible, friendly)

#### Post-Event (Same Night)
- [ ] Thank attendees as they leave
- [ ] Oversee vendor breakdown
- [ ] Collect vendor feedback
- [ ] Venue walkthrough (ensure clean, no damage)
- [ ] Post "Thank you" Instagram Story
- [ ] Pack up all materials

---

## POST-EVENT WRAP (Days 1-7 After)

### Day After Event

#### Immediate Follow-Up
- [ ] Email all attendees: "Thank you for coming!"
- [ ] Share event photos (Instagram, Facebook)
- [ ] Tag attendees in photos (with permission)
- [ ] Request Google/Yelp reviews (if applicable)
- [ ] Thank vendors publicly (Instagram Stories)

#### Financial Reconciliation
- [ ] Collect final vendor invoices
- [ ] Pay outstanding balances
- [ ] Update budget template with actuals
- [ ] Calculate profit/loss
- [ ] Identify budget variances

### Week After Event

#### Performance Analysis
- [ ] Review ticket sales vs capacity (XX% sold)
- [ ] Analyze marketing effectiveness (which posts drove sales)
- [ ] Calculate cost per attendee
- [ ] Vendor performance review (update RELATIONSHIPS.md)
- [ ] Attendee feedback survey (Google Form or email)

#### Content Creation
- [ ] Edit highlight reel (30-60 sec video)
- [ ] Create photo album (Google Photos or Dropbox)
- [ ] Write event recap blog post
- [ ] Share testimonials from attendees
- [ ] Update portfolio/case studies

#### Documentation
- [ ] Update event README with final stats
- [ ] Document lessons learned
- [ ] Update MEMORY.md with key insights
- [ ] Flag successful vendors for future events
- [ ] Note any issues to avoid next time

---

## CRITICAL SUCCESS FACTORS

### Must-Haves for Every Event:
1. **Venue locked within 48 hours of approval** (delays cascade)
2. **20+ vendor contacts per major category** (ensures options + competitive pricing)
3. **Marketing launch within 7 days of approval** (ticket sales need time)
4. **All contracts signed 2+ weeks before event** (no last-minute chaos)
5. **Final vendor confirmations 3 days before** (catch issues early)

### Common Failure Points:
- Waiting too long to lock venue → Preferred dates book up
- Low vendor outreach volume → Limited quotes, higher prices
- Late marketing launch → Ticket sales slow, last-minute discounting
- No backup plans → Vendor cancellations become crises
- Poor day-of coordination → Guest experience suffers

### Mitigation Strategies:
- **Venue**: Always have 3 backup venues researched
- **Vendors**: 20+ contacts ensures 5+ responses minimum
- **Marketing**: Pre-draft content during ideation phase (saves time)
- **Backups**: Every critical vendor needs a backup option
- **Coordination**: Detailed timeline + role assignments prevent chaos

---

## EVENT SIZE ADJUSTMENT GUIDE

### Intimate Events (20-50 guests)
- Compress timeline: 3-4 weeks total activation
- Fewer vendor categories (venue, catering, optional photo)
- Lower marketing intensity (email + Instagram only)
- Single-person coordination often sufficient

### Mid-Size Events (50-150 guests)
- Standard 6-8 week timeline
- Full vendor roster (DJ, catering, photo, entertainment)
- Active marketing (Instagram, email, partnerships)
- 2-3 person coordination team

### Large Events (150-300 guests)
- Extended 8-12 week timeline
- Complex vendor coordination (AV, production, security)
- Paid marketing budget ($200-500)
- Full team coordination (4-6 people)

### Festivals (300+ guests)
- 12-16 week timeline minimum
- Multiple vendors per category (backup DJs, caterers)
- Significant marketing spend ($500-2,000)
- Professional event coordinator recommended

---

## AUTOMATION OPPORTUNITIES

### Database Updates (Manual → Automated)
- Auto-update readinessScore as vendors get locked
- Auto-track ticket sales from Eventbrite API
- Auto-flag vendor non-responses after 48 hours

### Marketing (Manual → Automated)
- Pre-schedule Instagram posts (Buffer, Later)
- Auto-email reminders (Eventbrite sequences)
- Countdown Stories (create templates, schedule)

### Vendor Management (Manual → Automated)
- Auto-send confirmation emails 7/3/1 days before
- Auto-request insurance certificates
- Auto-generate day-of contact sheet

---

**Playbook Version:** 1.0 (2026-03-04)  
**Last Updated:** 2026-03-04 15:01 PM PST  
**Created By:** Vinny (AI Operations, Venn Social)

**Usage:** Follow this playbook for EVERY event activation. Customize timeline based on event size/complexity.
