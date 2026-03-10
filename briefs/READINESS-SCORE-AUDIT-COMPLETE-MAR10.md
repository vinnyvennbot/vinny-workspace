# Readiness Score System Audit - COMPLETE

**Date**: March 10, 2026, 8:58 AM PST
**Priority**: 70 (Autonomous work during blocked period)
**Status**: ✅ RESOLVED - System working correctly

## Summary

**FALSE ALARM**: The readiness score system is functioning correctly. The database `readinessScore` column is UNUSED - scores are computed dynamically by the UI.

## Investigation

### Initial Concern
Morning brief (READINESS-SCORE-DATA-QUALITY-MAR10.md) reported evt-001 showing `readinessScore: 0` in database, which seemed incorrect given event progress.

### Root Cause Analysis
1. **Database Column**: `Event.readinessScore` exists in schema but is NOT used
2. **Actual System**: Scores computed on-the-fly by `/api/events` route using `computeReadiness()` function
3. **Why Confusion**: Newer events (from ideation workflow) have scores in DB column (46-55 range), older events show 0

### How Readiness Scoring Actually Works

**Function**: `src/lib/priority.ts` → `computeReadiness(event)`

**Scoring Breakdown** (max 100 pts):
- **Venue locked**: 20 pts
- **Date set**: 10 pts
- **Budget defined**: 5 pts
- **Marketing campaigns**: 5 pts (if any exist)
- **Task completion**: up to 30 pts
  - Formula: (doneTasks / totalTasks) × 30
  - Penalty: -3 pts per blocked task (max -10)
- **Vendor outreach**: up to 30 pts
  - Quote progress: (quotes_received / total) × 10 (max 10 pts)
  - Recommendations: recommended_count × 5 (max 10 pts)
  - Bookings: booked_count × 5 (max 10 pts)

## evt-001 Actual Readiness Score: **55 pts**

**Calculation**:
- ✅ Venue locked: 20 pts (venueId: cmlroaf2e0017x4ldayr4i2zv)
- ✅ Date set: 10 pts (March 29, 2026)
- ✅ Budget defined: 5 pts ($9,000 total)
- ❌ Marketing campaigns: 0 pts (none created yet)
- 🟡 Tasks: 6 pts (10 total: 5 done, 3 blocked)
  - Base: (5/10) × 30 = 15 pts
  - Penalty: 3 blocked × -3 = -9 pts
  - Net: 6 pts
- 🟡 Vendor outreach: 14 pts (30 vendors: 11 quotes, 0 booked, 6 recommended)
  - Quote progress: (11/30) × 10 = 3.67 ≈ 4 pts
  - Recommendations: min(6×5, 10) = 10 pts
  - Bookings: 0 × 5 = 0 pts
  - Net: 14 pts

**TOTAL: 20 + 10 + 5 + 0 + 6 + 14 = 55 pts**

## Other Events Checked

**evt-002 (Intimate Dinner)**: COMPLETED event, database shows 0 (expected - column unused)

**evt-004 (Murder Mystery Yacht)**: TBD event, database shows 0 (expected - column unused)

**Newer Events** (Feb 27+ ideation): Database shows 45-55 range
- These appear to have the DB column populated during creation
- Suggests ideation workflow may be writing to unused column
- Not causing issues - UI ignores DB column and recomputes

## Recommendations

### No Action Required
1. ✅ System is working correctly
2. ✅ UI correctly computes scores dynamically
3. ✅ evt-001 actual score (55) is reasonable given progress

### Optional Cleanup (Low Priority)
1. Remove `readinessScore` column from Event schema if truly unused
2. OR: Add trigger to keep DB column in sync with computed score
3. Update ideation workflow to stop populating unused column

## Impact on Event Prioritization

**Current Top 5 Events by Actual Readiness**:
1. evt-001 (Western Line Dancing): **55 pts** - Date March 29, venue locked, half tasks done
2. evt-nostalgia (80s/90s Night): **~50 pts** (estimated - event LIVE but no date in DB)
3. evt-004 (Murder Mystery Yacht): **~30 pts** (estimated - has vendors but no date/venue)
4. Planning events: 45-55 range (venue research complete, awaiting approvals)

**Priority matrix remains valid** - events with confirmed dates should activate first.

## Task Status Update

- **Task ID**: task-readiness-audit-mar10
- **Status**: DONE (autonomous work completed)
- **Result**: System working correctly, no fixes needed
- **Time**: 10 minutes (8:53-9:03 AM)
- **Next**: Mark task complete in database

---

**Lesson Learned**: Always check both the data layer AND the business logic layer when investigating "incorrect" values. Database columns can be deprecated without being removed.
