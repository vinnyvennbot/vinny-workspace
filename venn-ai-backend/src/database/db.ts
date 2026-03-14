import { Pool, PoolClient } from 'pg';
import fs from 'fs';
import path from 'path';

/**
 * Database connection pool
 */
export class Database {
  private pool: Pool;
  private static instance: Database;

  private constructor(connectionString: string) {
    this.pool = new Pool({
      connectionString,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });

    // Handle pool errors
    this.pool.on('error', (err: Error) => {
      console.error('Unexpected error on idle client', err);
      process.exit(-1);
    });
  }

  /**
   * Get singleton database instance
   */
  static getInstance(connectionString?: string): Database {
    if (!Database.instance) {
      if (!connectionString) {
        throw new Error('Database connection string required for first initialization');
      }
      Database.instance = new Database(connectionString);
    }
    return Database.instance;
  }

  /**
   * Execute a query
   */
  async query(text: string, params?: any[]) {
    const start = Date.now();
    try {
      const res = await this.pool.query(text, params);
      const duration = Date.now() - start;
      
      if (duration > 100) {
        console.warn('Slow query detected:', { text, duration, rows: res.rowCount });
      }
      
      return res;
    } catch (error) {
      console.error('Database query error:', { text, error });
      throw error;
    }
  }

  /**
   * Get a client from the pool for transactions
   */
  async getClient(): Promise<PoolClient> {
    return this.pool.connect();
  }

  /**
   * Run database migrations
   */
  async runMigrations(): Promise<void> {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');

    try {
      console.log('Running database migrations...');
      await this.query(schema);
      console.log('✅ Database migrations complete');
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    }
  }

  /**
   * Check database health
   */
  async healthCheck(): Promise<boolean> {
    try {
      const result = await this.query('SELECT NOW()');
      return !!result.rows[0];
    } catch (error) {
      console.error('Database health check failed:', error);
      return false;
    }
  }

  /**
   * Close all connections
   */
  async close(): Promise<void> {
    await this.pool.end();
  }
}

/**
 * Event repository - CRUD operations for aggregated_events
 */
export class EventRepository {
  private db: Database;

  constructor(db: Database) {
    this.db = db;
  }

  /**
   * Insert or update event (upsert)
   */
  async upsertEvent(event: any): Promise<void> {
    const query = `
      INSERT INTO aggregated_events (
        id, name, description, start_time, end_time, location,
        latitude, longitude, source, external_url, image_url,
        tags, price_cents, capacity, attendees, organizer, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, NOW())
      ON CONFLICT (id) 
      DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        start_time = EXCLUDED.start_time,
        end_time = EXCLUDED.end_time,
        location = EXCLUDED.location,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        image_url = EXCLUDED.image_url,
        tags = EXCLUDED.tags,
        price_cents = EXCLUDED.price_cents,
        capacity = EXCLUDED.capacity,
        attendees = EXCLUDED.attendees,
        organizer = EXCLUDED.organizer,
        updated_at = NOW()
    `;

    const values = [
      event.id,
      event.name,
      event.description,
      event.startTime,
      event.endTime,
      event.location,
      event.latitude,
      event.longitude,
      event.source,
      event.externalUrl,
      event.imageUrl,
      event.tags || [],
      event.price,
      event.capacity,
      event.attendees,
      event.organizer
    ];

    await this.db.query(query, values);
  }

  /**
   * Bulk upsert events
   */
  async upsertEvents(events: any[]): Promise<number> {
    let count = 0;
    const client = await this.db.getClient();

    try {
      await client.query('BEGIN');

      for (const event of events) {
        await this.upsertEvent(event);
        count++;
      }

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }

    return count;
  }

  /**
   * Get events by location and date range
   */
  async getEvents(options: {
    location?: string;
    startDate?: Date;
    endDate?: Date;
    source?: string;
    limit?: number;
  }): Promise<any[]> {
    const conditions: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (options.location) {
      conditions.push(`location ILIKE $${paramIndex}`);
      values.push(`%${options.location}%`);
      paramIndex++;
    }

    if (options.startDate) {
      conditions.push(`start_time >= $${paramIndex}`);
      values.push(options.startDate.toISOString());
      paramIndex++;
    }

    if (options.endDate) {
      conditions.push(`start_time <= $${paramIndex}`);
      values.push(options.endDate.toISOString());
      paramIndex++;
    }

    if (options.source) {
      conditions.push(`source = $${paramIndex}`);
      values.push(options.source);
      paramIndex++;
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
    const limitClause = options.limit ? `LIMIT ${options.limit}` : '';

    const query = `
      SELECT * FROM aggregated_events
      ${whereClause}
      ORDER BY start_time ASC
      ${limitClause}
    `;

    const result = await this.db.query(query, values);
    return result.rows;
  }

  /**
   * Get event by ID
   */
  async getEventById(id: string): Promise<any | null> {
    const result = await this.db.query(
      'SELECT * FROM aggregated_events WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  /**
   * Count total events
   */
  async countEvents(source?: string): Promise<number> {
    const query = source
      ? 'SELECT COUNT(*) FROM aggregated_events WHERE source = $1'
      : 'SELECT COUNT(*) FROM aggregated_events';
    
    const values = source ? [source] : [];
    const result = await this.db.query(query, values);
    return parseInt(result.rows[0].count, 10);
  }
}
