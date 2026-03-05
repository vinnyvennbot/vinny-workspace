# Database Quality Issue: Orphaned Events Without Tasks
**Date:** March 4, 2026, 7:26 PM PST  
**Severity:** Medium  
**Category:** Data Integrity

---

## Issue Summary
Found **13 ideating events with zero tasks** in Mission Control database. Events exist in system but lack task structures needed for execution.

## Affected Events

| Event ID | Event Name | Status | Readiness | Tasks |
|----------|------------|--------|-----------|-------|
| EVT-2e378474 | Canvas & Cocktails | planning | 48 | **0** |
| EVT-927ea44b | Bay Lights Soirée | planning | 45 | **0** |
| EVT-928 | Jazz Age Garden Party | planning | 48 | **0** |
| EVT-929 | Neon Nights: Roller Disco Revival | planning | 46 | **0** |
| EVT-930 | Underground Supper Club | planning | 44 | **0** |
| EVT-931 | Cosmic Dreams: Planetarium Party | planning | 46 | **0** |
| EVT-a5ad16db | Golden Hour Social | planning | 46 | **0** |
| EVT-artdeco-feb27 | Art Deco Jazz Soirée | planning | 55 | **0** |
| EVT-be0b2d9a | Midnight Secrets | planning | 47 | **0** |
| EVT-botanical-feb27 | Botanical Cocktail Lab | planning | 50 | **0** |
| EVT-culinary-feb25 | Culinary Adventure Challenge | planning | 40 | **0** |
| EVT-cyberpunk-mar03 | Cyberpunk Underground | planning | 25 | **0** |
| EVT-jazz-supper-feb25 | Jazz Age Supper Club | planning | 42 | **0** |

**Only Exception:** EVT-enchanted-mar04 (Enchanted Forest) has 2 tasks

---

## Impact Analysis

### Operational
- **Event tracking incomplete** - No way to monitor progress toward activation
- **Vendor outreach blocked** - Can't track research, outreach, quotes without task structure
- **Team visibility reduced** - Events exist but appear "idle" in Mission Control
- **Prioritization unclear** - Can't distinguish between "approved pending work" vs "awaiting review"

### Strategic
- **Pipeline appears smaller than reality** - 13 concepts not visible in workflow
- **Resource allocation difficult** - Can't estimate time/effort without task breakdown
- **Approval bottleneck hidden** - No way to see which events need Zed's decision

---

## Root Cause

**Event Ideation Process Gap:**
1. Daily cron generates 4 event concepts → creates Event records
2. Research findings documented → stored in research/ files
3. **GAP:** No automatic task generation for new events
4. Events sit in "planning" status with no actionable tasks

**Result:** Events created but not "activated" in workflow

---

## Recommendations

### Immediate (This Week)
1. **Archive or activate** - Review 13 events with Zed:
   - Archive if not pursuing (prevent clutter)
   - Activate if approved (generate task structures)

2. **Generate task templates** - For events being pursued:
   - Venue research (3-5 options)
   - Vendor categories (DJ, catering, production, photo)
   - Partner outreach (sponsors, creators, marketing)
   - Budget modeling
   - Marketing content creation

### Process Improvement (Next Sprint)
3. **Automated task generation** - When event created, auto-generate:
   - "Research venues" task (priority 95)
   - "Identify vendor categories" task (priority 90)
   - "Create budget model" task (priority 85)
   - Status starts as 'pending' until Zed approves

4. **Event lifecycle states** - Clarify status field:
   - `ideating` → concept only, no tasks yet
   - `planning` → approved, tasks active, pursuing
   - `activating` → vendors being contacted
   - `confirmed` → date/venue locked
   - `live` → tickets on sale

### Monitoring (Ongoing)
5. **Weekly quality check** - Query events with zero tasks:
   ```sql
   SELECT e.id, e.name, COUNT(t.id) as tasks
   FROM Event e LEFT JOIN Task t ON t.eventId = e.id
   WHERE e.archived = 0 GROUP BY e.id HAVING tasks = 0;
   ```

6. **Heartbeat alert** - If orphaned events > 10, alert team

---

## Proposed Action (Next Heartbeat)

**Query for context:**
```bash
sqlite3 venn-mission-control/dev.db "
SELECT id, name, status, readinessScore, createdAt
FROM Event
WHERE archived = 0 AND id IN (
  SELECT e.id FROM Event e
  LEFT JOIN Task t ON t.eventId = e.id
  WHERE e.archived = 0
  GROUP BY e.id HAVING COUNT(t.id) = 0
)
ORDER BY createdAt DESC;"
```

**For Zed's Review:**
- Which of these 13 events should we pursue?
- Archive the rest to clean up pipeline?
- Generate task structures for approved events?

---

## Data Quality Metrics

**Current State:**
- Total active events: 28 (from previous query)
- Events with tasks: 15
- **Orphaned events: 13 (46.4%)**

**Target State:**
- Orphaned events: < 5% (max 1-2 pending review at any time)
- All "planning" events have ≥ 3 tasks
- Clear distinction between ideating vs pursuing

---

**Next Steps:**
1. Share brief with Zed for event review decisions
2. Generate task structures for approved events
3. Archive non-pursuing events
4. Implement automated task generation for future events

**Created:** 2026-03-04 19:26 PST  
**By:** Vinny (autonomous data quality audit)
