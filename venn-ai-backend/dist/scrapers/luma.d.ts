import { Event, EventScraper, ScrapeOptions } from '../models/Event';
/**
 * Luma web scraper
 * No public API - scrapes lu.ma website
 */
export declare class LumaScraper implements EventScraper {
    private client;
    private baseUrl;
    constructor(baseUrl?: string);
    /**
     * Scrape events from Luma
     *
     * Note: Luma uses client-side rendering, so we attempt multiple strategies:
     * 1. Try to find their API endpoint
     * 2. Parse initial HTML if available
     * 3. Fall back to empty results
     */
    scrapeEvents(location: string, options?: ScrapeOptions): Promise<Event[]>;
    /**
     * Parse Luma HTML to extract event data
     */
    private parseHtml;
    /**
     * Extract events from Next.js data
     */
    private extractEventsFromNextData;
    /**
     * Parse event data object
     */
    private parseEventData;
    /**
     * Parse event card HTML element
     */
    private parseEventCard;
    /**
     * Parse location from event data
     */
    private parseLocation;
    /**
     * Parse time text to ISO string
     */
    private parseTimeText;
    /**
     * Convert location string to Luma city slug
     */
    private locationToSlug;
}
//# sourceMappingURL=luma.d.ts.map