import { EventbriteScraper } from './eventbrite';
import { Event } from '../models/Event';

describe('EventbriteScraper', () => {
  let scraper: EventbriteScraper;

  beforeEach(() => {
    scraper = new EventbriteScraper(process.env.EVENTBRITE_API_KEY || 'test-key');
  });

  // Integration tests - require valid API key
  describe('scrapeEvents (integration)', () => {
    const skipIfNoApiKey = process.env.EVENTBRITE_API_KEY ? it : it.skip;

    skipIfNoApiKey('should return array of events for San Francisco', async () => {
      const events = await scraper.scrapeEvents('San Francisco, CA');
      
      expect(Array.isArray(events)).toBe(true);
      expect(events.length).toBeGreaterThan(0);
    });

    skipIfNoApiKey('should return events with required fields', async () => {
      const events = await scraper.scrapeEvents('San Francisco, CA', { limit: 1 });
      
      expect(events.length).toBeGreaterThan(0);
      
      const event = events[0];
      expect(event).toHaveProperty('id');
      expect(event).toHaveProperty('name');
      expect(event).toHaveProperty('description');
      expect(event).toHaveProperty('startTime');
      expect(event).toHaveProperty('endTime');
      expect(event).toHaveProperty('location');
      expect(event).toHaveProperty('source');
      expect(event.source).toBe('eventbrite');
    });

    skipIfNoApiKey('should respect limit parameter', async () => {
      const limit = 5;
      const events = await scraper.scrapeEvents('San Francisco, CA', { limit });
      
      expect(events.length).toBeLessThanOrEqual(limit);
    });

    skipIfNoApiKey('should filter by date range', async () => {
      const today = new Date();
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      const events = await scraper.scrapeEvents('San Francisco, CA', {
        startDate: today,
        endDate: tomorrow
      });
      
      events.forEach(event => {
        const eventDate = new Date(event.startTime);
        expect(eventDate >= today && eventDate <= tomorrow).toBe(true);
      });
    });

    it('should handle API errors gracefully', async () => {
      const badScraper = new EventbriteScraper('invalid-key');
      
      await expect(badScraper.scrapeEvents('San Francisco, CA')).rejects.toThrow();
    });
  });

  describe('parseEvent', () => {
    it('should parse Eventbrite API response correctly', () => {
      const mockApiResponse = {
        id: '123456789',
        name: { text: 'Test Event' },
        description: { text: 'Test Description' },
        start: { utc: '2024-03-20T19:00:00Z' },
        end: { utc: '2024-03-20T22:00:00Z' },
        venue: {
          name: 'Test Venue',
          address: {
            address_1: '123 Main St',
            city: 'San Francisco',
            region: 'CA',
            postal_code: '94105'
          }
        },
        logo: {
          url: 'https://example.com/image.jpg'
        },
        url: 'https://eventbrite.com/e/123456789'
      };

      const event = scraper.parseEvent(mockApiResponse);
      
      expect(event.id).toBe('eventbrite_123456789');
      expect(event.name).toBe('Test Event');
      expect(event.description).toBe('Test Description');
      expect(event.location).toBe('Test Venue, 123 Main St, San Francisco, CA, 94105');
      expect(event.source).toBe('eventbrite');
      expect(event.externalUrl).toBe('https://eventbrite.com/e/123456789');
    });
  });
});
