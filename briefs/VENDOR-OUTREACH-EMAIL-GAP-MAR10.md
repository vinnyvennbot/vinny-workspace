# VendorOutreach Email Gap Analysis

**Date**: March 10, 2026, 9:06 AM PST
**Priority**: 85 (Data quality - blocks outreach)
**Status**: Analysis complete, systematic fix plan created

## Summary

**CRITICAL DATA QUALITY ISSUE**: 250 of 565 VendorOutreach records (44%) are missing contact emails, blocking vendor activation for multiple events.

## Current State

**Total VendorOutreach Records**: 565 (active events only)
**Missing Email**: 250 (44.2%)
**Status**: All 250 are in 'researching' status (cannot advance without contact info)

### Missing Emails by Category

| Category | Count | % of Missing |
|----------|-------|--------------|
| Venue | 63 | 25% |
| Photography | 25 | 10% |
| Live Music | 21 | 8% |
| Catering | 16 | 6% |
| Entertainment | 14 | 6% |
| Bartending | 13 | 5% |
| Decor | 11 | 4% |
| AV Production | 10 | 4% |
| Costume Rental | 8 | 3% |
| Partner | varies | varies |

## Root Cause

**March 6-8 Research Campaign** filled Vendor table emails (567 vendors, 54% → 1.7% missing), but **VendorOutreach table was never synced**.

### Why This Happened

1. **Two Separate Tables**: 
   - `Vendor` table = master vendor directory (name, category, email, phone, website)
   - `VendorOutreach` table = event-specific vendor contacts (eventId, category, contactName, contactEmail, status)

2. **Research Target**: March 6-8 campaign focused on Vendor table only

3. **Missing Sync**: No automated sync from Vendor → VendorOutreach when emails are found

4. **Manual Creation**: VendorOutreach records created during event planning often lack contact info (just vendor name + category)

## Impact

**BLOCKED ACTIVATION**: 250 vendor contacts across multiple events cannot be contacted without email addresses.

**Affected Events** (sample):
- evt-silent-disco-13557: Music Tech Sponsors missing
- evt-masquerade-21277: Multiple entertainment/partner contacts missing
- EVT-a5ad16db (Golden Hour Social): 4+ bartending/music vendors missing
- EVT-botanical-feb27: Distillery 209 sponsor contact missing (CRITICAL - pitch ready!)
- EVT-2e378474 (Canvas & Cocktails): ClassBento instructor contact missing
- EVT-be0b2d9a (Midnight Secrets): 3 jazz band contacts missing

## Systematic Fix Plan

### Phase 1: Sync Existing Data (Quick Win)
**Match VendorOutreach.contactName to Vendor.name** and copy email addresses

```sql
-- Find matches where Vendor has email but VendorOutreach doesn't
SELECT vo.id, vo.contactName, v.email 
FROM VendorOutreach vo
JOIN Vendor v ON LOWER(vo.contactName) = LOWER(v.name)
WHERE (vo.contactEmail IS NULL OR vo.contactEmail = '')
AND v.email IS NOT NULL AND v.email != '';
```

**Estimated Coverage**: 30-50% of missing emails (vendors we already researched)

### Phase 2: Research Remaining Gaps
**Categories to research** (prioritized by event impact):

1. **HIGH PRIORITY** (blocks approved events):
   - Distillery 209 (EVT-botanical-feb27) - sponsor pitch ready
   - Venue contacts for approved concepts
   - Entertainment for confirmed events

2. **MEDIUM PRIORITY** (planning events):
   - Photography vendors (25 missing)
   - Live Music (21 missing)
   - Catering (16 missing)

3. **LOW PRIORITY** (speculative):
   - Partner/sponsor contacts (research when event approved)
   - Costume rentals (niche vendors)

### Phase 3: Process Improvement
**Prevent future gaps**:

1. **Always populate email when creating VendorOutreach record**
2. **Check Vendor table first** before creating VendorOutreach entry
3. **Automated sync script**: When Vendor.email updated, propagate to VendorOutreach
4. **Validation**: Block VendorOutreach creation if email missing (force research up front)

## Immediate Action Items

### Task 1: Execute Data Sync (Priority 85)
- **Estimate**: 30 minutes
- **Result**: 75-125 emails filled automatically
- **Tool**: SQL UPDATE with JOIN

### Task 2: Research Critical Gaps (Priority 85)
- **Target**: Distillery 209, approved event vendors
- **Estimate**: 1 hour
- **Result**: 15-20 high-priority emails researched

### Task 3: Batch Research Remaining (Priority 75)
- **Target**: Photography, Live Music, Catering
- **Estimate**: 2-3 hours (spread over multiple sessions)
- **Result**: 50-80 emails researched

## Success Metrics

- **Target**: < 5% missing emails (< 30 of 565)
- **Timeline**: 2-3 sessions
- **Outcome**: All approved events have complete vendor contact lists

## Next Steps

1. ✅ **Analysis complete** (this document)
2. **Create database sync task** (execute Phase 1)
3. **Create research task** (execute Phase 2 batches)
4. **Monitor**: Re-audit weekly to prevent regression

---

**Dependencies**: None (autonomous work available immediately)
**Blocker**: None (can execute during any blocked period)
**Deliverable**: Clean VendorOutreach table ready for mass activation
