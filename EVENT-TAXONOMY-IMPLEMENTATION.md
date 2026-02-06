# Event Taxonomy System Implementation

## Problem Diagnosed (2026-02-05 23:30 PST)

**Root causes of event confusion:**
1. No event structure - all files scattered in root workspace
2. Inconsistent naming conventions (gatsby_*, western_*, intimate_dinner_*)
3. Context bleeding in memory files (all events mixed together)
4. Database mixing - no way to filter "which vendors for which event?"
5. Timeline conflicts not surfaced (March 7 double-booking)

## Solution Implemented (2026-02-05 23:36 PST)

### 1. Event Folder Structure
Created `/events/` directory with unique Event IDs:

```
/events/
├── EVENT-REGISTRY.md                      # Master event list
├── EVT-001-western-march7/               # Western line dancing
│   ├── metadata.json
│   ├── README.md
│   └── [5 event files moved]
├── EVT-002-dinner-feb28/                 # Intimate dinner
│   ├── metadata.json
│   ├── README.md
│   └── [3 event files moved]
└── EVT-003-gatsby-festival-1000/         # Great Gatsby festival
    ├── metadata.json
    ├── README.md
    └── [60+ event files moved]
```

### 2. Event Metadata System
Each event has `metadata.json` with:
- event_id (EVT-XXX)
- name, date, status, capacity, budget
- theme, venue, priority, notes
- created/last_updated timestamps

### 3. Master Registry
`EVENT-REGISTRY.md` provides:
- Complete list of all active events
- Quick reference for dates/budgets/status
- Date conflict checking
- Event ID lookup

### 4. Event READMEs
Each event folder contains `README.md` with:
- Event details
- Active issues/warnings
- Vendor status
- Files inventory
- Next steps

### 5. Documentation Updates
Updated core files to use Event IDs:
- **WORKFLOWS.md**: Added event taxonomy rules section
- **HEARTBEAT.md**: References EVT-001, EVT-002, EVT-003 instead of mixing
- **TOOLS.md**: Added Event_ID column requirement for Google Sheets
- **EVENT-SYSTEM-GUIDE.md**: Comprehensive usage guide (new file)

### 6. File Migration
Moved 70+ event-specific files into correct event folders:
- EVT-001: 5 western dancing files
- EVT-002: 3 intimate dinner files
- EVT-003: 60+ Great Gatsby files

### 7. Helper Script
Created `add_event_id_to_sheets.py` to assist with adding Event_ID columns to existing Google Sheets databases.

## Benefits

### Clarity
- ✅ Each event has isolated files - no mixing
- ✅ Event IDs make it clear which event you're working on
- ✅ README per event shows status at a glance

### Conflict Prevention
- ✅ EVENT-REGISTRY.md shows all dates - no double-booking
- ✅ Identified March 7 conflict (Western + SF Chronicle Wine Competition)

### Database Organization
- ✅ Event_ID column enables filtering vendors by event
- ✅ Can query "Show me all EVT-001 vendors" in Google Sheets
- ✅ No more mixing mechanical bulls with Gatsby caterers

### Scalability
- ✅ Can manage 10+ concurrent events without confusion
- ✅ Clear structure for adding new events (EVT-004, EVT-005, etc.)
- ✅ Easy to archive completed events

### Team Coordination
- ✅ Everyone references same Event ID in emails/chats
- ✅ Clear ownership and status tracking
- ✅ Easier to delegate event-specific tasks

## Usage Rules (New Standard)

### 1. Always Use Event IDs
In emails: "EVT-001: Western Line Dancing inquiry"
In databases: Event_ID column = "EVT-001"
In memory: "EVT-003 vendor responses received"

### 2. All Event Files Go In Event Folder
❌ Don't: Create `gatsby_new_thing.md` in root workspace
✅ Do: Create `events/EVT-003-gatsby-festival-1000/new_thing.md`

### 3. Check EVENT-REGISTRY.md Before Scheduling
Prevents date conflicts like March 7 double-booking

### 4. Update metadata.json When Status Changes
Keep event status current: planning → outreach → confirmed → production

### 5. Google Sheets Must Have Event_ID Column
Enables filtering and prevents vendor mixing

## Next Steps

### Immediate (Tonight)
- [ ] Review EVENT-REGISTRY.md for accuracy
- [ ] Verify all files moved correctly
- [ ] Update MEMORY.md to reference Event IDs

### Short-term (This Week)
- [ ] Add Event_ID column to Google Sheets (Venues, Vendors masters)
- [ ] Update vendor tracking to use Event IDs
- [ ] Resolve EVT-001 March 7 date conflict
- [ ] Fix EVT-002 budget overrun ($60 reduction needed)

### Medium-term (This Month)
- [ ] Train all future memory entries to use Event IDs
- [ ] Create event archival process for completed events
- [ ] Expand system to handle 5+ concurrent events

## Lessons Learned

### What Went Wrong
- Started planning multiple events without organization structure
- Let files accumulate in root workspace without taxonomy
- Mixed event context in memory files
- No date conflict checking system

### What We Fixed
- Created strict event folder structure
- Assigned unique Event IDs to prevent confusion
- Separated event contexts in all documentation
- Built date conflict prevention system

### Prevention Going Forward
- NEVER create event files in root workspace
- ALWAYS assign Event ID before starting planning
- ALWAYS check EVENT-REGISTRY.md before scheduling
- ALWAYS include Event_ID in database entries

## Files Created

1. `/events/EVENT-REGISTRY.md` - Master event list
2. `/events/EVT-001-western-march7/metadata.json` - Western event config
3. `/events/EVT-001-western-march7/README.md` - Western event overview
4. `/events/EVT-002-dinner-feb28/metadata.json` - Dinner event config
5. `/events/EVT-002-dinner-feb28/README.md` - Dinner event overview
6. `/events/EVT-003-gatsby-festival-1000/metadata.json` - Gatsby event config
7. `/events/EVT-003-gatsby-festival-1000/README.md` - Gatsby event overview
8. `/EVENT-SYSTEM-GUIDE.md` - Comprehensive usage guide
9. `/add_event_id_to_sheets.py` - Helper script for Google Sheets
10. `/EVENT-TAXONOMY-IMPLEMENTATION.md` - This document

## Files Modified

1. `WORKFLOWS.md` - Added event taxonomy section
2. `HEARTBEAT.md` - Updated to use Event IDs
3. `TOOLS.md` - Added Event_ID column requirement

## Files Moved

- 5 files → EVT-001
- 3 files → EVT-002
- 60+ files → EVT-003

Total: 70+ files organized

---

**Implementation Date:** 2026-02-05 23:36 PST  
**Implementation Time:** ~15 minutes  
**Status:** ✅ Complete  
**Impact:** High - prevents all future event confusion  
**Approval:** User requested via "Yes, do that"
