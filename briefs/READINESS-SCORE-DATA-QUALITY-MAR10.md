# Readiness Score Data Quality Issue - Mar 10, 2026 6:32 AM

## ISSUE SUMMARY
Multiple events have incorrect or unupdated readiness scores that don't reflect their actual planning state.

## CRITICAL EXAMPLE: evt-001 (Western Line Dancing Night)

### Current Database State
```
Event ID: evt-001
Name: Western Line Dancing Night
Date: 2026-03-29 (19 days away)
Venue ID: cmlroaf2e0017x4ldayr4i2zv (Log Cabin, 300 capacity)
Status: planning
Readiness Score: 0 ❌ INCORRECT
```

### Actual Readiness Assessment

**Date Status:** ✅ CONFIRMED (March 29, 2026)
- Event is 19 days away
- Date communicated to multiple vendors
- Date correction email sent March 6 to Bay Area Beats

**Venue Status:** ✅ SET (Log Cabin, 300 capacity)
- Venue ID exists in database
- Listed in Event table

**Vendor Status:** ⚠️ PARTIAL PROGRESS
- 5 venue vendors contacted Feb 5-6 (Frontier Tower, Stable Cafe, etc)
- Bay Area Beats DJ confirmed and corrected
- Multiple vendors awaiting responses (30+ days overdue)
- **Blocker:** Venue follow-ups needed (priority 85 task)

**Budget Status:** ⚠️ LIKELY DEFINED
- Financial models exist for similar events
- Per-person target: $40-70 range

**Marketing Status:** ❌ NOT LAUNCHED
- Not visible on Luma (unconfirmed)
- No public registrations tracked

### Estimated Correct Readiness Score: 75-80

**Breakdown:**
- Date confirmed: +30
- Venue confirmed: +30
- Vendor outreach initiated: +15
- Vendor responses pending: +5
- Budget framework: +5
- Marketing not launched: +0
- **Total: 85**

Deduct 5-10 points for overdue vendor follow-ups = **75-80 range**

## COMPARISON: Nostalgia Night (evt-nostalgia-2414)

### Database State
```
Status: confirmed
Date: NULL
Venue: NULL
Readiness Score: 30
```

**Analysis:** Score of 30 is more accurate than evt-001's score of 0, but status "confirmed" is wrong when date/venue are missing. Should be "planning" status.

## PATTERN ACROSS ALL PLANNING EVENTS

Checked top 10 events by readiness score:
```
1. Art Deco Jazz Soirée: 55
2. Botanical Cocktail Lab: 50
3. Canvas & Cocktails: 48
4. Jazz Age Garden Party: 48
5. Midnight Secrets: 47
6. Golden Hour Social: 46
7. Neon Nights Roller Disco: 46
8. Cosmic Dreams Planetarium: 46
9. Bay Lights Soirée: 45
10. Moonlight Film Festival: 45
```

**Observation:** These events have NO confirmed dates/venues yet have higher readiness scores (45-55) than evt-001 which HAS confirmed date/venue (score 0).

**Conclusion:** Readiness scoring system is either:
1. Not being calculated automatically
2. Not updated when event details change
3. Calculated incorrectly (inverse correlation with actual readiness)

## ROOT CAUSE HYPOTHESIS

**Theory 1: Manual Scoring**
- Readiness scores are manually set, not auto-calculated
- evt-001 score never updated after date/venue confirmation
- Other events have scores from initial brainstorming phase

**Theory 2: Stale Data**
- Scoring algorithm ran once during initial setup
- No trigger for recalculation when event details change
- evt-001 created before scoring system existed (defaults to 0)

**Theory 3: Broken Calculation**
- Scoring algorithm exists but has bugs
- Wrong factors weighted or inverted logic

## IMPACT

### Decision-Making Problems
- Cannot trust readiness scores for prioritization
- evt-001 appears "not ready" when it's actually closest to launch
- Nostalgia Night appears partially ready but missing critical data

### Resource Allocation Issues
- Team may deprioritize evt-001 based on low score
- Other events may get more attention despite being less ready
- Automated systems relying on readiness scores will fail

### Operational Confusion
- Readiness score should guide "what's next" decisions
- Current scores mislead rather than inform

## RECOMMENDED ACTIONS

### Immediate (This Week)
1. **Manual evt-001 score update:** Set to 75 to reflect actual state
2. **Nostalgia Night status fix:** Change "confirmed" → "planning" until date/venue set
3. **Document scoring criteria:** What factors contribute to readiness score?

### Short-Term (This Month)
4. **Scoring algorithm audit:** Review code, identify calculation logic
5. **Trigger implementation:** Auto-recalculate when date/venue/vendors change
6. **Bulk recalculation:** Run scoring on all active events

### Long-Term (Ongoing)
7. **Monitoring dashboard:** Track readiness score changes over time
8. **Validation rules:** Alert when score doesn't match manual assessment
9. **Score breakdown UI:** Show which factors contribute to each event's score

## AUTONOMOUS FIX (Proposed)

**Can I manually update evt-001 score right now?**

```sql
UPDATE Event 
SET readinessScore = 75,
    notes = COALESCE(notes, '') || ' | Readiness score manually corrected Mar 10 2026 (was 0, should be 75 based on confirmed date/venue)'
WHERE id = 'evt-001';
```

**Risk:** Low - score is clearly wrong, manual correction improves data quality

**Authorization needed:** This changes event metadata, should confirm with Zed first

## NEXT STEPS

**For Zed:**
1. Approve manual evt-001 readiness score correction (0 → 75)
2. Clarify: Is readiness scoring automatic or manual?
3. If manual: Provide criteria so I can calculate accurately
4. If automatic: Identify why calculation isn't running/working

**For Vinny (autonomous):**
1. Create task for scoring algorithm audit (priority 70)
2. Document current scores as baseline for tracking
3. Build readiness score calculator tool for validation

---

**Generated:** 2026-03-10 6:32 AM PST  
**Autonomous data quality analysis during blocked period**  
**Impact:** Critical for event prioritization and resource allocation
