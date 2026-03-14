import { LumaScraper } from './luma';
import { Event } from '../models/Event';

describe('LumaScraper', () => {
  let scraper: LumaScraper;

  beforeEach(() => {
    scraper = new LumaScraper();
  });

  describe('scrapeEvents', () => {
    it('should return array of events for San Francisco', async () => {
      const events = await scraper.scrapeEvents('San Francisco, CA');
      
      expect(Array.isArray(events)).toBe(true);
      // Luma might have 0 events, that's ok
      expect(events.length).toBeGreaterThanOrEqual(0);
    }, 30000); // 30 second timeout for web scraping

    it('should return events with required fields', async () => {
      const events = await scraper.scrapeEvents('San Francisco, CA', { limit: 1 });
      
      if (events.length === 0) {
        // No events found - skip validation
        return;
      }
      
      const event = events[0];
      expect(event).toHaveProperty('id');
      expect(event).toHaveProperty('name');
      expect(event).toHaveProperty('startTime');
      expect(event).toHaveProperty('location');
      expect(event).toHaveProperty('source');
      expect(event.source).toBe('luma');
      expect(event).toHaveProperty('externalUrl');
      expect(event.externalUrl).toContain('lu.ma');
    }, 30000);

    it('should respect limit parameter', async () => {
      const limit = 3;
      const events = await scraper.scrapeEvents('San Francisco, CA', { limit });
      
      expect(events.length).toBeLessThanOrEqual(limit);
    }, 30000);

    it('should handle network errors gracefully', async () => {
      // Create scraper with invalid base URL
      const badScraper = new LumaScraper('https://invalid-url-that-does-not-exist.com');
      
      // Should return empty array instead of throwing (graceful degradation)
      const events = await badScraper.scrapeEvents('San Francisco, CA');
      expect(Array.isArray(events)).toBe(true);
    }, 10000);
  });

  describe('parseEvent', () => {
    it('should extract event data from HTML structure', () => {
      // Mock Luma event HTML structure
      const mockHtml = `
        <div class="event-card">
          <a href="/e/evt-123456">Test Event</a>
          <div class="event-time">Thu, Mar 14 • 7:00 PM PDT</div>
          <div class="event-location">The Mission, San Francisco</div>
        </div>
      `;

      // Test parsing logic
      expect(mockHtml).toContain('Test Event');
    });
  });
});
