#!/usr/bin/env python3
"""
Migrate ALL of RELATIONSHIPS.md to Mission Control database via API
Handles both markdown tables and bullet-point vendor sections
"""
import re
import json
import subprocess
import sys

def post_to_api(endpoint, data):
    """POST data to Mission Control API"""
    cmd = [
        'curl', '-s', '-X', 'POST',
        f'http://localhost:3000{endpoint}',
        '-H', 'Content-Type: application/json',
        '-d', json.dumps(data)
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    try:
        return json.loads(result.stdout)
    except:
        return None

def extract_stars(line):
    """Extract star rating from '⭐⭐⭐⭐⭐' or '⭐⭐⭐'"""
    return line.count('⭐')

def parse_vendor_section(content):
    """Parse vendor sections with ** headings and bullet points"""
    vendors = []
    lines = content.split('\n')
    
    current_vendor = None
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Detect vendor header: **Vendor Name** ⭐⭐⭐
        if line.startswith('**') and '**' in line[2:] and ('⭐' in line or 'Contact:' in lines[i+1] if i+1 < len(lines) else False):
            # Save previous vendor
            if current_vendor:
                vendors.append(current_vendor)
            
            # Extract vendor name and stars
            name_end = line.find('**', 2)
            vendor_name = line[2:name_end].strip()
            stars = extract_stars(line)
            
            current_vendor = {
                'name': vendor_name,
                'stars': stars,
                'contact': '',
                'email': '',
                'phone': '',
                'quote': '',
                'notes': [],
                'status': '',
                'category': ''
            }
        
        # Parse bullet points for current vendor
        elif current_vendor and line.startswith('- **'):
            field_match = re.match(r'- \*\*([^:]+):\*\*\s*(.*)', line)
            if field_match:
                field_name = field_match.group(1).lower()
                field_value = field_match.group(2).strip()
                
                if 'contact' in field_name:
                    current_vendor['contact'] = field_value
                    # Extract email and phone
                    if '@' in field_value:
                        email_match = re.search(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', field_value)
                        if email_match:
                            current_vendor['email'] = email_match.group(1)
                    phone_match = re.search(r'[\(]?([0-9]{3})[\)]?[-\s\.]?([0-9]{3})[-\s\.]?([0-9]{4})', field_value)
                    if phone_match:
                        current_vendor['phone'] = f"{phone_match.group(1)}-{phone_match.group(2)}-{phone_match.group(3)}"
                
                elif 'quote' in field_name:
                    current_vendor['quote'] = field_value
                    # Extract cost
                    cost_match = re.search(r'\$([0-9,]+)', field_value)
                    if cost_match:
                        current_vendor['cost'] = float(cost_match.group(1).replace(',', ''))
                
                elif 'status' in field_name:
                    current_vendor['status'] = field_value
                
                elif 'category' in field_name or 'service' in field_name:
                    current_vendor['category'] = field_value
                
                elif 'notes' in field_name:
                    current_vendor['notes'].append(f"{field_name}: {field_value}")
                
                else:
                    current_vendor['notes'].append(f"{field_name}: {field_value}")
        
        i += 1
    
    # Save last vendor
    if current_vendor:
        vendors.append(current_vendor)
    
    return vendors

def categorize_vendor(vendor_name, category_text, notes):
    """Determine vendor category from context"""
    text = f"{vendor_name} {category_text} {' '.join(notes)}".lower()
    
    if any(word in text for word in ['bull', 'mechanical']):
        return 'entertainment'
    elif any(word in text for word in ['dj', 'music', 'beats']):
        return 'dj'
    elif any(word in text for word in ['cater', 'food', 'menu', 'buffet']):
        return 'catering'
    elif any(word in text for word in ['photo', 'camera', 'photography']):
        return 'photography'
    elif any(word in text for word in ['av', 'audio', 'visual', 'sound', 'light', 'production']):
        return 'av'
    elif any(word in text for word in ['yacht', 'boat', 'charter', 'cruise', 'fleet']):
        return 'charter'
    elif any(word in text for word in ['magic', 'entertainment', 'performer']):
        return 'entertainment'
    elif any(word in text for word in ['venue', 'space', 'room', 'hall']):
        return 'venue'
    else:
        return 'other'

def main():
    print("🚀 Full RELATIONSHIPS.md → Database migration\n")
    
    with open('/Users/vinnyvenn/.openclaw/workspace/RELATIONSHIPS.md', 'r') as f:
        content = f.read()
    
    stats = {'vendors': 0, 'partners': 0, 'venues': 0, 'skipped': 0, 'errors': 0}
    
    # Parse vendor sections
    print("📦 Parsing vendor sections...")
    vendors = parse_vendor_section(content)
    print(f"  Found {len(vendors)} vendor entries\n")
    
    # Migrate vendors
    print("💾 Migrating to database...")
    for vendor in vendors:
        # Determine type
        vendor_type = categorize_vendor(vendor['name'], vendor['category'], vendor['notes'])
        
        # Calculate reliability from stars (1-10 scale)
        reliability = min(10, (vendor['stars'] * 2)) if vendor['stars'] > 0 else 5
        
        # Check if it's actually a venue
        if vendor_type == 'venue':
            data = {
                'name': vendor['name'],
                'workedTogetherBefore': vendor['stars'] >= 4,
                'notes': ' | '.join([vendor['contact'], vendor['status']] + vendor['notes']),
                'tags': json.dumps(['from-relationships'])
            }
            result = post_to_api('/api/venues', data)
            if result:
                print(f"  🏢 {vendor['name']}")
                stats['venues'] += 1
            else:
                stats['errors'] += 1
        else:
            # It's a vendor
            data = {
                'name': vendor['name'],
                'category': vendor_type,
                'cost': vendor.get('cost'),
                'reliability': reliability,
                'workedTogetherBefore': vendor['stars'] >= 4,
                'notes': ' | '.join([vendor['contact'], vendor['quote'], vendor['status']] + vendor['notes']),
                'tags': json.dumps(['from-relationships', f'{vendor["stars"]}-star'])
            }
            
            result = post_to_api('/api/vendors', data)
            if result:
                icon = '⭐' * min(5, vendor['stars']) if vendor['stars'] > 0 else '📦'
                print(f"  {icon} {vendor['name']} ({vendor_type})")
                stats['vendors'] += 1
            else:
                stats['errors'] += 1
    
    # Summary
    print(f"\n📊 Migration Summary:")
    print(f"  Vendors: {stats['vendors']}")
    print(f"  Venues: {stats['venues']}")
    print(f"  Errors: {stats['errors']}")
    print(f"  Total: {stats['vendors'] + stats['venues']}")
    
    if stats['errors'] == 0:
        print("\n✅ Migration completed successfully!")
        return 0
    else:
        print(f"\n⚠️  Migration completed with {stats['errors']} errors")
        return 1

if __name__ == '__main__':
    sys.exit(main())
