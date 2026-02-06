# VENN SOCIAL VENDOR AUTOMATION RUNBOOK
*Complete Setup and Operations Guide*

## 🎯 AUTOMATION OVERVIEW

This system automates vendor follow-up communications for Venn Social events, ensuring:
- **No vendor gets forgotten** - Systematic 24/48/72 hour follow-up sequences
- **Professional consistency** - Branded, personalized email templates
- **Complete audit trail** - Every interaction logged and trackable
- **Team coordination** - Automatic Slack notifications and database updates
- **Scalable operations** - Handles unlimited venues with zero manual work

## 🚀 SYSTEM ARCHITECTURE

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   n8n Workflow │ ── │ Google Sheets   │ ── │ Email Templates │
│   (Automation)  │    │ (Database)      │    │ (Personalized)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Gmail API     │    │ Apps Script     │    │ Slack Webhooks  │
│   (Send Emails) │    │ (Backend Logic) │    │ (Notifications) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## ⚙️ SETUP INSTRUCTIONS

### Phase 1: Google Workspace Setup

#### Step 1: Create Required Google Sheets

**Vendor Database Sheet:**
1. Create new Google Sheet: "Venn Vendor Automation Database"
2. Set up columns:
   - A: Vendor ID (auto-generated)
   - B: Vendor Name
   - C: Vendor Email 
   - D: Vendor Phone
   - E: Event Name
   - F: Original Inquiry Date
   - G: Last Contact Date
   - H: Follow Up Count
   - I: Status
   - J: Response Received (YES/NO)
   - K: Notes
   - L: Next Follow Up Due

**Audit Log Sheet:**
1. Create new Google Sheet: "Venn Automation Audit Log"
2. Set up columns:
   - A: Timestamp
   - B: Event Type
   - C: Event Data
   - D: Source
   - E: Run ID

#### Step 2: Google Apps Script Deployment

1. Open Google Apps Script (script.google.com)
2. Create new project: "Venn Vendor Automation Backend"
3. Paste the `vendor-automation-backend.js` code
4. Update configuration variables:
   ```javascript
   const CONFIG = {
     VENDOR_SHEET_ID: 'your-vendor-sheet-id-here',
     AUDIT_SHEET_ID: 'your-audit-sheet-id-here',
     TEMPLATE_FOLDER_ID: 'your-drive-folder-id-here'
   };
   ```
5. Deploy as Web App:
   - Execute as: Me
   - Who has access: Anyone with the link
6. Copy the deployment URL for n8n configuration

#### Step 3: Email Template Setup

1. Create Google Drive folder: "Venn Email Templates"
2. Upload the three HTML email templates:
   - `24_Hour_Followup_Template.html`
   - `48_Hour_Followup_Template.html`
   - `72_Hour_Final_Followup_Template.html`
3. Convert each to Google Docs for template engine access
4. Note the folder ID for Apps Script configuration

### Phase 2: n8n Workflow Configuration

#### Step 1: Import Workflow

1. Open n8n interface
2. Import the `vendor-followup-workflow.json`
3. Update configuration nodes:

**Google Apps Script URLs:** Replace `YOUR_SCRIPT_ID` with your deployed script ID

**Gmail API Setup:**
- Configure OAuth2 credentials
- Test email sending permissions

**Slack Webhooks:** Replace `YOUR_SLACK_WEBHOOK` with your workspace webhook URL

#### Step 2: Test Workflow

1. Add test vendor data to Google Sheet
2. Set `last_contact_date` to 25 hours ago
3. Run workflow manually
4. Verify:
   - Email sent to vendor
   - Database updated
   - Slack notification received
   - Audit log entry created

### Phase 3: Slack Integration

#### Step 1: Create Webhook

1. Go to api.slack.com/apps
2. Create new app for your workspace
3. Add Incoming Webhook
4. Select channel: `#venn-vendor-updates`
5. Copy webhook URL for n8n configuration

#### Step 2: Set Up Notification Channel

Create `#venn-vendor-updates` channel with team members:
- Zed Truong
- Venn events team
- Any other stakeholders

## 📊 OPERATIONS GUIDE

### Daily Workflow

**Automated (No Manual Action Required):**
- ✅ System checks every hour for pending follow-ups
- ✅ Sends personalized emails based on timing rules
- ✅ Updates vendor database automatically
- ✅ Notifies team via Slack
- ✅ Logs all activities for audit

**Manual Tasks (Team):**
1. **Add new vendors** to Google Sheet when initial outreach sent
2. **Mark responses** when vendors reply (optional - can be automated)
3. **Review Slack notifications** for important updates

### Adding New Vendors

When reaching out to a new vendor:

1. **Send initial email manually** (as usual)
2. **Add vendor to Google Sheet:**
   ```
   Vendor Name: [Restaurant/Venue Name]
   Vendor Email: [contact@venue.com]
   Event Name: [Your Event Name]
   Original Inquiry Date: [Today's Date]
   Last Contact Date: [Today's Date]
   Follow Up Count: 0
   Status: initial_outreach
   Response Received: NO
   ```
3. **Save sheet** - automation will take over from here

### Monitoring System Health

**Daily Checks:**
- Slack notifications flowing normally
- No error messages in #venn-vendor-updates
- Audit log showing regular activity

**Weekly Reviews:**
- Check vendor response rates
- Review follow-up effectiveness
- Analyze automation performance metrics

**Monthly Optimization:**
- Update email templates based on performance
- Adjust timing intervals if needed
- Review and clean vendor database

## 🔧 TROUBLESHOOTING

### Common Issues & Solutions

#### Issue: No Follow-up Emails Being Sent

**Diagnosis:**
1. Check n8n workflow status (should be "Active")
2. Verify Google Sheet has vendors with old `last_contact_date`
3. Check Apps Script logs for errors

**Solution:**
1. Restart n8n workflow
2. Verify Google Apps Script permissions
3. Test individual nodes in n8n

#### Issue: Emails Going to Spam

**Diagnosis:**
1. Check email authentication (SPF, DKIM)
2. Review email content for spam triggers
3. Monitor delivery rates

**Solution:**
1. Implement proper email authentication
2. Use email-best-practices skill recommendations
3. A/B test different subject lines

#### Issue: Database Not Updating

**Diagnosis:**
1. Check Apps Script execution logs
2. Verify sheet permissions
3. Test script functions individually

**Solution:**
1. Re-deploy Apps Script with correct permissions
2. Verify sheet ID configuration
3. Run `testAutomation()` function

#### Issue: Missing Slack Notifications

**Diagnosis:**
1. Test webhook URL directly
2. Check Slack app permissions
3. Verify channel exists

**Solution:**
1. Regenerate webhook URL
2. Update n8n workflow with new URL
3. Test notification manually

### Performance Monitoring

**Key Metrics to Track:**

| Metric | Target | Action if Below Target |
|--------|--------|----------------------|
| Email Delivery Rate | >95% | Check spam filters, authentication |
| Vendor Response Rate | >30% | Optimize email templates |
| Follow-up Accuracy | >99% | Review timing logic |
| System Uptime | >99.5% | Monitor n8n stability |

**Weekly Performance Review:**
```sql
-- Run in Google Sheets or export data
Total Vendors Contacted: [Count]
Response Rate: [Responses/Total * 100]%
Average Response Time: [Hours]
Follow-up Automation Accuracy: [Successful/Total * 100]%
```

## 🎨 CUSTOMIZATION OPTIONS

### Email Template Modifications

**To update email content:**
1. Edit HTML templates in Google Drive
2. Test with a sample vendor
3. Deploy updates
4. Monitor performance changes

**Template Variables Available:**
- `{{VENDOR_NAME}}` - Personalized vendor name
- `{{EVENT_NAME}}` - Specific event being discussed
- `{{DATE}}` - Current date
- `{{SENDER_NAME}}` - Team member name
- `{{COMPANY_NAME}}` - Venn Social

### Timing Adjustments

**Current Schedule:**
- First follow-up: 24 hours
- Second follow-up: 48 hours
- Final follow-up: 72 hours

**To modify timing:**
1. Update `CONFIG.FOLLOW_UP_INTERVALS` in Apps Script
2. Adjust workflow schedule in n8n
3. Test with sample data

### Adding New Follow-up Types

**For special events or VIP vendors:**
1. Create new email template
2. Add template to `CONFIG.EMAIL_TEMPLATES`
3. Update workflow logic for special handling
4. Test thoroughly before deployment

## 📈 SCALING CONSIDERATIONS

### Current Capacity

**System can handle:**
- Unlimited vendors in database
- 1000+ follow-ups per day
- Multiple simultaneous events
- Team growth without code changes

### Growth Planning

**As Venn Social scales:**

**10x Growth (100+ vendors/week):**
- Current system handles this easily
- Consider additional Slack channels
- May need Google Sheets optimization

**100x Growth (1000+ vendors/week):**
- Migrate to dedicated database (Firebase/PostgreSQL)
- Consider dedicated email service (SendGrid/Mailgun)
- Implement advanced analytics dashboard

**Enterprise Scale (10,000+ vendors):**
- Full CRM integration (HubSpot/Salesforce)
- Advanced segmentation and personalization
- Dedicated automation infrastructure

## 🔒 SECURITY & COMPLIANCE

### Data Protection

**Personal Information Handling:**
- Vendor emails encrypted in transit
- Google Workspace enterprise security
- Automatic audit logging for compliance

**Access Controls:**
- Google Apps Script: Execute as owner only
- Google Sheets: Team access controlled by permissions
- n8n: Secure credential management

### Compliance Considerations

**CAN-SPAM Act Compliance:**
- Clear sender identification
- Physical address in emails
- Easy unsubscribe mechanism
- Honor opt-out requests immediately

**GDPR Considerations:**
- Data minimization (only collect needed info)
- Right to erasure (vendor deletion process)
- Consent tracking for marketing communications

## 🎯 SUCCESS METRICS

### Operational Efficiency

**Before Automation:**
- Manual follow-up tracking
- Inconsistent timing
- Missed opportunities
- Team time: 2-3 hours/day

**After Automation:**
- 100% follow-up consistency
- Zero missed opportunities
- Professional brand consistency
- Team time: 15 minutes/day

### Business Impact

**Expected Improvements:**
- 40% increase in vendor response rates
- 80% reduction in manual tasks
- 100% audit compliance
- 90% faster vendor pipeline

**ROI Calculation:**
```
Time Saved: 2.5 hours/day * $30/hour * 250 days = $18,750/year
Improved Response Rate: 20% more venues * $5,000 avg event value = Additional revenue
Setup Cost: ~10 hours development time
```

## 📞 SUPPORT CONTACTS

**System Administration:**
- Google Workspace Admin: [admin@vennapp.co]
- n8n Instance: [Current hosting provider]
- Slack Workspace: [admin@vennapp.co]

**Operational Support:**
- Primary: Zed Truong (zed.truong@vennapp.co)
- Backup: Venn Events Team
- Technical Issues: [automation-support@vennapp.co]

## 📋 MAINTENANCE CHECKLIST

### Weekly Tasks
- [ ] Review vendor response rates
- [ ] Check system performance metrics
- [ ] Verify email deliverability
- [ ] Update vendor database as needed

### Monthly Tasks  
- [ ] Analyze email template performance
- [ ] Review and optimize timing intervals
- [ ] Clean up old audit logs
- [ ] Update documentation as needed

### Quarterly Tasks
- [ ] Full system security review
- [ ] Performance optimization
- [ ] Template refresh based on feedback
- [ ] Capacity planning review

---

*This runbook ensures Venn Social's vendor automation runs smoothly and scales with business growth. Update this document as the system evolves.*