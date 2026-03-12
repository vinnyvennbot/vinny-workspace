# Wave 1 Spirits Brand Contact Research
**Date**: March 11, 2026 11:48 AM PST  
**Purpose**: Find contact emails for Wave 1 sponsor outreach (SF spirits brands)  
**Method**: Web search → official website → contact page verification

## Research Results

### ✅ SUCCESS: Email Found (3 of 4 brands)

#### 1. Distillery No. 209
- **Contact**: info@distillery209.com
- **Source**: Official website (distillery209.com/contact)
- **Location**: Pier 50, San Francisco
- **Website**: distillery209.com
- **Notes**: "We'd love to hear from you – Whether you have questions about our gin, need assistance, or are interested in exploring wholesale opportunities. Drop us a line!"
- **Status**: READY FOR WAVE 1 OUTREACH ✅

#### 2. Fernet-Branca
- **Contact**: contactus@brancausa.com
- **Source**: Official US website (brancausa.com/contact)
- **Parent Company**: Branca USA
- **Office**: 570 Lexington Ave, Suite 4200, New York, NY 10022
- **Website**: brancausa.com
- **Notes**: Extensive SF sponsorship history (art shows, music events, bartender parties per KQED article). "Bartenders, art and music, always with Fernet-Branca" was their SF strategy.
- **Status**: READY FOR WAVE 1 OUTREACH ✅

#### 3. St. George Spirits
- **Contact**: info@stgeorgespirits.com
- **Source**: Website news article (stgeorgespirits.com/news/distribution-update)
- **Phone**: 510-769-1601
- **Location**: 2601 Monarch St., Alameda, CA 94501
- **Website**: stgeorgespirits.com
- **Notes**: "If you have questions about availability or need help locating our products near you, please reach out to our office (info@stgeorgespirits.com, 510-769-1601) for assistance."
- **Community Engagement**: Partners with local festivals, Headwest Marketplace (per LeadIQ research)
- **Status**: READY FOR WAVE 1 OUTREACH ✅

### ⚠️ ISSUE: Brand Not Found (1 brand)

#### 4. SF Distilling Co
- **Contact**: NOT FOUND
- **Search Result**: Only 1 result found (tenereteam.com review site, not official)
- **Issue**: May not exist, could be different name, or very small/dormant brand
- **Action Required**: 
  - Verify this brand actually exists
  - Check if name is correct (could be "San Francisco Distilling" or different name)
  - Review Partner database to confirm source of this sponsor entry

**Recommendation**: Remove "SF Distilling Co" from Wave 1 if brand cannot be verified. Focus on the 3 confirmed brands (Distillery 209, Fernet-Branca, St. George).

## Wave 1 Sponsor Outreach Status

### Ready to Send (3 brands = $18-26K potential)
| Brand | Contact | Target $ | Status |
|-------|---------|----------|--------|
| Distillery No. 209 | info@distillery209.com | $5-8K | ✅ READY |
| Fernet-Branca | contactus@brancausa.com | $5-10K | ✅ READY |
| St. George Spirits | info@stgeorgespirits.com | $5-8K | ✅ READY |

**Total Potential**: $15-26K from 3 brands (still strong Wave 1)

### Blocked (1 brand)
| Brand | Issue | Next Action |
|-------|-------|-------------|
| SF Distilling Co | Cannot find official website or contact | Verify brand exists or remove from pipeline |

## Email Draft Requirements

All 3 brands need sponsor outreach emails drafted. Template should include:

**SF-Specific Angle**:
- Emphasize local SF connection (all 3 are Bay Area distilleries)
- Reference SF event series, unique SF venues (mansions, historic sites)
- Target SF young professional demographic

**Event Fit**:
- 1920s Prohibition speakeasy (perfect for all 3 spirits)
- Botanical cocktail garden parties (St. George botanicals angle)
- Murder mystery, immersive dinner experiences

**Partnership Ask**:
- $5-10K sponsorship for 2-3 event series
- Product integration (signature cocktails, bar placement)
- Brand mentions in marketing (email, social, event pages)
- Photo/video content for their channels

## Strategic Notes

### Fernet-Branca SF History (Competitive Advantage)
Per KQED article research:
- Fernet sponsored **art showings, rock shows, bartender parties** in SF
- Threw "huge parties for the bars that sold the most Fernet"
- Events at venues like Thee Parkside
- Strategy: "Bartenders, art and music, always with Fernet-Branca"

**Pitch Angle**: Reference their SF event sponsorship legacy, position as continuing that tradition with new generation of SF events.

### St. George Local Festivals
Per LeadIQ research:
- Partners with local festivals and community events (Headwest Marketplace)
- Experiential marketing focus (tastings, brand visibility)
- **Opportunity**: Position as similar local festival/community event partnership

## Database Updates Required

```sql
-- Update Partner table with confirmed contacts
UPDATE Partner SET 
  notes = 'Contact: info@distillery209.com (Official website contact for wholesale/partnerships)'
WHERE name = 'Distillery No. 209';

UPDATE Partner SET 
  notes = 'Contact: contactus@brancausa.com (Branca USA - NY office). Extensive SF sponsorship history: art shows, music events, bartender parties. Local event-friendly brand.'
WHERE name = 'Fernet-Branca';

UPDATE Partner SET 
  notes = 'Contact: info@stgeorgespirits.com, Phone: 510-769-1601. Community engagement focus: local festivals, experiential marketing.'
WHERE name = 'St. George Spirits';

-- Flag SF Distilling for review
UPDATE Partner SET 
  status = 'needs_verification',
  notes = 'VERIFY BRAND: Cannot find official website or contact info (March 11 research). May not exist or have different name.'
WHERE name = 'SF Distilling Co';
```

## Next Steps

### Immediate (Autonomous Work)
1. Draft 3 sponsor outreach emails:
   - Distillery 209 (SF gin, premium cocktail focus)
   - Fernet-Branca (SF legacy angle, art/music/bartender events)
   - St. George Spirits (Alameda craft distillery, community events)

2. Update SPONSOR-OUTREACH-TRACKER with contacts + ready status

### Main Session Required
1. Review 3 draft emails
2. Verify/remove "SF Distilling Co" from pipeline
3. Approve + send Wave 1 emails (3 brands)

## Research Methodology

**Time**: 11:47-11:48 AM (1 minute execution, minimal research needed)  
**Searches**: 4 total (1 per brand)  
**Success Rate**: 75% (3/4 brands found)  
**Blocker**: 1 brand cannot be verified (likely doesn't exist or wrong name)

**Pattern Observed**:
- Craft distilleries publish info@ or contact@ emails on websites
- Smaller brands (SF Distilling) may not have online presence
- SF spirits brands are event-friendly (Fernet history proves it)

## Impact on Wave 1 Campaign

**Before Research**:
- 4 brands targeted = $18-31K potential
- ALL blocked on contact research

**After Research**:
- 3 brands READY = $15-26K potential ✅
- 1 brand needs verification (likely remove)

**Campaign Health**: STRONG - 3 confirmed SF spirits brands with direct emails, all event-friendly based on research.

---

**Status**: Wave 1 contact research 75% complete. 3 brands ready for immediate outreach.  
**Blocker Removed**: Can now draft + send Wave 1 emails (pending main session approval).  
**Next Work**: Draft 3 sponsor emails for Distillery 209, Fernet-Branca, St. George Spirits.
