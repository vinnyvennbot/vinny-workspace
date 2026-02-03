#!/usr/bin/env python3
"""
Create beautiful Google Sheets pricing database for Venn Social using gog CLI.
Actually creates the sheets and populates them with data.
"""

import subprocess
import json
import csv
import os
from pathlib import Path

class VennSheetsCreatorGog:
    def __init__(self):
        # Check if gog is available and authenticated
        try:
            result = subprocess.run(['gog', 'auth', 'list'], capture_output=True, text=True, check=True)
            print("✅ gog CLI is authenticated and ready")
        except subprocess.CalledProcessError as e:
            raise Exception(f"gog CLI authentication failed. Run: gog auth list\nError: {e.stderr}")
    
    def run_gog(self, command_list, check_result=True):
        """Run gog command and return result"""
        try:
            result = subprocess.run(['gog'] + command_list, capture_output=True, text=True, check=check_result)
            if check_result:
                return result.stdout.strip()
            return result
        except subprocess.CalledProcessError as e:
            if check_result:
                print(f"❌ gog command failed: {' '.join(command_list)}")
                print(f"Error: {e.stderr}")
                return None
            return e
    
    def create_spreadsheet(self, title):
        """Create a new Google Sheets spreadsheet"""
        print(f"📊 Creating: {title}")
        
        # Create spreadsheet
        result = self.run_gog(['sheets', 'create', title, '--json'])
        if result:
            try:
                sheet_data = json.loads(result)
                sheet_id = sheet_data.get('spreadsheetId')
                sheet_url = sheet_data.get('spreadsheetUrl', f"https://docs.google.com/spreadsheets/d/{sheet_id}")
                print(f"✅ Created: {title}")
                print(f"   ID: {sheet_id}")
                print(f"   URL: {sheet_url}")
                return sheet_id, sheet_url
            except json.JSONDecodeError:
                print(f"❌ Failed to parse response for {title}")
                return None, None
        return None, None
    
    def load_csv_to_values(self, csv_file):
        """Convert CSV file to values array for Google Sheets"""
        values = []
        with open(csv_file, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                values.append(row)
        return values
    
    def populate_sheet(self, sheet_id, csv_file, title):
        """Populate sheet with CSV data"""
        if not os.path.exists(csv_file):
            print(f"⚠️  CSV file not found: {csv_file}")
            return False
        
        print(f"📝 Populating {title} with data...")
        
        # Load CSV data
        values = self.load_csv_to_values(csv_file)
        if not values:
            print(f"⚠️  No data in {csv_file}")
            return False
        
        # Convert to JSON format for gog
        values_json = json.dumps(values)
        
        # Update the sheet with data
        range_name = f"A1:Z{len(values)}"  # Dynamic range based on data
        result = self.run_gog([
            'sheets', 'update', sheet_id, range_name,
            '--values-json', values_json,
            '--input', 'USER_ENTERED'
        ], check_result=False)
        
        if result.returncode == 0:
            print(f"✅ Data added to {title}")
            return True
        else:
            print(f"❌ Failed to add data to {title}: {result.stderr}")
            return False
    
    def format_headers(self, sheet_id, num_columns, title):
        """Apply beautiful formatting to header row"""
        print(f"🎨 Formatting headers for {title}...")
        
        # Format header row - blue background, white text, bold
        header_range = f"A1:{chr(64 + num_columns)}1"  # A1:X1 etc based on columns
        
        result = self.run_gog([
            'sheets', 'format', sheet_id, header_range,
            '--background-color', '#1c4587',
            '--text-color', 'white',
            '--bold'
        ], check_result=False)
        
        if result.returncode == 0:
            print(f"✅ Headers formatted for {title}")
        else:
            print(f"⚠️  Header formatting may have failed for {title}")
    
    def share_with_team(self, sheet_id, title):
        """Share with Zed - using Drive API via gog"""
        print(f"📤 Sharing {title} with team...")
        
        # Note: gog might not have direct sharing commands
        # This would need to be done manually or via Drive API
        sheet_url = f"https://docs.google.com/spreadsheets/d/{sheet_id}"
        print(f"   📋 Share manually: {sheet_url}")
        print(f"   👤 Add zed.truong@vennapp.co with edit access")
    
    def create_all_sheets(self):
        """Create all pricing database sheets"""
        base_path = Path('/Users/vinnyvenn/.openclaw/workspace/pricing-database')
        
        sheets_to_create = [
            {
                'title': '🎯 VENN PRICING MASTER OVERVIEW',
                'csv_file': base_path / 'MASTER-PRICING-OVERVIEW.csv',
                'description': 'Main dashboard with all vendors at a glance'
            },
            {
                'title': 'Event Venues Master',
                'csv_file': base_path / 'event-venues-master.csv', 
                'description': 'Complete event venues database'
            },
            {
                'title': 'Dining Venues Master',
                'csv_file': base_path / 'dining-venues-master.csv',
                'description': 'Restaurant and dining venue pricing'
            },
            {
                'title': 'Vendors Master',
                'csv_file': base_path / 'vendors-master.csv',
                'description': 'All service providers and vendors'
            },
            {
                'title': 'Partners Master', 
                'csv_file': base_path / 'partners-master.csv',
                'description': 'Sponsors and partnership opportunities'
            },
            {
                'title': 'Influencers Master',
                'csv_file': base_path / 'influencers-master.csv',
                'description': 'Content creators and influencer pricing'
            }
        ]
        
        print("🚀 Creating Venn Social Pricing Database with gog...")
        print("="*60)
        
        created_sheets = []
        
        for sheet in sheets_to_create:
            print(f"\n🔄 Processing: {sheet['title']}")
            
            # Create the sheet
            sheet_id, sheet_url = self.create_spreadsheet(sheet['title'])
            if not sheet_id:
                continue
            
            # Populate with data
            if self.populate_sheet(sheet_id, sheet['csv_file'], sheet['title']):
                # Count columns for formatting
                if os.path.exists(sheet['csv_file']):
                    with open(sheet['csv_file'], 'r') as f:
                        first_row = next(csv.reader(f))
                        num_columns = len(first_row)
                        self.format_headers(sheet_id, num_columns, sheet['title'])
                
                # Share with team
                self.share_with_team(sheet_id, sheet['title'])
                
                created_sheets.append({
                    'title': sheet['title'],
                    'id': sheet_id,
                    'url': sheet_url,
                    'description': sheet['description']
                })
        
        print(f"\n🎉 COMPLETED! Created {len(created_sheets)} spreadsheets")
        print("="*60)
        
        for sheet in created_sheets:
            print(f"\n📊 {sheet['title']}")
            print(f"   🔗 {sheet['url']}")
            print(f"   📝 {sheet['description']}")
        
        print(f"\n📋 Next Steps:")
        print(f"   1. Manually share each sheet with zed.truong@vennapp.co")
        print(f"   2. Set up filters and freeze panes if needed")
        print(f"   3. Test the email parsing integration")
        
        return created_sheets

if __name__ == "__main__":
    try:
        creator = VennSheetsCreatorGog()
        sheets = creator.create_all_sheets()
        
        print(f"\n✅ Database creation complete!")
        print(f"🎯 Ready to process pricing emails and auto-update sheets")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print(f"\n🔧 Troubleshooting:")
        print(f"   1. Check gog authentication: gog auth list")
        print(f"   2. Verify CSV files exist in pricing-database/")
        print(f"   3. Ensure internet connection for Google APIs")