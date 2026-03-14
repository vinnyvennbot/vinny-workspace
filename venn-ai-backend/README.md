# Venn AI Backend

**AI Social Concierge** - Event aggregation, personalized recommendations, and Vivi chat service.

---

## Quick Start

```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Add your EVENTBRITE_API_KEY to .env

# Run tests (TDD)
npm test

# Start dev server
npm run dev

# Build for production
npm run build
npm start
```

---

## What's Built (March 13, 6:44 PM PST)

### ✅ Project Foundation
- TypeScript + strict mode
- Jest + TDD setup (80% coverage threshold)
- Express server on port 4000
- Project structure (scrapers, models, services, routes, utils, tests)

### ✅ Vivi AI Service (Claude Sonnet 4.6)
- **ViviService class** - Complete conversational AI
- **System prompt** - Vivi's personality, knowledge, behavior
- **Conversation history** - Context-aware responses
- **API endpoint** - `POST /api/vivi/chat`
- **Tests** - Full test suite (integration + personality)

**Vivi's Personality:**
- Warm, empathetic, genuinely curious
- Friend-like companion (not transactional)
- Proactive + encouraging (anti-loneliness)
- Knows SF neighborhoods, vibes, culture

### ✅ Database Layer (PostgreSQL)
- **5 tables** - aggregated_events, user_event_interactions, user_preferences, vivi_chat_history, event_duplicates
- **EventRepository** - CRUD operations with transactions
- **Geospatial indexing** - PostGIS for location queries
- **Auto-migrations** - Schema deploys on server startup
- **Performance monitoring** - Slow query detection

### ✅ Event Model
- Type-safe Event interface
- Supports multiple sources (eventbrite, luma, instagram, tiktok, reddit, venn)
- Rich metadata (location, images, tags, price, capacity, attendees)
- Scraper interface for consistency

### ✅ Eventbrite Scraper
- Full TDD implementation (tests written first)
- API integration with Eventbrite v3
- Location-based search
- Date range filtering
- Category filtering
- Proper error handling
- Type-safe parsing

### ✅ API Endpoints
- `GET /health` - Server health check + database status
- `POST /api/vivi/chat` - **Vivi AI conversational chat**
  - Request: `{ message, conversationHistory }`
  - Response: `{ response, timestamp }`
- `GET /api/events/eventbrite` - Test Eventbrite scraper
  - Query params: `location`, `limit`
- `GET /api/events` - Query aggregated events
  - Query params: `location`, `source`, `limit`
- `POST /api/events/scrape` - Scrape Eventbrite + store in DB

---

## Project Structure

```
venn-ai-backend/
├── src/
│   ├── scrapers/          # Event scrapers
│   │   ├── eventbrite.ts
│   │   └── eventbrite.test.ts
│   ├── models/            # Data models
│   │   └── Event.ts
│   ├── services/          # Business logic (coming soon)
│   ├── routes/            # API routes (coming soon)
│   ├── utils/             # Utilities (coming soon)
│   └── index.ts           # Express server
├── dist/                  # Compiled output
├── package.json
├── tsconfig.json
├── jest.config.js
└── .env
```

---

## Testing

```bash
# Run all tests
npm test

# Watch mode (TDD)
npm run test:watch

# Coverage report
npm run test:coverage
```

**Test Coverage Target:** 80% (branches, functions, lines, statements)

---

## Next Steps

### Phase 1: Event Aggregation (This Week)
- [ ] Luma scraper (web scraping, no API)
- [ ] Instagram location scraper
- [ ] TikTok hashtag scraper
- [ ] Reddit post scraper
- [ ] PostgreSQL database setup
- [ ] Deduplication logic
- [ ] Cron jobs for continuous refresh

### Phase 2: Recommendation Engine (Week 2)
- [ ] User preference model
- [ ] Event scoring algorithm
- [ ] Behavior tracking
- [ ] Social signals
- [ ] "Right now" filtering

### Phase 3: VennSwift Integration (Week 3)
- [ ] Vivi chat service (Claude API)
- [ ] iOS app integration
- [ ] Push notifications
- [ ] Offline support

---

## Quality Standards

- ✅ TDD: Tests written first, always
- ✅ Type Safety: TypeScript strict mode
- ✅ Performance: <500ms API responses
- ✅ Error Handling: Graceful degradation, retries
- ✅ Production-Ready: Uber/Lyft reliability from day 1

---

## Environment Variables

```bash
# Required
EVENTBRITE_API_KEY=your_api_key_here

# Optional
DATABASE_URL=postgresql://localhost:5432/venn_ai
PORT=4000
NODE_ENV=development
```

---

## Tech Stack

- **Runtime:** Node.js + TypeScript
- **Server:** Express
- **Testing:** Jest + Supertest (TDD)
- **Database:** PostgreSQL (coming soon)
- **Scraping:** Axios + Cheerio
- **AI:** Claude 3.5 Sonnet (coming soon)

---

**Quality Bar:** Production-grade from day 1. No prototypes. No shortcuts.
