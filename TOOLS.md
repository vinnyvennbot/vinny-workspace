# TOOLS.md - Local Tool Configuration

## 🖥️ SYSTEM CONFIGURATION

### **Screen Lock Prevention (macOS)**
Configured to never lock screen or sleep display:

```bash
# Screensaver disabled (idle time = 0)
defaults -currentHost write com.apple.screensaver idleTime 0

# Password prompt on wake disabled
defaults write com.apple.screensaver askForPassword -int 0

# Caffeinate running to prevent display sleep
caffeinate -d -i -s &
# Flags: -d (prevent display sleep), -i (prevent idle sleep), -s (prevent system sleep)

# Verify status:
pmset -g | grep -E "(displaysleep|sleep)"
# Should show: "display sleep prevented by caffeinate"

# Check caffeinate process:
ps aux | grep caffeinate | grep -v grep
```

**Current Status:**
- ✅ Screensaver idle time: 0 (never activates)
- ✅ Password on wake: disabled
- ✅ Caffeinate running: prevents display/system sleep indefinitely
- ✅ Display sleep: prevented by caffeinate (PID 12360)

**Note:** Caffeinate must be running to maintain this. Current instance started 2026-02-20 22:58 PST.

---

## 🚨 COMMAND SYNTAX REFERENCE (CRITICAL - READ FIRST!)

**ERROR PREVENTION PROTOCOL:**
1. **ALWAYS run `command --help` before using ANY new command or flag**
2. **NEVER assume syntax** - even similar commands differ across tools
3. **Test commands with non-critical data first**
4. **Document working patterns below immediately after discovery**

### **Gmail Commands (gog CLI)**

**❌ COMMON MISTAKES:**
```bash
# WRONG - these commands don't exist:
gog gmail get MESSAGE_ID       # ❌ No such command
gog gmail read MESSAGE_ID      # ❌ No such command  
gog gmail show MESSAGE_ID      # ❌ No such command
```

**✅ CORRECT SYNTAX:**
```bash
# Read/view a message (just pass the ID directly):
gog gmail MESSAGE_ID

# Search messages:
gog gmail messages search "query" --max 20
gog gmail messages search "in:inbox newer_than:4h" --max 20

# Send email (MUST include --to, --subject, --body):
gog gmail send --to="vendor@example.com" --subject="Title" --body='Message text'

# Reply in thread (PREFERRED - maintains threading):
gog gmail send --reply-to-message-id="19c4xxx" --reply-all --subject="Re: Title" --body='Reply'

# Get help when unsure:
gog gmail --help
gog gmail send --help
gog gmail messages --help
```

**CRITICAL RULES:**
- ✅ Always use `--reply-to-message-id` for vendor responses (maintains threading)
- ✅ Always include `--reply-all` to auto-populate recipients
- ✅ Always provide `--subject` even when replying
- ✅ Use **single quotes** for `--body` when text contains `$` symbols
- ❌ NEVER use double quotes with dollar amounts (`$1,400` becomes `,400`)

### **Google Calendar Commands (gog CLI)**

**❌ COMMON MISTAKES:**
```bash
# WRONG - these flags don't exist:
gog calendar events create --summary="Title"     # ❌ Wrong flag
gog calendar events create --time-min="..."      # ❌ Wrong flag
gog calendar create --start="..." --end="..."    # ❌ Missing calendar ID
```

**✅ CORRECT SYNTAX:**
```bash
# Create event (MUST specify calendar ID first):
gog calendar create primary --summary="Meeting Title" \
  --from="2026-02-13T10:00:00-08:00" \
  --to="2026-02-13T11:00:00-08:00" \
  --attendees="person1@example.com,person2@example.com" \
  --description="Meeting description" \
  --with-meet                # Adds Google Meet link

# List events:
gog calendar events list --max 50
gog calendar events list --from="2026-02-01" --to="2026-02-28"

# Get help:
gog calendar --help
gog calendar create --help
```

**CRITICAL RULES:**
- ✅ Calendar ID comes BEFORE flags (e.g., `create primary --summary=...`)
- ✅ Use `--from` and `--to` (NOT `--start` and `--end`)
- ✅ Use `--with-meet` to add Google Meet (NOT `--conference-solution`)
- ✅ Date format: ISO 8601 with timezone (`2026-02-13T10:00:00-08:00`)

### **Google Sheets Commands (gog CLI)**

**❌ COMMON MISTAKE:**
```bash
# WRONG - trying to update Excel files as if they were Google Sheets:
gog sheets update EXCEL_FILE_ID "A2" "data"   # ❌ Fails with "operation not supported"
```

**✅ CORRECT APPROACH:**
```bash
# Only works on actual Google Sheets (not .xlsx files in Drive):
gog sheets update SHEET_ID "A2:K2" "col1" "col2" "col3" ...

# Check if file is a Google Sheet first:
gog drive ls --query "name contains 'filename'"  # Look for mimeType

# For Excel files (.xlsx), you need to:
# 1. Download the file
# 2. Edit locally
# 3. Re-upload to Drive
```

**CRITICAL RULES:**
- ✅ `gog sheets` ONLY works with Google Sheets (mimeType: application/vnd.google-apps.spreadsheet)
- ✅ Excel files (.xlsx) in Drive are NOT Google Sheets - need different approach
- ✅ Check file type before attempting sheet operations

### **Google Drive Commands (gog CLI)**

**✅ CORRECT SYNTAX:**
```bash
# List files:
gog drive ls
gog drive ls --parent FOLDER_ID
gog drive ls --query "name contains 'search'"

# Upload file:
gog drive upload /path/to/file.pdf --parent FOLDER_ID --name "Custom Name"

# Share file:
gog drive share FILE_ID --email person@example.com --role writer

# Get help:
gog drive --help
```

### **Error Recovery Protocol**

When a command fails:

1. **Read the error message carefully** - it usually tells you exactly what's wrong
2. **Run `--help` on the command** - don't guess the fix
3. **Check TOOLS.md** - see if pattern is documented
4. **Test with a simple example** - verify syntax before complex usage
5. **Document the working pattern** - update TOOLS.md immediately

**Example Recovery:**
```bash
# Command failed:
gog gmail send --to="vendor@example.com" --body="Hi there"
# Error: required: --subject

# Check help:
gog gmail send --help
# Output shows: --subject is required

# Fix and document:
gog gmail send --to="vendor@example.com" --subject="Hello" --body="Hi there"
```

---

## ⚡ API RATE LIMITS & EFFICIENCY RULES

### **Brave Search API**
- **CRITICAL RATE LIMIT:** Maximum 1 request per second
- Always wait at least 1 second between consecutive web_search calls
- Batch research needs instead of rapid-fire searches

### **Browser Usage**
- **❌ NEVER use browser UI for automation** - extremely inefficient and wastes tokens
- ✅ Use direct APIs (gog, web_fetch, web_search) instead
- Browser is for visual verification only, not data extraction

---

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

### **🚨 EMAIL BODY FORMATTING — NO HARD LINE WRAPS (Added Feb 18, 2026)**
Never manually wrap lines within a paragraph. Hard line breaks (`\n`) are preserved literally in email clients, causing jagged right-edge whitespace gaps.

**WRONG** (creates broken layout):
```
Thank you for the follow-up and for sharing those ideas —
really thoughtful concepts, and I can see how the Guided
Listening format could work beautifully at one of our events.
```

**CORRECT** (flows naturally):
```
Thank you for the follow-up and for sharing those ideas — really thoughtful concepts, and I can see how the Guided Listening format could work beautifully at one of our events.
```

Rules:
- Each paragraph = **one continuous line** (no `\n` within a paragraph, ever)
- Separate paragraphs with `\n\n` only (blank line between)
- Use `--body-file` for long emails to control formatting precisely
- **Never word-wrap at 80 chars** — email clients handle wrapping automatically

---

### **Business Email Protocol**

### **🚨 MANDATORY: VERIFY DATES BEFORE SENDING 🚨**
**ALWAYS verify the day of week before mentioning ANY date in emails!**

Incorrect dates are extremely unprofessional and disrupt planning.

**Verification Commands:**
```bash
# Check specific date
date -j -f "%Y-%m-%d" "2026-03-07" "+%A %B %d, %Y"

# View monthly calendar
cal 3 2026  # March 2026

# Quick check
date -v+1d  # Tomorrow
date -v+7d  # Week from now
```

**Rule:** If you write "Friday, March 7" but don't verify it's actually Friday, STOP and verify first.

---

### **🚨 CRITICAL: SHELL ESCAPING FOR DOLLAR SIGNS 🚨**
**NEVER USE DOUBLE QUOTES WITH DOLLAR SIGNS IN EMAIL BODIES!**

Dollar signs (`$`) are shell variables. If you write `--body="The price is $1,400"`, the shell will interpret `$1` as a variable and strip it out, leaving `"The price is ,400"`.

**✅ CORRECT - Use single quotes for email bodies with prices:**
```bash
gog gmail send --to="vendor@example.com" --subject="Quote Follow-up" --body='Thank you for the $1,400 quote for DJ services.'
```

**❌ WRONG - Double quotes will break dollar signs:**
```bash
gog gmail send --to="vendor@example.com" --body="Thank you for the $1,400 quote"  # BROKEN!
# Result: "Thank you for the ,400 quote" (shell strips $1)
```

**Alternative: Escape dollar signs with backslash:**
```bash
gog gmail send --to="vendor@example.com" --body="Thank you for the \$1,400 quote"
```

**Best Practice: Use --body-file for complex emails:**
```bash
echo 'Thank you for the $1,400 quote for DJ services.' > /tmp/email.txt
gog gmail send --to="vendor@example.com" --subject="Quote" --body-file=/tmp/email.txt
```

**REMEMBER:** ANY email mentioning prices, costs, rates, or dollar amounts MUST use single quotes or escaped dollar signs!

---

```bash
# Send vendor outreach email
gog gmail send --to="vendor@example.com" --subject="Great Gatsby Festival Inquiry" --body='[email content with $prices]'

# Send with CC to team
gog gmail send --to="vendor@example.com" --cc="zed.truong@vennapp.co" --subject="Subject" --body='Content with $amounts'

# Send using template file (safest for complex emails)
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

### **🚨 CRITICAL: EMAIL THREADING RULES (Added Feb 11, 2026)**
**MANDATORY:** Always reply within existing email threads, NEVER create new threads.

**How to Reply in Thread:**
```bash
# Option 1: Reply to specific message (PREFERRED)
gog gmail send --reply-to-message-id="MESSAGE_ID" --body='Reply text'

# Option 2: Reply within thread
gog gmail send --thread-id="THREAD_ID" --body='Reply text'

# With reply-all (auto-populates recipients)
gog gmail send --reply-to-message-id="MESSAGE_ID" --reply-all --body='Reply text'
```

**When responding to vendor emails:**
1. Get the message ID from the vendor's email
2. Use `--reply-to-message-id=MESSAGE_ID` in your send command
3. This maintains threading and professional communication flow

**Example:**
```bash
# Vendor email received with ID: 19c4d4248fdf6b2a
# Reply in same thread:
gog gmail send --reply-to-message-id="19c4d4248fdf6b2a" \
  --subject="Re: Yacht Event Photography Inquiry" \
  --body='Thank you for following up...'
```

**❌ WRONG - Creates new thread:**
```bash
gog gmail send --to="vendor@example.com" --subject="Response" --body="..."
```

**✅ CORRECT - Replies in thread:**
```bash
gog gmail send --reply-to-message-id="19c4xxx" --reply-all --body="..."
```

### **Business Email Guidelines**
- ✅ **Always use gog** for vendor/business outreach
- ✅ **Professional signature** on all business emails
- ✅ **CC Zed** on important vendor responses
- ✅ **ALWAYS reply in thread** using --reply-to-message-id
- ❌ **Never mention budget** in initial outreach
- ❌ **No emojis** in business communications
- ❌ **NEVER create new threads** when replying to vendors

## Calendar Integration

### **Google Calendar via gog**
```bash
# Create event when Zed requests meetings
gog calendar events create --summary="Vendor Call" --start="2026-02-07T10:00:00" --attendees="vendor@example.com,zed.truong@vennapp.co"
```

## Environment-Specific Setup

### **Telegram Configuration**
- **Group Chat ID**: -5157705859 (Venn Team)
- **Usage**: Team notifications for urgent items, important updates
- **Mention Required**: Yes (group chat requires @mention)

### **Camera Names** 
- None currently configured

### **SSH Hosts**
- None currently configured  

### **Voice Preferences**
- Default: System voice for TTS
- Business calls: Professional tone

### **Vinny's Account Credentials**
**Luma & Partiful:**
- Email: vinny@vennapp.co
- Password: `HkK6m2lDTfFHuIbMccCf`
- Both accounts use same credentials

---

This is your operational cheat sheet for daily business tools.
