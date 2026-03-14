-- Aggregated Events Table
-- Stores events scraped from multiple sources (Eventbrite, Luma, Instagram, TikTok, Reddit, Venn)

CREATE TABLE IF NOT EXISTS aggregated_events (
  id VARCHAR(255) PRIMARY KEY,  -- Prefixed with source (e.g., "eventbrite_123")
  name VARCHAR(500) NOT NULL,
  description TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  location VARCHAR(500),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  source VARCHAR(50) NOT NULL,  -- eventbrite, luma, instagram, tiktok, reddit, venn
  external_url VARCHAR(1000) NOT NULL,
  image_url VARCHAR(1000),
  tags TEXT[],  -- PostgreSQL array of strings
  price_cents INTEGER,  -- NULL = price unknown, 0 = free
  capacity INTEGER,
  attendees INTEGER,
  organizer VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Indexes for performance
  CONSTRAINT valid_source CHECK (source IN ('eventbrite', 'luma', 'instagram', 'tiktok', 'reddit', 'venn'))
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_events_start_time ON aggregated_events(start_time);
CREATE INDEX IF NOT EXISTS idx_events_source ON aggregated_events(source);
CREATE INDEX IF NOT EXISTS idx_events_location ON aggregated_events(location);
CREATE INDEX IF NOT EXISTS idx_events_tags ON aggregated_events USING GIN(tags);

-- Geospatial index for location-based queries (requires PostGIS extension)
CREATE INDEX IF NOT EXISTS idx_events_location_geo ON aggregated_events USING GIST(
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- User Behavior Tracking Table
-- Tracks user interactions with events for recommendation learning

CREATE TABLE IF NOT EXISTS user_event_interactions (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,  -- References existing users table
  event_id VARCHAR(255) NOT NULL REFERENCES aggregated_events(id),
  interaction_type VARCHAR(50) NOT NULL,  -- view, click, skip, rsvp, checkin, share
  interaction_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  dwell_time_seconds INTEGER,  -- How long they viewed the event
  
  CONSTRAINT valid_interaction CHECK (interaction_type IN ('view', 'click', 'skip', 'rsvp', 'checkin', 'share'))
);

-- Indexes for behavior queries
CREATE INDEX IF NOT EXISTS idx_interactions_user ON user_event_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_interactions_event ON user_event_interactions(event_id);
CREATE INDEX IF NOT EXISTS idx_interactions_timestamp ON user_event_interactions(interaction_timestamp);

-- User Preferences Table (for Vivi onboarding)
-- Stores taste graph and preference signals

CREATE TABLE IF NOT EXISTS user_preferences (
  user_id UUID PRIMARY KEY,  -- References existing users table
  interests TEXT[],  -- Array of interest keywords
  preferred_vibes TEXT[],  -- Array of vibe descriptors (e.g., "chill", "energetic", "intimate")
  joy_triggers TEXT[],  -- What brings them joy
  preferred_times VARCHAR(50)[],  -- weeknight, weekend_day, weekend_night
  preferred_locations VARCHAR(255)[],  -- Neighborhood preferences
  budget_range VARCHAR(50),  -- free, budget, mid, premium
  group_size_preference VARCHAR(50),  -- solo, small_group, large_group, any
  onboarding_complete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vivi Chat History Table
-- Stores conversation context for personalized recommendations

CREATE TABLE IF NOT EXISTS vivi_chat_history (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,  -- References existing users table
  message_role VARCHAR(20) NOT NULL,  -- user, assistant
  message_content TEXT NOT NULL,
  message_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_role CHECK (message_role IN ('user', 'assistant'))
);

CREATE INDEX IF NOT EXISTS idx_chat_user ON vivi_chat_history(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_timestamp ON vivi_chat_history(message_timestamp);

-- Event Deduplication Candidates Table
-- Tracks potential duplicates for manual review or automatic merging

CREATE TABLE IF NOT EXISTS event_duplicates (
  id SERIAL PRIMARY KEY,
  event_id_1 VARCHAR(255) NOT NULL REFERENCES aggregated_events(id),
  event_id_2 VARCHAR(255) NOT NULL REFERENCES aggregated_events(id),
  similarity_score DECIMAL(5, 4),  -- 0.0 to 1.0
  merge_status VARCHAR(20) DEFAULT 'pending',  -- pending, merged, ignored
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_merge_status CHECK (merge_status IN ('pending', 'merged', 'ignored')),
  CONSTRAINT different_events CHECK (event_id_1 != event_id_2)
);

CREATE INDEX IF NOT EXISTS idx_duplicates_status ON event_duplicates(merge_status);
