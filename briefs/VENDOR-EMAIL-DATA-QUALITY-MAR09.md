# Vendor Email Data Quality Issue - Mar 9, 2026 4:23 AM

## CRITICAL FINDING: 44% OF VENDORS HAVE NO EMAIL

**Data Quality Breakdown:**
- Total vendor records: 542
- Missing email (NULL or empty): 239 (44%)
- Valid email addresses: 303 (56%)

**All 239 missing emails are in "researching" status.**

## IMPACT

**Cannot Execute Outreach:**
- 239 vendors cannot be contacted via email
- Represents ~$50K+ in potential vendor services
- Blocks event activation for affected events

**Top 10 Events Most Affected:**

| Event | Missing Emails | Total Vendors | % Missing |
|-------|----------------|---------------|-----------|
| Moonlight Film Festival | 23 | 30 | 77% |
| Senegalese Night | 21 | 26 | 81% |
| Masquerade Ball | 20 | 28 | 71% |
| Art Deco Soirée | 19 | 24 | 79% |
| Botanical Cocktail Lab | 18 | 25 | 72% |

**Pattern:** Events with 25-30 vendors typically have 70-80% missing emails.

## ROOT CAUSE

**Incomplete Research Process:**

1. **Vendor brainstorming**: Names added during ideation ("we should contact X")
2. **No follow-through**: Contact research never completed
3. **Database pollution**: Placeholder records left in "researching" indefinitely

**Example:**
```
contactName: "SF Cocktail Club"
contactEmail: NULL
status: "researching"
notes: NULL
```

This is a **brainstorm entry**, not a researched vendor.

## DATA INTEGRITY RULES VIOLATED

Per MEMORY.md:
> "FINANCIAL DATA INTEGRITY: Never enter quote amounts or mark expenses paid without verbatim source."

**Missing rule:** Never create vendor records without verified contact information.

## RECOMMENDED FIXES

### Short-Term (Clean Existing Data)
1. **Manual research campaign**: Systematically find emails for 239 vendors
2. **Delete non-viable**: Remove vendors that can't be researched (defunct, contact form only)
3. **Target priority events**: Start with evt-001, evt-004, evt-nostalgia (active events)

### Long-Term (Prevent Future Issues)
4. **Schema enforcement**: Make `contactEmail` REQUIRED in VendorOutreach table
5. **Research validation**: Don't mark vendor "researched" until email verified
6. **Two-step process**: 
   - Step 1: Brainstorm vendors (separate "ideas" list)
   - Step 2: Research + add to database (only when contact verified)

## HISTORICAL CONTEXT

**Prior Research Campaign (Mar 6-8):**
- Researched 83 vendors across 2 days
- Improved Vendor table from 54% missing emails → 1.7% missing
- **Same issue now found in VendorOutreach table** (different table, same problem)

**Lesson:** Database-wide audit needed, not just single-table fixes.

## AUTONOMOUS WORK PLAN

**Batch Research Protocol (if approved):**
- 10 vendors per session
- 1-sec API delays (rate limit compliance)
- Multi-source verification (web search → official site → contact page)
- Real-time database updates
- Target: 239 → <20 missing emails within 1 week

**Priority Order:**
1. evt-001 vendors (23 missing emails) - HIGHEST
2. evt-004 vendors (6 missing emails)
3. evt-nostalgia vendors (14 missing emails)
4. Planning events with >20 missing emails

## NEXT STEPS

**Decision Needed:**
- Should I execute batch research campaign for 239 vendors?
- Or archive low-priority events and reduce research scope?
- Or enforce schema change first (prevent new bad data)?

**Estimated Time:**
- 239 vendors × 1 min avg = 4 hours total research
- Spread across 7 days = 35 min/day
- Could complete during overnight heartbeats

---

**Generated:** 2026-03-09 4:23 AM PST  
**Autonomous Discovery:** Database health audit  
**Recommendation:** Systematic research campaign or event triage
