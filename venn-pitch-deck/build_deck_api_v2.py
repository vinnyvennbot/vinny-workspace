#!/usr/bin/env python3
"""Build Venn Pre-Seed pitch deck using Google Slides API"""

import os
import subprocess
import json
import os
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

PRESENTATION_ID = "1EUB5XTyZFL2jrucF3WkxAE7IAUHxPTRbmu98hrTHdH0"
SCOPES = ['https://www.googleapis.com/auth/presentations']

# gog OAuth client credentials
CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "")
CLIENT_SECRET = os.environ.get("GOOGLE_CLIENT_SECRET", "")

def get_access_token_from_gog():
    """Get access token by calling gog (which handles auth)"""
    try:
        # gog info command will use stored credentials
        result = subprocess.run(
            ['gog', 'slides', 'info', PRESENTATION_ID, '--json'],
            capture_output=True,
            text=True,
            check=True
        )
        # If this succeeds, gog has valid credentials
        return True
    except:
        return False

def get_credentials_interactive():
    """Get credentials interactively if needed"""
    print("🔐 Setting up Google Slides API credentials...")
    
    # Check if gog is already authenticated
    if get_access_token_from_gog():
        print("✅ gog is authenticated\n")
    else:
        print("❌ gog is not authenticated")
        print("💡 Run: gog slides info <presentation_id> to authenticate")
        return None
    
    # Since gog uses macOS Keychain, we need to use OAuth flow
    # For now, let's use the google-auth-oauthlib flow
    from google_auth_oauthlib.flow import InstalledAppFlow
    
    client_config = {
        "installed": {
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "redirect_uris": ["http://localhost"],
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token"
        }
    }
    
    flow = InstalledAppFlow.from_client_config(client_config, SCOPES)
    creds = flow.run_local_server(port=0)
    
    return creds

def populate_slides(service, presentation_id):
    """Populate slides with content"""
    
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
            "body": "The Venn Flywheel\n\n🎉 Curated Events → Build audience & trust\n\n💳 Memberships → Recurring revenue + status\n\n🏛️ Owned Venues → Control experience + capture value\n\n📱 Media/Content → Feed discovery loop\n\nAutonomous AI (10x efficiency vs competitors)"
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
    
    # Get presentation
    presentation = service.presentations().get(presentationId=presentation_id).execute()
    slides = presentation.get('slides', [])
    
    print(f"📊 Current presentation has {len(slides)} slides")
    
    # Create additional slides if needed
    if len(slides) < 10:
        num_to_create = 10 - len(slides)
        print(f"Creating {num_to_create} additional slides...")
        
        requests = []
        for i in range(num_to_create):
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
        
        # Refresh
        presentation = service.presentations().get(presentationId=presentation_id).execute()
        slides = presentation.get('slides', [])
        print(f"✅ Now have {len(slides)} slides\n")
    
    # Populate each slide
    all_requests = []
    
    for i, slide_data in enumerate(slides_data):
        if i >= len(slides):
            continue
        
        slide = slides[i]
        print(f"{i+1}. {slide_data['title']}")
        
        # Find text elements
        for element in slide.get('pageElements', []):
            if 'shape' not in element:
                continue
            
            shape = element['shape']
            if 'placeholder' not in shape:
                continue
            
            placeholder_type = shape['placeholder'].get('type', '')
            object_id = element['objectId']
            
            if placeholder_type in ['TITLE', 'CENTERED_TITLE']:
                all_requests.extend([
                    {'deleteText': {'objectId': object_id, 'textRange': {'type': 'ALL'}}},
                    {'insertText': {'objectId': object_id, 'text': slide_data['title'], 'insertionIndex': 0}}
                ])
            elif placeholder_type in ['BODY', 'SUBTITLE']:
                all_requests.extend([
                    {'deleteText': {'objectId': object_id, 'textRange': {'type': 'ALL'}}},
                    {'insertText': {'objectId': object_id, 'text': slide_data['body'], 'insertionIndex': 0}}
                ])
    
    # Execute all updates
    if all_requests:
        print(f"\n🔄 Updating {len(all_requests)//2} text elements...")
        service.presentations().batchUpdate(
            presentationId=presentation_id,
            body={'requests': all_requests}
        ).execute()
        print("✅ All slides updated!")
        return True
    
    return False

def main():
    print("🎨 Building Venn Pre-Seed Pitch Deck\n")
    
    # Get credentials
    creds = get_credentials_interactive()
    if not creds:
        return
    
    # Build service
    service = build('slides', 'v1', credentials=creds)
    print("✅ Connected to Google Slides API\n")
    
    # Populate slides
    success = populate_slides(service, PRESENTATION_ID)
    
    if success:
        print(f"\n🎉 Deck complete!")
        print(f"🔗 https://docs.google.com/presentation/d/{PRESENTATION_ID}/edit")

if __name__ == "__main__":
    main()
