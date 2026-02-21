#!/usr/bin/env python3
"""
Comprehensive RELATIONSHIPS.md migration with validation
"""
import re
import json
import subprocess
import sys
from collections import defaultdict

# Valid categories
VENDOR_CATEGORIES = {
    'dj', 'catering', 'photography', 'av', 'entertainment', 
    'mechanical_bull', 'charter', 'decor', 'bar', 'other'
}

def extract_email(text):
    """Extract email address from text"""
    match = re.search(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', text)
    return match.group(1) if match else None

def extract_phone(text):
    """Extract phone number from text"""
    # Various phone formats
    patterns = [
        r'\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})',  # (415) 123-4567
        r'(\d{3})[-.\s](\d{3})[-.\s](\d{4})',          # 415-123-4567
        r'\+?1?[-.\s]?\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})',  # +1-415-123-4567
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            groups = match.groups()
            return f"({groups[0]}) {groups[1]}-{groups[2]}"
    return None

def extract_cost(text):
    """Extract cost from text like '$1,400' or '$3,500'"""
    match = re.search(r'\$([0-9,]+(?:\.[0-9]{2})?)', text)
    if match:
        return float(match.group(1).replace(',', ''))
    return None

def categorize_vendor(name, context):
    """Determine vendor category from name and context"""
    text = f"{name} {context}".lower()
    
    if any(w in text for w in ['bull', 'mechanical']):
        return 'mechanical_bull'
    elif any(w in text for w in ['dj', 'music', 'beats', 'jazz', 'orchestra', 'band']):
        return 'dj'
    elif any(w in text for w in ['cater', 'food', 'menu', 'buffet', 'culinary']):
        return 'catering'
    elif any(w in text for w in ['photo', 'camera', 'photography', 'photographer']):
        return 'photography'
    elif any(w in text for w in ['av', 'audio', 'visual', 'sound', 'light', 'production', 'stage']):
        return 'av'
    elif any(w in text for w in ['yacht', 'boat', 'charter', 'cruise', 'fleet', 'vessel']):
        return 'charter'
    elif any(w in text for w in ['magic', 'entertai', 'performer', 'casino', 'dance']):
        return 'entertainment'
    elif any(w in text for w in ['decor', 'floral', 'design']):
        return 'decor'
    elif any(w in text for w in ['bar', 'bartend', 'beverage', 'alcohol']):
        return 'bar'
    else:
        return 'other'

def parse_relationships_file(filepath):
    """Parse RELATIONSHIPS.md and extract all vendors"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    vendors = []
    lines = content.split('\n')
    
    current_vendor = None
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # Detect vendor header: **Vendor Name** ⭐⭐⭐
        if line.startswith('**') and '**' in line[2:]:
            # Save previous vendor
            if current_vendor and current_vendor['name']:
                vendors.append(current_vendor)
            
            # Extract vendor name
            name_end = line.find('**', 2)
            vendor_name = line[2:name_end].strip()
            stars = line.count('⭐')
            
            current_vendor = {
                'name': vendor_name,
                'stars': stars,
                'contactName': '',
                'email': '',
                'phone': '',
                'cost': None,
                'notes_parts': [],
                'category_hint': '',
                'status': '',
            }
        
        # Parse bullet points
        elif current_vendor and line.startswith('- **'):
            field_match = re.match(r'- \*\*([^:]+):\*\*\s*(.*)', line)
            if field_match:
                field_name = field_match.group(1).strip().lower()
                field_value = field_match.group(2).strip()
                
                if 'contact' in field_name:
                    # Parse contact line
                    current_vendor['contactName'] = field_value.split(',')[0].split('·')[0].strip()
                    email = extract_email(field_value)
                    if email:
                        current_vendor['email'] = email
                    phone = extract_phone(field_value)
                    if phone:
                        current_vendor['phone'] = phone
                
                elif 'quote' in field_name or 'pricing' in field_name or 'cost' in field_name:
                    cost = extract_cost(field_value)
                    if cost:
                        current_vendor['cost'] = cost
                    current_vendor['notes_parts'].append(f"{field_name}: {field_value}")
                
                elif 'service' in field_name or 'category' in field_name:
                    current_vendor['category_hint'] += ' ' + field_value
                
                elif 'status' in field_name:
                    current_vendor['status'] = field_value
                
                else:
                    # Add to notes
                    current_vendor['notes_parts'].append(f"{field_name}: {field_value}")
        
        i += 1
    
    # Save last vendor
    if current_vendor and current_vendor['name']:
        vendors.append(current_vendor)
    
    return vendors

def post_vendor(vendor_data):
    """POST vendor to API"""
    cmd = [
        'curl', '-s', '-X', 'POST',
        'http://localhost:3000/api/vendors',
        '-H', 'Content-Type: application/json',
        '-d', json.dumps(vendor_data)
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None, result.stderr
    try:
        return json.loads(result.stdout), None
    except:
        return None, f"Invalid JSON response: {result.stdout[:200]}"

def main():
    print("🔍 Comprehensive RELATIONSHIPS.md Migration v2\n")
    
    # Parse file
    print("📖 Parsing RELATIONSHIPS.md.backup...")
    vendors = parse_relationships_file('/Users/vinnyvenn/.openclaw/workspace/RELATIONSHIPS.md.backup')
    print(f"  Found {len(vendors)} vendor entries\n")
    
    # Check for duplicates
    print("🔎 Checking for duplicates...")
    name_counts = defaultdict(int)
    for v in vendors:
        name_counts[v['name'].lower()] += 1
    
    duplicates = {name: count for name, count in name_counts.items() if count > 1}
    if duplicates:
        print(f"  ⚠️  Found {len(duplicates)} duplicate names:")
        for name, count in duplicates.items():
            print(f"    - {name}: {count} entries")
        print()
    
    # Process and migrate
    print("💾 Migrating vendors...\n")
    stats = {'success': 0, 'skipped': 0, 'errors': 0}
    error_log = []
    
    seen_names = set()
    
    for vendor in vendors:
        # Skip duplicates (keep first occurrence)
        name_lower = vendor['name'].lower()
        if name_lower in seen_names:
            print(f"  ⏭️  SKIP: {vendor['name']} (duplicate)")
            stats['skipped'] += 1
            continue
        seen_names.add(name_lower)
        
        # Determine category
        context = ' '.join(vendor['notes_parts']) + ' ' + vendor['category_hint']
        category = categorize_vendor(vendor['name'], context)
        
        # Calculate reliability from stars
        reliability = min(10, max(1, vendor['stars'] * 2)) if vendor['stars'] > 0 else 5
        
        # Build vendor data
        vendor_data = {
            'name': vendor['name'],
            'category': category,
            'contactName': vendor['contactName'] or None,
            'email': vendor['email'] or None,
            'phone': vendor['phone'] or None,
            'cost': vendor['cost'],
            'reliability': reliability,
            'workedTogetherBefore': vendor['stars'] >= 4,
            'notes': ' | '.join(vendor['notes_parts']) if vendor['notes_parts'] else None,
            'tags': json.dumps(['from-relationships', f'{vendor["stars"]}-star'] if vendor['stars'] > 0 else ['from-relationships'])
        }
        
        # POST to API
        result, error = post_vendor(vendor_data)
        if result:
            stars = '⭐' * min(5, vendor['stars']) if vendor['stars'] > 0 else '📦'
            contact = f" ({vendor['email'] or vendor['phone'] or 'no contact'})"
            print(f"  {stars} {vendor['name']:50} | {category:15} {contact}")
            stats['success'] += 1
        else:
            print(f"  ❌ {vendor['name']:50} | ERROR: {error}")
            error_log.append((vendor['name'], error))
            stats['errors'] += 1
    
    # Summary
    print(f"\n📊 Migration Summary:")
    print(f"  Total parsed: {len(vendors)}")
    print(f"  Successful: {stats['success']}")
    print(f"  Skipped (duplicates): {stats['skipped']}")
    print(f"  Errors: {stats['errors']}")
    
    if error_log:
        print(f"\n❌ Errors:")
        for name, error in error_log:
            print(f"  - {name}: {error}")
    
    if stats['errors'] == 0 and stats['success'] > 0:
        print(f"\n✅ Migration completed successfully!")
        print(f"  {stats['success']} vendors migrated to database")
        return 0
    else:
        print(f"\n⚠️  Migration completed with issues")
        return 1

if __name__ == '__main__':
    sys.exit(main())
