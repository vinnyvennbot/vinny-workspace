# Silver Cloud - Research Notes
**Date:** March 7, 2026, 4:27 AM PST  
**Status:** Research complete - RECLASSIFICATION NEEDED

---

## Company Overview
**Name:** Silver Cloud  
**Type:** Restaurant and karaoke bar  
**Location:** 1994 Lombard St, San Francisco, CA 94123 (Marina District)  
**Established:** 1979 (40+ years, family-run business)

**Services:**
- American restaurant
- Karaoke bar
- Likely private events/parties

**Contact:**
- **Phone:** (415) 922-1977
- **Website:** silvercloudsf.com
- **Address:** 1994 Lombard St (corner of Lombard)

---

## Strategic Assessment

### ❌ NOT A SPONSOR CANDIDATE
Silver Cloud is a **restaurant/bar business**, not a consumer brand that sponsors events.

**Classification:** Same category as Catch French Bistro
- They operate a venue/restaurant
- They don't sponsor other people's events
- They may offer private event hosting

---

## RECOMMENDATION

**Reclassify in database:**
- From: partnerType = "sponsor", category = "hospitality"
- To: partnerType = "vendor", category = "venue" OR "restaurant_bar"
- Status: "researched"

**Potential Value (Low Priority):**
- Venue option for small karaoke-themed events (<50 people)
- Cross-promotion with Marina District businesses
- NOT a source of cash sponsorship

**Priority:** Low (not relevant to cash sponsor pipeline)

---

## Database Update Command
```sql
UPDATE Partner 
SET partnerType = 'vendor', 
    category = 'restaurant_bar',
    status = 'researched',
    notes = 'Restaurant & karaoke bar at 1994 Lombard St (Marina). Est 1979, family-run. NOT cash sponsor. Potential small venue option or cross-promo. (415) 922-1977. silvercloudsf.com. Researched Mar 7 2026.',
    localityScore = 5
WHERE name = 'Silver Cloud';
```

---

**Research Time:** 5 minutes  
**Value:** Prevented misaligned sponsor outreach  
**Category Correction:** Sponsor → Restaurant/bar vendor  
**Next:** No Days Wasted (final Tier 2 sponsor)
