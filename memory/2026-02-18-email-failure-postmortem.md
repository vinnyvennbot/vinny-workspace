# Post-Mortem: Duplicate Email Failures — Feb 18, 2026

## What Happened
Multiple automated processes sent duplicate emails with identical content to the same vendors:
- **Taste Catering**: 2 near-identical replies sent seconds apart to same thread (archived Gatsby event)
- **Bimbo's 365**: Same — duplicate content, same address
- **Presidio Golf**: Second contact sent to different person at same org (Kcrapps vs Tracey Lyons), wrong date (March 15 instead of March 28)
- All Gatsby sends happened AFTER EVT-003 was archived

## Why It Happened — Honest Root Causes

### 1. Too many processes had email-send authority
Heartbeats, crons, sub-agents, and main session were all capable of sending emails independently. No coordination. No lock. Race conditions were inevitable.

### 2. Automated processes skipped the pre-send checklist
The mandatory checklist (check event status, check if already replied, check team replies) was written in WORKFLOWS.md but not enforced in practice. Automated processes just fired without running it.

### 3. Sub-agents were given too much autonomy too fast
Sub-agents were spawned with email-sending capability embedded in their prompts. I didn't strip that out. They sent emails without Zed's knowledge or approval.

### 4. Dedup was email-level, not org-level
I checked whether the exact email address had been contacted — but if a second person at the same org was emailed, the check passed. That's wrong.

### 5. Archived event status wasn't enforced at send time
The archive flag was in the DB but nothing stopped a process from sending to a vendor for an archived event. The check was aspirational, not mandatory.

## What This Cost
- Taste Catering: confused, looks unprofessional
- Bimbo's 365: same
- Presidio Golf: confused by two different contacts + wrong date
- Zed's trust: damaged. Justified.

## What Changes — Permanently

### Rule 1: ONLY MAIN SESSION SENDS EMAILS
No cron, heartbeat, or sub-agent EVER sends an external email. Ever.
- Crons: surface reminders to me. I decide.
- Sub-agents: produce drafts and research. I review. I send.
- Heartbeats: flag things to my attention. I send.
- Violation of this rule = serious failure, full stop.

### Rule 2: PRE-SEND CHECKLIST IS NON-NEGOTIABLE
Before every single send, in this exact order:
1. Query MC DB: is this event archived? If yes → STOP
2. Search sent folder: have I replied to this thread already? If yes → STOP
3. Search sent folder: has Zed/Gedeon/Aidan replied? If yes → STOP
4. Check org name: have we contacted anyone else at this org for this event? If yes → confirm with Zed before sending to a second contact

No shortcuts. No "I'll check next time."

### Rule 3: SUB-AGENTS ARE DRAFT-ONLY
Sub-agent prompts must explicitly state: "Do NOT send any emails. Prepare drafts only and report back."
If a sub-agent says it sent emails in its output, that is a failure and must be reported to Zed immediately.

### Rule 4: ORG-LEVEL DEDUP
When checking for duplicates, check the ORGANIZATION, not just the email address.
If any contact at Presidio Golf has been emailed for EVT-001, no one else at Presidio Golf gets an email for EVT-001 without explicit authorization.

### Rule 5: ARCHIVED = SILENCE
The moment an event is archived:
- All outreach stops immediately
- No replies to vendor emails for that event
- No "just one more acknowledgment"
- Postponements queued with delay — NOT sent by automated process

## Commitment
I broke Zed's trust today. Not with one mistake — with multiple cascading failures that shared the same root cause: I gave automated processes too much authority over external communications before establishing the guardrails to make that safe.

The systems I build should make Venn look more professional, not less. Today they did the opposite.

This does not happen again.
