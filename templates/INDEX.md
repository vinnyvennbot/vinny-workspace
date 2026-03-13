# Templates Index - Reusable Workflows & Communications

**Last Updated:** March 13, 2026, 5:24 AM PST  
**Purpose:** Quick reference for all communication templates and planning frameworks

---

## 📧 VENDOR OUTREACH TEMPLATES

### Follow-Up Communications
- **follow-up-24h.txt** - Standard 24-hour vendor follow-up template
- **evt001-vendor-followup-24h.txt** - Western Line Dancing event-specific follow-up

### Event-Specific Outreach
- **evt001-bbq-outreach-template.txt** - BBQ catering vendor outreach for Western Line Dancing
- **evt001-line-instructor-outreach-template.txt** - Line dancing instructor inquiry template
- **nostalgia-night-vendor-outreach.md** - Nostalgia Night vendor outreach template

---

## 📋 EVENT PLANNING FRAMEWORKS

### Planning Checklists
- **event-planning-checklist.md** - Comprehensive event planning workflow
- **event-production-checklist.md** - Production day execution checklist

### Budget & Financial
- **event-budget-template.md** - Event budget planning template with per-person calculations

---

## 📅 MARKETING & CONTENT

- **marketing-calendar-template.md** - Social media and marketing timeline planning

---

## 💰 SPONSOR & PARTNERSHIP

- **sponsor-pitch-deck-master-template.md** - Master sponsor pitch deck framework

---

## 📝 USAGE GUIDELINES

### Email Template Standards

**Before Sending:**
1. **Verify date and day-of-week** with `date` command
2. **Use single quotes** for `--body` parameter if mentioning prices ($)
3. **Personalize** - replace [VENDOR_NAME], [EVENT_NAME], etc.
4. **Check event status** in database (not archived)
5. **Verify org hasn't been contacted** for this event already

**Email Structure:**
- Subject: Clear, specific, includes event name
- Opening: Personalized greeting with vendor/contact name
- Body: Event description, date, venue, audience size
- Ask: Specific request (quote, availability, pricing)
- Closing: Professional signature with contact info
- Never: Mention budget in first outreach

### Template Customization

**Variables to Replace:**
- `[VENDOR_NAME]` - Contact or company name
- `[EVENT_NAME]` - Full event title
- `[EVENT_DATE]` - Verified date with day of week
- `[VENUE_NAME]` - Confirmed venue
- `[GUEST_COUNT]` - Expected attendance
- `[YOUR_NAME]` - Sender name (usually "Vinny")

**Event-Specific Elements:**
- Theme description and vibe
- Target audience demographics
- Unique venue features
- Partnership opportunities
- Brand alignment points

---

## 🔄 TEMPLATE LIFECYCLE

### When to Use Templates
- **First vendor contact** - Use event-specific outreach templates
- **24h follow-up** - Use standard or event-specific follow-up
- **Planning phases** - Use checklists and frameworks

### When to Customize
- Partnership/collaboration events (different tone)
- High-value sponsors (more formal)
- Recurring vendors (acknowledge relationship)
- Recovery emails (acknowledge delay)

### Template Maintenance
- Update after successful responses (learn from what works)
- Remove outdated event references
- Add new templates for recurring needs
- Document effective variations in notes

---

## 🚨 CRITICAL REMINDERS

### Email Sending Rules (from WORKFLOWS.md)

**AUTO-SEND Authority:**
- Initial vendor outreach for quotes
- 24-hour follow-ups
- Thank you / acknowledgment responses
- Logistics coordination

**ASK FIRST:**
- Contract negotiations
- Budget mentions
- Sponsor proposals over $1K value

**NEVER:**
- Binding commitments
- Budget in first contact
- External communication without checking archived status

### Shell Escaping (from TOOLS.md)
```bash
# WRONG - dollar signs disappear:
gog gmail send --body="The $1,400 quote"

# RIGHT - single quotes preserve prices:
gog gmail send --body='The $1,400 quote'
```

---

## 📁 RELATED RESOURCES

### Cross-References
- **WORKFLOWS.md** - Email authority and protocols
- **TOOLS.md** - Command syntax and shell escaping
- **briefs/** - Strategic analysis and event planning docs
- **memory/** - Past vendor responses and patterns

### Database Integration
Templates reference event data from Mission Control:
- Event table: name, date, venue, capacity
- VendorOutreach table: contact info, outreach history
- Vendor table: vendor details, past performance

---

*This index is maintained autonomously during heartbeat cycles*  
*Last audit: March 13, 2026, 5:24 AM PST*
