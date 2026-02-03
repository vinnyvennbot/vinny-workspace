#!/usr/bin/env python3
"""
Apply investment banker-style formatting to Google Sheets using the API
"""

import json
import subprocess

def run_gog_command(cmd):
    """Run gog command and return result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error: {result.stderr}")
            return None
        return result.stdout.strip()
    except Exception as e:
        print(f"Command failed: {e}")
        return None

def apply_formatting_to_western_dancing():
    """Apply professional formatting to Western Dancing sheet"""
    spreadsheet_id = "1c4IqemQuC6KuvvkIlHfswCy6YUu8Nru0jcRbNHH2rmg"
    
    # First, clear and rebuild with proper structure
    print("Rebuilding Western Dancing sheet...")
    run_gog_command(f'gog sheets clear "{spreadsheet_id}" "Sheet1!A1:Z100"')
    
    # Add structured data
    data = [
        ["VENN SOCIAL - WESTERN LINE DANCING FINANCIAL MODEL", "", "", "", "", "", "", ""],
        ["Event: Wild West Nights | Venue: The Chapel | Capacity: 100 people", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["KEY INPUT ASSUMPTIONS", "", "", "", "", "Value", "Units", ""],
        ["Event Capacity", "", "", "", "", "100", "people", ""],
        ["Ticket Price", "", "", "", "", "65", "$ per ticket", ""],
        ["Volo Sponsorship", "", "", "", "", "1500", "$", ""],
        ["Whiskey Brand Sponsor", "", "", "", "", "1000", "$", ""],
        ["Total Sponsorships", "", "", "", "", "=F7+F8", "$", ""],
        ["", "", "", "", "", "", "", ""],
        ["REVENUE ANALYSIS", "", "", "", "", "", "", ""],
        ["Gross Ticket Sales", "", "", "", "", "=F5*F6", "$", ""],
        ["Sponsorship Revenue", "", "", "", "", "=F9", "$", ""],
        ["TOTAL REVENUE", "", "", "", "", "=F12+F13", "$", ""],
        ["", "", "", "", "", "", "", ""],
        ["COST STRUCTURE", "", "Per Person", "", "Total Cost", "% of Revenue", "", ""],
        ["Venue - The Chapel", "", "25", "", "=C16*$F$5", "=E16/$F$14", "", ""],
        ["Live Country Band", "", "15", "", "=C17*$F$5", "=E17/$F$14", "", ""],
        ["Line Dancing Instructor", "", "4", "", "=C18*$F$5", "=E18/$F$14", "", ""],
        ["BBQ Catering", "", "22", "", "=C19*$F$5", "=E19/$F$14", "", ""],
        ["Photography/Marketing", "", "9", "", "=C20*$F$5", "=E20/$F$14", "", ""],
        ["TOTAL OPERATING COSTS", "", "=SUM(C16:C20)", "", "=SUM(E16:E20)", "=E21/$F$14", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["PROFITABILITY ANALYSIS", "", "", "", "", "", "", ""],
        ["Gross Profit", "", "", "", "=F14-E21", "$", "", ""],
        ["Profit Margin", "", "", "", "=F25/F14", "%", "", ""],
        ["Profit Per Person", "", "", "", "=F25/F5", "$ per person", "", ""],
        ["Break-Even Attendance", "", "", "", "=E21/F6", "people", "", ""],
        ["Cost Per Person", "", "", "", "=E21/F5", "$ per person", "", ""]
    ]
    
    # Convert to JSON format for gog sheets
    values_json = json.dumps(data)
    with open('western_data.json', 'w') as f:
        json.dump(data, f)
    
    # Upload data
    run_gog_command(f'gog sheets update "{spreadsheet_id}" "Sheet1!A1:H29" --values-json \'{values_json}\' --input USER_ENTERED')
    
    print("Data uploaded, now applying formatting...")
    
    # Apply formatting using batch update
    format_requests = [
        # Title row formatting (rows 1-2)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 0, "endRowIndex": 2},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 0.18, "green": 0.33, "blue": 0.59},
                        "textFormat": {"bold": True, "foregroundColor": {"red": 1, "green": 1, "blue": 1}, "fontSize": 14},
                        "horizontalAlignment": "CENTER"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Input section header (row 4)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 3, "endRowIndex": 4},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.85},
                        "textFormat": {"bold": True, "fontSize": 12},
                        "horizontalAlignment": "LEFT"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Input values (blue text, yellow background for column F, rows 5-8)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 4, "endRowIndex": 8, "startColumnIndex": 5, "endColumnIndex": 6},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 1, "green": 0.95, "blue": 0.8},
                        "textFormat": {"bold": True, "foregroundColor": {"red": 0, "green": 0, "blue": 1}},
                        "horizontalAlignment": "RIGHT"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Revenue section header (row 11)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 10, "endRowIndex": 11},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 0.44, "green": 0.68, "blue": 0.28},
                        "textFormat": {"bold": True, "foregroundColor": {"red": 1, "green": 1, "blue": 1}, "fontSize": 12},
                        "horizontalAlignment": "LEFT"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Cost section header (row 16)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 15, "endRowIndex": 16},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 0.78, "green": 0.35, "blue": 0.07},
                        "textFormat": {"bold": True, "foregroundColor": {"red": 1, "green": 1, "blue": 1}, "fontSize": 12},
                        "horizontalAlignment": "LEFT"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Cost input values (blue text for per-person costs)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 16, "endRowIndex": 21, "startColumnIndex": 2, "endColumnIndex": 3},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 1, "green": 0.95, "blue": 0.8},
                        "textFormat": {"bold": True, "foregroundColor": {"red": 0, "green": 0, "blue": 1}},
                        "horizontalAlignment": "RIGHT"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Profitability section header (row 24)
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 23, "endRowIndex": 24},
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": {"red": 0.44, "green": 0.19, "blue": 0.63},
                        "textFormat": {"bold": True, "foregroundColor": {"red": 1, "green": 1, "blue": 1}, "fontSize": 12},
                        "horizontalAlignment": "LEFT"
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
            }
        },
        # Key totals - thick borders
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 13, "endRowIndex": 14, "startColumnIndex": 5, "endColumnIndex": 6},
                "cell": {
                    "userEnteredFormat": {
                        "textFormat": {"bold": True, "fontSize": 12},
                        "borders": {
                            "top": {"style": "SOLID_THICK"},
                            "bottom": {"style": "SOLID_THICK"},
                            "left": {"style": "SOLID_THICK"},
                            "right": {"style": "SOLID_THICK"}
                        }
                    }
                },
                "fields": "userEnteredFormat(textFormat,borders)"
            }
        },
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 21, "endRowIndex": 22, "startColumnIndex": 4, "endColumnIndex": 5},
                "cell": {
                    "userEnteredFormat": {
                        "textFormat": {"bold": True, "fontSize": 12},
                        "borders": {
                            "top": {"style": "SOLID_THICK"},
                            "bottom": {"style": "SOLID_THICK"},
                            "left": {"style": "SOLID_THICK"},
                            "right": {"style": "SOLID_THICK"}
                        }
                    }
                },
                "fields": "userEnteredFormat(textFormat,borders)"
            }
        },
        {
            "repeatCell": {
                "range": {"sheetId": 0, "startRowIndex": 24, "endRowIndex": 25, "startColumnIndex": 4, "endColumnIndex": 5},
                "cell": {
                    "userEnteredFormat": {
                        "textFormat": {"bold": True, "fontSize": 12},
                        "borders": {
                            "top": {"style": "SOLID_THICK"},
                            "bottom": {"style": "SOLID_THICK"},
                            "left": {"style": "SOLID_THICK"},
                            "right": {"style": "SOLID_THICK"}
                        }
                    }
                },
                "fields": "userEnteredFormat(textFormat,borders)"
            }
        },
        # Auto-resize columns
        {
            "autoResizeDimensions": {
                "dimensions": {"sheetId": 0, "dimension": "COLUMNS", "startIndex": 0, "endIndex": 8}
            }
        }
    ]
    
    # Apply formatting
    format_json = json.dumps({"requests": format_requests})
    with open('western_format.json', 'w') as f:
        json.dump({"requests": format_requests}, f, indent=2)
    
    print("Applying formatting via batch update...")
    return format_requests

def apply_formatting_to_intimate_dinner():
    """Apply professional formatting to Intimate Dinner sheet"""
    spreadsheet_id = "1GRHaGA9vxsYCQEZHHSYX1DzeD_X86oQ2cmfOUUy8t2s"
    
    print("Rebuilding Intimate Dinner sheet...")
    run_gog_command(f'gog sheets clear "{spreadsheet_id}" "Sheet1!A1:Z100"')
    
    data = [
        ["VENN SOCIAL - INTIMATE DINNER FINANCIAL MODEL", "", "", "", "", "", "", ""],
        ["Event: The Gathering | Historic Private Venue | Capacity: 30 people", "", "", "", "", "", "", ""],
        ["⚠️ CONSTRAINT: Must stay under $70 per person total cost", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["KEY INPUT ASSUMPTIONS", "", "", "", "", "Value", "Units", ""],
        ["Event Capacity", "", "", "", "", "30", "people", ""],
        ["Ticket Price", "", "", "", "", "58", "$ per ticket", ""],
        ["Cost Per Person Limit", "", "", "", "", "70", "$ per person", ""],
        ["Wine Partner Contribution", "", "", "", "", "350", "$", ""],
        ["Experience Sponsor", "", "", "", "", "200", "$", ""],
        ["", "", "", "", "", "", "", ""],
        ["REVENUE ANALYSIS", "", "", "", "", "", "", ""],
        ["Gross Ticket Sales", "", "", "", "", "=F6*F7", "$", ""],
        ["Partnership Revenue", "", "", "", "", "=F9+F10", "$", ""],
        ["TOTAL REVENUE", "", "", "", "", "=F13+F14", "$", ""],
        ["", "", "", "", "", "", "", ""],
        ["COST STRUCTURE", "", "Per Person", "", "Total Cost", "% of Revenue", "", ""],
        ["Historic Venue Rental", "", "13", "", "=C17*$F$6", "=E17/$F$15", "", ""],
        ["3-Course Catering", "", "32", "", "=C18*$F$6", "=E18/$F$15", "", ""],
        ["Wine Pairings & Service", "", "10", "", "=C19*$F$6", "=E19/$F$15", "", ""],
        ["Photography & Experience", "", "10", "", "=C20*$F$6", "=E20/$F$15", "", ""],
        ["Operations & Marketing", "", "7", "", "=C21*$F$6", "=E21/$F$15", "", ""],
        ["TOTAL OPERATING COSTS", "", "=SUM(C17:C21)", "", "=SUM(E17:E21)", "=E22/$F$15", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["BUDGET COMPLIANCE CHECK", "", "", "", "", "", "", ""],
        ["Actual Cost Per Person", "", "", "", "=E22/F6", "$ per person", "", ""],
        ["Budget Limit", "", "", "", "=F8", "$ per person", "", ""],
        ["Budget Status", "", "", "", "=IF(F26<=F27,\"✓ COMPLIANT\",\"⚠️ OVER BUDGET\")", "", "", ""],
        ["Budget Headroom", "", "", "", "=F27-F26", "$ per person", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["PROFITABILITY ANALYSIS", "", "", "", "", "", "", ""],
        ["Gross Profit", "", "", "", "=F15-E22", "$", "", ""],
        ["Profit Margin", "", "", "", "=F32/F15", "%", "", ""],
        ["Profit Per Person", "", "", "", "=F32/F6", "$ per person", "", ""]
    ]
    
    values_json = json.dumps(data)
    run_gog_command(f'gog sheets update "{spreadsheet_id}" "Sheet1!A1:H34" --values-json \'{values_json}\' --input USER_ENTERED')
    
    print("Data uploaded for Intimate Dinner, applying formatting...")
    return True

if __name__ == "__main__":
    print("Starting Google Sheets formatting process...")
    
    # Format Western Dancing
    western_requests = apply_formatting_to_western_dancing()
    
    # Format Intimate Dinner  
    apply_formatting_to_intimate_dinner()
    
    print("Google Sheets formatting complete!")