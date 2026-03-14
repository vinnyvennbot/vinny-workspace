"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const dotenv_1 = __importDefault(require("dotenv"));
const eventbrite_1 = require("./scrapers/eventbrite");
const db_1 = require("./database/db");
const vivi_1 = require("./services/vivi");
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 4000;
app.use(express_1.default.json());
// Initialize database
let db;
let eventRepo;
let viviService;
async function initDatabase() {
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
        console.warn('⚠️  DATABASE_URL not set - database features disabled');
        return;
    }
    try {
        db = db_1.Database.getInstance(dbUrl);
        await db.runMigrations();
        eventRepo = new db_1.EventRepository(db);
        console.log('✅ Database connected and migrations complete');
    }
    catch (error) {
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
        viviService = new vivi_1.ViviService(anthropicKey);
        console.log('✅ Vivi AI service initialized (Claude Sonnet 4)');
    }
    catch (error) {
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
        const scraper = new eventbrite_1.EventbriteScraper(apiKey);
        const location = req.query.location || 'San Francisco, CA';
        const limit = parseInt(req.query.limit || '10');
        const events = await scraper.scrapeEvents(location, { limit });
        res.json({
            location,
            count: events.length,
            events
        });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Aggregated events endpoint
app.get('/api/events', async (req, res) => {
    if (!eventRepo) {
        return res.status(503).json({ error: 'Database not initialized' });
    }
    try {
        const location = req.query.location;
        const source = req.query.source;
        const limit = parseInt(req.query.limit || '50');
        const events = await eventRepo.getEvents({ location, source, limit });
        const total = await eventRepo.countEvents(source);
        res.json({
            location: location || 'all',
            source: source || 'all',
            total,
            count: events.length,
            events
        });
    }
    catch (error) {
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
        const scraper = new eventbrite_1.EventbriteScraper(apiKey);
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
    }
    catch (error) {
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
    }
    catch (error) {
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
    }
    catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}
start();
exports.default = app;
//# sourceMappingURL=index.js.map