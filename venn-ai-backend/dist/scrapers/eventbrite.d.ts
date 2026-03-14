import { Event, EventScraper, ScrapeOptions } from '../models/Event';
/**
 * Eventbrite API scraper
 * Docs: https://www.eventbrite.com/platform/api
 */
export declare class EventbriteScraper implements EventScraper {
    private client;
    private apiKey;
    constructor(apiKey: string);
    /**
     * Scrape events from Eventbrite
     */
    scrapeEvents(location: string, options?: ScrapeOptions): Promise<Event[]>;
    /**
     * Parse Eventbrite API response into Event model
     */
    parseEvent(apiEvent: any): Event;
}
//# sourceMappingURL=eventbrite.d.ts.map