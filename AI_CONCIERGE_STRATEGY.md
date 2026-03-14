# AI Social Concierge - Build Strategy

**Product:** Venn AI Social Concierge (Vivi)  
**Goal:** Solve loneliness through AI-powered event discovery + social matching  
**Quality Bar:** Uber/Lyft reliability + Partiful polish + Robinhood performance  
**Timeline:** 3 weeks to testable MVP

---

## Core Concept

**The Problem:** People don't know what to do, where to go, or who to meet in their city.

**The Solution:** Vivi - an AI companion that learns your preferences and recommends experiences, events, and people in real-time.

**Business Model:** Hybrid
- Venn-hosted events (revenue, brand control)
- AI recommendations for ALL SF events (engagement, scale, anti-loneliness)

---

## Product Pillars

### 1. Frictionless Onboarding
- One conversational chat (not 10-screen wizard)
- Ask: interests, vibe, what brings you joy
- Get enough signal to start recommending immediately

### 2. Behavior Learning Engine
- Tracks what users actually do vs what they say
- Adapts recommendations based on real behavior over time
- Gets smarter every session

### 3. Smart Matching
- **Events:** Tailored to your taste graph
- **People:** "Someone like you is going tonight"
- **Timing:** "Right now" recommendations (not "next week")

### 4. Anti-Loneliness Focus
- Companion-like presence (not transactional)
- Proactive outreach ("I found something for you tonight")
- Reduces friction to connecting IRL

---

## Technical Architecture

### Backend Services

**Event Aggregation Service**
- Sources: Eventbrite, Luma, Instagram, TikTok, Reddit
- Database: PostgreSQL with full-text search
- Refresh: Continuous scraping (cron jobs)
- Deduplication: Fuzzy matching on name + date + location

**Recommendation Engine**
- User preference model (onboarding + behavior)
- Event scoring algorithm (taste graph + social signals)
- Real-time filtering (time, location, capacity)
- Diversity logic (don't recommend same type 3x)

**Vivi AI Chat Service**
- LLM: Claude 3.5 Sonnet (conversational, empathetic)
- Context: User preferences + past behavior + friend activity
- Proactive: Push notifications for perfect-fit events
- Personality: Warm, curious, encouraging (friend, not search engine)

**Social Graph Service**
- Friend connections
- "Someone like you" matching algorithm
- Activity feed (who's going where)

### Frontend (VennSwift - iOS Native)

**Design System**
- Source: vennconsumer repo (vennsocial.co)
- Colors, fonts, spacing, components
- Animations: Smooth, Partiful-level polish

**Core Screens**
1. **Vivi Chat** - Onboarding + ongoing recommendations
2. **Discovery Feed** - All events (Venn + aggregated)
3. **Event Detail** - Rich media, social proof, RSVP
4. **Profile** - Preferences, past events, friends
5. **Social** - Friend activity, matches

**Key Features**
- Offline support (cached recommendations)
- Haptic feedback (micro-interactions)
- Accessibility (VoiceOver, Dynamic Type)
- Performance: <100ms UI updates, <500ms API responses

---

## Development Phases

### Phase 1: Event Aggregation (Week 1)
**Goal:** 1,000+ SF events in database, refreshing daily

**Tasks:**
- [ ] PostgreSQL database schema
- [ ] Eventbrite scraper (API)
- [ ] Luma scraper (web scraping)
- [ ] Instagram location tag scraper
- [ ] TikTok hashtag scraper
- [ ] Reddit post scraper
- [ ] Deduplication logic
- [ ] Cron jobs for continuous refresh

**Tests:**
- [ ] Each scraper returns valid events
- [ ] Deduplication catches duplicates
- [ ] Database handles 10K+ events
- [ ] Scraper error handling (retries, logging)

**Deliverable:** API endpoint `/events?city=sf&date=today` returns 50+ events

---

### Phase 2: Recommendation Engine (Week 2)
**Goal:** Personalized event recommendations based on user preferences

**Tasks:**
- [ ] User preference model (onboarding data → taste graph)
- [ ] Behavior tracking (clicks, skips, RSVPs, check-ins)
- [ ] Event scoring algorithm (preference match + social signals)
- [ ] "Right now" filtering (time, location, availability)
- [ ] Diversity logic (prevent monotony)
- [ ] Social signals ("someone like you is going")

**Tests:**
- [ ] User with jazz preference gets jazz events ranked higher
- [ ] "Right now" returns events starting in next 4 hours
- [ ] Diversity prevents 3 consecutive same-category events
- [ ] Social signal boosts events with friend attendance

**Deliverable:** API endpoint `/recommendations?user_id=123` returns personalized list

---

### Phase 3: VennSwift App (Week 3)
**Goal:** Testable iOS app with Vivi chat + discovery feed

**Tasks:**
- [ ] Vivi chat interface (conversational onboarding)
- [ ] Claude API integration (streaming responses)
- [ ] Discovery feed (event cards with images)
- [ ] Event detail screen (rich media, RSVP)
- [ ] Profile screen (preferences, past events)
- [ ] Design system implementation (vennconsumer assets)
- [ ] Animations (smooth transitions, loading states)
- [ ] Offline support (cache last 50 recommendations)

**Tests:**
- [ ] Onboarding captures enough signal in <2 min
- [ ] Event cards render in <100ms
- [ ] RSVP action completes in <500ms
- [ ] Offline mode displays cached events
- [ ] VoiceOver reads all UI elements correctly

**Deliverable:** TestFlight build ready for internal testing

---

### Phase 4: Social Layer (Week 4+)
**Goal:** People matching + friend activity feed

**Tasks:**
- [ ] Friend connection system
- [ ] "Someone like you" matching algorithm
- [ ] Activity feed (who's going where)
- [ ] Push notifications (friend attending event you'd like)

---

## Quality Standards

### Code
- **TDD:** Write tests first, always
- **Type Safety:** Swift (strict), TypeScript (strict mode)
- **Error Handling:** Retries, fallbacks, graceful degradation
- **Performance:** Monitor response times, render times
- **Documentation:** Clear README, API docs, inline comments

### UI/UX
- **No Jank:** 60fps animations, instant feedback
- **Micro-interactions:** Loading states, haptics, transitions
- **Consistency:** Design system enforced across all screens
- **Accessibility:** VoiceOver, Dynamic Type, high contrast

### Testing
- **Unit Tests:** All business logic (recommendation engine, scrapers)
- **Integration Tests:** API endpoints, database queries
- **E2E Tests:** Critical user flows (onboarding, RSVP, recommendations)
- **Performance Tests:** API response times, UI render times

---

## Metrics (North Star)

**DO NOT OPTIMIZE FOR:**
- ❌ Time in app
- ❌ Session length
- ❌ Screen views

**OPTIMIZE FOR:**
- ✅ Outings per month (real-world impact)
- ✅ New connections made (anti-loneliness)
- ✅ Recommendation acceptance rate (Vivi's taste accuracy)
- ✅ Retention (weekly active users)

---

## Next Steps

**Tonight (March 13):**
1. Set up backend repo (Node.js + TypeScript + PostgreSQL)
2. Build Eventbrite scraper with tests
3. Create database schema for aggregated events
4. First 50 SF events in database

**This Week:**
- Complete Phase 1 (event aggregation)
- 1,000+ SF events refreshing daily

**Week 2:**
- Build recommendation engine
- Personalized API endpoint working

**Week 3:**
- VennSwift app with Vivi chat
- TestFlight build ready

---

**Quality Bar:** Production-grade from day 1. No prototypes. No shortcuts.
