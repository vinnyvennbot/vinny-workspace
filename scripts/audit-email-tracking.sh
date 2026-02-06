#!/bin/bash

# Email tracking audit script
# Run this to verify all sent emails are properly tracked

echo "📧 AUDITING EMAIL TRACKING"
echo "=========================="

echo "🔍 Checking sent emails from last 24 hours..."
SENT_EMAILS=$(gog gmail search 'from:vinny@vennapp.co newer_than:1d' --max 20)

echo "📤 SENT EMAILS FOUND:"
echo "$SENT_EMAILS" | head -15

echo ""
echo "🔍 Checking received emails (potential responses)..."
RECEIVED_EMAILS=$(gog gmail search 'newer_than:1d -from:vinny@vennapp.co -from:zed.truong@vennapp.co' --max 10)

if [ -n "$RECEIVED_EMAILS" ]; then
    echo "📥 RECEIVED EMAILS:"
    echo "$RECEIVED_EMAILS"
else
    echo "📥 No new received emails found"
fi

echo ""
echo "✅ EMAIL AUDIT COMPLETE"
echo "REMINDER: Update vendor database with any missing responses!"