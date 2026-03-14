/**
 * Event model for aggregated events from multiple sources
 */
export interface Event {
  /** Unique identifier (prefixed with source, e.g., "eventbrite_123") */
  id: string;
  
  /** Event name/title */
  name: string;
  
  /** Event description (HTML or plain text) */
  description: string;
  
  /** ISO 8601 start time */
  startTime: string;
  
  /** ISO 8601 end time */
  endTime: string;
  
  /** Location string (venue name + address) */
  location: string;
  
  /** Latitude (optional, for mapping) */
  latitude?: number;
  
  /** Longitude (optional, for mapping) */
  longitude?: number;
  
  /** Source platform (eventbrite, luma, instagram, etc.) */
  source: EventSource;
  
  /** External URL to original event page */
  externalUrl: string;
  
  /** Image URL (cover photo) */
  imageUrl?: string;
  
  /** Event category/tags */
  tags?: string[];
  
  /** Price (in cents, 0 = free) */
  price?: number;
  
  /** Maximum capacity (if known) */
  capacity?: number;
  
  /** Number of attendees (if known) */
  attendees?: number;
  
  /** Organizer name */
  organizer?: string;
  
  /** Created timestamp */
  createdAt: string;
  
  /** Last updated timestamp */
  updatedAt: string;
}

export type EventSource = 
  | 'eventbrite' 
  | 'luma' 
  | 'instagram' 
  | 'tiktok' 
  | 'reddit' 
  | 'venn';

/**
 * Options for scraping events
 */
export interface ScrapeOptions {
  /** Maximum number of events to return */
  limit?: number;
  
  /** Start date filter (events starting after this date) */
  startDate?: Date;
  
  /** End date filter (events starting before this date) */
  endDate?: Date;
  
  /** Category filter */
  categories?: string[];
  
  /** Price range filter (in cents) */
  priceMin?: number;
  priceMax?: number;
}

/**
 * Base scraper interface that all scrapers must implement
 */
export interface EventScraper {
  /**
   * Scrape events from the source
   * @param location - Location query (e.g., "San Francisco, CA")
   * @param options - Scraping options
   * @returns Array of events
   */
  scrapeEvents(location: string, options?: ScrapeOptions): Promise<Event[]>;
}
