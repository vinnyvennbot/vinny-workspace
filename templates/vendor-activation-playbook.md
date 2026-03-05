# Vendor Activation Playbook
**Version:** 1.0  
**Created:** March 5, 2026  
**Purpose:** Standardized process for vendor outreach, quote collection, and booking

---

## Overview

This playbook ensures consistent, professional vendor outreach across all Venn events. Follow this process to maximize response rates, collect competitive quotes, and maintain strong vendor relationships.

---

## Pre-Activation Checklist

Before contacting ANY vendors, ensure:

✅ **Event approved** by Zed/team  
✅ **Date confirmed** (or date range if flexible)  
✅ **Budget model complete** with cost targets per category  
✅ **Venue locked or shortlist narrowed** to 2-3 options  
✅ **Financial model shows path to profitability**  
✅ **No archived event flag** in database (CRITICAL - check first!)

**MANDATORY DATABASE CHECK:**
```sql
SELECT name, archived, status FROM Event WHERE id = '[EVENT_ID]';
```

If `archived = 1` or `archived = true` → **STOP. DO NOT CONTACT ANY VENDORS.**

---

## Vendor Research Phase

### Step 1: Identify Vendor Categories
Based on event type, identify 5-10 vendor categories needed.

**Common Categories:**
- Venue
- Catering/Food
- Beverage/Bar Service
- Entertainment (DJ, live music, performers)
- Photography/Videography
- Production/AV (lighting, sound)
- Décor/Design
- Rentals (furniture, equipment)
- Security
- Transportation/Valet

**Event-Specific Categories:**
- [Example: Mechanical bull for Western event]
- [Example: Silent disco equipment]
- [Example: Art instructor for interactive workshops]

### Step 2: Research 20+ Vendors Per Category
**Target:** 20-25 vendors per major category (venue, catering, entertainment)  
**Target:** 10-15 vendors per secondary category (photography, décor)

**Research Sources:**
- Google Maps (search "[category] San Francisco")
- Yelp Business (filter by ratings 4.0+)
- Instagram hashtag search (#SFcatering, #SFeventphotography)
- Past event vendor lists (check RELATIONSHIPS.md)
- Vendor referrals from venues
- Industry directories (WeddingWire, The Knot, Peerspace)

**Data to Collect:**
- Business name
- Contact name (if available)
- Email address (primary method)
- Phone number (backup)
- Website
- Social media handles
- Price range (if publicly available)
- Specialties/style
- Past client reviews

### Step 3: Add to Database
```sql
INSERT INTO VendorOutreach (
  eventId, category, vendorName, contactEmail, 
  contactPhone, website, status, recommended
) VALUES (
  '[EVENT_ID]', '[CATEGORY]', '[NAME]', '[EMAIL]',
  '[PHONE]', '[WEBSITE]', 'researching', [TRUE/FALSE]
);
```

**Recommended Flag:** `true` for top 3-5 vendors per category based on:
- Strong online reviews (4.5+ stars)
- Portfolio matches event aesthetic
- Existing Venn relationships
- Referrals from trusted sources

---

## Email Outreach Phase

### Step 1: Email Template Selection

Use templates from `/workspace/templates/vendor-emails/`

**Initial Inquiry Templates:**
- `venue-inquiry.txt` - Venue availability and pricing
- `catering-inquiry.txt` - Menu and service quotes
- `entertainment-inquiry.txt` - DJ/band availability
- `photography-inquiry.txt` - Package pricing
- `general-vendor-inquiry.txt` - For all other categories

### Step 2: Email Customization Checklist

✅ **Event name** (human-readable, not "EVT-001")  
✅ **Specific date** (day of week verified with `date` command)  
✅ **Venue name** (if locked) or location area  
✅ **Guest count estimate**  
✅ **Event theme/vibe** (brief description)  
✅ **Your contact info** (vinny@vennapp.co, 925-389-4794)  
✅ **NO internal IDs** (never mention EVT-001, etc.)  
✅ **NO budget mentions** in first outreach (collect quotes first)

### Step 3: Send Email via gog CLI

**CRITICAL SYNTAX RULES:**
1. **Use single quotes for --body** if email contains dollar signs ($)
2. **Verify day of week** for any date mentioned (`date -j -f "%Y-%m-%d" "YYYY-MM-DD" "+%A"`)
3. **Include full signature** (see TOOLS.md)

```bash
# Example: Send catering inquiry
gog gmail send --to="vendor@example.com" \
  --subject="Catering Inquiry - Jazz Age Garden Party (June 14)" \
  --body='Hi [Name],

We'\''re planning a 1920s-themed garden party for 150 guests on Saturday, June 14, 2026 at Presidio Officers'\'' Club in San Francisco.

We'\''re looking for elegant passed hors d'\''oeuvres and stationary displays that match our Art Deco aesthetic. Could you share:
- Sample menu options for 150 guests
- Pricing per person or package pricing
- Your availability for June 14

Looking forward to hearing from you!

Best regards,
Vinny
Venn Social Events
vinny@vennapp.co | vennsocial.co
925-389-4794'
```

### Step 4: Update Database Immediately

```sql
UPDATE VendorOutreach 
SET status = 'contacted',
    notes = 'Initial inquiry sent [TIMESTAMP]'
WHERE eventId = '[EVENT_ID]' 
  AND contactEmail = 'vendor@example.com';
```

**Database Update Timing:** Within same minute as email send (not batched later)

---

## Response Handling

### Step 1: Check Email Every 2-4 Hours (Business Hours)

```bash
gog gmail messages search "in:inbox newer_than:4h" --max 20
```

**Note:** Current gog limitation - cannot read email bodies. Check for:
- New messages from contacted vendors
- Subject lines indicating quotes/availability
- Alert team for manual review if critical responses detected

### Step 2: Update Database on Response

```sql
UPDATE VendorOutreach
SET status = 'response_received',
    notes = 'Response received [TIMESTAMP] - [BRIEF SUMMARY]'
WHERE contactEmail = 'vendor@example.com'
  AND eventId = '[EVENT_ID]';
```

### Step 3: Quote Received → Update Status

```sql
UPDATE VendorOutreach
SET status = 'quote_received',
    quoteAmount = [AMOUNT],
    notes = '[QUOTE DETAILS]'
WHERE contactEmail = 'vendor@example.com'
  AND eventId = '[EVENT_ID]';
```

**CRITICAL:** Only update `quoteAmount` if you have verbatim quote from vendor. Never guess or estimate.

### Step 4: Reply in Thread (ALWAYS)

**MANDATORY:** Use `--reply-to-message-id` to maintain threading

```bash
gog gmail send --reply-to-message-id="MESSAGE_ID" \
  --reply-all \
  --subject="Re: [Original Subject]" \
  --body='[Response]'
```

**Never create new threads** when replying to vendors.

---

## Follow-Up Protocol

### 24-Hour Rule
If no response within 24 hours → send polite follow-up

**Follow-Up Template:**
```
Hi [Name],

Just following up on my inquiry from yesterday about [EVENT NAME] on [DATE]. 

We're moving forward with vendor selection this week and would love to include [VENDOR NAME] in our consideration.

Could you let me know your availability and pricing when you have a moment?

Thanks!

Best regards,
Vinny
```

### 72-Hour Rule
If no response after follow-up → mark as non-responsive, move to backup vendors

```sql
UPDATE VendorOutreach
SET status = 'no_response',
    notes = 'No response after 2 attempts ([DATES])'
WHERE contactEmail = 'vendor@example.com'
  AND eventId = '[EVENT_ID]';
```

---

## Quote Comparison

### Step 1: Collect 3-5 Quotes Per Category
Don't book first quote received. Competitive quotes ensure best pricing.

**Minimum Quotes Before Recommendation:**
- Major categories (venue, catering, entertainment): 3 quotes
- Secondary categories (photography, décor): 2 quotes

### Step 2: Create Comparison Sheet

Document in `/workspace/financials/[event-name]-vendor-comparison.md`

**Format:**
```markdown
## [Category] Vendor Comparison

| Vendor | Price | Included | Pros | Cons | Recommended |
|--------|-------|----------|------|------|-------------|
| Vendor A | $X | [Details] | [List] | [List] | ⭐ YES |
| Vendor B | $Y | [Details] | [List] | [List] | - |
| Vendor C | $Z | [Details] | [List] | [List] | - |

**Recommendation:** Vendor A
**Reasoning:** [1-2 sentences explaining why]
```

### Step 3: Update Financial Model
Adjust event budget based on actual quotes received vs. estimates.

```sql
UPDATE Event
SET budgetTotal = [NEW_TOTAL],
    notes = 'Budget updated based on vendor quotes ([DATE])'
WHERE id = '[EVENT_ID]';
```

---

## Booking Process

### Step 1: Get Approval (MANDATORY)
**NEVER book vendors independently.** Present recommendations to Zed:

**Recommendation Format:**
```markdown
## [Category] Vendor Recommendation

**Recommended:** [Vendor Name]
**Price:** $[Amount]
**Why:** [2-3 sentences]

**Alternatives Considered:**
- [Vendor B]: $[Amount] - [Why not chosen]
- [Vendor C]: $[Amount] - [Why not chosen]

**Next Steps:** Pending approval to send booking confirmation.
```

### Step 2: Booking Confirmation Email
After approval, send booking confirmation:

```
Hi [Name],

Great news! We'd love to move forward with [VENDOR NAME] for [EVENT NAME] on [DATE].

Next steps:
1. Please send over your contract/agreement
2. Confirm deposit amount and payment terms
3. Let us know any information you need from us

Looking forward to working together!

Best regards,
Vinny
```

### Step 3: Update Database

```sql
UPDATE VendorOutreach
SET status = 'booked',
    notes = 'Booked [DATE]. Contract pending. Deposit: $[AMOUNT]'
WHERE contactEmail = 'vendor@example.com'
  AND eventId = '[EVENT_ID]';
```

---

## Vendor Declined Protocol

### When Vendor Declines
If vendor is unavailable or declines:

**Response:**
```
Hi [Name],

Thank you for getting back to me and for considering [EVENT NAME].

We appreciate your time and hope to work together on a future event!

Best regards,
Vinny
```

**Database Update:**
```sql
UPDATE VendorOutreach
SET status = 'declined',
    notes = 'Declined [DATE]. Reason: [IF PROVIDED]'
WHERE contactEmail = 'vendor@example.com'
  AND eventId = '[EVENT_ID]';
```

**Maintain Relationships:** Always thank vendors who decline. They may be available for future events.

---

## Communication Standards

### Email Formatting (MANDATORY)

❌ **NEVER:**
- Use asterisks or AI formatting (*bold*, **bold**)
- Include internal IDs (EVT-001, etc.)
- Mention budget in first outreach
- Use emojis in business emails
- Send emails with wrong day of week
- Use double quotes with dollar signs in gog commands

✅ **ALWAYS:**
- Clean paragraph structure
- Professional signature
- Reply in thread (--reply-to-message-id)
- Verify dates with date command
- Use single quotes for email bodies with prices
- Include event date in subject line

### Response Time Standards

**Business Hours (9 AM - 6 PM PST):**
- Respond to vendor emails within 4 hours
- Send follow-ups within 24 hours if no response

**After Hours:**
- Check emails once in evening (if working)
- No expectation for immediate response
- Follow up next business day

---

## Database Maintenance

### Weekly Cleanup Tasks
1. Remove duplicate vendor entries
2. Update vendor contact info if bounced emails
3. Archive old event vendor outreach (status != 'booked')
4. Update RELATIONSHIPS.md with new vendor ratings

### Status Definitions

| Status | Meaning |
|--------|---------|
| `researching` | Vendor identified, not yet contacted |
| `contacted` | Initial email sent, awaiting response |
| `response_received` | Vendor replied (any response) |
| `quote_received` | Vendor provided pricing quote |
| `awaiting_quote` | Vendor responsive but quote pending |
| `follow_up_sent` | Follow-up email sent after 24h |
| `no_response` | No reply after 2 attempts (72h) |
| `declined` | Vendor unavailable or declined |
| `booked` | Contract signed, deposit paid |

---

## Anti-Patterns (What NOT To Do)

❌ **Don't contact vendors before event approval**  
❌ **Don't mention budget in first email**  
❌ **Don't book without competitive quotes (3+ quotes)**  
❌ **Don't book without Zed approval**  
❌ **Don't send follow-ups less than 24h apart**  
❌ **Don't create new email threads when replying**  
❌ **Don't contact vendors for archived events** (CRITICAL)  
❌ **Don't batch database updates** (update immediately after action)  
❌ **Don't leave vendors on read** (always acknowledge responses)

---

## Success Metrics

Track these metrics per event:

- **Response Rate:** % of contacted vendors who respond
- **Quote Rate:** % of responses that include quotes
- **Booking Rate:** % of quotes that convert to bookings
- **Average Response Time:** How fast vendors reply
- **Cost Variance:** Quoted price vs. budgeted price

**Targets:**
- Response Rate: 60%+ (good vendor list)
- Quote Rate: 80%+ (clear inquiry emails)
- Booking Rate: 20-30% (competitive selection)
- Response Time: <48 hours average

---

## Templates Location

All vendor email templates stored in:
`/Users/vinnyvenn/.openclaw/workspace/templates/vendor-emails/`

Create category-specific templates as needed:
- `venue-inquiry.txt`
- `catering-inquiry.txt`
- `entertainment-inquiry.txt`
- `photography-inquiry.txt`
- `production-inquiry.txt`
- `general-vendor-inquiry.txt`

---

## Related Documentation

- **TOOLS.md** - Email command syntax, signature format
- **WORKFLOWS.md** - Email sending authority, budget protocols
- **RELATIONSHIPS.md** - Vendor ratings and relationship notes
- **MEMORY.md** - Lessons learned from past vendor interactions

---

## Version History

**v1.0** (March 5, 2026)
- Initial playbook created
- Covers research → outreach → booking flow
- Includes database update protocols
- Anti-patterns documented based on past mistakes

---

**Questions or edge cases?** Document in this playbook for future reference.
