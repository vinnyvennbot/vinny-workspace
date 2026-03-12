# Vendor Research: Pirate's Cove (Batch 1 - Partial)
**Event:** EVT-pirates-mar04 - Pirate's Cove: Maritime Adventure Night  
**Generated:** March 12, 2026, 4:27-4:30 AM PST  
**Context:** Autonomous work - event had 0 vendors, needed initial research

## Research Session Summary

**Target:** Initial vendor research for pirate/maritime themed event  
**Time:** 3 minutes research (abbreviated batch)  
**Vendors Found:** 3 venues/catering (all contact forms)  
**Success Rate:** 0% direct contact (all require web forms)  
**Status:** INCOMPLETE - need entertainment, decor, costumes

## Vendors Researched

### 1. SF Maritime Triangle at Pier 45 ⚠️
**Category:** Venue  
**Specialty:** Historic WWII building, waterfront venue with USS Pampanito submarine  
**Contact:** Contact form only (maritime.org/events-home/trianglerental/)  
**Website:** https://maritime.org/events-home/trianglerental/  
**Location:** Pier 45, San Francisco waterfront  
**Capacity:** 2,400 sq ft indoor + 5,000 sq ft outdoor pier apron  
**Notes:**
- Industrial feel, 20-foot ceilings
- Views of bay, Alcatraz, Coit Tower, Fisherman's Wharf
- Can include USS Pampanito submarine in rental (unique!)
- Near Pier 39, Musée Méchanique, SkyStar Ferris Wheel
- **PERFECT THEMATIC FIT** for pirate/maritime event
- **RECOMMENDED** (despite contact form barrier)

**Source:** Web search + website verification

### 2. Pier 48 (Giants Enterprises) ⚠️
**Category:** Venue  
**Specialty:** Large waterfront event space, historic maritime sheds  
**Contact:** Need to research (giantsenterprises.com/oracle-park-edge/pier-48/)  
**Website:** https://giantsenterprises.com/oracle-park-edge/pier-48/  
**Location:** Pier 48, San Francisco waterfront  
**Capacity:** Large (warehouse-style)  
**Notes:**
- Bay Bridge and waterfront views
- Wide-open warehouse maritime sheds
- Suitable for large corporate events, galas, conferences
- Alternative to Triangle if need larger capacity
- **RECOMMENDED** for larger pirate event (200+ guests)

**Source:** Web search (contact info pending)

### 3. Rich Water Oysters ⚠️
**Category:** Catering (Mobile Raw Bar)  
**Specialty:** Mobile oyster bar, seafood catering  
**Contact:** Contact form only (richwateroysters.com/contact)  
**Website:** https://www.richwateroysters.com  
**Location:** Santa Cruz, serves SF Bay Area  
**Notes:**
- Premier oyster catering company  
- Freshly shucked oysters, house-made sauces, mignonettes
- Mobile raw bar setup
- Serves Central Coast, SF Bay Area, Napa Valley
- Perfect for maritime/coastal pirate theme
- **RECOMMENDED**

**Source:** Web search + website verification

### 4. Hog Island Oyster Co. (Identified, Not Researched)
**Category:** Catering  
**Specialty:** Oyster bars, seafood  
**Website:** https://hogislandoysters.com/catering/  
**Notes:** Established SF oyster company, has catering division  
**Status:** Need to research contact info

## Critical Gaps (Not Yet Researched)

**HIGH PRIORITY MISSING CATEGORIES:**
1. **Entertainment** - Pirate actors/performers  
   - Pirates for Parties (piratesforparties.com) identified but not SF-specific
   - Need treasure hunt coordinators, sword fighting demos
   
2. **Decor** - Maritime/pirate theme  
   - Ship rigging, treasure chests, nautical flags
   - Rope, netting, wooden barrels
   
3. **Costumes** - Pirate costume rentals for guests
   - Period clothing (1736 era or Pirates of Caribbean style)

4. **Photography** - Event documentation

5. **DJ/Sound** - Sea shanties, adventure music

6. **Bartending** - Rum-focused bar service

## Next Research Batch Priorities

**Batch 2 (10-15 min):**
- Entertainment: pirate performers, treasure hunt companies
- Decor: nautical/maritime theme specialists  
- Contact info for Pier 48

**Batch 3 (10 min):**
- Costume rentals
- Photography
- DJ/sound

**Estimated Time to Tier 1:** 2 more batches (20-25 min) to reach 20 vendors

## Contact Form Barrier Pattern

**Issue:** All 3 vendors researched require contact forms (no direct email/phone)  
**Workaround:** When event gets date assigned, submit forms with specific event details  
**Alternative:** Look for vendors with direct contact in next batch

## Database Updates Pending

**Action Required:** Add 3 vendors to VendorOutreach table (noting contact form barrier)

```sql
INSERT INTO VendorOutreach (id, eventId, category, contactName, contactEmail, contactPhone, status, recommended, notes, createdAt, updatedAt)
VALUES
('vo-pirates-maritime-mar12', 'EVT-pirates-mar04', 'Venue', 'SF Maritime Triangle', NULL, NULL, 'researching', 1, 'Pier 45 historic WWII building. 2,400 sq ft indoor + 5,000 sq ft outdoor. Views of bay/Alcatraz. Can include USS Pampanito submarine! Contact form: maritime.org/events-home/trianglerental/', datetime('now'), datetime('now')),

('vo-pirates-pier48-mar12', 'EVT-pirates-mar04', 'Venue', 'Pier 48 (Giants Enterprises)', NULL, NULL, 'researching', 1, 'Large waterfront warehouse maritime sheds. Bay Bridge views. Good for 200+ guests. giantsenterprises.com/oracle-park-edge/pier-48/ - contact info TBD', datetime('now'), datetime('now')),

('vo-pirates-richwater-mar12', 'EVT-pirates-mar04', 'Catering', 'Rich Water Oysters', NULL, NULL, 'researching', 1, 'Mobile oyster bar, SF Bay Area service. Fresh oysters, house-made sauces. Perfect maritime theme. Contact form: richwateroysters.com/contact', datetime('now'), datetime('now'));
```

## Strategic Notes

**Thematic Strength:** SF Maritime Triangle with USS Pampanito submarine = UNIQUE venue opportunity. No other SF venue offers actual historic warship access for events. This could be signature differentiator for Pirate's Cove event.

**Venue Decision:** Triangle (100-150 guests intimate) vs Pier 48 (200+ large-scale). Depends on target attendance.

**Next Session Focus:** Entertainment/performers are critical gap - pirate theme requires actors/treasure hunt to execute concept properly.

---

**Status:** INCOMPLETE - need Batch 2 for entertainment/decor to reach minimum viability  
**Time Invested:** ~8 minutes (including documentation)  
**Event Progress:** 0 → 3 vendors (15% toward Tier 1, but missing critical entertainment category)
