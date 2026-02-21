# Instagram Engagement Protocol (@vinny.vennsf)

## Mission
Build a relevant For You page focused on SF events, creators, and venues through consistent daily engagement.

## Rules
- ✅ **Engage with**: SF events content, local creators, venues, culture, nightlife, food/drink scenes
- ❌ **EXCLUDE**: Vently, SF Social Club (competitors)
- ⚠️ **Bot Prevention**: Vary timing, realistic engagement patterns, daily limits
- 📊 **Log to CRM**: Interesting creators → Person table (role='Creator') + Partner table (category='content_creator')

## Daily Engagement Targets (24/7 Rotation)
**Spread across heartbeats to avoid detection:**

### Per Session (Every 2-3 heartbeats):
- **3-5 likes** on SF events/culture posts
- **1-2 story views** from followed accounts
- **0-1 comments** (only when genuinely relevant, mix it up)
- **0-1 new follows** (creators/venues only, not random people)

### Daily Total (~8-10 sessions):
- **25-40 likes** across SF content
- **8-15 story views**
- **2-5 comments** (natural, not spammy)
- **2-4 new follows** (quality over quantity)

## Content Priorities (What to Engage With)
1. **SF Event Announcements** - parties, festivals, experiences, pop-ups
2. **Creator Content** - people posting about SF nightlife/events
3. **Venue Posts** - clubs, bars, unique spaces, galleries
4. **SF Culture** - art, food, community events
5. **Discovery Content** - "hidden SF gems", local guides

## Engagement Pattern (Anti-Bot)
- **Vary timing**: Not every X minutes - randomize between 15-45 min gaps
- **Mix actions**: Like → story → comment → like → follow → like (never repeat patterns)
- **Human rhythm**: Burst activity (5 actions in 10 min) → quiet period (1 hour) → burst again
- **Session length**: 5-10 minutes of activity, then idle
- **Skip some cycles**: Not every heartbeat = Instagram activity

## CRM Logging Rule
**When to log a creator:**
- ✅ They post SF event content regularly (not just one-off)
- ✅ They have 1K+ followers OR unique niche (doesn't have to be huge)
- ✅ Content quality is high (good photos, engaged audience)
- ✅ Potential Venn partnership fit (our vibe, our audience)

**How to log:**
```sql
-- Add to Person table
INSERT INTO Person (name, email, instagramHandle, role) 
VALUES ('Creator Name', 'email@example.com', '@handle', 'Creator');

-- Add to Partner table
INSERT INTO Partner (name, partnerType, category, status, contactInfo, notes)
VALUES ('Creator Name', 'creator', 'content_creator', 'prospect', 
        '{"instagram": "@handle"}', 
        'SF events creator - [describe content/audience]');
```

## Tracking
Log engagement stats daily in `memory/instagram-engagement-log.md`:
- Date
- Likes given
- Comments posted
- New follows
- Creators logged to CRM
- For You page observations (is it getting better?)

## Current Status (Feb 20, 2026)
- Username: @vinny.vennsf
- Following: 26 accounts
- Followers: 0
- Posts: 0
- For You page: Building (SF-focused content appearing)
- Browser profile: openclaw (localhost:18800)

---
*Updated: 2026-02-20 23:12 PST*
