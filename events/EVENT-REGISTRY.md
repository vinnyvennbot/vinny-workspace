# EVENT REGISTRY

Master list of all active and planned events. Each event has its own folder with isolated files.

## Active Events

### EVT-001: Western Line Dancing Night
- **Date:** March 7, 2026 (TENTATIVE - may conflict with SF Chronicle Wine Competition)
- **Capacity:** 150
- **Budget:** $60/person
- **Status:** Planning
- **Folder:** `events/EVT-001-western-march7/`
- **Key Vendors:** Let's Party (mechanical bull), Boot Barn, DJ/band TBD
- **Next Steps:** Resolve date conflict, confirm venue

### EVT-002: Intimate 30-Person Dinner
- **Date:** February 28, 2026
- **Capacity:** 30
- **Budget:** $70/person (HARD CAP)
- **Status:** Planning
- **Folder:** `events/EVT-002-dinner-feb28/`
- **Key Vendors:** Venue TBD, catering TBD
- **Next Steps:** Venue selection, catering quotes

### EVT-003: Great Gatsby Festival
- **Date:** TBD
- **Capacity:** 1000
- **Budget:** $60/person
- **Status:** Outreach Phase
- **Folder:** `events/EVT-003-gatsby-festival-1000/`
- **Theme:** 1920s Art Deco / "The Great Gatsby Murder" interactive experience
- **Key Vendors:** 100+ contacted (venues, catering, entertainment, production)
- **Next Steps:** Collect vendor responses, negotiate pricing, select date

### EVT-004: Murder Mystery Yacht Party
- **Date:** TBD (4-6 months lead time)
- **Capacity:** 400
- **Budget:** $280/person ($112K total)
- **Status:** Outreach Phase
- **Folder:** `events/EVT-004-murder-mystery-yacht-400/`
- **Theme:** Immersive murder mystery theatrical experience on SF Bay
- **Venue:** City Experiences - San Francisco Spirit yacht (400 capacity)
- **Key Vendors:** 6 production companies contacted (2026-02-05)
- **Next Steps:** Verify email deliveries, contact yacht venue, follow up with vendors
- **Proven:** Venn executed similar 400-person yacht event "Boots on Deck" (Summer 2025)

---

## Event ID Format
- **EVT-XXX**: Sequential event identifier
- Folder naming: `EVT-XXX-shortname-date/`
- All event files MUST go in event folder (no root-level event files)

## Usage Rules
1. **Always reference Event ID** in vendor communications, database entries, memory files
2. **Create new event folder** before planning begins (don't wait for files to accumulate)
3. **Move all event files** into correct folder immediately (no mixing in root workspace)
4. **Update metadata.json** when status/details change
5. **Check EVENT-REGISTRY.md** before scheduling to avoid date conflicts

## Google Sheets Integration
All vendor/venue databases must include **Event_ID** column to prevent mixing.

Example:
```
Vendor Name | Category | Event_ID | Status | Contact | Date_Contacted
Let's Party | Bull     | EVT-001  | Quote Received | ...
```

---

## Event Status Summary

| Event ID | Name | Date | Capacity | Status | Priority |
|----------|------|------|----------|--------|----------|
| EVT-001 | Western Line Dancing | March 7, 2026* | 150 | Planning | High |
| EVT-002 | Intimate Dinner | Feb 28, 2026 | 30 | Planning | High |
| EVT-003 | Great Gatsby Festival | TBD | 1000 | Outreach | Medium |
| EVT-004 | Murder Mystery Yacht | TBD | 400 | Outreach | Medium |

*EVT-001 date conflict with SF Chronicle Wine Competition - may move to March 14

---

Last Updated: 2026-02-05 23:43 PST
