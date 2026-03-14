"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LumaScraper = void 0;
const axios_1 = __importDefault(require("axios"));
const cheerio = __importStar(require("cheerio"));
/**
 * Luma web scraper
 * No public API - scrapes lu.ma website
 */
class LumaScraper {
    client;
    baseUrl;
    constructor(baseUrl = 'https://lu.ma') {
        this.baseUrl = baseUrl;
        this.client = axios_1.default.create({
            baseURL: baseUrl,
            headers: {
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
            },
            timeout: 10000
        });
    }
    /**
     * Scrape events from Luma
     *
     * Note: Luma uses client-side rendering, so we attempt multiple strategies:
     * 1. Try to find their API endpoint
     * 2. Parse initial HTML if available
     * 3. Fall back to empty results
     */
    async scrapeEvents(location, options = {}) {
        try {
            // Luma's discover page for a city
            const citySlug = this.locationToSlug(location);
            const url = `/discover/${citySlug}`;
            console.log(`🔍 Scraping Luma: ${this.baseUrl}${url}`);
            const response = await this.client.get(url);
            const html = response.data;
            // Try to extract events from HTML
            const events = this.parseHtml(html);
            // Apply limit
            const limit = options.limit || 50;
            return events.slice(0, limit);
        }
        catch (error) {
            if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
                throw new Error(`Cannot connect to Luma: ${error.message}`);
            }
            console.error('Luma scraping error:', error.message);
            // Return empty array instead of throwing - Luma might not have events
            return [];
        }
    }
    /**
     * Parse Luma HTML to extract event data
     */
    parseHtml(html) {
        const $ = cheerio.load(html);
        const events = [];
        // Luma uses __NEXT_DATA__ for initial state (Next.js SSR)
        const nextDataScript = $('script#__NEXT_DATA__').html();
        if (nextDataScript) {
            try {
                const nextData = JSON.parse(nextDataScript);
                const eventsData = this.extractEventsFromNextData(nextData);
                events.push(...eventsData);
            }
            catch (error) {
                console.warn('Failed to parse __NEXT_DATA__:', error);
            }
        }
        // Fallback: Try to parse event cards directly
        if (events.length === 0) {
            $('.event-card, [data-testid="event-card"]').each((_, element) => {
                try {
                    const event = this.parseEventCard($, $(element));
                    if (event) {
                        events.push(event);
                    }
                }
                catch (error) {
                    // Skip malformed cards
                }
            });
        }
        return events;
    }
    /**
     * Extract events from Next.js data
     */
    extractEventsFromNextData(nextData) {
        const events = [];
        try {
            // Navigate Next.js data structure
            const pageProps = nextData?.props?.pageProps;
            const eventsData = pageProps?.events || pageProps?.initialEvents || [];
            for (const eventData of eventsData) {
                const event = this.parseEventData(eventData);
                if (event) {
                    events.push(event);
                }
            }
        }
        catch (error) {
            console.warn('Error extracting events from Next.js data:', error);
        }
        return events;
    }
    /**
     * Parse event data object
     */
    parseEventData(data) {
        try {
            const eventId = data.event_id || data.api_id || data.url?.split('/').pop();
            if (!eventId)
                return null;
            return {
                id: `luma_${eventId}`,
                name: data.name || data.title || 'Untitled Event',
                description: data.description || '',
                startTime: data.start_time || data.start_at || new Date().toISOString(),
                endTime: data.end_time || data.end_at || new Date().toISOString(),
                location: this.parseLocation(data),
                latitude: data.geo_latitude,
                longitude: data.geo_longitude,
                source: 'luma',
                externalUrl: data.url || `${this.baseUrl}/e/${eventId}`,
                imageUrl: data.cover_url || data.image_url,
                tags: data.tags || [],
                capacity: data.capacity,
                attendees: data.guest_count || data.attendee_count,
                organizer: data.host?.name || data.organizer?.name,
                createdAt: data.created_at || new Date().toISOString(),
                updatedAt: data.updated_at || new Date().toISOString()
            };
        }
        catch (error) {
            return null;
        }
    }
    /**
     * Parse event card HTML element
     */
    parseEventCard($, card) {
        try {
            const link = card.find('a').first();
            const href = link.attr('href');
            if (!href)
                return null;
            const eventId = href.split('/').pop() || 'unknown';
            const name = link.text().trim() || 'Untitled Event';
            const timeText = card.find('.event-time, [data-testid="event-time"]').text().trim();
            const locationText = card.find('.event-location, [data-testid="event-location"]').text().trim();
            return {
                id: `luma_${eventId}`,
                name,
                description: '',
                startTime: this.parseTimeText(timeText),
                endTime: this.parseTimeText(timeText),
                location: locationText || 'Location TBD',
                source: 'luma',
                externalUrl: href.startsWith('http') ? href : `${this.baseUrl}${href}`,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };
        }
        catch (error) {
            return null;
        }
    }
    /**
     * Parse location from event data
     */
    parseLocation(data) {
        if (data.geo_address_json) {
            const addr = data.geo_address_json;
            return [addr.name, addr.city, addr.region].filter(Boolean).join(', ');
        }
        if (data.location) {
            return data.location;
        }
        return 'Location TBD';
    }
    /**
     * Parse time text to ISO string
     */
    parseTimeText(text) {
        // TODO: Implement proper date parsing
        // For now, return current time
        return new Date().toISOString();
    }
    /**
     * Convert location string to Luma city slug
     */
    locationToSlug(location) {
        // Extract city name and convert to slug
        const city = location.split(',')[0].trim().toLowerCase();
        return city.replace(/\s+/g, '-');
    }
}
exports.LumaScraper = LumaScraper;
//# sourceMappingURL=luma.js.map