-- Vendor Category Case Sensitivity Fix
-- Generated: March 12, 2026, 4:17 AM PST
-- Purpose: Standardize vendor categories affected by case-sensitive duplicates
-- Impact: 406 records (75% of VendorOutreach table)

-- BEFORE:
-- venue (123) + Venue (63) = 186 total
-- catering (16) + Catering (63) = 79 total
-- photography (5) + Photography (54) = 59 total
-- entertainment (14) + Entertainment (31) = 45 total
-- dj (12) + DJ (9) = 21 total
-- production (5) + Production (11) = 16 total

-- STANDARD: Use Title Case for all categories (matches majority pattern)

BEGIN TRANSACTION;

-- Update venue → Venue
UPDATE VendorOutreach 
SET category = 'Venue', updatedAt = datetime('now')
WHERE category = 'venue';

-- Update catering → Catering
UPDATE VendorOutreach 
SET category = 'Catering', updatedAt = datetime('now')
WHERE category = 'catering';

-- Update photography → Photography
UPDATE VendorOutreach 
SET category = 'Photography', updatedAt = datetime('now')
WHERE category = 'photography';

-- Update entertainment → Entertainment
UPDATE VendorOutreach 
SET category = 'Entertainment', updatedAt = datetime('now')
WHERE category = 'entertainment';

-- Update dj → DJ
UPDATE VendorOutreach 
SET category = 'DJ', updatedAt = datetime('now')
WHERE category = 'dj';

-- Update production → Production
UPDATE VendorOutreach 
SET category = 'Production', updatedAt = datetime('now')
WHERE category = 'production';

-- Update av → AV Production (standardize to full name)
UPDATE VendorOutreach 
SET category = 'AV Production', updatedAt = datetime('now')
WHERE category = 'av';

-- Verification queries (run after commit):
-- SELECT category, COUNT(*) FROM VendorOutreach GROUP BY category ORDER BY COUNT(*) DESC;
-- SELECT COUNT(DISTINCT category) as unique_categories FROM VendorOutreach;

COMMIT;

-- Expected AFTER state:
-- Venue: 186 (123 + 63)
-- Catering: 79 (16 + 63)
-- Photography: 59 (5 + 54)
-- Entertainment: 45 (14 + 31)
-- DJ: 21 (12 + 9)
-- Production: 16 (5 + 11)
-- AV Production: 2 (1 + 1 existing)

-- Result: 406 records standardized, category count reduced from 46 to 39
