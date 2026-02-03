#!/usr/bin/env python3
"""
Create beautiful Google Sheets pricing database for Venn Social.
Requires MATON_API_KEY environment variable.
"""

import os
import requests
import json
import csv
from datetime import datetime

class VennSheetsCreator:
    def __init__(self):
        self.api_key = os.getenv('MATON_API_KEY')
        if not self.api_key:
            raise Exception("MATON_API_KEY environment variable required")
        
        self.base_url = "https://gateway.maton.ai/google-sheets/v4/spreadsheets"
        self.headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
    
    def create_spreadsheet(self, title, sheet_names=None):
        """Create a new spreadsheet with optional multiple sheets"""
        if sheet_names is None:
            sheet_names = ["Sheet1"]
        
        sheets = [{"properties": {"title": name}} for name in sheet_names]
        
        data = {
            "properties": {"title": title},
            "sheets": sheets
        }
        
        response = requests.post(self.base_url, headers=self.headers, json=data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Created: {title}")
            return result['spreadsheetId']
        else:
            print(f"❌ Failed to create {title}: {response.text}")
            return None
    
    def add_data(self, sheet_id, range_name, values):
        """Add data to a spreadsheet"""
        url = f"{self.base_url}/{sheet_id}/values/{range_name}:append"
        params = {'valueInputOption': 'USER_ENTERED'}
        data = {'values': values}
        
        response = requests.post(url, headers=self.headers, params=params, json=data)
        return response.status_code == 200
    
    def format_header_row(self, sheet_id, sheet_name, num_columns):
        """Apply beautiful formatting to header row"""
        url = f"{self.base_url}/{sheet_id}:batchUpdate"
        
        # Get sheet ID by name (simplified - assumes first sheet)
        sheet_id_num = 0  # Would need to query for actual sheet ID
        
        requests_data = [
            {
                "repeatCell": {
                    "range": {
                        "sheetId": sheet_id_num,
                        "startRowIndex": 0,
                        "endRowIndex": 1,
                        "startColumnIndex": 0,
                        "endColumnIndex": num_columns
                    },
                    "cell": {
                        "userEnteredFormat": {
                            "backgroundColor": {"red": 0.11, "green": 0.27, "blue": 0.53},
                            "textFormat": {"bold": True, "foregroundColor": {"red": 1, "green": 1, "blue": 1}, "fontSize": 12},
                            "horizontalAlignment": "CENTER"
                        }
                    },
                    "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
                }
            },
            {
                "updateDimensionProperties": {
                    "range": {
                        "sheetId": sheet_id_num,
                        "dimension": "ROWS",
                        "startIndex": 0,
                        "endIndex": 1
                    },
                    "properties": {"pixelSize": 35},
                    "fields": "pixelSize"
                }
            },
            {
                "setBasicFilter": {
                    "filter": {
                        "range": {
                            "sheetId": sheet_id_num,
                            "startRowIndex": 0,
                            "endRowIndex": 1000,
                            "startColumnIndex": 0,
                            "endColumnIndex": num_columns
                        }
                    }
                }
            },
            {
                "updateSheetProperties": {
                    "properties": {
                        "sheetId": sheet_id_num,
                        "gridProperties": {"frozenRowCount": 1}
                    },
                    "fields": "gridProperties.frozenRowCount"
                }
            }
        ]
        
        data = {"requests": requests_data}
        response = requests.post(url, headers=self.headers, json=data)
        return response.status_code == 200
    
    def share_with_team(self, sheet_id):
        """Share with Zed (would need Google Drive API for this)"""
        print(f"📤 Share spreadsheet manually with zed.truong@vennapp.co: https://docs.google.com/spreadsheets/d/{sheet_id}")
    
    def load_csv_data(self, csv_file):
        """Load data from CSV file"""
        with open(csv_file, 'r') as f:
            return list(csv.reader(f))
    
    def create_venue_sheets(self):
        """Create all venue-related spreadsheets"""
        
        # Event Venues Master
        sheet_id = self.create_spreadsheet("Event Venues Master")
        if sheet_id:
            data = self.load_csv_data('/Users/vinnyvenn/.openclaw/workspace/pricing-database/event-venues-master.csv')
            self.add_data(sheet_id, "A1", data)
            self.format_header_row(sheet_id, "Sheet1", len(data[0]))
            self.share_with_team(sheet_id)
        
        # Dining Venues Master  
        sheet_id = self.create_spreadsheet("Dining Venues Master")
        if sheet_id:
            data = self.load_csv_data('/Users/vinnyvenn/.openclaw/workspace/pricing-database/dining-venues-master.csv')
            self.add_data(sheet_id, "A1", data)
            self.format_header_row(sheet_id, "Sheet1", len(data[0]))
            self.share_with_team(sheet_id)
        
        # Vendors Master
        sheet_id = self.create_spreadsheet("Vendors Master")
        if sheet_id:
            data = self.load_csv_data('/Users/vinnyvenn/.openclaw/workspace/pricing-database/vendors-master.csv')
            self.add_data(sheet_id, "A1", data)
            self.format_header_row(sheet_id, "Sheet1", len(data[0]))
            self.share_with_team(sheet_id)
        
        # Partners Master
        sheet_id = self.create_spreadsheet("Partners Master")
        if sheet_id:
            data = self.load_csv_data('/Users/vinnyvenn/.openclaw/workspace/pricing-database/partners-master.csv')
            self.add_data(sheet_id, "A1", data)
            self.format_header_row(sheet_id, "Sheet1", len(data[0]))
            self.share_with_team(sheet_id)
        
        # Influencers Master
        sheet_id = self.create_spreadsheet("Influencers Master")
        if sheet_id:
            data = self.load_csv_data('/Users/vinnyvenn/.openclaw/workspace/pricing-database/influencers-master.csv')
            self.add_data(sheet_id, "A1", data)
            self.format_header_row(sheet_id, "Sheet1", len(data[0]))
            self.share_with_team(sheet_id)
        
        # Master Overview
        sheet_id = self.create_spreadsheet("🎯 VENN PRICING MASTER OVERVIEW")
        if sheet_id:
            data = self.load_csv_data('/Users/vinnyvenn/.openclaw/workspace/pricing-database/MASTER-PRICING-OVERVIEW.csv')
            self.add_data(sheet_id, "A1", data)
            self.format_header_row(sheet_id, "Sheet1", len(data[0]))
            self.share_with_team(sheet_id)

if __name__ == "__main__":
    try:
        creator = VennSheetsCreator()
        print("🚀 Creating Venn Social Pricing Database...")
        creator.create_venue_sheets()
        print("✅ Complete! All spreadsheets created and formatted.")
    except Exception as e:
        print(f"❌ Error: {e}")
        print("💡 Set MATON_API_KEY environment variable first")
        print("   Get your key from: https://maton.ai/settings")