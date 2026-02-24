#!/usr/bin/env python3
"""Add content to Venn Pre-Seed pitch deck using Google Slides API"""

import os
import json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

PRESENTATION_ID = "1EUB5XTyZFL2jrucF3WkxAE7IAUHxPTRbmu98hrTHdH0"
SCOPES = ['https://www.googleapis.com/auth/presentations']

# Load credentials from gog
GOG_CREDS_PATH = os.path.expanduser("~/Library/Application Support/gogcli/credentials.json")

def get_service():
    """Get Google Slides service using gog credentials"""
    try:
        with open(GOG_CREDS_PATH, 'r') as f:
            creds_data = json.load(f)
        
        creds = Credentials.from_authorized_user_info(creds_data, SCOPES)
        return build('slides', 'v1', credentials=creds)
    except Exception as e:
        print(f"❌ Error loading credentials: {e}")
        return None

def create_slide(service, presentation_id, title, content_type="TITLE_AND_BODY"):
    """Create a new slide"""
    requests = [
        {
            'createSlide': {
                'slideLayoutReference': {
                    'predefinedLayout': content_type
                }
            }
        }
    ]
    
    try:
        response = service.presentations().batchUpdate(
            presentationId=presentation_id,
            body={'requests': requests}
        ).execute()
        
        slide_id = response['replies'][0]['createSlide']['objectId']
        return slide_id
    except HttpError as error:
        print(f"❌ Error creating slide: {error}")
        return None

def add_text_to_slide(service, presentation_id, slide_id, title_text, body_text):
    """Add text to a slide"""
    requests = []
    
    # Get slide to find text box IDs
    presentation = service.presentations().get(
        presentationId=presentation_id
    ).execute()
    
    # Find the slide
    slide = None
    for s in presentation['slides']:
        if s['objectId'] == slide_id:
            slide = s
            break
    
    if not slide:
        return False
    
    # Find title and body text boxes
    for element in slide['pageElements']:
        if 'shape' in element:
            shape = element['shape']
            if 'placeholder' in shape:
                placeholder_type = shape['placeholder']['type']
                
                if placeholder_type == 'TITLE' or placeholder_type == 'CENTERED_TITLE':
                    requests.append({
                        'insertText': {
                            'objectId': element['objectId'],
                            'text': title_text
                        }
                    })
                elif placeholder_type == 'BODY' or placeholder_type == 'SUBTITLE':
                    requests.append({
                        'insertText': {
                            'objectId': element['objectId'],
                            'text': body_text
                        }
                    })
    
    if requests:
        try:
            service.presentations().batchUpdate(
                presentationId=presentation_id,
                body={'requests': requests}
            ).execute()
            return True
        except HttpError as error:
            print(f"❌ Error adding text: {error}")
            return False
    
    return False

def main():
    print("🎨 Building Venn Pre-Seed Pitch Deck in Google Slides...")
    
    service = get_service()
    if not service:
        print("❌ Could not authenticate with Google Slides API")
        print("💡 Try opening the Google Slides link manually and adding content")
        return
    
    # Slide content
    slides_content = [
        {
            "title": "Venn",
            "body": "We're building the Soho House of live experiences for Gen Z — curated events, exclusive memberships, and owned venues, powered by autonomous AI.\n\nPre-Seed Deck | February 2026",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "Event Discovery is Broken",
            "body": "🔍 Discovery sucks — Eventbrite/Partiful = endless scrolling, no curation\n\n🎟️ Quality lottery — No guarantee events are worth your time/money\n\n🏢 Venues are commoditized — No one owns the full experience",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "We Own the Full Stack",
            "body": "The Venn Flywheel:\n\n🎉 Curated Events → Build audience & trust\n💳 Memberships → Recurring revenue + status\n🏛️ Owned Venues → Control experience + capture value\n📱 Media/Content → Feed discovery loop\n\nAutonomous AI (10x efficiency vs competitors)",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "Three Products, One Experience",
            "body": "EVENTS\n• Western Line Dancing, Gatsby Festival, Murder Mystery Yacht\n• 2-4 events/month, 50-400 guests\n\nMEMBERSHIPS ($50-300/month)\n• Priority access, discounts, exclusive events\n• Status + community\n\nVENUES (SF flagship launching 2026)\n• Own the real estate = own the margins\n• Events 365 days/year",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "Sold-Out Events, Paying Members, Real Revenue",
            "body": "📊 12 events in 6 months\n🎟️ 500+ attendees (across events)\n💰 $25K revenue (early traction)\n💳 50+ members at $50-150/month\n\nIntimate Dinner sold out in 48 hours.\nGreat Gatsby Festival hit 200-person capacity in 2 weeks.",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "$85B Experiential Economy",
            "body": "$85B — Total US live events market\n$12B — Premium/curated events (our wedge)\n$900M — SF + NYC + LA (initial markets)\n\nCOMPARABLE EXITS:\n• Fever: $1B+ valuation (L Catterton led $100M)\n• Partiful: $100M valuation (a16z led $20M Series A)",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "Multiple Revenue Streams = De-Risked",
            "body": "💸 Event Tickets — $40-150/person (60% margin)\n💳 Memberships — $50-300/month (90% margin)\n🏛️ Venue Revenue — Own venues (40% margin)\n🤝 Sponsorships — Brand partnerships (100% margin)\n\nUNIT ECONOMICS:\n• Event margin: 60%\n• Membership LTV: $1,800\n• CAC: $45 (organic + word-of-mouth)",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "No One Else Owns the Full Stack",
            "body": "COMPETITORS:\n• Eventbrite: commoditized, transactional\n• Partiful: commoditized, transactional\n• Soho House: curated, membership (NO events focus)\n• Fever: curated, transactional\n\nVENN: curated + membership\n\nUNFAIR ADVANTAGE: Autonomous AI operations (10x efficiency)",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "Proven Builders",
            "body": "Zed Truong — CEO/Co-founder\nOps + community expert\n\nGedeon — CTO/Co-founder\nTech + infrastructure\n\nAidan Scudder — Co-founder\nProduct + growth\n\n+ Vinny (AI): Autonomous operations (handles 80% of event logistics)",
            "layout": "TITLE_AND_BODY"
        },
        {
            "title": "Help Us Define a Category",
            "body": "RAISING: $500K - $1M Pre-Seed\n\nUSE OF FUNDS:\n$300K — Team (CMO, Community Lead)\n$200K — Marketing & growth\n$200K — Venue scouting (SF flagship)\n$300K — 12-month runway\n\n12-MONTH MILESTONES:\n• 1,000 members | $100K MRR\n• SF flagship venue secured\n• Expand to LA or NYC\n\nZed Truong | zed.truong@vennapp.co | vennsocial.co",
            "layout": "TITLE_AND_BODY"
        }
    ]
    
    print(f"\n📊 Adding {len(slides_content)} slides to presentation...")
    
    for i, slide_data in enumerate(slides_content, 1):
        print(f"\n{i}. {slide_data['title']}")
        
        # Create slide
        slide_id = create_slide(service, PRESENTATION_ID, slide_data['title'], slide_data.get('layout', 'TITLE_AND_BODY'))
        
        if slide_id:
            # Add text
            success = add_text_to_slide(service, PRESENTATION_ID, slide_id, slide_data['title'], slide_data['body'])
            if success:
                print(f"   ✅ Created")
            else:
                print(f"   ⚠️  Created but text may need manual adjustment")
        else:
            print(f"   ❌ Failed to create slide")
    
    print(f"\n✅ Deck complete!")
    print(f"🔗 https://docs.google.com/presentation/d/1EUB5XTyZFL2jrucF3WkxAE7IAUHxPTRbmu98hrTHdH0/edit")

if __name__ == "__main__":
    main()
