# Database Category Normalization - Data Quality Fix
**Date**: March 11, 2026 9:48 AM PST  
**Issue**: Case-inconsistent category names causing duplicate groupings and poor data quality  
**Impact**: Analytics broken, vendor searches miss results, reporting inaccurate  
**Priority**: Medium (doesn't block operations, but degrades data quality over time)

## Problem Discovery

### Current VendorOutreach Category Chaos
Query: `SELECT category, COUNT(*) FROM VendorOutreach GROUP BY category`

**Duplicate Categories Found**:
| Category (Case Variations) | Count | Total if Normalized |
|-----------------------------|-------|---------------------|
| **venue** (lowercase) | 123 | |
| **Venue** (capitalized) | 55 | **178 venues total** |
| | | |
| **Catering** (capitalized) | 60 | |
| **catering** (lowercase) | 16 | **76 caterers total** |
| | | |
| **Entertainment** (capitalized) | 24 | |
| **entertainment** (lowercase) | 14 | **38 entertainers total** |
| | | |
| **DJ** (uppercase) | 9 | |
| **dj** (lowercase) | 12 | **21 DJs total** |

**Impact**: 
- 20+ vendor records "hidden" by case-sensitive grouping
- Analytics undercounting vendor coverage by ~10%
- Search queries may miss matches (searching "Venue" won't find "venue" entries)

### Root Cause
**No schema validation on category field**:
```sql
-- Current schema (from PRAGMA table_info):
category TEXT NOT NULL
-- No CHECK constraint, no enum validation, accepts any string
```

**Data Entry Patterns**:
- Manual entry → user types "venue" (lowercase)
- Automated import → capitalizes first letter "Venue"
- Different code paths → different casing conventions
- No normalization at write-time → garbage accumulates

## Normalization Standard

### Proposed Category Naming Convention
**Rule**: ALL categories use **Title Case** (capitalize first letter, lowercase rest)

**Examples**:
- ✅ `Venue` (not "venue" or "VENUE")
- ✅ `Catering` (not "catering")
- ✅ `Entertainment` (not "entertainment")
- ✅ `Dj` (not "DJ" or "dj") - *Note: "DJ" is acronym, but Title Case = "Dj" for consistency*

**Alternative for Acronyms**: Keep uppercase for readability
- ✅ `DJ` (not "Dj" or "dj")
- ✅ `AV Production` (not "Av Production")

**Decision Required**: Choose one standard consistently

## SQL Normalization Scripts

### Option 1: Title Case (Capitalize First Letter Only)
```sql
-- Normalize VendorOutreach categories
UPDATE VendorOutreach 
SET category = UPPER(SUBSTR(category, 1, 1)) || LOWER(SUBSTR(category, 2))
WHERE category != UPPER(SUBSTR(category, 1, 1)) || LOWER(SUBSTR(category, 2));

-- Result: "venue" → "Venue", "VENUE" → "Venue", "catering" → "Catering"
```

### Option 2: Manual Mapping (Preserve Acronyms)
```sql
-- Create mapping for known categories
UPDATE VendorOutreach SET category = 'Venue' WHERE LOWER(category) = 'venue';
UPDATE VendorOutreach SET category = 'Catering' WHERE LOWER(category) = 'catering';
UPDATE VendorOutreach SET category = 'Entertainment' WHERE LOWER(category) = 'entertainment';
UPDATE VendorOutreach SET category = 'DJ' WHERE LOWER(category) = 'dj';
UPDATE VendorOutreach SET category = 'Photography' WHERE LOWER(category) = 'photography';
UPDATE VendorOutreach SET category = 'Live Music' WHERE LOWER(category) = 'live music';
UPDATE VendorOutreach SET category = 'Bartending' WHERE LOWER(category) = 'bartending';
UPDATE VendorOutreach SET category = 'Decor' WHERE LOWER(category) = 'decor';
UPDATE VendorOutreach SET category = 'AV Production' WHERE LOWER(category) = 'av production';
UPDATE VendorOutreach SET category = 'Production' WHERE LOWER(category) = 'production';
UPDATE VendorOutreach SET category = 'Lighting' WHERE LOWER(category) = 'lighting';

-- Result: Preserves "DJ" and "AV" as uppercase acronyms
```

**Recommendation**: Option 2 (manual mapping) - better readability, preserves industry-standard acronyms

### Verification Query
```sql
-- After normalization, verify no duplicates remain
SELECT category, COUNT(*) as count 
FROM VendorOutreach 
GROUP BY category 
ORDER BY count DESC;

-- Should show clean categories:
-- Venue: 178
-- Catering: 76
-- Photography: 54
-- Entertainment: 38
-- Live Music: 38
-- Bartending: 33
-- Decor: 26
-- DJ: 21
-- AV Production: 13
-- Production: 10
-- Lighting: 10
```

## Schema Improvement (Future Prevention)

### Add Category Enum Validation
```sql
-- Create CHECK constraint to enforce valid categories
-- (Requires schema migration, can't alter existing table easily in SQLite)

-- For NEW tables or migrations:
CREATE TABLE VendorOutreach_new (
  id TEXT PRIMARY KEY,
  eventId TEXT NOT NULL,
  category TEXT NOT NULL CHECK(
    category IN (
      'Venue', 'Catering', 'Photography', 'Entertainment', 
      'Live Music', 'Bartending', 'Decor', 'DJ', 
      'AV Production', 'Production', 'Lighting', 'Security',
      'Transportation', 'Printing', 'Florist', 'Rentals'
    )
  ),
  -- ... other fields
);

-- Copy data from old table with normalization
INSERT INTO VendorOutreach_new 
SELECT 
  id, eventId, 
  CASE 
    WHEN LOWER(category) = 'venue' THEN 'Venue'
    WHEN LOWER(category) = 'catering' THEN 'Catering'
    WHEN LOWER(category) = 'entertainment' THEN 'Entertainment'
    WHEN LOWER(category) = 'dj' THEN 'DJ'
    -- ... map all categories
    ELSE category
  END as category,
  -- ... other fields
FROM VendorOutreach;

-- Drop old table, rename new
DROP TABLE VendorOutreach;
ALTER TABLE VendorOutreach_new RENAME TO VendorOutreach;
```

**Effort**: Medium (requires careful migration, data backup)  
**Benefit**: Prevents future category chaos, enforces data quality at write-time

### Application-Level Normalization (Easier Alternative)
Instead of database constraints, normalize in application code:

```javascript
// In VendorOutreach creation/update functions:
const CATEGORY_MAP = {
  'venue': 'Venue',
  'catering': 'Catering',
  'entertainment': 'Entertainment',
  'dj': 'DJ',
  'photography': 'Photography',
  // ... complete mapping
};

function normalizeCategory(category) {
  const normalized = CATEGORY_MAP[category.toLowerCase()];
  if (!normalized) {
    console.warn(`Unknown category: ${category}`);
    return category; // or throw error
  }
  return normalized;
}

// Use in all writes:
const vendorOutreach = {
  category: normalizeCategory(inputCategory),
  // ... other fields
};
```

**Effort**: Low (add helper function, update write paths)  
**Benefit**: Prevents future issues without database migration

## Impact Analysis

### Before Normalization (Current State)
**Vendor Count Queries**:
```sql
SELECT COUNT(*) FROM VendorOutreach WHERE category = 'Venue';
-- Returns: 55 (WRONG - missing 123 lowercase "venue" records)
```

**Analytics Dashboard**:
- Venue coverage: 55 vendors (actually 178) - 69% undercount
- Catering coverage: 60 vendors (actually 76) - 21% undercount

**Search Results**:
- User searches "Venue" → finds 55 results
- User doesn't know 123 additional venues exist under lowercase "venue"

### After Normalization
**Vendor Count Queries**:
```sql
SELECT COUNT(*) FROM VendorOutreach WHERE category = 'Venue';
-- Returns: 178 (CORRECT - all venue records found)
```

**Analytics Dashboard**:
- Accurate vendor counts across all categories
- Reliable reporting for stakeholders

**Search Results**:
- Comprehensive results regardless of case
- No hidden records

## Execution Plan

### Phase 1: Analysis & Backup (This Session - Autonomous)
- [x] Identify all case-inconsistent categories ✓ (completed above)
- [ ] Export current VendorOutreach table to CSV (backup before changes)
- [ ] Create complete category mapping (all variations found)
- [ ] Document expected before/after counts

### Phase 2: Normalization (Main Session - Requires Approval)
- [ ] Review normalization SQL with Zed (show before/after)
- [ ] Execute UPDATE queries (Option 2 - manual mapping)
- [ ] Run verification queries (confirm no duplicates)
- [ ] Compare counts (ensure no data loss)

### Phase 3: Prevention (Development Task)
- [ ] Add normalizeCategory() helper function to backend
- [ ] Update all VendorOutreach write paths to use normalization
- [ ] Add unit tests for category normalization
- [ ] Document standard categories in codebase

### Phase 4: Ongoing Maintenance
- [ ] Weekly audit query: Check for new case variations
- [ ] Alert if unknown categories appear
- [ ] Quarterly cleanup: Normalize any drift

## Risks & Mitigation

### Risk 1: Data Loss During Update
**Likelihood**: Low (UPDATE queries are non-destructive)  
**Impact**: High (lose vendor data)  
**Mitigation**: 
- Full database backup before execution
- Test on copy of database first
- Verify row counts before/after (should match exactly)

### Risk 2: Breaking Existing Queries
**Likelihood**: Medium (application code may hardcode case-sensitive searches)  
**Impact**: Medium (searches return no results temporarily)  
**Mitigation**:
- Search codebase for category string literals
- Update any hardcoded "venue" to "Venue" 
- Use case-insensitive WHERE clauses: `WHERE LOWER(category) = 'venue'`

### Risk 3: Incomplete Mapping
**Likelihood**: Low (only ~15 unique categories found)  
**Impact**: Low (unmapped categories left as-is, no data loss)  
**Mitigation**:
- Start with top 10 categories (cover 95% of records)
- Review remaining categories manually
- Add to mapping incrementally

## SQL Scripts Ready to Execute

### Backup First
```bash
# Export current state
sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db \
  "SELECT * FROM VendorOutreach;" > /tmp/vendoroutreach_backup_mar11.csv

# Count before normalization
sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db \
  "SELECT COUNT(*) FROM VendorOutreach;"
# Expected: 542 records
```

### Execute Normalization (Option 2 - Manual Mapping)
```sql
-- Save to: /workspace/sql/normalize-categories-mar11.sql

BEGIN TRANSACTION;

-- Normalize to Title Case with acronym preservation
UPDATE VendorOutreach SET category = 'Venue' WHERE LOWER(category) = 'venue';
UPDATE VendorOutreach SET category = 'Catering' WHERE LOWER(category) = 'catering';
UPDATE VendorOutreach SET category = 'Entertainment' WHERE LOWER(category) = 'entertainment';
UPDATE VendorOutreach SET category = 'DJ' WHERE LOWER(category) = 'dj';
UPDATE VendorOutreach SET category = 'Photography' WHERE LOWER(category) = 'photography';
UPDATE VendorOutreach SET category = 'Live Music' WHERE LOWER(category) = 'live music';
UPDATE VendorOutreach SET category = 'Bartending' WHERE LOWER(category) = 'bartending';
UPDATE VendorOutreach SET category = 'Decor' WHERE LOWER(category) = 'decor';
UPDATE VendorOutreach SET category = 'AV Production' WHERE LOWER(category) = 'av production';
UPDATE VendorOutreach SET category = 'Production' WHERE LOWER(category) = 'production';
UPDATE VendorOutreach SET category = 'Lighting' WHERE LOWER(category) = 'lighting';
UPDATE VendorOutreach SET category = 'Security' WHERE LOWER(category) = 'security';
UPDATE VendorOutreach SET category = 'Partner' WHERE LOWER(category) = 'partner';

-- Verify row count unchanged
SELECT COUNT(*) as final_count FROM VendorOutreach;
-- Should still be 542

COMMIT;
```

### Verify Results
```sql
-- Check for duplicates (should be clean)
SELECT category, COUNT(*) as count 
FROM VendorOutreach 
GROUP BY category 
ORDER BY count DESC;

-- Check for any remaining lowercase (should be empty)
SELECT DISTINCT category 
FROM VendorOutreach 
WHERE category != UPPER(SUBSTR(category, 1, 1)) || SUBSTR(category, 2)
  AND category NOT IN ('DJ', 'AV Production'); -- Allow acronyms
```

## Recommendation

**Execute Phase 1** (analysis & backup) autonomously now.  
**Hold Phase 2** (normalization SQL) for main session approval.  
**Phase 3-4** (prevention) = development task for Zed/team.

**Estimated Time**:
- Phase 1: 5 minutes (autonomous)
- Phase 2: 10 minutes (main session, with approval)
- Phase 3: 1-2 hours (development)
- Phase 4: Ongoing (5 min/week)

**Impact**: Improves data quality by 10-20%, enables accurate analytics, prevents future category chaos.

---

**Status**: Analysis complete. Backup scripts ready. Awaiting approval to execute normalization SQL.

**Next Step**: Export backup CSV and create complete category mapping for review.
