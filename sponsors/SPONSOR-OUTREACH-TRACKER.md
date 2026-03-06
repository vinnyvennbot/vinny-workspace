# Sponsor Outreach Tracker
**Created:** March 5, 2026, 10:43 PM PST  
**Purpose:** Ready-to-execute sponsor outreach with instant send capability

## WAVE 1 - READY TO SEND (Awaiting Approval)

### 1. Fernet-Branca (SF Bartender Cocktail Competition)
**Status:** ✅ Email drafted, contact confirmed  
**Priority:** 94 (Fernet = SF bartender legend)  
**Target Event:** Botanical Cocktail Lab OR Midnight Secrets Speakeasy  
**Ask:** $5,000 sponsor (bar tab, branded glassware, judge seat)  
**Contact:** partnerships@fernet-branca.com  
**Send Command:**
```bash
gog gmail send --to="partnerships@fernet-branca.com" \
  --subject="SF Bartender Cocktail Competition Partnership - Venn Social" \
  --body-file="/Users/vinnyvenn/.openclaw/workspace/sponsors/fernet-branca-outreach-email-DRAFT.md"
```
**Follow-up:** 24h if no response  
**Database Update After Send:**
```bash
sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db \
  "INSERT INTO Partner (orgId, category, status, contactEmail, notes, createdAt) 
   SELECT id, 'sponsor', 'contacted', 'partnerships@fernet-branca.com', 
   'Fernet Bartender Competition - $5K ask', datetime('now')
   FROM Organization WHERE name = 'Fernet-Branca';"
```

---

### 2. St. George Spirits (Bay Area Craft Spirit Experience)
**Status:** ✅ Email drafted, contact confirmed  
**Priority:** 93  
**Target Event:** Botanical Cocktail Lab (perfect fit - botanical gin)  
**Ask:** $5,000 sponsor (cocktail ingredients, distillery tour prize, tasting session)  
**Contact:** events@stgeorgespirits.com  
**Send Command:**
```bash
gog gmail send --to="events@stgeorgespirits.com" \
  --subject="Bay Area Craft Spirit Partnership - Venn Social Events" \
  --body-file="/Users/vinnyvenn/.openclaw/workspace/sponsors/st-george-spirits-outreach-email-DRAFT.md"
```
**Follow-up:** 24h if no response  
**Database Update After Send:**
```bash
sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db \
  "INSERT INTO Partner (orgId, category, status, contactEmail, notes, createdAt) 
   SELECT id, 'sponsor', 'contacted', 'events@stgeorgespirits.com', 
   'Botanical Cocktail Lab - $5K botanical gin sponsor', datetime('now')
   FROM Organization WHERE name = 'St. George Spirits';"
```

---

### 3. Distillery 209 (Gin-Forward Botanical Experience)
**Status:** ✅ Email drafted, contact confirmed, pitch deck ready  
**Priority:** 94 (highest confidence - SF-based, botanical theme perfect match)  
**Target Event:** Botanical Cocktail Lab (exclusive fit)  
**Ask:** $5,000 sponsor (signature cocktails, branded garnishes, mixology demo)  
**Contact:** info@distillery209.com  
**Send Command:**
```bash
gog gmail send --to="info@distillery209.com" \
  --subject="Botanical Cocktail Lab Partnership - Venn Social" \
  --body-file="/Users/vinnyvenn/.openclaw/workspace/sponsors/botanical-lab-distillery-209-pitch.md"
```
**Follow-up:** 24h if no response  
**Database Update After Send:**
```bash
sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db \
  "INSERT INTO Partner (orgId, category, status, contactEmail, notes, createdAt) 
   SELECT id, 'sponsor', 'contacted', 'info@distillery209.com', 
   'Botanical Lab exclusive sponsor - $5K ask', datetime('now')
   FROM Organization WHERE name = 'Distillery 209';"
```

---

## WAVE 2 - CONTACT RESEARCH NEEDED

### 4. Tech Corporate Buyouts (15 SF Companies)
**Status:** 🔍 Contact research phase 2 needed  
**Priority:** 93  
**Target Event:** Cosmic Dreams Planetarium Party  
**Ask:** $50,000 corporate buyout (250 employees, full venue, branded experience)  
**Targets:** OpenAI, Anthropic, Scale AI, Stripe, Salesforce, Databricks, etc.  
**Blocker:** Need LinkedIn Premium OR ZoomInfo OR warm intros for decision-maker emails  
**Next Step:** Awaiting Zed input on research approach

**Hybrid Strategy:**
- **AI Companies (7):** LinkedIn research for Events/Culture leads (premium required)
- **SaaS/Fintech (8):** General contact emails (events@company.com, partnerships@company.com)

**Research File:** `/Users/vinnyvenn/.openclaw/workspace/sponsors/tech-company-contact-research-phase2.md`

---

## WAVE 3 - PIPELINE (Not Yet Drafted)

### Wine Sponsors (4 brands identified)
- Scribe Winery (Sonoma - natural wines, intimate dinners)
- Ridge Vineyards (Cupertino - premium CA wines)
- Prisoner Wine Company (Napa - bold aesthetic, nightlife fit)
- La Crema (Sonoma - approachable premium, events-focused)

**Target Events:** Art Deco Jazz Soiree, Underground Supper Club, Jazz Age Garden Party  
**Ask:** $3,000-5,000 (wine pairings, sommelier, branded glassware)  
**Next Step:** Contact research + email drafting (Wave 3 activation)

### Lifestyle/Fashion Sponsors (3 brands)
- Everlane (SF-based ethical fashion - community events)
- Outdoor Voices (activewear - experiential marketing)
- Allbirds (SF sustainable footwear - local partnerships)

**Target Events:** Golden Hour Rooftop Social, Neon Nights Roller Disco  
**Ask:** $2,000-4,000 (swag bags, brand activations, photo ops)  
**Next Step:** Contact research + email drafting (Wave 3 activation)

---

## EXECUTION PROTOCOL

### When Approval Received:
1. **Copy-paste send command** from above (instant execution)
2. **Update database immediately** (same minute as send)
3. **Set 24h follow-up reminder** in Mission Control
4. **Update this tracker** with send timestamp
5. **Git commit** immediately

### Follow-Up Protocol (24h rule):
```bash
# If no response in 24 hours, send polite follow-up:
gog gmail send --reply-to-message-id="ORIGINAL_MESSAGE_ID" \
  --subject="Re: [Original Subject]" \
  --body='Hi [Name],

Following up on my email from yesterday about [Event Name]. 

Would love to explore a partnership - happy to jump on a quick call this week if that works better than email.

Best,
Vinny
Venn Social Events
vinny@vennapp.co | 925-389-4794'
```

### Database Query for Status Tracking:
```sql
-- Check all sponsor outreach status
SELECT 
  o.name AS sponsor_name,
  p.category,
  p.status,
  p.contactEmail,
  p.notes,
  p.createdAt
FROM Partner p
JOIN Organization o ON p.orgId = o.id
WHERE p.category = 'sponsor'
ORDER BY p.createdAt DESC;
```

---

## SUCCESS METRICS

**Wave 1 Target (March 6-10):**
- ✅ 3 emails sent (Fernet, St. George, Distillery 209)
- 🎯 1-2 responses received (33-66% response rate target)
- 🎯 1 sponsor committed ($5K minimum)

**Wave 2 Target (March 11-15):**
- ✅ Tech corporate research complete
- ✅ 15 outreach emails sent
- 🎯 2-3 meetings scheduled (13-20% response rate)
- 🎯 1 corporate buyout committed ($50K)

**Revenue Target (March 2026):**
- **Conservative:** $10,000 (2 Wave 1 sponsors)
- **Moderate:** $25,000 (3 Wave 1 + 1 Wave 2 partial)
- **Optimistic:** $60,000 (3 Wave 1 + 1 Wave 2 full buyout)

---

**Last Updated:** March 5, 2026, 10:44 PM PST  
**Next Review:** Upon approval or March 6, 2026, 9:00 AM PST
