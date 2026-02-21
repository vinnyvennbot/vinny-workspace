#!/usr/bin/env python3
"""
Migrate RELATIONSHIPS.md to Mission Control database via API
"""
import re
import json
import subprocess
import sys

def parse_markdown_table(content, start_marker):
    """Extract rows from a markdown table"""
    lines = content.split('\n')
    in_table = False
    headers = []
    rows = []
    
    for i, line in enumerate(lines):
        if start_marker in line:
            in_table = True
            # Next line should be headers
            if i + 1 < len(lines):
                header_line = lines[i + 1]
                if '|' in header_line:
                    headers = [h.strip() for h in header_line.split('|') if h.strip()]
            continue
        
        if in_table:
            if line.strip().startswith('|---'):
                continue
            if line.strip() == '' or not line.strip().startswith('|'):
                break
            
            parts = [p.strip() for p in line.split('|') if p.strip()]
            if parts:
                rows.append(parts)
    
    return headers, rows

def extract_contact_info(contact_cell):
    """Parse contact info: 'Name · email · phone' or 'email' or 'name · email'"""
    parts = contact_cell.split('·')
    name = None
    email = None
    phone = None
    
    for part in parts:
        part = part.strip()
        if '@' in part:
            email = part
        elif any(char.isdigit() for char in part):
            phone = part
        elif part:
            name = part
    
    return name, email, phone

def parse_cost(notes):
    """Extract cost from notes like '$1,400' or '$3,500'"""
    match = re.search(r'\$([0-9,]+)', notes)
    if match:
        return float(match.group(1).replace(',', ''))
    return None

def category_to_vendor_type(category):
    """Map markdown category to database category"""
    mapping = {
        'FPV/Drone video & editing': 'photography',
        'Photo booth': 'photography',
        'Entertainment': 'entertainment',
        'DJ': 'dj',
        'Catering': 'catering',
        'Photography': 'photography',
        'AV': 'av',
        'AV / Sound': 'av',
        'Mechanical Bull': 'entertainment',
        'Charter / Boat': 'charter',
        'Lighting': 'av',
        'Production': 'av',
    }
    for key, value in mapping.items():
        if key.lower() in category.lower():
            return value
    return 'other'

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
        print(f"ERROR posting to {endpoint}: {result.stderr}")
        return None
    try:
        return json.loads(result.stdout)
    except:
        print(f"WARNING: Could not parse response from {endpoint}")
        return None

def main():
    print("🚀 Starting RELATIONSHIPS.md → Database migration\n")
    
    # Read RELATIONSHIPS.md
    with open('/Users/vinnyvenn/.openclaw/workspace/RELATIONSHIPS.md', 'r') as f:
        content = f.read()
    
    stats = {
        'vendors': 0,
        'partners': 0,
        'venues': 0,
        'errors': 0
    }
    
    # Parse Service Vendors
    print("📦 Migrating Service Vendors...")
    headers, rows = parse_markdown_table(content, '### Service Vendors (Hired/Used Directly)')
    for row in rows:
        if len(row) >= 4:
            vendor_name = row[0]
            category = row[1]
            contact = row[2]
            notes = row[3]
            
            contact_name, email, phone = extract_contact_info(contact)
            cost = parse_cost(notes)
            vendor_type = category_to_vendor_type(category)
            
            data = {
                'name': vendor_name,
                'category': vendor_type,
                'cost': cost,
                'reliability': 8,  # Default high for preferred vendors
                'workedTogetherBefore': True,
                'notes': notes,
                'tags': json.dumps(['preferred', 'past-work'])
            }
            
            result = post_to_api('/api/vendors', data)
            if result:
                print(f"  ✓ {vendor_name} ({vendor_type})")
                stats['vendors'] += 1
            else:
                print(f"  ✗ {vendor_name} FAILED")
                stats['errors'] += 1
    
    # Parse Sponsors & Brand Partners
    print("\n🤝 Migrating Sponsors & Brand Partners...")
    headers, rows = parse_markdown_table(content, '### Sponsors & Brand Partners')
    for row in rows:
        if len(row) >= 4:
            partner_name = row[0]
            category = row[1]
            contact = row[2]
            last_event = row[3]
            
            contact_name, email, phone = extract_contact_info(contact)
            
            data = {
                'name': partner_name,
                'partnerType': 'sponsor',
                'category': 'community',  # Can refine based on category text
                'channel': 'email',
                'workedTogetherBefore': True,
                'notes': f"{category}. Last event: {last_event}",
                'tags': json.dumps(['sponsor', 'past-work'])
            }
            
            result = post_to_api('/api/partners', data)
            if result:
                print(f"  ✓ {partner_name}")
                stats['partners'] += 1
            else:
                print(f"  ✗ {partner_name} FAILED")
                stats['errors'] += 1
    
    # Parse Venue Partners
    print("\n🏢 Migrating Venue Partners...")
    headers, rows = parse_markdown_table(content, '### Venue Partners')
    for row in rows:
        if len(row) >= 4:
            venue_name = row[0]
            category = row[1]
            contact = row[2]
            last_event = row[3]
            
            contact_name, email, phone = extract_contact_info(contact)
            
            data = {
                'name': venue_name,
                'workedTogetherBefore': True,
                'notes': f"{category}. Last event: {last_event}. Contact: {contact}",
                'tags': json.dumps(['partner', 'past-work'])
            }
            
            result = post_to_api('/api/venues', data)
            if result:
                print(f"  ✓ {venue_name}")
                stats['venues'] += 1
            else:
                print(f"  ✗ {venue_name} FAILED")
                stats['errors'] += 1
    
    # Parse Creator Partners
    print("\n✨ Migrating Creator Partners...")
    headers, rows = parse_markdown_table(content, '### Creator Partners')
    for row in rows:
        if len(row) >= 4:
            creator_name = row[0]
            category = row[1]
            contact = row[2]
            last_event = row[3]
            
            data = {
                'name': creator_name,
                'partnerType': 'marketing',
                'category': 'media',
                'channel': 'instagram' if 'IG' in category or '@' in contact else 'email',
                'workedTogetherBefore': True,
                'notes': f"{category}. Last event: {last_event}. Contact: {contact}",
                'tags': json.dumps(['creator', 'content', 'past-work'])
            }
            
            result = post_to_api('/api/partners', data)
            if result:
                print(f"  ✓ {creator_name}")
                stats['partners'] += 1
            else:
                print(f"  ✗ {creator_name} FAILED")
                stats['errors'] += 1
    
    # Summary
    print(f"\n📊 Migration Summary:")
    print(f"  Vendors: {stats['vendors']}")
    print(f"  Partners: {stats['partners']}")
    print(f"  Venues: {stats['venues']}")
    print(f"  Errors: {stats['errors']}")
    print(f"  Total: {stats['vendors'] + stats['partners'] + stats['venues']}")
    
    if stats['errors'] == 0:
        print("\n✅ Migration completed successfully!")
        return 0
    else:
        print(f"\n⚠️  Migration completed with {stats['errors']} errors")
        return 1

if __name__ == '__main__':
    sys.exit(main())
