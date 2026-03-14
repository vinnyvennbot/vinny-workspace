import { Database, EventRepository } from './db';
import { Event } from '../models/Event';

describe('Database', () => {
  let db: Database;
  let repo: EventRepository;

  beforeAll(async () => {
    // Use test database or skip if DATABASE_URL not set
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
      console.warn('DATABASE_URL not set - skipping database tests');
      return;
    }

    db = Database.getInstance(dbUrl);
    await db.runMigrations();
    repo = new EventRepository(db);
  });

  afterAll(async () => {
    if (db) {
      await db.close();
    }
  });

  const skipIfNoDb = process.env.DATABASE_URL ? it : it.skip;

  describe('EventRepository', () => {
    skipIfNoDb('should upsert event', async () => {
      const event: Event = {
        id: 'test_event_1',
        name: 'Test Event',
        description: 'Test Description',
        startTime: new Date('2024-03-20T19:00:00Z').toISOString(),
        endTime: new Date('2024-03-20T22:00:00Z').toISOString(),
        location: 'San Francisco, CA',
        latitude: 37.7749,
        longitude: -122.4194,
        source: 'eventbrite',
        externalUrl: 'https://example.com/event',
        imageUrl: 'https://example.com/image.jpg',
        tags: ['music', 'nightlife'],
        price: 2500, // $25.00
        capacity: 100,
        organizer: 'Test Organizer',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      await repo.upsertEvent(event);

      const retrieved = await repo.getEventById(event.id);
      expect(retrieved).toBeDefined();
      expect(retrieved.name).toBe(event.name);
      expect(retrieved.source).toBe(event.source);
    });

    skipIfNoDb('should get events by location', async () => {
      const events = await repo.getEvents({
        location: 'San Francisco',
        limit: 10
      });

      expect(Array.isArray(events)).toBe(true);
    });

    skipIfNoDb('should count events', async () => {
      const count = await repo.countEvents();
      expect(typeof count).toBe('number');
      expect(count).toBeGreaterThanOrEqual(0);
    });

    skipIfNoDb('should count events by source', async () => {
      const count = await repo.countEvents('eventbrite');
      expect(typeof count).toBe('number');
    });
  });

  describe('Database health', () => {
    skipIfNoDb('should pass health check', async () => {
      const healthy = await db.healthCheck();
      expect(healthy).toBe(true);
    });
  });
});
