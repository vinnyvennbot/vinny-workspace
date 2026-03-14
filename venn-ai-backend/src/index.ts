import express from 'express';
import dotenv from 'dotenv';
import { EventbriteScraper } from './scrapers/eventbrite';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
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

// Aggregated events endpoint (placeholder for now)
app.get('/api/events', async (req, res) => {
  res.json({
    message: 'Event aggregation coming soon',
    sources: ['eventbrite', 'luma', 'instagram', 'tiktok', 'reddit']
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Venn AI Backend running on http://localhost:${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/health`);
  console.log(`🎉 Events: http://localhost:${PORT}/api/events/eventbrite`);
});

export default app;
