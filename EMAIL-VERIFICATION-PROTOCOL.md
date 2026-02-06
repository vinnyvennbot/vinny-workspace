# EMAIL VERIFICATION PROTOCOL

**MANDATORY FOR ALL VENDOR OUTREACH - NO EXCEPTIONS**

## 🚨 THE RULE

**NEVER send an email without verifying the contact information first.**

## Why This Matters

- Bounced emails damage sender reputation with Gmail/Google Workspace
- Makes us look unprofessional and amateurish
- Wastes time and effort on invalid outreach
- May affect future email deliverability for all Venn Social communications

**Lesson learned 2026-02-06:** Sent 71+ unverified emails, nearly all bounced.

---

## ✅ PROPER VERIFICATION WORKFLOW

### Step 1: Find Vendor via Google Places API

```bash
goplaces text-search "Vendor Name San Francisco" --format json
```

**What to extract:**
- Official business name
- Verified phone number
- Website URL
- Google Maps listing confirmation

**Example:**
```bash
goplaces text-search "City Cruises San Francisco" --format json
# Returns: cityexperiences.com, (415) 788-8866, verified business
```

### Step 2: Check Official Website Contact Page

```bash
web_fetch https://vendorwebsite.com/contact
```

**What to look for:**
- Direct email addresses (not contact forms)
- Specific department emails (events@, sales@, etc.)
- Phone numbers to verify against Google Places
- Contact form URLs (fallback if no email listed)

**Example:**
```bash
web_fetch https://cityexperiences.com/san-francisco/contact/
# Returns: Contact page with group sales phone, event inquiry form
```

### Step 3: Web Search for Contact Info (If Needed)

```bash
web_search "Vendor Name San Francisco contact email"
```

**Use when:**
- Website doesn't list email addresses
- Need to find specific department contact
- Verify information found elsewhere

**Wait 1+ seconds between searches** (Brave API rate limit)

### Step 4: Verify Contact Method Exists

**Before sending, confirm:**
- ✅ Email address is explicitly listed on website or Google Places
- ✅ Phone number matches across sources (Google Places + website)
- ✅ Business is currently operating (not closed/moved)

**If verification fails:**
- ❌ DO NOT guess email patterns (info@, events@, sales@)
- ❌ DO NOT send to unconfirmed addresses
- ✅ Mark in database as "Contact Info Needed"
- ✅ Use alternative: phone call, contact form, LinkedIn message

---

## 📋 DATABASE TRACKING

**Add to all vendor/venue databases:**

| Column | Purpose | Values |
|--------|---------|--------|
| Contact_Verified | Track verification status | Yes / No / Pending |
| Verification_Method | How we verified | Google Places / Website / Phone / N/A |
| Verification_Date | When verified | YYYY-MM-DD |

**Example row:**
```
Vendor Name | Contact Email | Contact_Verified | Verification_Method | Verification_Date
City Cruises | events@cityexperiences.com | Yes | Website + Phone | 2026-02-06
```

---

## 🚫 NEVER DO THIS

❌ **Assume email patterns:**
- info@vendorname.com
- events@vendorname.com  
- sales@vendorname.com
- contact@vendorname.com

❌ **Send without verification because "it's probably right"**

❌ **Skip verification for "just a few emails"**

❌ **Batch send before verifying all contacts**

---

## ✅ PROPER EXECUTION SEQUENCE

### Phase 1: Research & Verify (Do NOT Send Yet)
1. Identify 20+ vendors in category
2. For EACH vendor:
   - Run goplaces search
   - Check website contact page
   - Verify email/phone exists
   - Add to database with verification status
3. Mark verified vs unverified in database

### Phase 2: Send to Verified Only
1. Filter database for "Contact_Verified = Yes"
2. Send emails ONLY to verified addresses
3. Update database with send status + message IDs
4. Track responses

### Phase 3: Alternative Contact for Unverified
1. For "Contact_Verified = No" vendors:
   - Use phone calls
   - Submit website contact forms
   - LinkedIn outreach
   - Skip if no alternative available

---

## 🤖 SUBAGENT INSTRUCTIONS TEMPLATE

When delegating vendor outreach to subagents, use this template:

```
YOUR MISSION: Research and contact [N] vendors for [Event/Category].

PHASE 1 - VERIFY CONTACTS (DO NOT SEND YET):
1. Research 20+ vendors using web_search
2. For EACH vendor, verify contact info:
   a. goplaces text-search "Vendor Name San Francisco" --format json
   b. web_fetch [vendor website]/contact
   c. Confirm email/phone explicitly listed
3. Add to database with Contact_Verified column
4. Report back with verified count before proceeding

PHASE 2 - SEND TO VERIFIED ONLY (After My Approval):
5. Send emails ONLY to Contact_Verified = Yes vendors
6. Use gog gmail send with professional formatting
7. Update database immediately with send status
8. Continue until 5+ responses received

NEVER:
- ❌ Guess email patterns (info@, events@, etc.)
- ❌ Send without explicit verification
- ❌ Combine research and send phases
```

---

## 📊 VERIFICATION CHECKLIST

Before ANY vendor email send campaign:

- [ ] All vendor contacts verified via goplaces or website
- [ ] Database includes Contact_Verified column
- [ ] Only "Yes" verified contacts in send list
- [ ] Email addresses explicitly found (not guessed)
- [ ] Phone numbers match across sources
- [ ] Businesses confirmed currently operating
- [ ] Alternative contact methods identified for unverified
- [ ] Spot check: First 3-5 emails verified by human before mass send

---

## Recovery from Bounce Disaster

**If emails already bounced (like 2026-02-06):**

1. **Stop all sends immediately**
2. **Audit database** - mark all unverified contacts
3. **Research proper contacts** for high-priority vendors
4. **Wait 48-72 hours** before re-contacting (avoid spam flags)
5. **Use alternative methods** (phone, contact forms) for critical vendors
6. **Document lessons** in daily memory file
7. **Update protocols** to prevent recurrence

---

## Success Criteria

**A vendor outreach campaign is successful when:**

✅ 90%+ verified contact rate before any sends  
✅ <5% bounce rate on sent emails  
✅ Professional appearance maintained  
✅ Sender reputation protected  
✅ Database contains accurate, verified contacts for future use

**NOT successful:**
❌ High bounce rates (>10%)  
❌ Guessed email patterns  
❌ Damaged sender reputation  
❌ Database full of invalid contacts

---

**Remember: Quality > Speed. Verified contacts > Mass volume.**

*Updated 2026-02-06 after catastrophic bounce failure.*
