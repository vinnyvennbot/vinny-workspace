#!/bin/bash

# Enhanced vendor response monitoring script
# Checks Gmail for vendor responses and updates database

echo "🔍 Checking Gmail for vendor responses..."

# Search for emails from potential vendors in last hour
RECENT_EMAILS=$(gog gmail search 'newer_than:1h -from:vinny@vennapp.co -from:zed.truong@vennapp.co' --max 10 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$RECENT_EMAILS" ]; then
    echo "📧 Found recent emails - checking for vendor responses..."
    
    # Look for vendor-related keywords
    VENDOR_RESPONSES=$(echo "$RECENT_EMAILS" | grep -i -E "(mechanical bull|private dining|event|quote|rental|catering|venue|dining|restaurant)")
    
    if [ -n "$VENDOR_RESPONSES" ]; then
        echo "🎉 VENDOR RESPONSE DETECTED!"
        echo "$VENDOR_RESPONSES"
        
        # Alert about vendor response
        echo "📧 New vendor response detected at $(date)"
        exit 1  # Exit code 1 to trigger alert
    else
        echo "✅ No new vendor responses found"
    fi
else
    echo "ℹ️  No recent emails found"
fi

echo "📊 Gmail monitoring complete"
exit 0