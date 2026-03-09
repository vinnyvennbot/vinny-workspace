# Bay Area Beats Database Cleanup Plan - March 9, 2026

## DUPLICATE ISSUE CONFIRMED

**Database audit shows 7 Bay Area Beats entries with inconsistent naming:**

| ID | Name | Email | Event | Status | Date |
|----|------|-------|-------|--------|------|
| cmlroaf35002dx4ldpsndnnhx | Bay Area Beats | info@bayareabeats.com | evt-001 | awaiting_quote | 2026-02-09 |
| cmlroaf3g0033x4ld7e18rmrr | Bay Area Beats DJs | booking@bayareabeats.com | evt-001 | awaiting_quote | 2026-02-09 |
| vo-11979 | Bay Area Beats | info@bayareabeats.com | evt-silent-disco-13557 | researching | 2026-02-23 |
| vo-nostalgia-bayareabeats | Bay Area Beats | info@bayareabeats.com | evt-nostalgia-2414 | researching | 2026-02-28 |
| vo-yacht-dj-2 | Bay Area Beats | info@bayareabeats.com | EVT-yacht-mixer-feb25 | researching | 2026-02-28 |
| vo-planet-dj-2 | Bay Area Beats | info@bayareabeats.com | EVT-931 | researching | 2026-02-28 |
| vo-12a88a9e9c3063e6 | Bay Area Beats DJs | (NO EMAIL) | evt-time-travelers-b2a460f4 | researching | 2026-03-09 |

---

## VERIFICATION: NO OUTREACH SENT

**Gmail search results:** No emails to info@bayareabeats.com OR booking@bayareabeats.com

**Conclusion:**
- evt-001 entries marked "awaiting_quote" but never actually contacted
- All other entries marked "researching" correctly (no outreach)
- No risk of duplicate vendor contact (nothing sent yet)

---

## ROOT CAUSE

**evt-001 duplicate (Feb 9):**
- Likely created during initial vendor brainstorming
- Two contact emails found for same vendor (info@ and booking@)
- System treated as separate vendors due to name variation ("Bay Area Beats" vs "Bay Area Beats DJs")

**Today's duplicate (Mar 9):**
- Daily ideation cron created evt-time-travelers-b2a460f4
- Added "Bay Area Beats DJs" with NO email
- Naming inconsistency continues

---

## RECOMMENDED FIX

### **Option A: Standardize All Entries (Preferred)**

**Action:**
1. Keep vendor name as: "Bay Area Beats" (canonical)
2. Primary email: info@bayareabeats.com
3. Add note to all entries: "Alternative contact: booking@bayareabeats.com"
4. Delete duplicate evt-001 entry (cmlroaf3g0033x4ld7e18rmrr)
5. Update evt-time-travelers entry with email address

**SQL Commands:**
```sql
-- Update "Bay Area Beats DJs" → "Bay Area Beats"
UPDATE VendorOutreach 
SET contactName = 'Bay Area Beats',
    contactEmail = 'info@bayareabeats.com',
    notes = COALESCE(notes || ' | ', '') || 'Alternative contact: booking@bayareabeats.com',
    updatedAt = CURRENT_TIMESTAMP
WHERE contactName = 'Bay Area Beats DJs';

-- Delete evt-001 duplicate (keep info@ entry, remove booking@ entry)
DELETE FROM VendorOutreach WHERE id = 'cmlroaf3g0033x4ld7e18rmrr';
```

**Result:**
- Consistent vendor naming across all events
- Both contact emails documented
- No duplicate entries per event
- Clean database for future outreach

---

### **Option B: Keep Both Emails, Rename for Clarity**

**Action:**
1. Rename "Bay Area Beats DJs" → "Bay Area Beats (Booking)"
2. Keep both evt-001 entries (if different outreach was intended)
3. Update new entry with email

**When to use:** If we intentionally wanted to contact both emails separately

**Current evidence:** No emails sent to either, so likely NOT intentional duplication

---

## DATA QUALITY PATTERN

**This is symptom of larger issue:** Vendor entries created during brainstorming without complete contact research.

**Prevention:**
1. Don't add vendors to VendorOutreach until contact info verified
2. Use separate "brainstorm" list for ideas
3. Research → verify email → add to database (one-way flow)

**Current approach causes:**
- 239 vendors (44%) with missing emails
- Duplicate entries with name variations
- "awaiting_quote" status on vendors never contacted

---

## RECOMMENDED IMMEDIATE ACTION

✅ **Execute Option A** (standardize all to "Bay Area Beats")

**Why:**
- No outreach sent = safe to merge
- Eliminates confusion for future vendor activation
- Improves database quality
- Prevents accidental duplicate contact later

**Risk:** None (no external communication affected)

**Time:** 2 minutes to execute SQL + verify

---

## LONG-TERM FIX

**Prevent future duplicates:**
1. Schema validation: Warn on similar vendor names for same event
2. Contact verification: Don't mark "researching" without email
3. Vendor database: Separate master vendor list from event-specific outreach
4. Naming standards: Always use official company name from website

---

**Generated:** 2026-03-09 11:44 AM PST  
**Autonomous Discovery:** Database quality audit  
**Recommendation:** Execute cleanup (Option A) - safe, no external impact  
**Approval Required:** Yes (database modification)
