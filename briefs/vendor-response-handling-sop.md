# Vendor Response Handling - Standard Operating Procedure
**Version:** 1.0  
**Date:** March 4, 2026  
**Purpose:** Standardize how we handle all vendor responses to maintain professionalism and efficiency

---

## Pre-Response Checklist

**BEFORE responding to ANY vendor email, verify:**

1. ✅ **Check sent folder** - Have I already replied to this thread?
2. ✅ **Check team responses** - Has Zed, Gedeon, or Aidan already replied?
3. ✅ **Verify event status** - Is this event still active (not archived)?
4. ✅ **Check org dedup** - Has anyone else at this vendor org been contacted for this event?
5. ✅ **Read full thread** - What was the original inquiry? What did they ask?
6. ✅ **Update database FIRST** - Log their response before replying

**If ANY check fails → DO NOT RESPOND (or ask Zed first)**

---

## Response Type Categories

### 1. **Quote Received** ✅
**Vendor provides pricing for services**

**Immediate Actions:**
1. Update VendorOutreach table:
   - `status: 'quote_received'`
   - `quoteAmount: [exact amount from email]`
   - `responseDate: [today's date]`
   - `lastContactDate: [today's date]`

2. Update Event budget model with quote

3. **Response Template:**
```
Thank you for the quote! This is very helpful for our planning.

We're currently reviewing quotes from several vendors and will be in touch within [3-5 business days] with next steps.

Best regards,
Vinny
```

**Timing:** Respond within 4 hours (acknowledge promptly)

**Escalation:** If quote is significantly higher/lower than expected, flag for Zed review before responding

---

### 2. **Questions About Event** ❓
**Vendor asks for more details (date, venue, guest count, etc.)**

**Immediate Actions:**
1. Update VendorOutreach: `status: 'engaged'`

2. **Check what we can share:**
   - ✅ Event theme/concept (always safe)
   - ✅ Approximate guest count (if confirmed)
   - ✅ Event date (VERIFY DAY-OF-WEEK FIRST with `date` command)
   - ✅ General location (SF downtown, waterfront, etc.)
   - ⚠️ Specific venue name (only if locked and announced)
   - ❌ Budget/price range (NEVER in first exchange)

3. **Response Template:**
```
Great questions! Here are the details:

• Event: [Theme Name - e.g., Western Line Dancing Night]
• Date: [Day of week, Month Day, Year - VERIFIED]
• Time: [Start - End time]
• Expected attendance: [Guest count range]
• Location: [General area - e.g., "downtown SF historic venue"]
• Vibe: [Brief description - e.g., "energetic, social, instagram-worthy"]

[Answer their specific questions here]

Looking forward to your quote!

Best regards,
Vinny
```

**Timing:** Respond within 6 hours

**Escalation:** If they ask about budget → politely decline and ask for their standard pricing

---

### 3. **Availability Check** 📅
**Vendor confirms they're available (or not) for the date**

**Scenario A: Available**
1. Update VendorOutreach: `status: 'available'`
2. **Response:**
```
Excellent! We're moving forward with planning and will send over details for a formal quote this week.

Are there any questions about the event I can answer in the meantime?

Best regards,
Vinny
```

**Scenario B: Not Available**
1. Update VendorOutreach: `status: 'unavailable'`
2. Mark in database for future events
3. **Response:**
```
Thank you for letting us know! We appreciate the quick response.

We'll keep you in mind for future Venn events. Do you have upcoming dates you'd recommend checking with you about?

Best regards,
Vinny
```

**Timing:** Respond within 4 hours

---

### 4. **Counter-Questions or Negotiation** 💬
**Vendor proposes alternatives, asks about terms, etc.**

**Immediate Actions:**
1. Update VendorOutreach: `status: 'negotiating'`
2. **DO NOT commit to anything** - this requires Zed approval
3. Document their proposal in database notes

**Response Template:**
```
Thank you for the follow-up and for [proposing X / asking about Y].

Let me discuss this with our team and get back to you by [specific date within 48h].

Best regards,
Vinny
```

**Timing:** Acknowledge within 4 hours, coordinate with Zed before substantive reply

**Escalation:** ALL negotiation discussions go to Zed before responding with specifics

---

### 5. **Requires Booking Commitment** 📝
**Vendor asks for deposit, contract signature, or formal booking**

**STOP. DO NOT RESPOND INDEPENDENTLY.**

**Actions:**
1. Update VendorOutreach: `status: 'pending_booking'`
2. Forward to Zed with context:
   - Event details
   - Quote amount
   - Terms being proposed
   - Your recommendation (book/pass/negotiate)
   - Alternative vendors if passing

3. **Response Template (AFTER Zed approval):**
```
Thank you for sending over the details. We're reviewing internally and will have a decision for you by [date].

Best regards,
Vinny
```

**Timing:** Forward to Zed within 1 hour, respond to vendor after Zed's decision

**Authority Level:** ZERO independent booking authority

---

### 6. **Decline or Pass** ❌
**Vendor declines the opportunity or can't meet requirements**

**Immediate Actions:**
1. Update VendorOutreach: `status: 'declined'`
2. Add declineReason to notes

**Response Template:**
```
Thank you for your time and for considering our event. We appreciate the quick response.

We'll keep you in mind for future Venn events that might be a better fit.

Best regards,
Vinny
```

**Timing:** Respond within 6 hours (be gracious)

**Follow-up:** Mark vendor for future outreach with notes about preferences/constraints

---

### 7. **Referral to Another Vendor** 🔗
**Vendor can't help but recommends someone else**

**Immediate Actions:**
1. Update VendorOutreach: `status: 'referred'`
2. Add referral in notes: `"Referred to [Vendor Name] - [contact info]"`
3. Create NEW VendorOutreach record for referred vendor:
   - referredBy: [original vendor name]
   - Increases trust/response likelihood

**Response Template:**
```
Thank you so much for the referral! We really appreciate you taking the time to connect us.

We'll reach out to [referred vendor] and mention you sent us their way.

Best regards,
Vinny
```

**Timing:** Respond within 4 hours, contact referred vendor within 24 hours

**Note:** Referrals have ~70% higher response rates - track these carefully

---

### 8. **Out of Office / Auto-Reply** 🏖️
**Automated response, no human interaction yet**

**Immediate Actions:**
1. Update VendorOutreach: `status: 'ooo_received'`
2. Note return date in database
3. Set follow-up task for day after return

**Response:** NONE (don't reply to auto-responders)

**Timing:** Wait for human response or follow up 1-2 days after return date

---

### 9. **Spam or Irrelevant** 🚫
**Marketing emails, unrelated offers, phishing**

**Immediate Actions:**
1. Mark as spam in Gmail
2. No database update needed
3. No response

**Exception:** If legitimate vendor but offering wrong service, politely decline:
```
Thank you for reaching out. This isn't what we're looking for right now, but we'll keep you in mind for future needs.

Best regards,
Vinny
```

---

## Response Timing Standards

| Response Type | Target Response Time | Max Response Time |
|---------------|---------------------|-------------------|
| Quote received | 4 hours | 12 hours |
| Questions | 6 hours | 24 hours |
| Availability check | 4 hours | 8 hours |
| Negotiation start | 4 hours (ack only) | 48 hours (full) |
| Booking request | Forward to Zed in 1h | After Zed decision |
| Decline/Pass | 6 hours | 24 hours |
| Referral | 4 hours | 12 hours |

**Business Hours:** 9 AM - 6 PM PST (Mon-Fri)  
**After Hours:** Acknowledge only, substantive reply next business day

---

## Database Update Protocol

**EVERY vendor response requires database update BEFORE replying:**

```sql
-- Update VendorOutreach record
UPDATE VendorOutreach SET
  status = '[new status]',
  responseDate = '[today]',
  lastContactDate = '[today]',
  quoteAmount = [amount if provided],
  notes = '[append new information]'
WHERE id = '[vendor_outreach_id]';
```

**Status Flow:**
```
email_sent → awaiting_response → 
  ├─ quote_received → negotiating → pending_booking → confirmed/declined
  ├─ engaged (asking questions) → quote_received
  ├─ available → quote_received
  ├─ unavailable (mark for future)
  ├─ declined (end of flow)
  └─ referred (create new record for referral)
```

---

## Escalation Matrix

| Scenario | Action | Timeline |
|----------|--------|----------|
| Quote > 2x expected budget | Flag for Zed | Before responding |
| Vendor asks for budget range | Decline, ask for their pricing | Can respond independently |
| Contract/deposit requested | Forward to Zed | Within 1 hour |
| Negotiation on terms | Forward to Zed | Before substantive reply |
| Referral to competitor | Note in CRM, inform Zed | FYI only |
| Vendor seems sketchy | Screenshot, forward to Zed | Before responding |
| Multiple vendors same org | Check database, ask Zed | Before responding |

---

## Quality Checks

**Before hitting send on ANY vendor reply:**

1. ✅ Did I update the database?
2. ✅ Is event still active (not archived)?
3. ✅ Did I verify the day of week for any dates mentioned?
4. ✅ Did I use single quotes for email body (if prices mentioned)?
5. ✅ Am I replying in the correct thread (--reply-to-message-id)?
6. ✅ Did I include proper signature?
7. ✅ Is tone professional but warm?
8. ✅ Did I answer all their questions?
9. ✅ Did I avoid mentioning budget?
10. ✅ Did I avoid making commitments beyond my authority?

**If any check fails → STOP and fix before sending**

---

## Common Mistakes to Avoid

❌ **Responding without checking if Zed already replied** (creates confusion)  
❌ **Mentioning specific budget numbers** (collect quotes first)  
❌ **Confirming bookings independently** (requires Zed approval)  
❌ **Creating new email threads** (always reply in existing thread)  
❌ **Wrong day of week for dates** (always verify with `date` command)  
❌ **Double quotes with dollar signs** (shell strips $1,400 to ,400)  
❌ **Forgetting to update database** (causes tracking gaps)  
❌ **Replying to archived event contacts** (wastes time, confuses vendors)  
❌ **Asterisks or formatting symbols** (looks AI-generated)  
❌ **Generic "thanks for reaching out"** (be specific about their response)

---

## Response Templates

### Generic Acknowledgment (When Needing Time)
```
Thank you for getting back to us! I'm reviewing your response with our team and will have a full reply for you by [specific date within 48h].

Best regards,
Vinny
```

### Request for More Information
```
Thank you for the quote! A few follow-up questions to help us move forward:

1. [Question 1]
2. [Question 2]
3. [Question 3]

Looking forward to your response.

Best regards,
Vinny
```

### Polite Decline (Price Too High)
```
Thank you for the detailed quote. We're currently working within a different budget range for this event.

We'll definitely keep you in mind for future events where the budget allows.

Best regards,
Vinny
```

### Polite Decline (Service Not Needed)
```
Thank you for the follow-up. After reviewing our event needs, we've decided to go in a different direction for [this service].

We appreciate your time and will keep you in mind for future opportunities.

Best regards,
Vinny
```

---

## Metrics to Track

**Response Rate:**
- % of vendors who respond within 48h
- % who provide quotes
- % who decline or don't respond

**Quality Indicators:**
- Average time from inquiry to quote received
- % requiring follow-up clarifications (lower is better)
- % leading to bookings

**Red Flags:**
- Multiple vendors from same org contacted
- Responses to archived events
- Delayed responses (>48h) suggesting we missed something

---

## Process Improvements

**Weekly Review:**
- Which vendor categories have low response rates?
- Are there common questions we should address proactively?
- Which templates work best (measure by response quality)?

**Monthly Review:**
- Update RELATIONSHIPS.md confidence scores based on responsiveness
- Archive vendors who consistently don't respond
- Document patterns in successful vendor relationships

---

**Last Updated:** March 4, 2026  
**Next Review:** March 11, 2026  
**Owner:** Vinny (with Zed oversight)
