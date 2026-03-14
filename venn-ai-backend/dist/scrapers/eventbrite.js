"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventbriteScraper = void 0;
const axios_1 = __importDefault(require("axios"));
/**
 * Eventbrite API scraper
 * Docs: https://www.eventbrite.com/platform/api
 */
class EventbriteScraper {
    client;
    apiKey;
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.client = axios_1.default.create({
            baseURL: 'https://www.eventbriteapi.com/v3',
            headers: {
                'Authorization': `Bearer ${apiKey}`
            }
        });
    }
    /**
     * Scrape events from Eventbrite
     */
    async scrapeEvents(location, options = {}) {
        try {
            const params = {
                'location.address': location,
                'expand': 'venue,logo',
                'page_size': options.limit || 50
            };
            // Add date filters if provided
            if (options.startDate) {
                params['start_date.range_start'] = options.startDate.toISOString();
            }
            if (options.endDate) {
                params['start_date.range_end'] = options.endDate.toISOString();
            }
            // Add category filter if provided
            if (options.categories && options.categories.length > 0) {
                params['categories'] = options.categories.join(',');
            }
            const response = await this.client.get('/events/search/', { params });
            if (!response.data || !response.data.events) {
                return [];
            }
            return response.data.events.map((apiEvent) => this.parseEvent(apiEvent));
        }
        catch (error) {
            if (error.response?.status === 401) {
                throw new Error('Invalid Eventbrite API key');
            }
            throw new Error(`Failed to scrape Eventbrite events: ${error.message}`);
        }
    }
    /**
     * Parse Eventbrite API response into Event model
     */
    parseEvent(apiEvent) {
        const venue = apiEvent.venue || {};
        const address = venue.address || {};
        // Build location string
        const addressParts = [
            address.address_1,
            address.city,
            address.region
        ].filter(Boolean).join(', ');
        const locationParts = [venue.name, addressParts, address.postal_code].filter(Boolean);
        const location = locationParts.join(', ');
        // Parse tags from categories
        const tags = [];
        if (apiEvent.category) {
            tags.push(apiEvent.category.name);
        }
        if (apiEvent.subcategory) {
            tags.push(apiEvent.subcategory.name);
        }
        // Parse price (Eventbrite returns ticket info separately, default to free)
        let price = 0;
        if (apiEvent.is_free === false) {
            // Would need separate API call to get actual price
            // For now, leave as undefined to indicate price unknown
            price = undefined;
        }
        return {
            id: `eventbrite_${apiEvent.id}`,
            name: apiEvent.name?.text || 'Untitled Event',
            description: apiEvent.description?.text || '',
            startTime: apiEvent.start?.utc || apiEvent.start?.local,
            endTime: apiEvent.end?.utc || apiEvent.end?.local,
            location,
            latitude: venue.latitude ? parseFloat(venue.latitude) : undefined,
            longitude: venue.longitude ? parseFloat(venue.longitude) : undefined,
            source: 'eventbrite',
            externalUrl: apiEvent.url,
            imageUrl: apiEvent.logo?.url,
            tags,
            price,
            capacity: apiEvent.capacity,
            organizer: apiEvent.organizer?.name,
            createdAt: apiEvent.created || new Date().toISOString(),
            updatedAt: apiEvent.changed || new Date().toISOString()
        };
    }
}
exports.EventbriteScraper = EventbriteScraper;
//# sourceMappingURL=eventbrite.js.map