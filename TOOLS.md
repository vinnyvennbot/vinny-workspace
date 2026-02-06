# TOOLS.md - Local Tool Configuration

## 🗄️ DATABASE LOCATIONS & REAL-TIME UPDATE PROTOCOL

### **Google Sheets - Source of Truth**
All business operations tracked in Google Drive folder structure:
```
Database/ (ID: 1cD2qjNpq15vv2hUJ-9Armo6VX1dMer6f)
├── Venues/ (ID: 11s38axjvVAwkwMib5VzuaQeYqvnu-rhY)
│   └── Event Venues Master (ID: 1M_9po4jW6coYgqnlLr34dNxUK91zDquMe9Pf4ldHYVU)
├── Vendors/ (ID: 1Iwn-76C29pK7WKOOh9-mKnmRdRX9lUTf)
│   └── vendors_master_formatted.xlsx (ID: 1Q6WAcAEJ5GEqpGSBucyqcqP3KK2BNBMh)
├── Partners/ (ID: 1em8cGF1pa2NqVy238qsU4quJ1XUawW3Y)
├── Sponsors/ (ID: 1eAHRkk5Vpa-Ai1gdsmm7TON2uV96Uke0)
└── Influencers/ (ID: 1DQiHgQHEhQPWs4FI51f9ZrVnVIsTTW1j)
```

### **REAL-TIME UPDATE REQUIREMENTS**
**CRITICAL:** Every vendor interaction MUST update Google Sheets immediately:

```bash
# Example: After sending email to vendor
gog gmail send --to="vendor@example.com" --subject="..." --body="..."
# ↓ IMMEDIATELY AFTER (same minute):
gog sheets update SHEET_ID "A2" "Vendor Name" "Category" "email@example.com" "..." "2026-02-05" "22:35 PST" "Email Sent" "message_id_here"
```

**Pattern: ACTION → DATABASE UPDATE → COMMIT**
1. Take action (send email, make call, receive response)
2. Update Google Sheet with that action immediately
3. Git commit tracking files

**NEVER:**
- ❌ Batch updates "at the end"
- ❌ Update markdown files instead of sheets
- ❌ Create new sheets for every new project (check existing first)
- ❌ Share plain unformatted sheets with team

### **Sheet Update Commands**
```bash
# List sheets in folder
gog drive ls --parent FOLDER_ID

# Update single row (ALWAYS include Event_ID column)
gog sheets update SHEET_ID "A2:K2" "EVT-001" "Vendor Name" "Category" "email@example.com" "..." 

# Get sheet metadata
gog sheets metadata SHEET_ID

# Share with team (ALWAYS do this)
gog drive share SHEET_ID --email zed.truong@vennapp.co --role writer
```

### **Event ID Column Requirement**
**CRITICAL:** All vendor/venue databases MUST include Event_ID column:
```
Event_ID | Vendor_Name | Category | Contact_Email | Status | Date_Contacted | ...
EVT-001  | Let's Party | Bull     | info@...      | Quote  | 2026-02-05     | ...
EVT-003  | Fort Mason  | Venue    | events@...    | Email  | 2026-02-05     | ...
```

This prevents mixing vendors from different events and enables filtering.

### **Professional Formatting (Use xlsx skill)**
```python
# Create formatted Excel file, then upload
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

# ... create formatted workbook ...
wb.save("formatted_sheet.xlsx")

# Upload to Drive
gog drive upload formatted_sheet.xlsx --parent FOLDER_ID --name "Sheet Name"
```

---

## Email Sending (gog CLI)

### **Business Email Protocol**
```bash
# Send vendor outreach email
gog gmail send --to="vendor@example.com" --subject="Great Gatsby Festival Inquiry" --body="[email content]"

# Send with CC to team
gog gmail send --to="vendor@example.com" --cc="zed.truong@vennapp.co" --subject="Subject" --body="Content"

# Send using template file
gog gmail send --to="vendor@example.com" --subject="Subject" --body-file="templates/vendor-outreach.txt"
```

### **Standard Email Signature**
```
Best regards,
Vinny
Venn Social Events
vinny@vennapp.co | vennsocial.co
925-389-4794
```

### **Email Templates Location**
- Vendor outreach: `templates/vendor-outreach.txt`
- Follow-up: `templates/follow-up-24h.txt`  
- Thank you: `templates/thank-you.txt`

### **Gmail Configuration**
- **Account**: Pre-configured in gog CLI
- **Config**: `/Users/vinnyvenn/Library/Application Support/gogcli/config.json`
- **Auth**: OAuth already set up and working

### **Business Email Guidelines**
- ✅ **Always use gog** for vendor/business outreach
- ✅ **Professional signature** on all business emails
- ✅ **CC Zed** on important vendor responses
- ❌ **Never mention budget** in initial outreach
- ❌ **No emojis** in business communications

## Calendar Integration

### **Google Calendar via gog**
```bash
# Create event when Zed requests meetings
gog calendar events create --summary="Vendor Call" --start="2026-02-07T10:00:00" --attendees="vendor@example.com,zed.truong@vennapp.co"
```

## Environment-Specific Setup

### **Camera Names** 
- None currently configured

### **SSH Hosts**
- None currently configured  

### **Voice Preferences**
- Default: System voice for TTS
- Business calls: Professional tone

---

This is your operational cheat sheet for daily business tools.
