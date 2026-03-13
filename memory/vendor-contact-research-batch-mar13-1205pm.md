# Vendor Contact Research Batch #12 - March 13, 2026 12:05 PM

## Purpose
Begin Photography category research (next priority after Lighting completion). Photography shows 67% success rate similar to Lighting.

## Batch Details
- **Category:** Photography (20 vendors missing emails at start)
- **Vendors Processed:** 7 total (4 duplicates + 3 new researched)
- **Time:** 12:05-12:10 PM PST  
- **Success Rate:** 67% (2/3 new vendors with direct email; 1 contact form only)

## Results

### New Vendors Researched

#### ⚠️ Rebecca Wilkowski Photography (Contact Form)
- **ID:** vo-masq-rebecca-B11AEA0E4CD6CDA2
- **Email:** Contact form only (no public email found)
- **Phone:** (415) 506-9302 ✅
- **Website:** rebeccawilkowski.com
- **Location:** 185 Clara Street, Suite 102B, San Francisco, CA 94107
- **Hours:** Tuesday-Saturday, 10am-6pm PST (Closed Sun-Mon)
- **Specialties:** Corporate event photography, headshots
- **Licensed & Insured:** $2M by Hill & Usher/The Hartford
- **Note:** Active in photographic community, authors articles, teaches workshops

#### ✅ Starscape Studios
- **ID:** VO-ba5a299c
- **Email:** kimmi@starscapestudios.com ✅
- **Phone:** (530) 208-3218
- **Website:** starscapestudios.com
- **Photographer:** Kimmi Cranes
- **Based:** Lake Tahoe & San Francisco
- **Specialties:** Destination wedding & elopement photographer
- **Services:** Event photography, engagements, proposals, family portraits, company branding
- **Available:** Travel worldwide

#### ✅ Drew Altizer Photography
- **ID:** VO-2566df71
- **Email:** drew@drewaltizer.com ✅
- **Phone:** (415) 812-2500 (alternate: (415) 684-7259)
- **Website:** drewaltizer.com
- **Location:** San Francisco, CA 94123
- **Hours:** Monday-Friday, 9:30am-5:45pm (Closed Sat-Sun)
- **Specialties:** Public relations, corporate events, marketing & brands, event planners, private clients
- **Description:** "One of San Francisco's premiere photography and videography agencies"
- **Services:** Event photography, event videography, photo booths, corporate portraits, commercial photography

### Duplicate Entries Updated

#### 🔄 Drew Bird Photography (2 duplicates)
- **IDs:** vo-artdeco-drew-CBF6979A54FE3E52, vo-masq-drew-C175F7856272F8D2
- **Email:** studio@drewbirdphoto.com ✅
- **Phone:** 1-503-545-7580
- **Note:** Previously researched in batch #5, applied to duplicate entries

#### 🔄 Orange Photography (2 duplicates)
- **IDs:** vo-senegal-orange-D5707A587110DC7B, vo-silent-orange-6640054CB8C6F1F5
- **Email:** Contact form only
- **Phone:** 415-255-7478
- **Note:** Previously researched in batch #4, applied to duplicate entries

## Database Updates
All 7 VendorOutreach Photography records updated with:
- Contact emails (where available)
- Phone numbers
- Comprehensive service details and specialties
- Duplicate flags on repeat entries

## Methodology
- Duplicate detection via database query (checked existing photographers by name)
- Applied existing contact info to 4 duplicate entries
- Web search for 3 new vendors (1-sec delays between searches)
- Contact page verification (Facebook for backup contact info)
- Multi-phone number documentation where available

## Impact
- **Photography missing emails:** 20 → 16 (20% reduction this batch)
- **Overall missing emails:** 330 → 326 (1.2% reduction)
- **Database quality improvement:** 2 new vendors with direct emails, 4 duplicates resolved
- **Efficiency:** Saved ~4 minutes by identifying duplicates before research

## Key Findings

### Photography Category Performance Update
**Current Photography Stats:**
- Vendors with contact info: 8 (from previous + this batch)
- Vendors still missing: 16
- **Email success rate so far:** ~60% (mix of direct emails and contact forms)

**Pattern:** Photography vendors show similar professional structure to Lighting category, though some use contact forms (like Rebecca Wilkowski).

### Duplicate Vendor Detection Continues
**Photography duplicates identified:**
- Drew Bird Photography: 5 total database entries (same business)
- Orange Photography: 6 total database entries (same business)

**Total duplicates across all categories so far:**
- Ideas Events & Rentals: 7 entries
- Brilliant Event Lighting: 3 entries
- Stage Lights and Sound: 2 entries
- Drew Bird Photography: 5 entries
- Orange Photography: 6 entries

**Implication:** Database has significant duplicate entries inflating "missing contact" counts. Actual unique vendors needing research is lower than raw counts suggest.

### Photographer Business Models
Photography category includes diverse specializations:
1. **Corporate/Event:** Rebecca Wilkowski, Drew Altizer (PR, corporate, event planners)
2. **Wedding/Destination:** Starscape Studios (weddings, elopements, worldwide travel)
3. **Lifestyle:** Drew Bird (corporate lifestyle, portraits, weddings)

**Strategic Value:** Different photographer types for different event needs and budgets.

## Pattern Analysis Update

**Photography Category Results (partial - 8 vendors with contact):**
- Direct email: ~60%
- Contact form only: ~40%

**Overall Campaign Results (12 batches, 41 vendors):**
- Direct email success: 54% (22/41)
- Contact form only: 29% (12/41)
- No online presence: 12% (5/41)
- Duplicates: 5% (2/41)

**Category Performance Ranking:**
1. **Lighting: 100%** 🏆 **COMPLETE** (10/10 unique vendors)
2. Photography: ~60% (in progress - 16 remaining)
3. Corporate Catering: 67% (2/3)
4. Entertainment (Studio): 67% (2/3)
5. Bartending: 67% (2/3)
6. Decor: 67% (2/3)
7. Venue: 33% (1/3)
8. Restaurant Catering: 0% (0/3)
9. Live Music: 0% (0/3)
10. Production: 0% (0/3)

## Strategic Recommendations

### Continue Photography Category
- 16 vendors remaining (down from 20)
- Similar professional structure to completed Lighting category
- Good email success rate (~60%) makes this efficient research
- Target: Complete Photography category as second 100% category

### Database Deduplication Urgency
With 23+ duplicate entries identified across 5 vendors:
```sql
-- Recommended cleanup query
SELECT contactName, category, COUNT(*) as count, GROUP_CONCAT(id) as entry_ids
FROM VendorOutreach 
GROUP BY contactName, category
HAVING count > 1 
ORDER BY count DESC;
```

This would reveal all duplicates for cleanup/merging.

### Vendor Tier Matching
Based on research, photographers fall into pricing tiers:
- **Premium/PR:** Drew Altizer (SF premiere, corporate/PR)
- **Professional:** Rebecca Wilkowski ($2M insured, corporate events)
- **Destination:** Starscape Studios (worldwide travel, Lake Tahoe base)
- **Lifestyle:** Drew Bird (versatile, multiple event types)

Match photographer to event budget and style needs.

## Next Steps
**Remaining Photography vendors:** 16

**Goal:** Continue systematic Photography research in next batches. At current ~60% success rate, expect to find 10+ more direct emails from remaining 16 vendors.

**Efficiency Note:** Detecting 4 duplicates this batch saved ~4 minutes of redundant research.

---
**Generated:** March 13, 2026 12:10 PM PST  
**Status:** Photography category 20% complete (4 of 20 processed)  
**Autonomous work during heartbeat cycle**
