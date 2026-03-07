# Catch French Bistro - Research Notes
**Date:** March 7, 2026, 4:21 AM PST  
**Status:** Research complete - RECLASSIFICATION NEEDED

---

## Company Overview
**Name:** Catch French Bistro (also "Catch SF")  
**Type:** French bistro restaurant with catering services  
**Location:** 2362 Market Street, San Francisco, CA 94114 (Castro/Duboce Triangle)

**Services:**
- Full-service French bistro restaurant
- Catering for events (birthday parties, corporate events, weddings)
- Private events/parties hosting
- Seafood-focused menu (clam chowder, cioppino, fish dishes)

**Contact:**
- **Phone:** (415) 431-5000
- **Address:** 2362 Market Street, SF 94114
- **Website:** https://catchfrenchbistro.com
- **Email:** Not publicly listed (contact via phone)

**Historical Significance:**
- Located in SF landmark building
- Originally housed NAMES Project (AIDS Memorial Quilt)
- Castro District location

---

## Strategic Assessment

### ❌ NOT A SPONSOR CANDIDATE
Catch French Bistro is a **restaurant/catering service**, not a consumer brand that sponsors events.

### ✅ POTENTIAL PARTNERSHIP VALUE

**Option 1: Catering Partner**
- They offer tailored catering packages
- Could provide food service for Venn events
- Approach: "We're hosting events in SF - interested in catering partnership?"
- Value: Reduces food costs, local SF flavor

**Option 2: Venue Partner (Low Priority)**
- They host groups/parties
- Likely too small for Venn's typical 100+ person events
- Better suited for intimate dinners (<50 people)

**Option 3: Cross-Promotion**
- Castro location = LGBT+ community engagement
- Could partner for themed events (Pride Month, community events)
- More appropriate for community partnership than cash sponsorship

---

## RECOMMENDATION

**Reclassify in database:**
- From: partnerType = "sponsor", category = "food"
- To: partnerType = "vendor", category = "catering"
- Status: "researched"

**Why NOT a sponsor:**
- Restaurants don't typically sponsor other people's events with cash
- They offer services (catering), not brand sponsorship dollars
- More appropriate as vendor/catering partner

**Potential Value:**
- Catering partner for intimate dinners or community-focused events
- Cross-promotion opportunities in Castro/LGBT+ community
- NOT a source of $5-15K sponsorship cash

**Priority:** Low (not blocking sponsor pipeline goals)

---

## Database Update Command
```sql
UPDATE Partner 
SET partnerType = 'vendor', 
    category = 'catering',
    status = 'researched',
    notes = 'French bistro restaurant at 2362 Market St (Castro). Catering services available (415-431-5000). Potential catering partner, NOT cash sponsor. Landmark building (NAMES Project history). Researched Mar 7 2026.',
    localityScore = 5
WHERE name = 'Catch French';
```

---

**Research Time:** 10 minutes  
**Value:** Prevented misaligned sponsor outreach  
**Category Correction:** Sponsor → Catering vendor  
**Next:** Move to Best Day Brewing (actual beverage brand, real sponsor potential)
