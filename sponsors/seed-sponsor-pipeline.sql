-- Sponsor Pipeline Database Seeding Script
-- Created: March 5, 2026, 10:53 PM PST
-- Purpose: Populate CRM with 24-brand sponsor pipeline for tracking

-- WAVE 1 - READY TO CONTACT (Priority Spirits Sponsors)

-- Fernet-Branca
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-fernet-branca',
  'Fernet-Branca',
  'brand',
  'https://www.fernet-branca.com',
  'partnerships@fernet-branca.com',
  'Italian amaro brand - legendary among SF bartenders. Target: Bartender cocktail competition sponsor.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-fernet-branca',
  'Fernet-Branca',
  'brand',
  'sponsor',
  'https://www.fernet-branca.com',
  'researching',
  'org-fernet-branca',
  'email',
  9, -- High brand alignment (SF bartender legend)
  8, -- Bay Area presence
  7, -- Active in sponsorships
  8, -- Established brand reliability
  'Wave 1 priority - SF bartender cocktail competition. $5K ask. Events: Botanical Lab, Midnight Secrets.',
  datetime('now'),
  datetime('now')
);

-- St. George Spirits
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-st-george-spirits',
  'St. George Spirits',
  'brand',
  'https://www.stgeorgespirits.com',
  'events@stgeorgespirits.com',
  'Bay Area craft distillery (Alameda). Known for botanical gin, absinthe, whiskey. Local partnerships.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-st-george-spirits',
  'St. George Spirits',
  'brand',
  'sponsor',
  'https://www.stgeorgespirits.com',
  'researching',
  'org-st-george-spirits',
  'email',
  9, -- Perfect fit - Bay Area craft, botanical theme
  10, -- Alameda-based (local)
  6, -- Moderate sponsorship activity
  9, -- High reliability (established distillery)
  'Wave 1 priority - Botanical Cocktail Lab exclusive sponsor. $5K ask. Botanical gin perfect match.',
  datetime('now'),
  datetime('now')
);

-- Distillery 209
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-distillery-209',
  'Distillery 209',
  'brand',
  'https://www.distillery209.com',
  'info@distillery209.com',
  'SF-based gin distillery (Pier 50). Premium botanical gin, local focus.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-distillery-209',
  'Distillery 209',
  'brand',
  'sponsor',
  'https://www.distillery209.com',
  'researching',
  'org-distillery-209',
  'email',
  10, -- Perfect alignment - SF-based, botanical gin, garden theme
  10, -- SF-based (Pier 50)
  5, -- Unknown sponsorship frequency
  8, -- Established brand
  'Wave 1 HIGHEST PRIORITY - Botanical Lab exclusive sponsor. $5K ask. SF location, botanical gin = perfect fit.',
  datetime('now'),
  datetime('now')
);

-- WAVE 2 - WINE SPONSORS

-- Scribe Winery
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-scribe-winery',
  'Scribe Winery',
  'brand',
  'https://www.scribewinery.com',
  'events@scribewinery.com',
  'Sonoma natural wine producer. Intimate dining experiences, sustainable farming.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-scribe-winery',
  'Scribe Winery',
  'brand',
  'sponsor',
  'https://www.scribewinery.com',
  'researching',
  'org-scribe-winery',
  'email',
  8, -- Strong fit - intimate dining, natural wine
  9, -- Sonoma (Bay Area)
  6, -- Moderate sponsorship activity
  8, -- Established winery
  'Wave 2 - Underground Supper Club wine pairings. $3-5K ask. Natural wine focus aligns with intimate dining.',
  datetime('now'),
  datetime('now')
);

-- Ridge Vineyards
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-ridge-vineyards',
  'Ridge Vineyards',
  'brand',
  'https://www.ridgewine.com',
  'info@ridgewine.com',
  'Cupertino premium winery. Prestigious CA wines, legacy brand.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-ridge-vineyards',
  'Ridge Vineyards',
  'brand',
  'sponsor',
  'https://www.ridgewine.com',
  'researching',
  'org-ridge-vineyards',
  'email',
  7, -- Good fit - premium wine for upscale events
  9, -- Cupertino (Bay Area)
  5, -- Unknown sponsorship frequency
  9, -- Prestigious brand
  'Wave 2 - Jazz Age Garden Party, Art Deco Soiree. $4-6K ask. Premium wine for upscale themed events.',
  datetime('now'),
  datetime('now')
);

-- Prisoner Wine Company
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-prisoner-wine',
  'Prisoner Wine Company',
  'brand',
  'https://www.theprisonerwinecompany.com',
  'info@theprisonerwinecompany.com',
  'Napa bold wine brand. Strong visual aesthetic, nightlife-friendly brand.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-prisoner-wine',
  'Prisoner Wine Company',
  'brand',
  'sponsor',
  'https://www.theprisonerwinecompany.com',
  'researching',
  'org-prisoner-wine',
  'email',
  8, -- Strong aesthetic fit - bold branding for nightlife events
  7, -- Napa (nearby)
  6, -- Active in experiential marketing
  8, -- Established brand
  'Wave 2 - Midnight Secrets Speakeasy, Underground Supper. $3-5K ask. Bold brand aesthetic fits speakeasy/underground themes.',
  datetime('now'),
  datetime('now')
);

-- La Crema
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-la-crema',
  'La Crema',
  'brand',
  'https://www.lacrema.com',
  'partnerships@lacrema.com',
  'Sonoma approachable premium wine. Events-focused brand, community partnerships.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-la-crema',
  'La Crema',
  'brand',
  'sponsor',
  'https://www.lacrema.com',
  'researching',
  'org-la-crema',
  'email',
  7, -- Good fit - approachable premium for broader events
  8, -- Sonoma (Bay Area)
  8, -- Very active in events/sponsorships
  9, -- Reliable brand
  'Wave 2 - Golden Hour Rooftop, Canvas Cocktails. $3-4K ask. Approachable premium wine for casual upscale events.',
  datetime('now'),
  datetime('now')
);

-- WAVE 3 - LIFESTYLE/FASHION SPONSORS

-- Everlane
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-everlane',
  'Everlane',
  'brand',
  'https://www.everlane.com',
  'partnerships@everlane.com',
  'SF-based ethical fashion brand. Radical transparency, community events.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-everlane',
  'Everlane',
  'brand',
  'sponsor',
  'https://www.everlane.com',
  'researching',
  'org-everlane',
  'email',
  8, -- Strong fit - SF brand, community values
  10, -- SF-based
  7, -- Active in community events
  9, -- Established brand
  'Wave 3 - Golden Hour Rooftop, Neon Nights Roller Disco. $2-4K ask. SF brand activation, swag bags, photo moments.',
  datetime('now'),
  datetime('now')
);

-- Outdoor Voices
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-outdoor-voices',
  'Outdoor Voices',
  'brand',
  'https://www.outdoorvoices.com',
  'community@outdoorvoices.com',
  'Activewear brand. Experiential marketing, community-driven events.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-outdoor-voices',
  'Outdoor Voices',
  'brand',
  'sponsor',
  'https://www.outdoorvoices.com',
  'researching',
  'org-outdoor-voices',
  'email',
  7, -- Moderate fit - activewear for active events
  6, -- Not SF-based but active in SF market
  8, -- Very active in experiential marketing
  8, -- Reliable brand
  'Wave 3 - Neon Nights Roller Disco, Golden Hour Rooftop. $2-3K ask. Activewear brand for active/social events.',
  datetime('now'),
  datetime('now')
);

-- Allbirds
INSERT INTO Organization (id, name, type, website, email, notes, createdAt, updatedAt)
VALUES (
  'org-allbirds',
  'Allbirds',
  'brand',
  'https://www.allbirds.com',
  'partnerships@allbirds.com',
  'SF-based sustainable footwear. Local partnerships, sustainability focus.',
  datetime('now'),
  datetime('now')
);

INSERT INTO Partner (id, name, partnerType, category, website, status, orgId, channel, brandAlignment, localityScore, sponsorFrequency, reliability, notes, createdAt, updatedAt)
VALUES (
  'partner-allbirds',
  'Allbirds',
  'brand',
  'sponsor',
  'https://www.allbirds.com',
  'researching',
  'org-allbirds',
  'email',
  8, -- Strong fit - SF brand, sustainability values
  10, -- SF-based
  7, -- Active in community events
  9, -- Established brand
  'Wave 3 - Multiple events. $2-4K ask. SF brand, product giveaways, sustainability messaging.',
  datetime('now'),
  datetime('now')
);

-- ANCHOR BREWING - ON HOLD (Dormant since July 2023)
-- DO NOT INSERT YET - Monitor for reopening announcement

-- TECH CORPORATE SPONSORS (Pipeline - Contact Research Phase)
-- These will be added after contact research Phase 2 completes
-- Target companies: OpenAI, Anthropic, Scale AI, Stripe, Salesforce, Databricks, etc.
-- Corporate buyout model: $50K for 250 employees

-- FOOD/BEVERAGE SPONSORS (Pipeline - Not Yet Researched)
-- Categories to research: Artisan coffee, specialty catering, local food brands
-- Wave 4 activation after Wave 1-3 performance data

-- End of seeding script
-- To execute: sqlite3 /Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db < seed-sponsor-pipeline.sql
