#!/usr/bin/env python3
"""
Intelligent parser for venue/vendor pricing emails.
Extracts key pricing info and adds to our database.
"""

import json
import re
import csv
from datetime import datetime
from pathlib import Path

class PricingEmailParser:
    def __init__(self):
        self.db_path = Path(__file__).parent / "venue-pricing.json"
        self.csv_path = Path(__file__).parent / "venue-pricing.csv"
        
    def load_database(self):
        """Load existing database or create new one"""
        try:
            with open(self.db_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"venues": {}, "vendors": {}, "last_updated": datetime.now().strftime("%Y-%m-%d")}
    
    def save_database(self, db):
        """Save database and update CSV"""
        db["last_updated"] = datetime.now().strftime("%Y-%m-%d")
        
        with open(self.db_path, 'w') as f:
            json.dump(db, f, indent=2)
        
        self.export_to_csv(db)
        self.update_master_overview(db)
    
    def update_master_overview(self, db):
        """Update the master pricing overview CSV"""
        overview_path = Path(__file__).parent.parent / "pricing-database" / "MASTER-PRICING-OVERVIEW.csv"
        overview_path.parent.mkdir(exist_ok=True)
        
        with open(overview_path, 'w', newline='') as f:
            writer = csv.writer(f)
            
            # Header
            writer.writerow([
                'Name', 'Type', 'Category', 'Contact', 'Phone', 'Email', 
                'Key Pricing', 'Capacity', 'Date Quoted', 'Venn Rating', 'Status', 'Quick Notes'
            ])
            
            # Venues
            for name, venue in db.get('venues', {}).items():
                contact = venue.get('contact', {})
                pricing = venue.get('pricing', {})
                capacity = venue.get('capacity', {})
                
                key_pricing = []
                if pricing.get('base_rental'):
                    key_pricing.append(f"${pricing['base_rental']:.0f} base")
                if pricing.get('per_person'):
                    key_pricing.append(f"${pricing['per_person']:.0f}pp")
                if pricing.get('minimum_spend'):
                    key_pricing.append(f"${pricing['minimum_spend']:.0f} min")
                
                cap_str = []
                if capacity.get('max_seated'):
                    cap_str.append(f"{capacity['max_seated']} seated")
                if capacity.get('max_standing'):
                    cap_str.append(f"{capacity['max_standing']} standing")
                
                writer.writerow([
                    name, 'Venue', venue.get('category', 'Event Space'),
                    contact.get('contact_person', ''), contact.get('phone', ''),
                    contact.get('email', ''), ' + '.join(key_pricing),
                    ' / '.join(cap_str), pricing.get('date_quoted', ''),
                    venue.get('venn_rating', ''), venue.get('booking_status', ''),
                    venue.get('notes', '')
                ])
    
    def export_to_csv(self, db):
        """Export to CSV for easy Google Sheets import"""
        with open(self.csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            
            # Header
            writer.writerow([
                'Type', 'Name', 'Address', 'Phone', 'Email', 'Website',
                'Contact Person', 'Max Seated', 'Max Standing', 'Base Rental',
                'Per Person', 'Minimum Spend', 'Deposit', 'Date Quoted',
                'Amenities', 'Restrictions', 'Notes', 'Venn Rating', 'Status'
            ])
            
            # Venues
            for name, venue in db.get('venues', {}).items():
                contact = venue.get('contact', {})
                capacity = venue.get('capacity', {})
                pricing = venue.get('pricing', {})
                
                writer.writerow([
                    'Venue', name, venue.get('address', ''),
                    contact.get('phone', ''), contact.get('email', ''), 
                    contact.get('website', ''), contact.get('contact_person', ''),
                    capacity.get('max_seated', ''), capacity.get('max_standing', ''),
                    pricing.get('base_rental', ''), pricing.get('per_person', ''),
                    pricing.get('minimum_spend', ''), pricing.get('deposit_required', ''),
                    pricing.get('date_quoted', ''),
                    '; '.join(venue.get('amenities', [])),
                    '; '.join(venue.get('restrictions', [])),
                    venue.get('notes', ''), venue.get('venn_rating', ''),
                    venue.get('booking_status', '')
                ])
            
            # Vendors  
            for name, vendor in db.get('vendors', {}).items():
                contact = vendor.get('contact', {})
                pricing = vendor.get('pricing', {})
                
                writer.writerow([
                    'Vendor', name, vendor.get('address', ''),
                    contact.get('phone', ''), contact.get('email', ''), 
                    contact.get('website', ''), contact.get('contact_person', ''),
                    '', '',  # No capacity for vendors
                    pricing.get('base_rate', ''), pricing.get('per_person', ''),
                    pricing.get('minimum_order', ''), pricing.get('deposit_required', ''),
                    pricing.get('date_quoted', ''),
                    '; '.join(vendor.get('services', [])),
                    '; '.join(vendor.get('restrictions', [])),
                    vendor.get('notes', ''), vendor.get('venn_rating', ''),
                    vendor.get('booking_status', '')
                ])
    
    def extract_pricing(self, email_text):
        """Extract pricing info from email text"""
        pricing = {}
        
        # Look for dollar amounts
        dollar_patterns = [
            r'\$(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            r'(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)\s*dollars?',
            r'USD\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
        ]
        
        amounts = []
        for pattern in dollar_patterns:
            amounts.extend(re.findall(pattern, email_text, re.IGNORECASE))
        
        # Clean and convert amounts
        clean_amounts = []
        for amount in amounts:
            clean = amount.replace(',', '').replace('$', '')
            try:
                clean_amounts.append(float(clean))
            except:
                continue
        
        # Look for context around amounts
        if 'rental' in email_text.lower() and clean_amounts:
            pricing['base_rental'] = min(clean_amounts)
        
        if 'per person' in email_text.lower():
            per_person_matches = re.findall(r'\$(\d+(?:\.\d{2})?)\s*per\s*person', email_text, re.IGNORECASE)
            if per_person_matches:
                pricing['per_person'] = float(per_person_matches[0])
        
        if 'minimum' in email_text.lower() and clean_amounts:
            pricing['minimum_spend'] = max(clean_amounts)
        
        if 'deposit' in email_text.lower():
            deposit_matches = re.findall(r'deposit.*?\$(\d+(?:,\d{3})*(?:\.\d{2})?)', email_text, re.IGNORECASE)
            if deposit_matches:
                pricing['deposit_required'] = float(deposit_matches[0].replace(',', ''))
        
        return pricing
    
    def extract_contact_info(self, email_text):
        """Extract contact information"""
        contact = {}
        
        # Phone numbers
        phone_pattern = r'(\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})'
        phones = re.findall(phone_pattern, email_text)
        if phones:
            contact['phone'] = phones[0]
        
        # Email addresses
        email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
        emails = re.findall(email_pattern, email_text)
        if emails:
            contact['email'] = emails[0]
        
        # Websites
        url_pattern = r'https?://[^\s<>"{}|\\^`\[\]]+'
        urls = re.findall(url_pattern, email_text)
        if urls:
            contact['website'] = urls[0]
        
        return contact
    
    def parse_email(self, subject, sender, email_body, venue_name=None):
        """Main parsing function"""
        db = self.load_database()
        
        # Auto-detect venue name from subject or ask user
        if not venue_name:
            venue_name = input(f"Venue name for email '{subject}' from {sender}: ").strip()
        
        # Extract data
        pricing = self.extract_pricing(email_body)
        contact = self.extract_contact_info(email_body)
        
        # Add date quoted
        pricing['date_quoted'] = datetime.now().strftime("%Y-%m-%d")
        
        # Create or update venue entry
        if venue_name not in db['venues']:
            db['venues'][venue_name] = {
                'name': venue_name,
                'contact': contact,
                'pricing': pricing,
                'booking_status': 'quoted',
                'notes': f"Email from {sender}"
            }
        else:
            # Update existing entry
            db['venues'][venue_name]['contact'].update(contact)
            db['venues'][venue_name]['pricing'].update(pricing)
            db['venues'][venue_name]['booking_status'] = 'quoted'
            
        print(f"Added pricing for {venue_name}:")
        print(f"  Contact: {contact}")
        print(f"  Pricing: {pricing}")
        
        self.save_database(db)
        return db['venues'][venue_name]

if __name__ == "__main__":
    import sys
    
    parser = PricingEmailParser()
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "export":
            db = parser.load_database()
            parser.export_to_csv(db)
            print(f"Exported to {parser.csv_path}")
        elif sys.argv[1] == "test":
            # Test with sample data
            sample_email = """
            Hi Vinny,
            
            Thanks for your inquiry about our venue for your line dancing event.
            
            Our pricing for a 200-person event would be:
            - Venue rental: $3,500 
            - Per person catering: $45 per person minimum
            - Minimum spend: $12,000
            - Deposit required: $1,750 (50% of rental)
            
            Contact me at events@logcabin.com or 415-555-0123
            Website: www.logcabinvenue.com
            
            Best,
            Sarah Johnson
            Event Coordinator
            """
            
            result = parser.parse_email(
                "Log Cabin Pricing Quote", 
                "events@logcabin.com",
                sample_email,
                "Log Cabin at the Presidio"
            )
            print("\nTest completed!")
    else:
        print("Usage: python parse-pricing-email.py [export|test]")
        print("  export - Export database to CSV")
        print("  test   - Test with sample data")