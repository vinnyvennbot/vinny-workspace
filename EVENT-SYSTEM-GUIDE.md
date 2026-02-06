# Event Taxonomy System Guide

## Overview
To prevent confusion between multiple concurrent events, we use a structured event taxonomy system with unique Event IDs.

## Directory Structure

```
/events/
├── EVENT-REGISTRY.md                  # Master event list
├── EVT-001-western-march7/
│   ├── metadata.json                   # Event configuration
│   ├── README.md                       # Event overview
│   ├── western-line-dancing-budget.md
│   ├── western_dancing_financial_model.xlsx
│   └── [all EVT-001 related files]
├── EVT-002-dinner-feb28/
│   ├── metadata.json
│   ├── README.md
│   ├── private-dinner-proposal.md
│   └── [all EVT-002 related files]
└── EVT-003-gatsby-festival-1000/
    ├── metadata.json
    ├── README.md
    ├── gatsby_vendor_outreach.md
    └── [all EVT-003 related files]
```

## Event ID Format

- **Format:** `EVT-XXX` (sequential numbers)
- **Folder naming:** `EVT-XXX-shortname-date/`
- **Examples:**
  - EVT-001: Western Line Dancing
  - EVT-002: Intimate Dinner
  - EVT-003: Great Gatsby Festival

## Creating a New Event

### 1. Create Event Folder & Metadata
```bash
mkdir -p events/EVT-004-event-name-date/

cat > events/EVT-004-event-name-date/metadata.json << 'EOF'
{
  "event_id": "EVT-004",
  "name": "Event Name",
  "date": "YYYY-MM-DD",
  "status": "planning",
  "capacity": 100,
  "budget_per_person": 50,
  "theme": "Event theme",
  "venue": "TBD",
  "created": "YYYY-MM-DD",
  "last_updated": "YYYY-MM-DD",
  "priority": "medium",
  "notes": ""
}
EOF
```

### 2. Create README
Use template from existing event folders.

### 3. Update EVENT-REGISTRY.md
Add new event to master list with:
- Event ID
- Date
- Capacity
- Budget
- Status
- Key details

### 4. Check for Date Conflicts
Before finalizing date, verify no overlap with other events in EVENT-REGISTRY.md

## Using Event IDs

### In Emails
**Subject:**
```
EVT-001: Western Line Dancing - Mechanical Bull Inquiry
```

**Body:**
```
We're planning our EVT-001: Western Line Dancing event on March 7...
```

### In Google Sheets
**Always include Event_ID column:**

| Vendor Name | Category | Event_ID | Status | Contact | Date_Contacted |
|-------------|----------|----------|--------|---------|----------------|
| Let's Party | Bull     | EVT-001  | Quote  | ...     | 2026-02-05     |
| Fort Mason  | Venue    | EVT-003  | Email  | ...     | 2026-02-05     |

### In Memory Files & Documentation
```markdown
## EVT-001 Status Update
- Let's Party: Awaiting insurance docs
- Boot Barn: Partnership proposal sent

## EVT-003 Vendor Outreach
- 100+ vendors contacted
- 24-hour follow-up in progress
```

### In Code/Scripts
```python
EVENT_ID = "EVT-001"
vendor_database[vendor_name]["event_id"] = EVENT_ID
```

## Metadata Fields

```json
{
  "event_id": "EVT-XXX",          // Unique identifier
  "name": "string",                // Event name
  "date": "YYYY-MM-DD",           // Event date (or "TBD")
  "status": "string",              // planning|outreach|confirmed|complete
  "capacity": number,              // Attendee capacity
  "budget_per_person": number,    // Per-person budget
  "theme": "string",               // Event theme/concept
  "venue": "string",               // Venue name or "TBD"
  "created": "YYYY-MM-DD",        // Creation date
  "last_updated": "YYYY-MM-DD",   // Last modification
  "priority": "string",            // low|medium|high|urgent
  "notes": "string"                // Additional context
}
```

## Status Values

- **planning**: Initial planning phase
- **outreach**: Vendor outreach in progress
- **negotiation**: Quotes received, negotiating
- **confirmed**: Vendors/venue confirmed
- **production**: Active setup phase
- **complete**: Event finished
- **cancelled**: Event cancelled
- **postponed**: Event postponed

## File Organization Rules

### ✅ DO:
- Keep ALL event files in event folder
- Use Event ID in filenames: `EVT-001_vendor_tracker.xlsx`
- Update metadata.json when status changes
- Reference Event ID in all external communications
- Check EVENT-REGISTRY.md before scheduling

### ❌ DON'T:
- Don't mix event files in root workspace
- Don't create event files without Event ID
- Don't schedule without checking for conflicts
- Don't forget to update Google Sheets with Event_ID column
- Don't reference events by name only (always include ID)

## Google Sheets Integration

### Master Vendor Database Structure
```
Vendor_Name | Category | Event_ID | Status | Contact_Email | Phone | Date_Contacted | Last_Followup | Quote_Amount | Notes
```

### Querying by Event
```bash
# Get all vendors for EVT-001
gog sheets query SHEET_ID "SELECT * WHERE Event_ID = 'EVT-001'"

# Get all venues across all events
gog sheets query SHEET_ID "SELECT * WHERE Category = 'Venue'"
```

## Benefits

1. **No Confusion**: Each event has isolated files and clear ID
2. **Date Conflict Prevention**: EVENT-REGISTRY.md shows all dates at a glance
3. **Database Filtering**: Easy to query vendors/venues by Event_ID
4. **Scalability**: Can manage 10+ concurrent events without mixing
5. **Team Clarity**: Everyone knows which event is which
6. **Audit Trail**: Clear history per event in its folder

## Migration Process (Completed 2026-02-05)

1. ✅ Created `/events/` folder structure
2. ✅ Assigned Event IDs to existing events
3. ✅ Created metadata.json for each event
4. ✅ Moved all existing files to correct event folders
5. ✅ Created README.md for each event
6. ✅ Created EVENT-REGISTRY.md master list
7. ✅ Updated HEARTBEAT.md to reference Event IDs
8. ✅ Updated WORKFLOWS.md with event taxonomy rules
9. ⏳ Next: Update Google Sheets with Event_ID columns
10. ⏳ Next: Train all memory references to use Event IDs

---

**Created:** 2026-02-05 23:36 PST  
**Version:** 1.0  
**Status:** Active
