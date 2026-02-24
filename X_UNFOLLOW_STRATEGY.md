# X (Twitter) Unfollow Strategy - Daily Automation

**Goal:** Reduce following count to 10 without triggering bot detection

**Current Status:** Need to check following count (requires login)

---

## 🤖 ANTI-BOT-DETECTION STRATEGY

### **Daily Limits (Conservative)**
- **Max unfollows per day:** 5-10 (start with 5)
- **Timing:** Randomized between 9 AM - 9 PM PST
- **Delay between unfollows:** 2-5 minutes (random)
- **Days off:** Skip 1-2 days per week randomly

### **Human-Like Behavior**
- Mix unfollows with scrolling
- Occasionally view a profile before unfollowing
- Don't unfollow in alphabetical order (randomize)
- Vary time of day (morning/afternoon/evening)

### **Red Flags to Avoid**
- ❌ Unfollowing 50+ accounts in one session
- ❌ Consistent timing (same time every day)
- ❌ No other activity (scroll, like, view profiles)
- ❌ Perfect intervals (always 2 min apart)

---

## 📊 EXECUTION PLAN

### **Phase 1: Setup (Day 1)**
1. Log in to X via openclaw browser
2. Check current following count
3. Calculate days needed: `(current_following - 10) / 5 = days`
4. Example: 100 following → 90 to unfollow → 18 days at 5/day

### **Phase 2: Daily Execution**
**Script location:** `/workspace/scripts/x-unfollow-daily.py`

**Process:**
1. Open X in openclaw browser
2. Navigate to Following page
3. Scroll randomly (2-4 times)
4. Select 5 random accounts from visible list
5. Unfollow each with 2-5 min delay
6. Occasionally view profile before unfollowing (30% chance)
7. Log results to `/workspace/memory/x-unfollow-log.json`
8. Close browser

**Randomization:**
- Time: Pick random hour between 9 AM - 9 PM
- Count: Vary between 4-6 unfollows per session
- Order: Shuffle following list before selection
- Skip days: 15% chance to skip any given day

### **Phase 3: Monitoring**
Track in Mission Control:
- Current following count
- Unfollows per day
- Days to completion
- Any rate limiting or warnings

---

## 🔧 IMPLEMENTATION

### **Daily Heartbeat Integration**
Added to `HEARTBEAT.md`:
```markdown
### X Unfollow Task (Daily)
- **Frequency:** Once per day (randomized 9 AM - 9 PM PST)
- **Action:** Unfollow 4-6 random accounts
- **Status:** Check `/workspace/memory/x-unfollow-log.json`
- **Stop condition:** Following count ≤ 10
```

### **Mission Control Task**
```sql
INSERT INTO Task (title, description, status, priority, category, dueDate)
VALUES (
  'X Daily Unfollow Automation',
  'Safely reduce X following count to 10 (5 unfollows/day max)',
  'in_progress',
  'medium',
  'automation',
  NULL  -- Ongoing until complete
);
```

### **Log Format**
`/workspace/memory/x-unfollow-log.json`:
```json
{
  "start_date": "2026-02-24",
  "initial_following": 100,
  "target_following": 10,
  "sessions": [
    {
      "date": "2026-02-24",
      "time": "14:32 PST",
      "unfollowed_count": 5,
      "unfollowed_accounts": ["@user1", "@user2", ...],
      "following_after": 95,
      "notes": ""
    }
  ]
}
```

---

## ⚠️ SAFETY CHECKS

### **Before Each Session**
- [ ] Check if X is experiencing issues (don't run during outages)
- [ ] Verify following count > 10
- [ ] Check for rate limit warnings

### **During Session**
- [ ] If "unusual activity" warning appears → stop immediately
- [ ] If rate limited → pause for 24 hours
- [ ] If captcha appears → alert Zed

### **After Session**
- [ ] Log results
- [ ] Update Mission Control task notes
- [ ] If <15 following remaining → ask Zed which 10 to keep

---

## 🚀 NEXT STEPS

1. **Zed:** Log in to X via openclaw browser so cookies persist
   - Run: `openclaw gateway` if needed
   - Open: https://x.com in openclaw browser
   - Sign in
   - Close browser (cookies saved)

2. **Vinny:** Create Python automation script
3. **Vinny:** Add to HEARTBEAT.md
4. **Vinny:** Add to Mission Control database
5. **Vinny:** Run first session manually to test
6. **Vinny:** Enable daily automation

---

**Created:** 2026-02-24  
**Status:** Awaiting X login from Zed
