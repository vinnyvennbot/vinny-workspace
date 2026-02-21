# Schema Improvements Needed

## Current Issues

### 1. Missing Contact Fields on Vendor
**Problem:** Vendor has no email/phone - only via Organization foreign key  
**Impact:** Can't store simple vendor contact info without creating Organization  
**Fix:** Add email, phone, contactName to Vendor table

### 2. No Category Constraints
**Problem:** Vendor.category is free text (allows typos, inconsistency)  
**Current values:** dj, catering, photography, av, entertainment, charter, other  
**Fix:** Add CHECK constraint or enum

### 3. No Unique Constraints on Names
**Problem:** Allows duplicate vendors ("Bay Area Beats" + "Bay Area Beats DJs")  
**Fix:** Add UNIQUE constraint on Vendor.name (case-insensitive)

### 4. Tags as JSON Strings
**Problem:** Tags stored as JSON strings '["tag1","tag2"]' - hard to query  
**Fix:** Keep as-is for now (changing to relation table is major refactor)

### 5. Partner.channel No Constraints
**Problem:** Free text allows typos  
**Current:** email, instagram, tiktok, discord, other  
**Fix:** Add CHECK constraint

## Migration Strategy

### Phase 1: Add Missing Columns (Safe)
```sql
-- Add contact fields to Vendor
ALTER TABLE Vendor ADD COLUMN email TEXT;
ALTER TABLE Vendor ADD COLUMN phone TEXT;
ALTER TABLE Vendor ADD COLUMN contactName TEXT;

-- Add contact fields to Venue
ALTER TABLE Venue ADD COLUMN email TEXT;
ALTER TABLE Venue ADD COLUMN phone TEXT;
ALTER TABLE Venue ADD COLUMN contactName TEXT;
```

### Phase 2: Data Cleanup
1. Find and merge duplicates
2. Normalize category values
3. Validate all foreign keys
4. Populate new contact fields from notes

### Phase 3: Add Constraints (After cleanup)
```sql
-- Prevent future duplicates (case-insensitive)
CREATE UNIQUE INDEX idx_vendor_name_unique ON Vendor(LOWER(name));
CREATE UNIQUE INDEX idx_partner_name_unique ON Partner(LOWER(name));
CREATE UNIQUE INDEX idx_venue_name_unique ON Venue(LOWER(name));
```

### Phase 4: Better Migration Script
- Parse ALL vendor formats (tables + bullet points + inline)
- Extract email/phone/contact properly
- Detect duplicates before inserting
- Validate category values
- Preserve all notes/context
- Generate verification report

## Recommended Schema (For Future)

```prisma
model Vendor {
  id                   String        @id @default(cuid())
  name                 String        @unique // Prevent duplicates
  category             VendorCategory // Enum instead of free text
  contactName          String?
  email                String?
  phone                String?
  orgId                String?
  org                  Organization? @relation(fields: [orgId], references: [id])
  cost                 Float?
  reliability          Int           @default(5) @db.Integer // 1-10
  lastUsed             DateTime?
  paymentStatus        PaymentStatus @default(NONE)
  workedTogetherBefore Boolean       @default(false)
  notes                String?
  tags                 String        @default("[]") // JSON for now
  createdAt            DateTime      @default(now())
  updatedAt            DateTime      @updatedAt
  
  @@index([category])
  @@index([reliability])
}

enum VendorCategory {
  DJ
  CATERING
  PHOTOGRAPHY
  AV
  ENTERTAINMENT
  MECHANICAL_BULL
  CHARTER
  DECOR
  BAR
  VENUE_SERVICES
  OTHER
}

enum PaymentStatus {
  NONE
  INVOICED
  PAID
  OVERDUE
}
```

## Action Plan

1. ✅ Add email/phone/contactName columns to Vendor, Venue, Partner
2. ✅ Write better migration script that:
   - Parses all vendor formats
   - Extracts contact info to new fields
   - Detects duplicates
   - Validates data
3. ✅ Run migration with full verification
4. ✅ Add unique indexes after data is clean
5. ⏳ Future: Convert to enums (requires Prisma schema change + migration)
