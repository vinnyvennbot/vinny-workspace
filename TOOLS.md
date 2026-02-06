# TOOLS.md - Local Tool Configuration

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
