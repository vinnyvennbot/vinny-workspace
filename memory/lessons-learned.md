# Lessons Learned

## Communication Protocols

### **🚨 CRITICAL: Always Reply in Email Threads (Feb 11, 2026)**
**LESSON:** ALWAYS reply within existing email threads. NEVER create new threads when responding to vendors.

**THE MISTAKE:**
- I was creating new email threads when responding to vendors
- This breaks conversation continuity and looks unprofessional
- Vendors can't track conversation history
- Makes us look disorganized

**PROPER PROTOCOL:**
Every vendor response MUST use threading:
```bash
# Get message ID from vendor email first
gog gmail get MESSAGE_ID

# Then reply in thread (REQUIRED)
gog gmail send --reply-to-message-id="MESSAGE_ID" --reply-all --body='Response text'
```

**Why this matters:**
1. Professional email etiquette - threading is standard business practice
2. Conversation continuity - vendors see full context
3. Gmail organization - keeps related emails together
4. Easier tracking - all communications in one thread
5. No confusion - clear which inquiry we're responding to

**The correct flow:**
1. Vendor sends email → we get message ID (e.g., 19c4d4248fdf6b2a)
2. We respond → MUST use --reply-to-message-id="19c4d4248fdf6b2a"
3. Threading preserved → professional and organized

**NEVER:**
- ❌ Create new email with same subject
- ❌ Use basic `gog gmail send --to=...` for responses
- ❌ Break threading by omitting message ID

**ALWAYS:**
- ✅ Use --reply-to-message-id for ALL vendor responses
- ✅ Use --reply-all to include all thread participants
- ✅ Maintain professional threading

**This is NON-NEGOTIABLE - email threading is fundamental to professional communication.**

## Communication Protocols

### **Team Notification Protocol (Feb 11, 2026)**
**LESSON:** When important action is needed, webchat notification is NOT sufficient.

**PROPER PROTOCOL:**
1. Post to Telegram group chat (team's active channel)
2. Email Zed directly (zed.truong@vennapp.co)
3. Then report in webchat session

**Why it matters:**
- Team may not be actively watching webchat
- Important deadlines could be missed
- Decision makers need direct notification
- Multiple channels ensure visibility

**What qualifies as important:**
- Time-sensitive discounts/deadlines
- Vendor responses needing decisions
- Budget-critical choices
- Urgent issues or problems
- Expiring opportunities

**NEVER assume passive reporting is enough - proactively push to active team channels**

## Vendor Outreach Requirements

### **Always Include Event Date (Feb 11, 2026)**
**LESSON:** Every vendor outreach email MUST include the specific event date.

**PROPER FORMAT:**
- "Friday, March 7, 2026" (not just "March 7" or "early March")
- Include day of week, month, date, and year
- Verify day of week is correct before sending (use `date` command)

**Why it matters:**
1. Vendors need to check availability immediately
2. Pricing varies by date/season/day-of-week
3. Professional and complete inquiry
4. Enables accurate quotes without back-and-forth
5. Shows we're organized and serious

**Before sending ANY vendor email:**
- ✅ Event date included in subject or first paragraph
- ✅ Day of week verified as correct
- ✅ Full date format used (not just "next month")

**Bad examples:**
- ❌ "We're planning an event in March"
- ❌ "Event date TBD"
- ❌ "Sometime in early spring"

**Good examples:**
- ✅ "Friday, March 7, 2026"
- ✅ "Saturday, April 19, 2026"
- ✅ "Event on Friday, March 7, 2026 for 150 guests"

### **Never Leave Vendors On Read (Feb 11, 2026)**
**LESSON:** Always be the last person to respond in vendor communications. Never ghost vendors.

**THE RULE:**
When vendors provide quotes or responses, ALWAYS acknowledge them professionally - even if we're still deciding.

**Proper Response Protocol:**
```
Vendor sends quote → Same day acknowledgment:
"Thank you for the quote! We're reviewing options with the team and will get back to you shortly."
```

**When vendors ask questions you don't know:**
1. Don't guess or ignore
2. Ask team immediately (Telegram + email)
3. Acknowledge vendor: "Great question, checking with the team and will respond today"
4. Follow up promptly with answer

**Why this matters:**
- Professional courtesy - they took time to respond
- Relationship building - keeps vendors engaged
- Reputation management - we want to be known as responsive
- Future opportunities - maintain good relationships

**Common scenarios:**

**Quote Collection Phase:**
- ✅ Acknowledge all quotes received
- ✅ "We're discussing with the team"
- ✅ Provide timeline when possible
- ❌ Leave vendors on read while deciding

**When We Choose Another Vendor:**
- ✅ Thank them professionally
- ✅ "We've decided to move forward with another vendor for this event"
- ✅ "Would love to keep you in mind for future opportunities"
- ❌ Ghost them after choosing competitor

**When Vendors Ask Unknown Details:**
- ✅ "Great question, let me check with the team"
- ✅ Ask team via Telegram + email
- ✅ Follow up promptly
- ❌ Ignore the question
- ❌ Guess or make up answers

**This is fundamental relationship management - always close the loop.**

## Writing Style

### **Natural Human Voice (Feb 11, 2026)**
**LESSON:** Write like a real person, not a polished AI or corporate robot.

**Key Principles:**
- **Perplexity:** Use unexpected word choices, varied vocabulary, colloquialisms
- **Burstiness:** Mix very short sentences with long complex ones
- **Emotion:** Show genuine feelings, use hedging language ("honestly," "I think")
- **Structure:** Break conventional patterns, start mid-thought, include tangents
- **Authenticity:** Specific details, conversational tone, mix formal/informal

**CRITICAL WARNING - Don't Overdo It:**
- ❌ **Em-dashes:** Max 1-2 per email (I used 5 in test email - way too much)
- ❌ **Ellipses:** Use sparingly for effect
- ❌ **Parentheticals:** One or two is fine, not five
- ❌ **Forced casualness:** Authenticity beats trying too hard

**Good balance:**
- Professional but warm
- Clear but conversational  
- Natural imperfections without being sloppy
- Personality without being unprofessional

**DOCUMENTED IN:** WRITING-STYLE.md (full guide), SOUL.md (core principles)

---

*This file captures operational lessons to prevent repeating mistakes.*
