#!/usr/bin/env python3
"""Build Venn Pre-Seed pitch deck in Google Slides"""

import json
import subprocess
import sys

PRESENTATION_ID = "1EUB5XTyZFL2jrucF3WkxAE7IAUHxPTRbmu98hrTHdH0"

# Slide content (10 slides)
slides = [
    {
        "title": "Venn",
        "subtitle": "We're building the Soho House of live experiences for Gen Z — curated events, exclusive memberships, and owned venues, powered by autonomous AI.",
        "footer": "Pre-Seed Deck | February 2026"
    },
    {
        "title": "Event Discovery is Broken",
        "bullets": [
            "🔍 Discovery sucks — Eventbrite/Partiful = endless scrolling, no curation",
            "🎟️ Quality lottery — No guarantee events are worth your time/money",
            "🏢 Venues are commoditized — No one owns the full experience"
        ]
    },
    {
        "title": "We Own the Full Stack",
        "subtitle": "The Venn Flywheel",
        "bullets": [
            "🎉 Curated Events → Build audience & trust",
            "💳 Memberships → Recurring revenue + status",
            "🏛️ Owned Venues → Control experience + capture value",
            "📱 Media/Content → Feed discovery loop",
            "",
            "CENTER: Autonomous AI (10x efficiency vs competitors)"
        ]
    },
    {
        "title": "Three Products, One Experience",
        "sections": [
            {
                "header": "Events",
                "items": [
                    "Western Line Dancing, Gatsby Festival, Murder Mystery Yacht",
                    "2-4 events/month, 50-400 guests"
                ]
            },
            {
                "header": "Memberships ($50-300/month)",
                "items": [
                    "Priority access, discounts, exclusive events",
                    "Status + community"
                ]
            },
            {
                "header": "Venues (SF flagship launching 2026)",
                "items": [
                    "Own the real estate = own the margins",
                    "Events 365 days/year"
                ]
            }
        ]
    },
    {
        "title": "Sold-Out Events, Paying Members, Real Revenue",
        "metrics": [
            "📊 12 events in 6 months",
            "🎟️ 500+ attendees (across events)",
            "💰 $25K revenue (early traction)",
            "💳 50+ members at $50-150/month"
        ],
        "proof": "Intimate Dinner sold out in 48 hours. Great Gatsby Festival hit 200-person capacity in 2 weeks."
    },
    {
        "title": "$85B Experiential Economy",
        "bullets": [
            "$85B — Total US live events market",
            "$12B — Premium/curated events (our wedge)",
            "$900M — SF + NYC + LA (initial markets)",
            "",
            "COMPARABLE EXITS:",
            "• Fever: $1B+ valuation (L Catterton led $100M)",
            "• Partiful: $100M valuation (a16z led $20M Series A)"
        ]
    },
    {
        "title": "Multiple Revenue Streams = De-Risked",
        "streams": [
            "💸 Event Tickets — $40-150/person (60% margin after costs)",
            "💳 Memberships — $50-300/month recurring (90% margin)",
            "🏛️ Venue Revenue — Own venues = own margins (40% margin)",
            "🤝 Sponsorships — Brand partnerships (100% margin)"
        ],
        "economics": [
            "Event margin: 60%",
            "Membership LTV: $1,800 (avg 12-month retention)",
            "CAC: $45 (organic + word-of-mouth)"
        ]
    },
    {
        "title": "No One Else Owns the Full Stack",
        "competitors": [
            "Eventbrite: commoditized, transactional",
            "Partiful: commoditized, transactional",
            "Soho House: curated, membership — but NO events focus",
            "Fever: curated, transactional"
        ],
        "position": "VENN: Top-right corner (curated + membership)",
        "advantage": "UNFAIR ADVANTAGE: Autonomous AI operations (10x efficiency vs competitors)"
    },
    {
        "title": "Proven Builders",
        "team": [
            "Zed Truong — CEO/Co-founder | Ops + community expert",
            "Gedeon — CTO/Co-founder | Tech + infrastructure",
            "Aidan Scudder — Co-founder | Product + growth",
            "",
            "+ Vinny (AI): Autonomous operations (handles 80% of event logistics)"
        ]
    },
    {
        "title": "Help Us Define a Category",
        "raising": "RAISING: $500K - $1M Pre-Seed",
        "use_of_funds": [
            "$300K — Team (first hires: CMO, Community Lead)",
            "$200K — Marketing & growth (scale to 1,000 members)",
            "$200K — Venue scouting (SF flagship prep)",
            "$300K — 12-month runway"
        ],
        "milestones": [
            "12-MONTH MILESTONES:",
            "• 1,000 members",
            "• $100K MRR",
            "• SF flagship venue secured",
            "• Expand to LA or NYC"
        ],
        "contact": "Zed Truong | zed.truong@vennapp.co | vennsocial.co"
    }
]

print("🎨 Building Venn Pre-Seed Pitch Deck...")
print(f"Presentation ID: {PRESENTATION_ID}")
print(f"Total slides: {len(slides)}")
print("\n⚠️  Note: Google Slides API requires OAuth setup via Google Cloud Console")
print("    The gog CLI doesn't support slide editing yet.")
print("\n📋 Slide content prepared:")

for i, slide in enumerate(slides, 1):
    print(f"\n{i}. {slide.get('title', 'Untitled')}")
    if 'subtitle' in slide:
        print(f"   → {slide['subtitle'][:80]}...")

print("\n💡 RECOMMENDATION:")
print("   Open the Google Slides link and manually add content from PRE_SEED_10_SLIDES.md")
print("   OR I can create a detailed step-by-step script for you to follow")
print(f"\n🔗 Link: https://docs.google.com/presentation/d/1EUB5XTyZFL2jrucF3WkxAE7IAUHxPTRbmu98hrTHdH0/edit")

