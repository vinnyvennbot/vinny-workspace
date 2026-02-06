# DELEGATION PROTOCOL - Parallel Task Management

## When to Delegate (sessions_spawn)

### **AUTO-DELEGATE (>15 min tasks)**
- Vendor research AND outreach execution across multiple categories
- Complex financial model creation  
- Competitive analysis with multiple data points
- Multi-vendor email campaigns with systematic sending
- Event post-mortem analysis with attendee feedback

### **KEEP INLINE (<5 min tasks)**
- Single vendor email responses
- Database status updates
- Quick pricing comparisons
- Calendar event creation

## Delegation Templates

### **Volume Vendor Outreach Sprint**
```javascript
sessions_spawn({
    task: `EXECUTE vendor outreach campaign: Contact 20+ entertainment vendors for [Event Theme] on [Date] for [X] people in SF.
           1. Research vendor contacts and create professional email templates
           2. SEND ACTUAL EMAILS using: gog gmail send --to="vendor@email.com" --subject="Event Inquiry" --body="[template content]"
           3. Track sent emails and responses systematically
           Creative options beyond mechanical bulls - match theme. Priority to existing relationships (check RELATIONSHIPS.md).
           Never mention budget in first outreach. Continue until 5+ responses received. Update RELATIONSHIPS.md immediately.`,
    agentId: "main",
    cleanup: "keep", 
    label: "vendor_outreach_[event_theme]",
    timeoutSeconds: 3600
})
```

### **Financial Model Creation**
```javascript  
sessions_spawn({
    task: `Create comprehensive financial model for western line dancing event.
           Budget: $70/person, 200 attendees. Include venue, entertainment, catering, marketing.
           Audit all formulas, ensure no circular references. Share with zed.truong@vennapp.co.`,
    agentId: "main",
    cleanup: "keep",
    label: "financial_model_western_event", 
    timeoutSeconds: 1200
})
```

### **Creative Vendor Brainstorming**
```javascript
sessions_spawn({
    task: `Brainstorm creative vendor options for [Event Theme]. Check memory/events/ for similar past events.
           Generate 5+ vendor categories beyond obvious choices. Match theme to experience.
           Research existing relationships first (RELATIONSHIPS.md). Present creative alternatives
           with theme alignment rationale.`,
    agentId: "main", 
    cleanup: "keep",
    label: "creative_vendor_[event_theme]",
    timeoutSeconds: 1800
})
```

### **Competitive Analysis**
```javascript
sessions_spawn({
    task: `Analyze 10 similar SF events in past 6 months. Pricing, venues, attendance, themes.
           Identify market gaps and competitive positioning for Venn Social.
           Create summary report with actionable insights.`,
    agentId: "main", 
    cleanup: "keep",
    label: "competitive_analysis_sf_events",
    timeoutSeconds: 2400
})
```

## Split-Role Delegation

### **Multi-Perspective Vendor Selection**
When selecting critical vendors (venues, major entertainment), spawn 3 agents:

**Engineer Agent:** Technical evaluation
```javascript
sessions_spawn({
    task: "Evaluate technical requirements for mechanical bull vendors: setup, power, insurance, safety protocols.",
    agentId: "main",
    label: "vendor_eval_technical"
})
```

**Business Agent:** Cost/ROI analysis  
```javascript
sessions_spawn({
    task: "Analyze pricing and ROI for mechanical bull vendors: cost per person, upsell opportunities, sponsorship integration.",
    agentId: "main", 
    label: "vendor_eval_business"
})
```

**Experience Agent:** Customer experience evaluation
```javascript
sessions_spawn({
    task: "Evaluate customer experience for mechanical bull vendors: entertainment value, crowd engagement, Instagram moments.",
    agentId: "main",
    label: "vendor_eval_experience"  
})
```

## Delegation Recovery Protocol

### **Session Tracking**
- Log all spawned sessions in `memory/delegation_log.json`
- Include task, timestamp, expected completion, session_id
- Monitor for timeouts or failures

### **Rollback Strategy**
If sub-agent fails:
1. Check `sessions_history` for partial progress
2. Extract any useful research/data 
3. Continue inline or re-spawn with adjusted scope
4. Document failure pattern for future optimization

### **Context Handoff**
Sub-agents should:
- Update shared databases immediately
- CC main session on critical findings
- Create handoff summaries for complex research
- Store work products in accessible workspace files

## Email Execution Protocol (CRITICAL)

### **Sub-Agent Email Authority**
- **✅ CAN SEND**: Initial vendor inquiries using professional templates
- **✅ CAN SEND**: Follow-up emails per 24-hour rule
- **✅ MUST USE**: `gog gmail send` for ALL business email outreach
- **❌ CANNOT**: Mention budget, negotiate contracts, make commitments

### **Email Execution Steps**
1. **Research phase**: Gather vendor contacts and specialties
2. **Template creation**: Professional email content (no budget mentions)
3. **EXECUTION PHASE**: Actually send emails using gog CLI:
   ```bash
   gog gmail send --to="vendor@example.com" --subject="Great Gatsby Festival Inquiry" --body="[template content]"
   ```
4. **Tracking phase**: Monitor responses, update RELATIONSHIPS.md
5. **Reporting**: Confirm "Sent X emails, received Y responses"

### **Execution vs Preparation**
- **WRONG**: Create templates and contact lists only
- **RIGHT**: Create templates AND send actual emails AND track responses
- **Success metric**: Number of actual emails sent and responses received

## Parallel Execution Examples

### **Event Planning (Week 1)**
Spawn simultaneously:
- Agent A: Venue research + quotes
- Agent B: Entertainment vendor research  
- Agent C: Catering options analysis
- Agent D: Sponsor outreach campaign
- Main session: Coordinate and integrate results

### **Crisis Management (Vendor Cancellation)**
Spawn immediately:
- Agent A: Emergency replacement vendors
- Agent B: Contract review and rebooking
- Agent C: Attendee communication plan
- Main session: Team coordination and decision making

---

*Delegation reduces main session cognitive load and accelerates complex workflows. Updated 2026-02-06.*