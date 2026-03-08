# Bay Area Beats DJ - Contact Research - March 8, 2026, 4:42 AM PST

**Vendor:** Bay Area Beats DJs  
**Research Trigger:** Duplicate vendor entries with conflicting contact emails  
**Purpose:** Determine correct primary contact email for standardization

---

## 🔍 RESEARCH FINDINGS

### **Official Website**
- **URL:** https://www.bayareabeatsdjs.com/
- **Contact Method:** Contact form only (no email displayed publicly)
- **Owner:** Adrian Blackhurst (aka DJ Boogiemeister)
- **Location:** Oakland, CA (services SF, Berkeley, Oakland, Bay Area)

### **Awards & Recognition**
- WeddingWire Couples Choice Award Winner (2013-present)
- The Knot Pro DJ Award
- Top 5% of nation's wedding vendors
- Top 3 DJs of Oakland (2018-2022)
- 110+ positive reviews across WeddingWire, Yelp, Google, Gigmasters

### **Services**
- Wedding DJ/MC
- Corporate events
- Private parties
- Bar/Bat Mitzvahs
- 2000+ events combined (team), 450+ weddings (Adrian)
- Uplighting, sound systems, photo booth, silent disco options

---

## 📧 EMAIL ADDRESS ANALYSIS

### **Database Records (6 entries across 5 events):**

| Email | Usage Count | Events |
|-------|-------------|--------|
| info@bayareabeats.com | **5x** | evt-001, evt-silent-disco-13557, evt-nostalgia-2414, EVT-yacht-mixer-feb25, EVT-931 |
| booking@bayareabeats.com | **1x** | evt-001 only |

### **Public Email Visibility**
- ❌ **Not displayed on official website** (uses contact form)
- ❌ **Not displayed on The Knot profile** (uses "Contact" button)
- ❌ **Not displayed on WeddingWire** (likely same pattern)
- ❌ **Not found via web search** (vendor hides direct email publicly)

**Why vendors do this:**
- Reduce spam
- Force inquiries through booking platforms (get commission)
- Centralize lead tracking
- Screen casual vs serious inquiries

---

## 💡 ANALYSIS & RECOMMENDATION

### **Pattern Assessment:**

**info@bayareabeats.com (5x usage):**
- Standard business email pattern (info@)
- Used consistently across multiple events
- Most recent research sessions used this
- General inquiry email (typical for "info@" addresses)

**booking@bayareabeats.com (1x usage):**
- Only appears in evt-001 (Western Line Dancing)
- Created Feb 9, 2026
- Could be specialized booking confirmation email
- Less common pattern (typically venues use "bookings@", DJs use "info@")

### **Hypothesis:**

**Scenario 1: Two Valid Emails**
- info@ = Initial inquiry/quote requests
- booking@ = Confirmed booking management
- We contacted info@ for quote, got booking@ in response for next steps

**Scenario 2: Typo/Research Error**
- Only info@ is correct
- booking@ was created by mistake (guessing typical booking email)
- Never actually verified with vendor

**Scenario 3: Domain Confusion**
- info@bayareabeats.com = correct
- booking@bayareabeats.com = doesn't exist (bayareabeatsdjs.com is real domain)
- Note: Website is bayareabeatsdjs.com (with "djs"), not bayareabeats.com

---

## 🚨 CRITICAL ISSUE DISCOVERED

### **Domain Mismatch Risk**

**Our database emails:**
- info@bayareabeats.com
- booking@bayareabeats.com

**Actual vendor website:**
- www.bayareabeatsdjs.com (note the "djs" at the end)

**Possible outcomes:**
1. They own both domains (common for businesses)
2. We have the wrong domain entirely
3. Emails bounce (and we never noticed because gog CLI can't read responses)

**CRITICAL:** We need to verify if bayareabeats.com emails actually work!

---

## ✅ RECOMMENDATIONS

### **Immediate Action (Morning Review):**

1. **Check Gmail sent folder for Feb 9 evt-001 outreach**
   - Did we email info@ or booking@?
   - Did either bounce?
   - Did vendor respond with their preferred email?

2. **Test email validity (optional)**
   ```bash
   # Use email verification service or send test
   ```

3. **Try contact form on website**
   - Submit inquiry asking for direct email contact
   - Reference potential booking for March event
   - Get official contact email from vendor directly

### **Database Standardization:**

**Until verified, use:**
- **Primary:** info@bayareabeats.com (most common in DB)
- **Backup:** booking@bayareabeats.com (listed for reference)
- **Website form:** https://www.bayareabeatsdjs.com/contact/ (if emails fail)

**Update all 6 VendorOutreach records to:**
```
contactName: Bay Area Beats DJs (standardized)
contactEmail: info@bayareabeats.com
notes: "Owner: Adrian Blackhurst. Backup email: booking@bayareabeats.com. Website: bayareabeatsdjs.com. Award-winning DJ (WeddingWire Couples Choice). 450+ weddings, Top 5% nationwide."
```

### **For Future Vendor Research:**

**Rule: Always verify both email AND domain**
- Check website URL carefully (bayareabeatsdjs.com not bayareabeats.com)
- Use contact form to get official email if not publicly listed
- Test emails with non-critical inquiry before important outreach
- Document source of email (website, form response, referral, etc.)

---

## 📋 FOLLOW-UP TASKS

**Task 1: Sent Folder Verification** (Priority: HIGH)
- Manual Gmail review to check if we actually contacted Bay Area Beats
- Determine if they responded and with what email
- Check for any bounce notifications

**Task 2: Standardize Database Entries** (Priority: MEDIUM)
- Merge 6 VendorOutreach records to consistent name/email
- Add notes about vendor credentials
- Flag for email verification

**Task 3: Domain Verification** (Priority: MEDIUM)
- Confirm bayareabeats.com vs bayareabeatsdjs.com ownership
- Update database with correct domain/email
- Test email deliverability before future outreach

---

## 🎯 DECISION FOR NOW (4:42 AM)

**Use: info@bayareabeats.com**

**Rationale:**
1. Most commonly used in our database (5 vs 1)
2. Standard business email pattern
3. Recent research sessions chose this
4. Lower risk than booking@ (which could be invalid)

**Caveat:** MUST verify in morning with sent folder review and domain check

**Status:** Research complete, awaiting morning email verification session

---

**Time Invested:** 6 minutes (4:42-4:48 AM)  
**Result:** Recommended info@bayareabeats.com pending verification  
**Next:** Morning sent folder audit + domain verification  
**Created:** March 8, 2026, 4:48 AM PST
