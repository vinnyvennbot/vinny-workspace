import { PoolClient } from 'pg';
/**
 * Database connection pool
 */
export declare class Database {
    private pool;
    private static instance;
    private constructor();
    /**
     * Get singleton database instance
     */
    static getInstance(connectionString?: string): Database;
    /**
     * Execute a query
     */
    query(text: string, params?: any[]): Promise<import("pg").QueryResult<any>>;
    /**
     * Get a client from the pool for transactions
     */
    getClient(): Promise<PoolClient>;
    /**
     * Run database migrations
     */
    runMigrations(): Promise<void>;
    /**
     * Check database health
     */
    healthCheck(): Promise<boolean>;
    /**
     * Close all connections
     */
    close(): Promise<void>;
}
/**
 * Event repository - CRUD operations for aggregated_events
 */
export declare class EventRepository {
    private db;
    constructor(db: Database);
    /**
     * Insert or update event (upsert)
     */
    upsertEvent(event: any): Promise<void>;
    /**
     * Bulk upsert events
     */
    upsertEvents(events: any[]): Promise<number>;
    /**
     * Get events by location and date range
     */
    getEvents(options: {
        location?: string;
        startDate?: Date;
        endDate?: Date;
        source?: string;
        limit?: number;
    }): Promise<any[]>;
    /**
     * Get event by ID
     */
    getEventById(id: string): Promise<any | null>;
    /**
     * Count total events
     */
    countEvents(source?: string): Promise<number>;
}
//# sourceMappingURL=db.d.ts.map