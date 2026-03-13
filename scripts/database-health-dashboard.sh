#!/bin/bash
# Database Health Dashboard - Quick diagnostic for Mission Control database
# Usage: ./scripts/database-health-dashboard.sh

DB="/Users/vinnyvenn/.openclaw/workspace/venn-mission-control/dev.db"

echo "=== MISSION CONTROL DATABASE HEALTH ==="
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""

echo "📊 EVENTS OVERVIEW"
sqlite3 "$DB" "SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN archived = 1 THEN 1 END) as archived,
  COUNT(CASE WHEN archived = 0 AND date IS NOT NULL THEN 1 END) as dated,
  COUNT(CASE WHEN archived = 0 AND date IS NULL THEN 1 END) as no_date
FROM Event;"
echo ""

echo "✅ TASKS STATUS"
sqlite3 "$DB" "SELECT 
  status,
  COUNT(*) as count,
  AVG(priority) as avg_priority
FROM Task 
GROUP BY status 
ORDER BY count DESC;"
echo ""

echo "👥 VENDORS PIPELINE"
sqlite3 "$DB" "SELECT 
  COUNT(DISTINCT id) as total_vendors,
  COUNT(CASE WHEN email IS NOT NULL AND email != '' THEN 1 END) as with_email,
  COUNT(CASE WHEN phone IS NOT NULL AND phone != '' THEN 1 END) as with_phone,
  COUNT(CASE WHEN email IS NULL OR email = '' THEN 1 END) as missing_contact
FROM Vendor;"
echo ""

echo "📧 VENDOR OUTREACH STATUS"
sqlite3 "$DB" "SELECT 
  status,
  COUNT(*) as count
FROM VendorOutreach 
GROUP BY status 
ORDER BY count DESC;"
echo ""

echo "🎯 TOP PRIORITY TASKS"
sqlite3 "$DB" "SELECT 
  printf('%3d', priority) || ' | ' || substr(title, 1, 60) as task
FROM Task 
WHERE status = 'todo' 
ORDER BY priority DESC 
LIMIT 10;"
echo ""

echo "📅 EVENTS NEEDING DATES (Top 10)"
sqlite3 "$DB" "SELECT 
  substr(name, 1, 40) as event_name
FROM Event 
WHERE archived = 0 AND date IS NULL 
ORDER BY createdAt DESC 
LIMIT 10;"
echo ""

echo "🚨 DATA QUALITY ALERTS"
# Check for events with vendors but no date
EVENTS_NO_DATE=$(sqlite3 "$DB" "SELECT COUNT(DISTINCT eventId) FROM VendorOutreach WHERE eventId IN (SELECT id FROM Event WHERE date IS NULL AND archived = 0);")
echo "Events with vendors but no date: $EVENTS_NO_DATE"

# Check for contacted vendors with no follow-up
CONTACTED_NO_FOLLOWUP=$(sqlite3 "$DB" "SELECT COUNT(*) FROM VendorOutreach WHERE status = 'contacted' AND contactedAt < datetime('now', '-24 hours');")
echo "Vendors contacted >24h ago (need follow-up): $CONTACTED_NO_FOLLOWUP"

# Check for missing vendor emails
MISSING_EMAILS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM VendorOutreach WHERE (contactEmail IS NULL OR contactEmail = '') AND status = 'researching';")
echo "VendorOutreach records missing email: $MISSING_EMAILS"

echo ""
echo "=== END HEALTH CHECK ==="
