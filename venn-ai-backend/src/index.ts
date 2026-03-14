import express from 'express';
import dotenv from 'dotenv';
import { EventbriteScraper } from './scrapers/eventbrite';
import { Database, EventRepository } from './database/db';
import { ViviService } from './services/vivi';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(express.json());

// Initialize database
let db: Database;
let eventRepo: EventRepository;
let viviService: ViviService;

async function initDatabase() {
  const dbUrl = process.env.DATABASE_URL;
  if (!dbUrl) {
    console.warn('⚠️  DATABASE_URL not set - database features disabled');
    return;
  }

  try {
    db = Database.getInstance(dbUrl);
    await db.runMigrations();
    eventRepo = new EventRepository(db);
    console.log('✅ Database connected and migrations complete');
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
}

async function initVivi() {
  const anthropicKey = process.env.ANTHROPIC_API_KEY;
  if (!anthropicKey) {
    console.warn('⚠️  ANTHROPIC_API_KEY not set - Vivi chat disabled');
    return;
  }

  try {
    viviService = new ViviService(anthropicKey);
    console.log('✅ Vivi AI service initialized (Claude Sonnet 4)');
  } catch (error) {
    console.error('❌ Vivi initialization failed:', error);
  }
}

// Health check
app.get('/health', async (req, res) => {
  const dbHealth = db ? await db.healthCheck() : false;
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    database: dbHealth ? 'connected' : 'disconnected'
  });
});

// Test Eventbrite scraper
app.get('/api/events/eventbrite', async (req, res) => {
  try {
    const apiKey = process.env.EVENTBRITE_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'EVENTBRITE_API_KEY not configured' });
    }

    const scraper = new EventbriteScraper(apiKey);
    const location = req.query.location as string || 'San Francisco, CA';
    const limit = parseInt(req.query.limit as string || '10');

    const events = await scraper.scrapeEvents(location, { limit });
    
    res.json({
      location,
      count: events.length,
      events
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Aggregated events endpoint
app.get('/api/events', async (req, res) => {
  if (!eventRepo) {
    return res.status(503).json({ error: 'Database not initialized' });
  }

  try {
    const location = req.query.location as string;
    const source = req.query.source as string;
    const limit = parseInt(req.query.limit as string || '50');

    const events = await eventRepo.getEvents({ location, source, limit });
    const total = await eventRepo.countEvents(source);

    res.json({
      location: location || 'all',
      source: source || 'all',
      total,
      count: events.length,
      events
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Scrape and store events
app.post('/api/events/scrape', async (req, res) => {
  if (!eventRepo) {
    return res.status(503).json({ error: 'Database not initialized' });
  }

  try {
    const apiKey = process.env.EVENTBRITE_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'EVENTBRITE_API_KEY not configured' });
    }

    const scraper = new EventbriteScraper(apiKey);
    const location = req.body.location || 'San Francisco, CA';
    const limit = parseInt(req.body.limit || '50');

    console.log(`📥 Scraping Eventbrite for ${location}...`);
    const events = await scraper.scrapeEvents(location, { limit });
    
    console.log(`💾 Storing ${events.length} events in database...`);
    const stored = await eventRepo.upsertEvents(events);

    res.json({
      message: 'Scraping complete',
      location,
      scraped: events.length,
      stored,
      total: await eventRepo.countEvents()
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Vivi chat endpoint
app.post('/api/vivi/chat', async (req, res) => {
  if (!viviService) {
    return res.status(503).json({ error: 'Vivi AI service not initialized' });
  }

  try {
    const { message, conversationHistory } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ error: 'Message is required' });
    }

    console.log(`💬 Vivi chat: "${message.substring(0, 50)}..."`);

    const response = await viviService.chat(message, conversationHistory || []);

    res.json({
      response,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Vivi chat error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start server
async function start() {
  try {
    await initDatabase();
    await initVivi();

    app.listen(PORT, () => {
      console.log(`🚀 Venn AI Backend running on http://localhost:${PORT}`);
      console.log(`📊 Health: http://localhost:${PORT}/health`);
      console.log(`💬 Vivi Chat: POST http://localhost:${PORT}/api/vivi/chat`);
      console.log(`🎉 Eventbrite Scraper: http://localhost:${PORT}/api/events/eventbrite`);
      console.log(`📥 Scrape & Store: POST http://localhost:${PORT}/api/events/scrape`);
      console.log(`📚 All Events: http://localhost:${PORT}/api/events`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

start();

export default app;
