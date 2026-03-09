# Bay Area Beats Duplicate Fix - Mar 9, 2026 4:17 AM

## DUPLICATE IDENTIFIED

**Event:** evt-001 (Western Line Dancing Night)  
**Vendor:** Bay Area Beats (same company, two database entries)

**Entry 1:**
- ID: cmlroaf35002dx4ldpsndnnhx
- Name: Bay Area Beats
- Email: info@bayareabeats.com
- Status: awaiting_quote
- Created: 2026-02-09

**Entry 2:**
- ID: cmlroaf3g0033x4ld7e18rmrr
- Name: Bay Area Beats DJs
- Email: booking@bayareabeats.com
- Status: awaiting_quote
- Created: 2026-02-09

## ROOT CAUSE

Likely created during initial vendor outreach with both contact emails found. System treated as two separate vendors due to name variation.

## RECOMMENDED ACTION

**Option A: Merge (Preferred)**
- Keep Entry 1 (cmlroaf35002dx4ldpsndnnhx) as canonical record
- Update notes: "Alternative contact: booking@bayareabeats.com"
- Delete Entry 2 (duplicate)

**Option B: Update Only**
- Standardize Entry 2 name to "Bay Area Beats" (remove "DJs")
- Add note: "Booking-specific email"
- Keep both if different outreach was sent to each

## VERIFICATION NEEDED

Check sent folder to confirm:
1. Were emails sent to BOTH addresses for evt-001?
2. If yes: Keep both entries, just standardize naming
3. If no: Merge entries (delete duplicate)

**Current blocker:** Cannot verify via gog CLI (email body reading limitation)

## PATTERN ACROSS ALL EVENTS

Bay Area Beats appears in 6 events:
- evt-001 (2 entries - DUPLICATE)
- EVT-931, EVT-yacht-mixer-feb25, evt-nostalgia-2414, evt-silent-disco-13557 (single entries)

**Action:** Standardize naming to "Bay Area Beats" across all events for consistency.

## SQL FIX (if merge approved)

```sql
-- Update duplicate entry name
UPDATE VendorOutreach 
SET contactName = 'Bay Area Beats', 
    notes = COALESCE(notes || ' | ', '') || 'Alternative contact: booking@bayareabeats.com'
WHERE id = 'cmlroaf3g0033x4ld7e18rmrr';

-- OR delete duplicate (if no separate outreach sent)
-- DELETE FROM VendorOutreach WHERE id = 'cmlroaf3g0033x4ld7e18rmrr';
```

## NEXT STEP
Add to task queue: Verify sent emails, then execute merge (priority 85)
