# Breakthru Beverage Group - Research Notes
**Date:** March 7, 2026, 4:14 AM PST  
**Status:** Research complete - STRATEGIC REASSESSMENT NEEDED

---

## Company Overview
**Name:** Breakthru Beverage Group (NOT "Breakthrough")  
**Type:** Wholesale beverage distributor (NOT a brand)  
**Scale:** One of North America's largest wine, spirits, beer distributors

**California Presence:**
- **North:** 912 Harbour Way South, Richmond, CA 94804
- **South:** 6550 E. Washington Blvd, Los Angeles, CA 90040
- **Phone:** (800) 339-1410 (North), (800) 331-2829 (South)
- **Customer Service:** (800) 421-5904
- **Orders:** ccorders@breakthrubev.com

---

## Strategic Assessment

### ❌ NOT A DIRECT SPONSOR CANDIDATE
Breakthru Beverage is a **distributor**, not a brand. They don't sponsor events themselves.

### ✅ POTENTIAL PARTNERSHIP VALUE

**Option 1: Brand Introductions**
- They distribute premium wine/spirits brands
- Could connect Venn to brands in their portfolio for sponsorships
- Approach: "We're hosting premium cocktail events in SF - can you introduce us to brands seeking local activation?"

**Option 2: Product Support**
- Wholesale pricing or product donations for events
- Less valuable than cash sponsors but reduces bar costs
- Approach: "Can you provide wholesale access for our event bars?"

**Option 3: Portfolio Mapping**
- Research which brands they distribute
- Contact those brands directly for sponsorship
- Breakthru becomes sourcing channel, not sponsor

---

## RECOMMENDATION

**Reclassify in database:**
- From: "sponsor" (partnerType)
- To: "vendor" or "distribution_partner"
- Category: "beverage_wholesale"

**Next Action:**
1. Update database classification
2. Research which SF-relevant brands they distribute
3. Add those brands as direct sponsor targets
4. Remove from Tier 2 sponsor contact research queue

**Priority:** Low (not blocking event sponsorship activation)

---

## Database Update Command
```sql
UPDATE Partner 
SET partnerType = 'distribution_partner', 
    category = 'beverage_wholesale',
    status = 'researched',
    notes = 'Wholesale distributor, not direct sponsor. Potential value: brand introductions, product support, portfolio access.'
WHERE name = 'Breakthrough Beverage';
```

---

**Research Time:** 15 minutes  
**Value:** Strategic clarity - prevents wasted sponsor outreach effort  
**Next:** Move to SF Distilling Co (actual brand, direct sponsor potential)
