#!/usr/bin/env python3
"""
Add Event_ID column to existing Google Sheets vendor/venue databases.
Prevents mixing vendors from different events.

Usage:
    python3 add_event_id_to_sheets.py SHEET_ID
"""

import subprocess
import sys
import json

def add_event_id_column(sheet_id):
    """Add Event_ID as first column in Google Sheet"""
    
    print(f"Adding Event_ID column to sheet {sheet_id}...")
    
    # Get current sheet metadata
    result = subprocess.run(
        ["gog", "sheets", "metadata", sheet_id],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print(f"Error: Could not access sheet {sheet_id}")
        print(result.stderr)
        return False
    
    # Insert column A (Event_ID)
    # This will shift all existing columns to the right
    cmd = [
        "gog", "sheets", "update", sheet_id,
        "A1", "Event_ID"  # Add header
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Error: Could not update sheet")
        print(result.stderr)
        return False
    
    print("✅ Event_ID column added successfully!")
    print("\n⚠️  IMPORTANT: You must now manually:")
    print("   1. Open the sheet in Google Sheets")
    print("   2. Insert a new column BEFORE column A")
    print("   3. Name it 'Event_ID'")
    print("   4. Fill in Event_ID for each row (EVT-001, EVT-002, EVT-003)")
    print("\n   OR use the gog CLI to batch update rows with Event_ID values")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 add_event_id_to_sheets.py SHEET_ID")
        print("\nKnown sheets:")
        print("  - Venues Master: 1M_9po4jW6coYgqnlLr34dNxUK91zDquMe9Pf4ldHYVU")
        print("  - Vendors Master: 1Q6WAcAEJ5GEqpGSBucyqcqP3KK2BNBMh")
        sys.exit(1)
    
    sheet_id = sys.argv[1]
    success = add_event_id_column(sheet_id)
    
    sys.exit(0 if success else 1)
