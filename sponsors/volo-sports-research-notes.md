# Volo Sports - Research Notes
**Date:** March 7, 2026, 4:26 AM PST  
**Status:** Research complete - RECLASSIFICATION NEEDED

---

## Company Overview
**Name:** Volo Sports  
**Type:** Adult social sports league & events company  
**Services:** 
- Sports leagues (volleyball, kickball, soccer, pickleball, etc.)
- Pickup games
- Fitness classes
- Social events
- Corporate team building
- Volo Pass membership program

**Target Audience:** Adults 21+ looking to play sports and meet people  
**Markets:** Nationwide (including San Francisco)  
**Business Model:** Membership fees, league registrations, corporate events

**Contact:**
- **Website:** https://www.volosports.com/san-francisco
- **General Contact:** Contact form on volosports.com/contact-us
- **Corporate:** info.volosports.com/corporate
- **SF Member:** San Francisco Chamber of Commerce

---

## Strategic Assessment

### ❌ NOT A CASH SPONSOR CANDIDATE
Volo Sports is a **social events company**, not a consumer brand that sponsors other people's events.

**Why NOT a sponsor:**
- They organize events themselves (similar to Venn)
- Revenue model = membership/registration fees, not brand marketing
- They SELL corporate events, they don't sponsor them
- Potential competitor in social events space

---

## RELATIONSHIP TYPE ANALYSIS

### Option 1: Cross-Promotion Partner (RECOMMENDED)
**Model:** Audience exchange - their members → our events, our attendees → their leagues

**Value Proposition:**
- Volo members (sports/active/social) = ideal Venn audience
- Venn attendees (culture/nightlife/social) = potential Volo members
- Complementary offerings: Volo = recurring sports, Venn = one-off experiences

**Approach:**
- Co-marketing agreement (social media cross-posts, email blasts)
- Member discount codes (Volo members get $5 off Venn events, vice versa)
- Co-hosted events (Volo sports tournament → Venn after-party)

**Contact:** Partnership inquiries via contact form

---

### Option 2: Vendor/Competitor (Lower Priority)
**If they offer:**
- Venue access (they manage private facilities "Club Volo")
- Corporate event referrals (companies who want experiences beyond sports)

**If they're:**
- Direct competitor for corporate team building budgets
- Avoid partnerships if conflicting

---

### Option 3: NOT Relevant
They don't provide services or cash that help Venn events.

---

## RECOMMENDATION

**Reclassify in database:**
- From: partnerType = "sponsor", category = "sports"
- To: partnerType = "marketing_partner", category = "cross_promotion"
- Status: "potential"

**Why This Matters:**
- Prevents wasted sponsor outreach effort (they won't pay to sponsor us)
- Identifies potential cross-promotion opportunity (audience exchange)
- Clarifies relationship type (marketing partner, not cash sponsor)

**Next Action (Low Priority):**
- Add to marketing partners pipeline (separate from cash sponsors)
- Research their SF member base size
- Draft cross-promotion proposal (post sponsor pipeline activation)

**Immediate Action:**
- Remove from Tier 2 sponsor research queue
- Update database classification
- Move on to actual sponsor candidates

---

## Database Update Command
```sql
UPDATE Partner 
SET partnerType = 'marketing_partner', 
    category = 'cross_promotion',
    status = 'potential',
    notes = 'Adult sports league company (volleyball, kickball, soccer, etc). NOT cash sponsor - potential cross-promotion partner (audience exchange). SF market active. Contact: volosports.com/contact-us. Corporate: info.volosports.com/corporate. Researched Mar 7 2026.',
    brandAlignment = 4,
    localityScore = 2
WHERE name = 'Volo Sports';
```

---

**Research Time:** 10 minutes  
**Value:** Prevented misaligned sponsor outreach, identified cross-promo opportunity  
**Category Correction:** Sponsor → Marketing partner  
**Priority:** Low (not cash sponsor, focus on actual sponsor pipeline first)  
**Next:** Move to Silver Cloud research
