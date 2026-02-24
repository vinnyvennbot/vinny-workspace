#!/usr/bin/env python3
"""Build Venn Pre-Seed pitch deck using Google Slides API with gog credentials"""

import os
import json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

PRESENTATION_ID = "1EUB5XTyZFL2jrucF3WkxAE7IAUHxPTRbmu98hrTHdH0"
SCOPES = ['https://www.googleapis.com/auth/presentations', 'https://www.googleapis.com/auth/drive']

# Load gog credentials
GOG_CONFIG = os.path.expanduser("~/Library/Application Support/gogcli/config.json")

def get_credentials():
    """Load credentials from gog config"""
    try:
        with open(GOG_CONFIG, 'r') as f:
            config = json.load(f)
        
        # gog stores credentials per account
        accounts = config.get('accounts', {})
        if not accounts:
            raise Exception("No accounts found in gog config")
        
        # Get first account (vinny@vennapp.co)
        account_email = list(accounts.keys())[0]
        account_data = accounts[account_email]
        
        # Build credentials object
        creds_info = {
            'token': account_data.get('token'),
            'refresh_token': account_data.get('refresh_token'),
            'token_uri': 'https://oauth2.googleapis.com/token',
            'client_id': account_data.get('client_id'),
            'client_secret': account_data.get('client_secret'),
            'scopes': SCOPES
        }
        
        return Credentials.from_authorized_user_info(creds_info, SCOPES)
    except Exception as e:
        print(f"❌ Error loading gog credentials: {e}")
        return None

def create_slides_with_content(service, presentation_id):
    """Create and populate all 10 slides"""
    
    # Slide content data
    slides_data = [
        {
            "title": "Venn",
            "body": "We're building the Soho House of live experiences for Gen Z — curated events, exclusive memberships, and owned venues, powered by autonomous AI.\n\nPre-Seed Deck | February 2026"
        },
        {
            "title": "Event Discovery is Broken",
            "body": "🔍 Discovery sucks — Eventbrite/Partiful = endless scrolling, no curation\n\n🎟️ Quality lottery — No guarantee events are worth your time/money\n\n🏢 Venues are commoditized — No one owns the full experience"
        },
        {
            "title": "We Own the Full Stack",
            "subtitle": "The Venn Flywheel",
            "body": "🎉 Curated Events → Build audience & trust\n\n💳 Memberships → Recurring revenue + status\n\n🏛️ Owned Venues → Control experience + capture value\n\n📱 Media/Content → Feed discovery loop\n\nAutonomous AI (10x efficiency vs competitors)"
        },
        {
            "title": "Three Products, One Experience",
            "body": "EVENTS\n• Western Line Dancing, Gatsby Festival, Murder Mystery Yacht\n• 2-4 events/month, 50-400 guests\n\nMEMBERSHIPS ($50-300/month)\n• Priority access, discounts, exclusive events\n• Status + community\n\nVENUES (SF flagship launching 2026)\n• Own the real estate = own the margins\n• Events 365 days/year"
        },
        {
            "title": "Sold-Out Events, Paying Members, Real Revenue",
            "body": "📊 12 events in 6 months\n🎟️ 500+ attendees (across events)\n💰 $25K revenue (early traction)\n💳 50+ members at $50-150/month\n\nIntimate Dinner sold out in 48 hours.\nGreat Gatsby Festival hit 200-person capacity in 2 weeks."
        },
        {
            "title": "$85B Experiential Economy",
            "body": "$85B — Total US live events market\n$12B — Premium/curated events (our wedge)\n$900M — SF + NYC + LA (initial markets)\n\nCOMPARABLE EXITS:\n• Fever: $1B+ valuation (L Catterton led $100M)\n• Partiful: $100M valuation (a16z led $20M Series A)"
        },
        {
            "title": "Multiple Revenue Streams = De-Risked",
            "body": "💸 Event Tickets — $40-150/person (60% margin)\n\n💳 Memberships — $50-300/month (90% margin)\n\n🏛️ Venue Revenue — Own venues (40% margin)\n\n🤝 Sponsorships — Brand partnerships (100% margin)\n\nUNIT ECONOMICS:\n• Event margin: 60%\n• Membership LTV: $1,800\n• CAC: $45 (organic + word-of-mouth)"
        },
        {
            "title": "No One Else Owns the Full Stack",
            "body": "COMPETITORS:\n• Eventbrite: commoditized, transactional\n• Partiful: commoditized, transactional\n• Soho House: curated, membership (NO events focus)\n• Fever: curated, transactional\n\nVENN: curated + membership\n\nUNFAIR ADVANTAGE: Autonomous AI operations (10x efficiency)"
        },
        {
            "title": "Proven Builders",
            "body": "Zed Truong — CEO/Co-founder\nOps + community expert\n\nGedeon — CTO/Co-founder\nTech + infrastructure\n\nAidan Scudder — Co-founder\nProduct + growth\n\n+ Vinny (AI): Autonomous operations (handles 80% of event logistics)"
        },
        {
            "title": "Help Us Define a Category",
            "body": "RAISING: $500K - $1M Pre-Seed\n\nUSE OF FUNDS:\n$300K — Team (CMO, Community Lead)\n$200K — Marketing & growth\n$200K — Venue scouting (SF flagship)\n$300K — 12-month runway\n\n12-MONTH MILESTONES:\n• 1,000 members | $100K MRR\n• SF flagship venue secured\n• Expand to LA or NYC\n\nZed Truong | zed.truong@vennapp.co | vennsocial.co"
        }
    ]
    
    # Get current presentation structure
    presentation = service.presentations().get(presentationId=presentation_id).execute()
    slides = presentation.get('slides', [])
    
    print(f"\n📊 Current presentation has {len(slides)} slides")
    
    # We need 10 slides total - create additional ones if needed
    slides_to_create = max(0, 10 - len(slides))
    
    if slides_to_create > 0:
        print(f"Creating {slides_to_create} additional slides...")
        requests = []
        for i in range(slides_to_create):
            requests.append({
                'createSlide': {
                    'slideLayoutReference': {
                        'predefinedLayout': 'TITLE_AND_BODY'
                    }
                }
            })
        
        service.presentations().batchUpdate(
            presentationId=presentation_id,
            body={'requests': requests}
        ).execute()
        
        # Refresh presentation data
        presentation = service.presentations().get(presentationId=presentation_id).execute()
        slides = presentation.get('slides', [])
    
    print(f"✅ Presentation now has {len(slides)} slides\n")
    
    # Now populate each slide with content
    all_requests = []
    
    for i, slide_data in enumerate(slides_data):
        if i >= len(slides):
            print(f"⚠️  Slide {i+1} not found, skipping")
            continue
            
        slide = slides[i]
        slide_id = slide['objectId']
        
        print(f"{i+1}. {slide_data['title']}")
        
        # Find text boxes in this slide
        page_elements = slide.get('pageElements', [])
        
        for element in page_elements:
            if 'shape' not in element:
                continue
                
            shape = element['shape']
            if 'placeholder' not in shape:
                continue
            
            placeholder_type = shape['placeholder'].get('type', '')
            object_id = element['objectId']
            
            # Insert text based on placeholder type
            if placeholder_type in ['TITLE', 'CENTERED_TITLE']:
                # Delete existing text first
                all_requests.append({
                    'deleteText': {
                        'objectId': object_id,
                        'textRange': {'type': 'ALL'}
                    }
                })
                # Insert new title
                all_requests.append({
                    'insertText': {
                        'objectId': object_id,
                        'text': slide_data['title'],
                        'insertionIndex': 0
                    }
                })
            
            elif placeholder_type in ['BODY', 'SUBTITLE']:
                # Delete existing text
                all_requests.append({
                    'deleteText': {
                        'objectId': object_id,
                        'textRange': {'type': 'ALL'}
                    }
                })
                # Insert body text
                body_text = slide_data.get('body', slide_data.get('subtitle', ''))
                all_requests.append({
                    'insertText': {
                        'objectId': object_id,
                        'text': body_text,
                        'insertionIndex': 0
                    }
                })
    
    # Execute all text updates in one batch
    if all_requests:
        print(f"\n🔄 Executing {len(all_requests)} text updates...")
        try:
            service.presentations().batchUpdate(
                presentationId=presentation_id,
                body={'requests': all_requests}
            ).execute()
            print("✅ All slides updated successfully!")
        except HttpError as error:
            print(f"❌ Error updating slides: {error}")
            return False
    
    return True

def main():
    print("🎨 Building Venn Pre-Seed Pitch Deck using Google Slides API\n")
    
    # Get credentials from gog
    creds = get_credentials()
    if not creds:
        print("\n❌ Failed to load credentials")
        print("💡 Make sure gog is properly configured: `gog slides info <id>`")
        return
    
    print(f"✅ Loaded credentials from gog config\n")
    
    # Build service
    try:
        service = build('slides', 'v1', credentials=creds)
        print("✅ Connected to Google Slides API\n")
    except Exception as e:
        print(f"❌ Error building service: {e}")
        return
    
    # Create and populate slides
    success = create_slides_with_content(service, PRESENTATION_ID)
    
    if success:
        print(f"\n🎉 Deck complete!")
        print(f"🔗 https://docs.google.com/presentation/d/{PRESENTATION_ID}/edit")
    else:
        print("\n⚠️  Deck partially complete - check for errors above")

if __name__ == "__main__":
    main()
