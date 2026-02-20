#!/usr/bin/env python3
"""
Build "The Capital Table" Google Slides presentation for Mavros Group.
Uses existing gog OAuth token via refresh_token.
"""

import json
import os

# Load token data
with open('/tmp/gog_token.json') as f:
    token_data = json.load(f)

with open('/Users/vinnyvenn/Library/Application Support/gogcli/credentials.json') as f:
    creds_data = json.load(f)

REFRESH_TOKEN = token_data['refresh_token']
CLIENT_ID = creds_data['client_id']
CLIENT_SECRET = creds_data['client_secret']
PRESENTATION_ID = "1hTAu9S_oFbsHZYbTq-6-IBGhdPhxKiiJi9oMDHPdOSY"

# Build credentials
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

creds = Credentials(
    token=None,
    refresh_token=REFRESH_TOKEN,
    token_uri="https://oauth2.googleapis.com/token",
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    scopes=["https://www.googleapis.com/auth/drive"]
)

# Refresh the access token
request = Request()
creds.refresh(request)
print(f"✅ Authenticated. Token expires: {creds.expiry}")

service = build('slides', 'v1', credentials=creds)
drive_service = build('drive', 'v3', credentials=creds)

# ============================================================
# HELPER FUNCTIONS
# ============================================================

def rgb(r, g, b):
    return {"red": r/255, "green": g/255, "blue": b/255}

# Color palette
CHARCOAL = rgb(18, 18, 22)       # near-black background
DARK_CARD = rgb(28, 28, 36)      # card background
GOLD = rgb(212, 175, 55)         # gold accent
CREAM = rgb(248, 243, 225)       # cream text
WHITE = rgb(255, 255, 255)
LIGHT_GRAY = rgb(180, 180, 190)
GOLD_DARK = rgb(160, 130, 30)

def pt(points):
    """Convert points to EMU (914400 EMU = 1 inch; 72pt = 1 inch → 12700 EMU/pt)"""
    return int(points * 12700)

def emu(v):
    return int(v)

# Slide dimensions (widescreen 10" x 5.625")
SLIDE_W = 9144000
SLIDE_H = 5143500

def make_id(base, n):
    return f"{base}_{n:03d}"

counter = [0]
def next_id(prefix="el"):
    counter[0] += 1
    return f"{prefix}_{counter[0]:04d}"

# ============================================================
# GET EXISTING SLIDES & DELETE THEM
# ============================================================

print("📋 Fetching existing presentation...")
pres = service.presentations().get(presentationId=PRESENTATION_ID).execute()
existing_slides = pres.get('slides', [])
print(f"   Found {len(existing_slides)} existing slide(s)")

requests = []

# Delete existing slides (keep at least one, we'll replace content)
if len(existing_slides) > 1:
    for slide in existing_slides[1:]:
        requests.append({"deleteObject": {"objectId": slide['objectId']}})

# Clear content from first slide
for slide in existing_slides[:1]:
    for element in slide.get('pageElements', []):
        requests.append({"deleteObject": {"objectId": element['objectId']}})

if requests:
    service.presentations().batchUpdate(
        presentationId=PRESENTATION_ID,
        body={"requests": requests}
    ).execute()
    print("   Cleared existing content")

# ============================================================
# SLIDE DATA
# ============================================================

slides_content = [
    {
        "title": "COVER",
        "type": "cover"
    },
    {
        "title": "THE PROBLEM",
        "type": "problem"
    },
    {
        "title": "THE SOLUTION",
        "type": "solution"
    },
    {
        "title": "THE CONCEPT",
        "type": "concept"
    },
    {
        "title": "TARGET GUEST",
        "type": "persona"
    },
    {
        "title": "SAMPLE INVITE",
        "type": "invite"
    },
    {
        "title": "EXPERIENCE FLOW",
        "type": "flow"
    },
    {
        "title": "VENUE OPTIONS",
        "type": "venues"
    },
    {
        "title": "VENDOR STACK",
        "type": "vendors"
    },
    {
        "title": "SPONSOR TIERS",
        "type": "sponsors"
    },
    {
        "title": "UNIT ECONOMICS",
        "type": "unit_econ"
    },
    {
        "title": "BREAK-EVEN",
        "type": "breakeven"
    },
    {
        "title": "REVENUE UPSIDE",
        "type": "revenue"
    },
    {
        "title": "PODCAST INTEGRATION",
        "type": "podcast"
    },
    {
        "title": "AI ASSIST LAYER",
        "type": "ai_layer"
    }
]

# ============================================================
# BUILD ALL SLIDES
# ============================================================

print("🏗️  Building slides...")

all_requests = []

def add_slide(layout="BLANK", insert_at=None):
    sid = next_id("slide")
    req = {
        "createSlide": {
            "objectId": sid,
            "slideLayoutReference": {"predefinedLayout": layout}
        }
    }
    if insert_at is not None:
        req["createSlide"]["insertionIndex"] = insert_at
    all_requests.append(req)
    return sid

def set_bg(sid, color):
    all_requests.append({
        "updatePageProperties": {
            "objectId": sid,
            "pageProperties": {
                "pageBackgroundFill": {
                    "solidFill": {"color": {"rgbColor": color}}
                }
            },
            "fields": "pageBackgroundFill"
        }
    })

def add_shape(sid, shape_type, x, y, w, h, fill_color=None, border_color=None, border_width=0):
    oid = next_id("shape")
    all_requests.append({
        "createShape": {
            "objectId": oid,
            "shapeType": shape_type,
            "elementProperties": {
                "pageObjectId": sid,
                "size": {"width": {"magnitude": w, "unit": "EMU"},
                         "height": {"magnitude": h, "unit": "EMU"}},
                "transform": {"scaleX": 1, "scaleY": 1,
                              "translateX": x, "translateY": y, "unit": "EMU"}
            }
        }
    })
    updates = {}
    if fill_color:
        updates["shapeBackgroundFill"] = {
            "solidFill": {"color": {"rgbColor": fill_color}}
        }
    if border_color:
        updates["outline"] = {
            "outlineFill": {"solidFill": {"color": {"rgbColor": border_color}}},
            "weight": {"magnitude": border_width, "unit": "PT"},
            "dashStyle": "SOLID"
        }
    else:
        updates["outline"] = {"propertyState": "NOT_RENDERED"}
    if updates:
        all_requests.append({
            "updateShapeProperties": {
                "objectId": oid,
                "shapeProperties": updates,
                "fields": ",".join(updates.keys())
            }
        })
    return oid

def add_text_box(sid, text, x, y, w, h, 
                 font_size=24, bold=False, color=None, 
                 align="START", v_align="MIDDLE",
                 font_family="Montserrat", italic=False,
                 line_spacing=None, para_spacing_after=None):
    oid = next_id("tb")
    if color is None:
        color = CREAM
    all_requests.append({
        "createShape": {
            "objectId": oid,
            "shapeType": "TEXT_BOX",
            "elementProperties": {
                "pageObjectId": sid,
                "size": {"width": {"magnitude": w, "unit": "EMU"},
                         "height": {"magnitude": h, "unit": "EMU"}},
                "transform": {"scaleX": 1, "scaleY": 1,
                              "translateX": x, "translateY": y, "unit": "EMU"}
            }
        }
    })
    all_requests.append({
        "updateShapeProperties": {
            "objectId": oid,
            "shapeProperties": {
                "shapeBackgroundFill": {"propertyState": "NOT_RENDERED"},
                "outline": {"propertyState": "NOT_RENDERED"},
                "contentAlignment": v_align
            },
            "fields": "shapeBackgroundFill,outline,contentAlignment"
        }
    })
    all_requests.append({
        "insertText": {
            "objectId": oid,
            "text": text,
            "insertionIndex": 0
        }
    })
    para_style = {"alignment": align}
    if line_spacing:
        para_style["lineSpacing"] = line_spacing
    if para_spacing_after:
        para_style["spaceAfter"] = {"magnitude": para_spacing_after, "unit": "PT"}
    
    all_requests.append({
        "updateParagraphStyle": {
            "objectId": oid,
            "textRange": {"type": "ALL"},
            "style": para_style,
            "fields": ",".join(para_style.keys())
        }
    })
    text_style = {
        "foregroundColor": {"opaqueColor": {"rgbColor": color}},
        "fontSize": {"magnitude": font_size, "unit": "PT"},
        "bold": bold,
        "italic": italic,
        "fontFamily": font_family
    }
    all_requests.append({
        "updateTextStyle": {
            "objectId": oid,
            "textRange": {"type": "ALL"},
            "style": text_style,
            "fields": "foregroundColor,fontSize,bold,italic,fontFamily"
        }
    })
    return oid

def gold_bar(sid, x, y, w=pt(0.4), h=pt(24)):
    """Thin gold horizontal bar accent"""
    return add_shape(sid, "RECTANGLE", x, y, w, h, fill_color=GOLD)

def section_label(sid, text, x, y, w):
    """Small gold uppercase label"""
    return add_text_box(sid, text, x, y, w, pt(20),
                       font_size=8, bold=True, color=GOLD,
                       font_family="Montserrat", align="START")

def slide_number(sid, n, total=15):
    add_text_box(sid, f"{n:02d} / {total}", 
                SLIDE_W - pt(80), SLIDE_H - pt(28), pt(70), pt(20),
                font_size=8, color=rgb(100,100,110), align="END",
                font_family="Montserrat")

MARGIN_L = pt(48)
MARGIN_T = pt(40)
CONTENT_W = SLIDE_W - MARGIN_L * 2
HEADER_H = pt(60)

# ============================================================
# SLIDE 1 — COVER
# ============================================================

# Get existing first slide ID
pres_fresh = service.presentations().get(presentationId=PRESENTATION_ID).execute()
first_slide_id = pres_fresh['slides'][0]['objectId']

set_bg(first_slide_id, CHARCOAL)

# Gold accent bar left
add_shape(first_slide_id, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)

# Main title
add_text_box(first_slide_id, "THE CAPITAL TABLE",
            pt(80), pt(90), pt(640), pt(80),
            font_size=44, bold=True, color=WHITE,
            font_family="Montserrat", align="START")

# Gold divider line
add_shape(first_slide_id, "RECTANGLE", pt(80), pt(178), pt(400), pt(2), fill_color=GOLD)

# Subtitle
add_text_box(first_slide_id, "A Flagship Event Sprint for Mavros Group",
            pt(80), pt(188), pt(540), pt(36),
            font_size=16, color=CREAM, font_family="Montserrat",
            italic=True, align="START")

# Description
add_text_box(first_slide_id,
            "Curated Investment Dinners · Live Podcast Recording · Quarterly National Expansion",
            pt(80), pt(234), pt(580), pt(28),
            font_size=11, color=LIGHT_GRAY, font_family="Montserrat", align="START")

# Stats row
stats = [("30", "CURATED GUESTS"), ("4x", "CITIES / YEAR"), ("$39K", "REVENUE POTENTIAL")]
sx = pt(80)
for val, label in stats:
    add_text_box(first_slide_id, val, sx, pt(310), pt(130), pt(50),
                font_size=32, bold=True, color=GOLD, font_family="Montserrat", align="START")
    add_text_box(first_slide_id, label, sx, pt(360), pt(130), pt(22),
                font_size=8, color=LIGHT_GRAY, font_family="Montserrat", align="START")
    sx += pt(140)

# Bottom tagline
add_text_box(first_slide_id,
            "\"Not a conference. Not networking. A dinner where capital moves.\"",
            pt(80), SLIDE_H - pt(72), pt(560), pt(36),
            font_size=13, italic=True, color=GOLD, font_family="Montserrat",
            align="START")

# Prepared by
add_text_box(first_slide_id,
            "Prepared by Mavros Group  ·  Q1 2026",
            pt(80), SLIDE_H - pt(34), pt(400), pt(22),
            font_size=9, color=LIGHT_GRAY, font_family="Montserrat", align="START")

slide_number(first_slide_id, 1)

# Now add 14 more slides
slide_ids = [first_slide_id]
for i in range(14):
    sid = add_slide("BLANK", insert_at=i+1)
    slide_ids.append(sid)

# ============================================================
# SLIDE 2 — THE PROBLEM
# ============================================================

def build_slide_2(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "THE CHALLENGE", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "Premium events don't scale.", 
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(52),
                font_size=34, bold=True, color=WHITE, font_family="Montserrat")
    add_text_box(sid, "Every event built from scratch. No compounding returns.",
                MARGIN_L + pt(12), MARGIN_T + pt(82), CONTENT_W, pt(28),
                font_size=14, italic=True, color=LIGHT_GRAY, font_family="Montserrat")
    
    problems = [
        ("🏛", "High Cost Per Event", "Venue, catering, AV, photography, staffing — $17K–$21K minimum with no reuse of systems or frameworks."),
        ("⏱", "Time-Intensive Execution", "Each event requires 40–80+ hours of planning. Zero carry-over from event to event. Zero operational leverage."),
        ("🌐", "No National Infrastructure", "Great LA events die in LA. Without a repeatable format, expansion to Austin, Miami, or NYC means starting over."),
        ("📢", "Sponsor Fragmentation", "One-off sponsor conversations. No tiered structure. No recurring revenue. Leaving $10K–$15K on the table per event."),
    ]
    py = MARGIN_T + pt(118)
    px = MARGIN_L + pt(12)
    box_w = (CONTENT_W - pt(24)) // 2
    box_h = pt(110)
    
    for i, (icon, title, body) in enumerate(problems):
        col = i % 2
        row = i // 2
        bx = px + col * (box_w + pt(24))
        by = py + row * (box_h + pt(16))
        add_shape(sid, "RECTANGLE", bx, by, box_w, box_h, fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", bx, by, pt(3), box_h, fill_color=GOLD)
        add_text_box(sid, title, bx + pt(14), by + pt(10), box_w - pt(20), pt(24),
                    font_size=13, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, body, bx + pt(14), by + pt(36), box_w - pt(20), pt(65),
                    font_size=9.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=130)
    slide_number(sid, 2)

# ============================================================
# SLIDE 3 — THE SOLUTION
# ============================================================

def build_slide_3(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "THE SOLUTION", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "One format. Every city.\nCompounds with every event.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(90),
                font_size=32, bold=True, color=WHITE, font_family="Montserrat")
    
    solutions = [
        ("01", "Plug-and-Play Format", "Same 30-person dinner structure, same podcast recording segment, same sponsor tiers — redeployed across LA, Austin, Miami, NYC."),
        ("02", "Built-In Revenue Stack", "Ticket sales + tiered sponsorship + podcast ad revenue. Three revenue streams per event, not one."),
        ("03", "Operational Leverage", "Every system, checklist, vendor relationship, and sponsor conversation compounds across quarters."),
        ("04", "Brand That Travels", "\"The Capital Table\" becomes a recognized name in private capital circles — a trusted room, not just an event."),
    ]
    py = MARGIN_T + pt(122)
    for i, (num, title, body) in enumerate(solutions):
        sx = MARGIN_L + pt(12) + i * pt(168)
        add_shape(sid, "RECTANGLE", sx, py, pt(158), pt(172), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", sx, py, pt(158), pt(3), fill_color=GOLD)
        add_text_box(sid, num, sx + pt(10), py + pt(10), pt(138), pt(30),
                    font_size=22, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, title, sx + pt(10), py + pt(44), pt(138), pt(28),
                    font_size=12, bold=True, color=WHITE, font_family="Montserrat")
        add_text_box(sid, body, sx + pt(10), py + pt(74), pt(138), pt(90),
                    font_size=9, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=130)
    slide_number(sid, 3)

# ============================================================
# SLIDE 4 — THE CONCEPT
# ============================================================

def build_slide_4(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "THE CONCEPT", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "The Capital Table",
                MARGIN_L + pt(12), MARGIN_T + pt(24), pt(500), pt(50),
                font_size=36, bold=True, color=GOLD, font_family="Montserrat")
    add_text_box(sid, "Quarterly Investment Dinner Sprint",
                MARGIN_L + pt(12), MARGIN_T + pt(78), pt(500), pt(28),
                font_size=16, italic=True, color=CREAM, font_family="Montserrat")
    add_shape(sid, "RECTANGLE", MARGIN_L + pt(12), MARGIN_T + pt(110), pt(360), pt(2), fill_color=GOLD)
    
    details = [
        ("FORMAT", "30 curated guests · Seated dinner · Structured conversation rounds"),
        ("GUESTS", "Capital allocators · RE syndicators · Private lenders · Fund managers"),
        ("CITIES", "Los Angeles / Malibu (Q1) → Austin → Miami → New York City"),
        ("VENUE", "Private estate · Rooftop members club · Exclusive gallery or penthouse"),
        ("THEME", "High-trust room. Capital moves here — not at conferences."),
        ("PODCAST", "Live recording segment → distributed as 'Inside The Capital Table' episode"),
        ("SPONSORS", "Financial services brands wanting qualified HNW eyeballs. Not mass exposure."),
        ("SCALE", "Same format · Rotating cities · Rotating sponsors · Same guest caliber. Plug-and-play."),
    ]
    py = MARGIN_T + pt(122)
    col_w = (CONTENT_W - pt(24)) // 2
    for i, (label, text) in enumerate(details):
        col = i % 2
        row = i // 2
        bx = MARGIN_L + pt(12) + col * (col_w + pt(24))
        by = py + row * pt(46)
        add_text_box(sid, label, bx, by, pt(100), pt(18),
                    font_size=8, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, text, bx, by + pt(16), col_w, pt(26),
                    font_size=9.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=120)
    slide_number(sid, 4)

# ============================================================
# SLIDE 5 — TARGET GUEST PERSONA
# ============================================================

def build_slide_5(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "GUEST PERSONA", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "The person in the room.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(42),
                font_size=28, bold=True, color=WHITE, font_family="Montserrat")
    add_text_box(sid, "Every seat filled deliberately. No passengers.",
                MARGIN_L + pt(12), MARGIN_T + pt(70), CONTENT_W, pt(24),
                font_size=13, italic=True, color=GOLD, font_family="Montserrat")
    
    personas = [
        ("Capital Allocator", "LP in 3–10 funds. Actively deploying $1M–$10M/yr. Looking for vetted operators, not pitch decks. Values time above all."),
        ("Real Estate Syndicator", "Raises capital for value-add multifamily or commercial. Actively building LP network. Wants a room without noise."),
        ("Private Lender / Fund Mgr", "$10M–$100M AUM. Bridges or notes secured by RE. Looking for quality deal flow and co-lending partners."),
        ("HNW Operator", "Entrepreneur or executive with liquid capital. Wants exposure to alternative investments in a trusted, off-market environment."),
    ]
    py = MARGIN_T + pt(102)
    pw = (CONTENT_W - pt(36)) // 2
    for i, (name, desc) in enumerate(personas):
        col = i % 2
        row = i // 2
        bx = MARGIN_L + pt(12) + col * (pw + pt(24))
        by = py + row * (pt(104) + pt(12))
        add_shape(sid, "RECTANGLE", bx, by, pw, pt(104), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", bx, by, pw, pt(3), fill_color=GOLD)
        add_text_box(sid, name, bx + pt(12), by + pt(10), pw - pt(20), pt(24),
                    font_size=13, bold=True, color=WHITE, font_family="Montserrat")
        add_text_box(sid, desc, bx + pt(12), by + pt(36), pw - pt(20), pt(62),
                    font_size=9.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=128)
    
    # Qualification criteria
    add_text_box(sid, "QUALIFICATION CRITERIA: Accredited investor · $1M+ net worth · Active deployer · Referral or vetting required",
                MARGIN_L + pt(12), SLIDE_H - pt(40), CONTENT_W, pt(24),
                font_size=8.5, color=GOLD, font_family="Montserrat", align="START")
    slide_number(sid, 5)

# ============================================================
# SLIDE 6 — SAMPLE INVITE COPY
# ============================================================

def build_slide_6(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "SAMPLE INVITE", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "The invite that sets the room.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    # Invite card background
    card_x = MARGIN_L + pt(12)
    card_y = MARGIN_T + pt(72)
    card_w = pt(380)
    card_h = pt(290)
    add_shape(sid, "RECTANGLE", card_x, card_y, card_w, card_h, fill_color=DARK_CARD)
    add_shape(sid, "RECTANGLE", card_x, card_y, card_w, pt(3), fill_color=GOLD)
    add_shape(sid, "RECTANGLE", card_x, card_y, pt(3), card_h, fill_color=GOLD)
    
    add_text_box(sid, "THE CAPITAL TABLE", card_x + pt(20), card_y + pt(16), card_w - pt(30), pt(22),
                font_size=11, bold=True, color=GOLD, font_family="Montserrat", align="CENTER")
    add_text_box(sid, "An Intimate Investment Dinner",
                card_x + pt(20), card_y + pt(40), card_w - pt(30), pt(20),
                font_size=10, italic=True, color=CREAM, font_family="Montserrat", align="CENTER")
    
    invite_text = ("You have been selected for a seat at The Capital Table — a curated dinner for 30 capital allocators, "
                   "real estate operators, and private lenders in Los Angeles.\n\n"
                   "This is not a conference. There are no panels, no keynotes, and no pitch sessions. "
                   "It is an intentional room where the right conversation happens over the right meal.\n\n"
                   "Attendance is by invitation only. Seats are limited and non-transferable.")
    
    add_text_box(sid, invite_text, card_x + pt(20), card_y + pt(68), card_w - pt(30), pt(150),
                font_size=9.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=140)
    
    add_shape(sid, "RECTANGLE", card_x + pt(20), card_y + pt(224), card_w - pt(40), pt(1), fill_color=GOLD)
    add_text_box(sid, "March 2026  ·  Los Angeles / Malibu  ·  Private Venue",
                card_x + pt(20), card_y + pt(230), card_w - pt(30), pt(20),
                font_size=8.5, color=GOLD, font_family="Montserrat", align="CENTER", italic=True)
    add_text_box(sid, "RSVP by February 14 · $650 per seat",
                card_x + pt(20), card_y + pt(254), card_w - pt(30), pt(20),
                font_size=9, bold=True, color=CREAM, font_family="Montserrat", align="CENTER")
    
    # Right column annotations
    notes_x = MARGIN_L + pt(410)
    notes_y = MARGIN_T + pt(72)
    notes_w = CONTENT_W - pt(410)
    
    annotations = [
        ("TONE", "Exclusive, not intimidating. Earned, not purchased."),
        ("SPECIFICITY", "\"30 capital allocators\" signals quality filtering. They know who else is coming."),
        ("FRICTION", "Invitation-only + limited seats = social proof. Scarcity drives response."),
        ("CLOSE", "Price and deadline front-loaded. No chase needed if the invite lands right."),
    ]
    for i, (label, note) in enumerate(annotations):
        ny = notes_y + i * pt(62)
        add_shape(sid, "RECTANGLE", notes_x, ny, notes_w - pt(12), pt(56), fill_color=DARK_CARD)
        add_text_box(sid, label, notes_x + pt(10), ny + pt(6), notes_w - pt(24), pt(16),
                    font_size=8, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, note, notes_x + pt(10), ny + pt(24), notes_w - pt(24), pt(28),
                    font_size=9, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=125)
    slide_number(sid, 6)

# ============================================================
# SLIDE 7 — EXPERIENCE FLOW
# ============================================================

def build_slide_7(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "EXPERIENCE FLOW", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "Every minute is designed.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=28, bold=True, color=WHITE, font_family="Montserrat")
    
    flow_steps = [
        ("6:30 PM", "ARRIVAL", "Guests arrive to a curated cocktail hour. No name badges. No company titles. Just people."),
        ("7:00 PM", "DINNER OPENS", "Curated seating by Mavros. Conversation guides at each place setting. Sommelier-led pour."),
        ("7:45 PM", "KEYNOTE MOMENT", "One 10-minute fireside — a practitioner, not a speaker. No slides. Just a real conversation."),
        ("8:15 PM", "LIVE RECORDING", "Mic goes live. Host leads structured Q&A for 'Inside The Capital Table' podcast episode."),
        ("9:00 PM", "DEAL ROOM", "Tables reorganized. Open networking. Sponsor activation. Private conversations encouraged."),
        ("10:00 PM", "CLOSE", "Guests receive curated follow-up packet. Mavros team makes warm introductions on exit."),
    ]
    
    py = MARGIN_T + pt(72)
    step_w = (CONTENT_W - pt(60)) // len(flow_steps)
    
    # Connector line
    add_shape(sid, "RECTANGLE", 
             MARGIN_L + pt(12) + step_w//2, 
             py + pt(28),
             CONTENT_W - step_w, pt(2), fill_color=GOLD)
    
    for i, (time, title, desc) in enumerate(flow_steps):
        sx = MARGIN_L + pt(12) + i * (step_w + pt(12))
        # Circle dot
        add_shape(sid, "ELLIPSE", sx + step_w//2 - pt(10), py + pt(18), pt(20), pt(20), 
                 fill_color=GOLD)
        add_text_box(sid, time, sx, py + pt(44), step_w, pt(16),
                    font_size=8, bold=True, color=GOLD, font_family="Montserrat", align="CENTER")
        add_text_box(sid, title, sx, py + pt(60), step_w, pt(20),
                    font_size=10, bold=True, color=WHITE, font_family="Montserrat", align="CENTER")
        add_text_box(sid, desc, sx, py + pt(82), step_w, pt(90),
                    font_size=8, color=LIGHT_GRAY, font_family="Montserrat", 
                    align="CENTER", line_spacing=125)
    
    # Bottom note
    add_text_box(sid, "Total runtime: 3.5 hours  ·  No filler. No wasted time. Designed to generate ROI for every person at the table.",
                MARGIN_L + pt(12), SLIDE_H - pt(42), CONTENT_W, pt(24),
                font_size=9, italic=True, color=GOLD, font_family="Montserrat", align="CENTER")
    slide_number(sid, 7)

# ============================================================
# SLIDE 8 — VENUE OPTIONS
# ============================================================

def build_slide_8(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "TOP VENUES — LA / MALIBU", MARGIN_L + pt(12), MARGIN_T, pt(300))
    add_text_box(sid, "The room signals everything.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    venues = [
        {
            "rank": "01",
            "name": "Nobu Malibu",
            "location": "22706 PCH, Malibu",
            "capacity": "Up to 50 (Private Dining + Fireplace Patio)",
            "rental": "F&B Minimum ~$15,000",
            "contact": "malibu.events@noburestaurants.com",
            "website": "noburestaurants.com/malibu",
            "why": "Oceanfront. Brand equity recognized globally. HNW guests already eat here. Name alone closes sponsors.",
        },
        {
            "rank": "02",
            "name": "Hotel Bel-Air",
            "location": "701 Stone Canyon Rd, Bel Air",
            "capacity": "20–60 (The Swan Room or Wolfgang's Terrace)",
            "rental": "On request — typically $5,000–$10,000 + F&B",
            "contact": "events@hotelbelair.com",
            "website": "hotelbelair.com",
            "why": "Legendary LA institution. Walled garden setting creates true privacy. Preferred by family office principals.",
        },
        {
            "rank": "03",
            "name": "Soho House West Hollywood",
            "location": "9200 Sunset Blvd, WeHo",
            "capacity": "20–80 (Luckman Club / Rooftop / Screening Room)",
            "rental": "Member access; event pricing on request",
            "contact": "events.westhollywood@sohohouse.com",
            "website": "sohohouse.com/en-us/houses/soho-house-west-hollywood",
            "why": "Built-in prestige filter. Members-only environment pre-qualifies the aesthetic. Strong for sponsor visibility.",
        },
    ]
    
    py = MARGIN_T + pt(72)
    for i, v in enumerate(venues):
        vy = py + i * pt(116)
        add_shape(sid, "RECTANGLE", MARGIN_L + pt(12), vy, CONTENT_W, pt(108), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", MARGIN_L + pt(12), vy, pt(3), pt(108), fill_color=GOLD)
        
        add_text_box(sid, v['rank'], MARGIN_L + pt(22), vy + pt(8), pt(30), pt(24),
                    font_size=18, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, v['name'], MARGIN_L + pt(58), vy + pt(8), pt(200), pt(24),
                    font_size=15, bold=True, color=WHITE, font_family="Montserrat")
        add_text_box(sid, v['location'], MARGIN_L + pt(58), vy + pt(32), pt(200), pt(16),
                    font_size=8.5, color=LIGHT_GRAY, font_family="Montserrat")
        add_text_box(sid, f"Cap: {v['capacity']}", MARGIN_L + pt(58), vy + pt(48), pt(280), pt(16),
                    font_size=8, color=LIGHT_GRAY, font_family="Montserrat")
        add_text_box(sid, f"Rental: {v['rental']}", MARGIN_L + pt(58), vy + pt(62), pt(280), pt(16),
                    font_size=8, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, f"Contact: {v['contact']}  ·  {v['website']}", 
                    MARGIN_L + pt(58), vy + pt(76), pt(360), pt(16),
                    font_size=7.5, color=LIGHT_GRAY, font_family="Montserrat")
        add_text_box(sid, f"✦ {v['why']}", MARGIN_L + pt(400), vy + pt(12), pt(270), pt(84),
                    font_size=9, italic=True, color=CREAM, font_family="Montserrat", 
                    align="START", line_spacing=130, v_align="MIDDLE")
    
    add_text_box(sid, "Additional options researched: Luxe Malibu Estate (Peerspace), The Little Door, Giorgio Baldi, Soho House Malibu",
                MARGIN_L + pt(12), SLIDE_H - pt(38), CONTENT_W, pt(22),
                font_size=8, color=rgb(100,100,110), font_family="Montserrat")
    slide_number(sid, 8)

# ============================================================
# SLIDE 9 — VENDOR STACK
# ============================================================

def build_slide_9(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "VENDOR STACK", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "Vetted. Premium. Podcast-capable.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    vendors = [
        ("CATERING", [
            ("Haute Chefs LA", "hautechefsla.com", "info@hautechefsla.com", "Bespoke culinary studio. Malibu experience. Luxury brand clients. Menu curation is their art form."),
            ("Wolfgang Puck Catering", "wolfgangpuckcatering.com", "la@wolfgangpuckcatering.com", "Oscar-pedigree catering. Name carries weight in HNW rooms. Impeccable execution at 30-person scale."),
            ("Marbled LA", "marbled.la", "events@marbled.la", "Boutique LA caterer specializing in private dinners. Customizable, chef-driven menus at intimate scale."),
        ]),
        ("AV / PRODUCTION", [
            ("Alliant Events", "alliantevents.com", "info@alliantevents.com", "Full AV production + podcast-grade audio. LA-based. Corporate event specialists with mobile recording rigs."),
            ("Corporate Events Inc.", "corporateeventsinc.net", "la@corporateeventsinc.net", "Intimate venue specialists. Podcast recording packages available. California-based crew."),
        ]),
        ("PHOTOGRAPHY", [
            ("The Lou Effect", "theloueffect.com", "hello@theloueffect.com", "Luxury Malibu + WeHo event specialist. Cinematic, story-driven. Exact aesthetic fit for Capital Table."),
            ("Kyle Espeleta Photography", "kyleespeletaphotography.com", "kyle@kyleespeletaphotography.com", "LA editorial event photographer. PR-ready imagery. MA/PR team background."),
        ]),
        ("STAFFING", [
            ("Premier Staff", "premierstaff.com", "book@premierstaff.com", "White-glove luxury event staffing. Vetted servers and hosts. Flat-rate pricing. LA-based with national reach."),
        ]),
    ]
    
    py = MARGIN_T + pt(68)
    col_w = (CONTENT_W - pt(24)) // 2
    
    row = 0
    for cat, items in vendors:
        col = 0 if cat in ["CATERING", "AV / PRODUCTION"] else 1
        if cat == "PHOTOGRAPHY":
            row = 0
        if cat == "STAFFING":
            row = 2
        
        by = py + row * pt(78)
        bx = MARGIN_L + pt(12) + col * (col_w + pt(24))
        
        add_text_box(sid, cat, bx, by, col_w, pt(16),
                    font_size=8, bold=True, color=GOLD, font_family="Montserrat")
        
        for j, (name, site, email, desc) in enumerate(items):
            iy = by + pt(18) + j * pt(52)
            add_shape(sid, "RECTANGLE", bx, iy, col_w, pt(48), fill_color=DARK_CARD)
            add_shape(sid, "RECTANGLE", bx, iy, pt(3), pt(48), fill_color=GOLD)
            add_text_box(sid, name, bx + pt(10), iy + pt(4), col_w - pt(16), pt(16),
                        font_size=10, bold=True, color=WHITE, font_family="Montserrat")
            add_text_box(sid, email, bx + pt(10), iy + pt(20), col_w - pt(16), pt(14),
                        font_size=7.5, color=GOLD, font_family="Montserrat")
            add_text_box(sid, desc, bx + pt(10), iy + pt(32), col_w - pt(16), pt(14),
                        font_size=7, color=LIGHT_GRAY, font_family="Montserrat")
        
        if cat == "CATERING":
            row += 3 * 1 + 0
            row = 3  # After 3 catering items
        elif cat == "AV / PRODUCTION":
            row = 0  # Reset to 0 for right col
    
    slide_number(sid, 9)

# ============================================================
# SLIDE 10 — SPONSOR TIERS
# ============================================================

def build_slide_10(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "SPONSOR TIERS", MARGIN_L + pt(12), MARGIN_T, pt(200))
    add_text_box(sid, "Qualified eyeballs. Not mass reach.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    tiers = [
        {
            "tier": "TITLE SPONSOR",
            "price": "$5,000–$10,000",
            "qty": "1 per event",
            "color": GOLD,
            "benefits": [
                "Exclusive verbal acknowledgment by host throughout event",
                "Logo on all event materials, invitations, and recap content",
                "2 reserved seats at the dinner",
                "Featured placement in podcast episode: 'Inside The Capital Table'",
                "Post-event attendee introduction (warm, opt-in)",
                "30-second branded segment in podcast episode",
                "Recap email to full attendee list (300–500 contacts by Q4)",
            ]
        },
        {
            "tier": "SUPPORTING SPONSOR",
            "price": "$2,500",
            "qty": "2 per event",
            "color": CREAM,
            "benefits": [
                "Logo on event materials and digital recap",
                "1 reserved seat at the dinner",
                "Verbal acknowledgment during deal room segment",
                "Mention in podcast episode show notes",
                "Post-event one-pager distribution to attendees",
            ]
        },
    ]
    
    py = MARGIN_T + pt(72)
    tier_w = (CONTENT_W - pt(24)) // 2
    
    for i, t in enumerate(tiers):
        tx = MARGIN_L + pt(12) + i * (tier_w + pt(24))
        add_shape(sid, "RECTANGLE", tx, py, tier_w, pt(310), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", tx, py, tier_w, pt(4), fill_color=t['color'])
        add_text_box(sid, t['tier'], tx + pt(16), py + pt(12), tier_w - pt(24), pt(22),
                    font_size=11, bold=True, color=t['color'], font_family="Montserrat")
        add_text_box(sid, t['price'], tx + pt(16), py + pt(36), tier_w - pt(24), pt(36),
                    font_size=28, bold=True, color=WHITE, font_family="Montserrat")
        add_text_box(sid, t['qty'], tx + pt(16), py + pt(74), tier_w - pt(24), pt(18),
                    font_size=9, italic=True, color=LIGHT_GRAY, font_family="Montserrat")
        
        add_shape(sid, "RECTANGLE", tx + pt(16), py + pt(95), tier_w - pt(32), pt(1), fill_color=GOLD)
        
        for j, benefit in enumerate(t['benefits']):
            by = py + pt(100) + j * pt(28)
            add_text_box(sid, f"✓  {benefit}", tx + pt(16), by, tier_w - pt(24), pt(25),
                        font_size=8.5, color=LIGHT_GRAY, font_family="Montserrat")
    
    # Target sponsors
    add_text_box(sid, "TARGET SPONSOR CATEGORIES",
                MARGIN_L + pt(12), py + pt(316), CONTENT_W, pt(18),
                font_size=8, bold=True, color=GOLD, font_family="Montserrat")
    
    sponsors_text = ("Kiavi (private lending)  ·  Juniper Square (RE investor mgmt SaaS)  ·  Dealpath (deal mgmt software)  ·  "
                    "First Western Financial (wealth mgmt)  ·  Luxury Portfolio International  ·  "
                    "RCM Capital Management  ·  Velocity Mortgage Capital  ·  Pacific Private Money")
    add_text_box(sid, sponsors_text, MARGIN_L + pt(12), py + pt(334), CONTENT_W, pt(28),
                font_size=8.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=130)
    slide_number(sid, 10)

# ============================================================
# SLIDE 11 — UNIT ECONOMICS
# ============================================================

def build_slide_11(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "UNIT ECONOMICS — ONE EVENT", MARGIN_L + pt(12), MARGIN_T, pt(300))
    add_text_box(sid, "The P&L for one Capital Table.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    # Costs column
    cx = MARGIN_L + pt(12)
    cy = MARGIN_T + pt(72)
    cw = pt(300)
    
    add_text_box(sid, "COSTS", cx, cy, cw, pt(20), font_size=9, bold=True, color=GOLD, font_family="Montserrat")
    
    costs = [
        ("Venue Rental", "$5,000 – $8,000"),
        ("Catering (30 pax @ $150–200/pp)", "$4,500 – $6,000"),
        ("AV + Production", "$3,000"),
        ("Photography", "$2,000"),
        ("Event Staffing", "$1,500"),
        ("Miscellaneous", "$1,000"),
    ]
    
    for i, (item, amount) in enumerate(costs):
        iy = cy + pt(22) + i * pt(32)
        add_shape(sid, "RECTANGLE", cx, iy, cw, pt(28), fill_color=DARK_CARD)
        add_text_box(sid, item, cx + pt(10), iy + pt(6), pt(185), pt(18),
                    font_size=9, color=LIGHT_GRAY, font_family="Montserrat")
        add_text_box(sid, amount, cx + pt(195), iy + pt(6), pt(100), pt(18),
                    font_size=9, bold=True, color=WHITE, font_family="Montserrat", align="END")
    
    total_y = cy + pt(22) + len(costs) * pt(32) + pt(6)
    add_shape(sid, "RECTANGLE", cx, total_y, cw, pt(36), fill_color=GOLD)
    add_text_box(sid, "TOTAL COSTS", cx + pt(10), total_y + pt(8), pt(185), pt(20),
                font_size=11, bold=True, color=CHARCOAL, font_family="Montserrat")
    add_text_box(sid, "$17,000 – $21,500", cx + pt(155), total_y + pt(8), pt(140), pt(20),
                font_size=11, bold=True, color=CHARCOAL, font_family="Montserrat", align="END")
    
    # Revenue column
    rx = MARGIN_L + pt(12) + pt(324)
    ry = cy
    rw = CONTENT_W - pt(324)
    
    add_text_box(sid, "REVENUE", rx, ry, rw, pt(20), font_size=9, bold=True, color=GOLD, font_family="Montserrat")
    
    revenues = [
        ("Tickets: 30 guests @ $500–800", "$15,000 – $24,000"),
        ("Title Sponsor (1x)", "$5,000 – $10,000"),
        ("Supporting Sponsors (2x @ $2,500)", "$5,000"),
        ("Total Sponsorship", "$10,000 – $15,000"),
    ]
    
    for i, (item, amount) in enumerate(revenues):
        iy = ry + pt(22) + i * pt(32)
        is_subtotal = item.startswith("Total")
        add_shape(sid, "RECTANGLE", rx, iy, rw, pt(28), 
                 fill_color=DARK_CARD if not is_subtotal else rgb(38,38,48))
        add_text_box(sid, item, rx + pt(10), iy + pt(6), rw - pt(120), pt(18),
                    font_size=9, color=LIGHT_GRAY if not is_subtotal else CREAM, 
                    bold=is_subtotal, font_family="Montserrat")
        add_text_box(sid, amount, rx + rw - pt(118), iy + pt(6), pt(108), pt(18),
                    font_size=9, bold=True, color=GOLD if is_subtotal else WHITE, 
                    font_family="Montserrat", align="END")
    
    rev_total_y = ry + pt(22) + len(revenues) * pt(32) + pt(6)
    add_shape(sid, "RECTANGLE", rx, rev_total_y, rw, pt(36), fill_color=GOLD)
    add_text_box(sid, "TOTAL REVENUE", rx + pt(10), rev_total_y + pt(8), rw - pt(120), pt(20),
                font_size=11, bold=True, color=CHARCOAL, font_family="Montserrat")
    add_text_box(sid, "$25,000 – $39,000", rx + rw - pt(160), rev_total_y + pt(8), pt(148), pt(20),
                font_size=11, bold=True, color=CHARCOAL, font_family="Montserrat", align="END")
    
    # Net
    net_y = max(total_y, rev_total_y) + pt(46)
    add_shape(sid, "RECTANGLE", cx, net_y, CONTENT_W, pt(52), fill_color=DARK_CARD)
    add_shape(sid, "RECTANGLE", cx, net_y, CONTENT_W, pt(3), fill_color=GOLD)
    add_text_box(sid, "NET PER EVENT", cx + pt(16), net_y + pt(10), pt(200), pt(28),
                font_size=13, bold=True, color=GOLD, font_family="Montserrat")
    add_text_box(sid, "$4,000 – $18,000", cx + pt(220), net_y + pt(6), pt(300), pt(36),
                font_size=28, bold=True, color=WHITE, font_family="Montserrat")
    add_text_box(sid, "before Mavros management fee", 
                cx + pt(220) + pt(300) + pt(10), net_y + pt(22), pt(200), pt(22),
                font_size=8, italic=True, color=LIGHT_GRAY, font_family="Montserrat")
    slide_number(sid, 11)

# ============================================================
# SLIDE 12 — BREAK-EVEN ANALYSIS
# ============================================================

def build_slide_12(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "BREAK-EVEN ANALYSIS", MARGIN_L + pt(12), MARGIN_T, pt(260))
    add_text_box(sid, "Profitable before a single sponsor.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    # Big BEP numbers
    stats = [
        ("14", "GUESTS", "to break even at $650/ticket\n(no sponsors)"),
        ("$0", "SPONSOR NEEDED", "to break even if 30 tickets sold at $650"),
        ("$1,500", "MARGIN/GUEST", "at 30 guests + 1 title sponsor\n(avg scenario)"),
    ]
    
    sy = MARGIN_T + pt(72)
    sw = (CONTENT_W - pt(48)) // 3
    
    for i, (val, label, sub) in enumerate(stats):
        sx = MARGIN_L + pt(12) + i * (sw + pt(24))
        add_shape(sid, "RECTANGLE", sx, sy, sw, pt(130), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", sx, sy, sw, pt(4), fill_color=GOLD)
        add_text_box(sid, val, sx + pt(12), sy + pt(10), sw - pt(20), pt(52),
                    font_size=40, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, label, sx + pt(12), sy + pt(64), sw - pt(20), pt(22),
                    font_size=11, bold=True, color=WHITE, font_family="Montserrat")
        add_text_box(sid, sub, sx + pt(12), sy + pt(86), sw - pt(20), pt(38),
                    font_size=8.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=130)
    
    # Scenario table
    table_y = sy + pt(142)
    add_text_box(sid, "SCENARIOS — 30 GUESTS", MARGIN_L + pt(12), table_y, CONTENT_W, pt(18),
                font_size=9, bold=True, color=GOLD, font_family="Montserrat")
    
    scenarios = [
        ("Conservative", "30 tickets @ $500", "$0 sponsor", "$15,000", "$17,000", "-$2,000"),
        ("Base Case", "30 tickets @ $650", "1 sponsor $5K + 2x $2.5K", "$19,500 + $10K = $29,500", "$19,000", "+$10,500"),
        ("Upside", "30 tickets @ $800", "1 sponsor $10K + 2x $2.5K", "$24,000 + $15K = $39,000", "$21,500", "+$17,500"),
    ]
    
    headers = ["SCENARIO", "TICKETS", "SPONSORS", "REVENUE", "COSTS", "NET"]
    col_widths = [pt(100), pt(110), pt(160), pt(160), pt(80), pt(80)]
    
    for j, header in enumerate(headers):
        hx = MARGIN_L + pt(12) + sum(col_widths[:j])
        add_shape(sid, "RECTANGLE", hx, table_y + pt(20), col_widths[j], pt(22), fill_color=GOLD)
        add_text_box(sid, header, hx + pt(4), table_y + pt(24), col_widths[j] - pt(8), pt(16),
                    font_size=7.5, bold=True, color=CHARCOAL, font_family="Montserrat")
    
    for i, row in enumerate(scenarios):
        ry = table_y + pt(42) + i * pt(28)
        row_bg = DARK_CARD if i % 2 == 0 else rgb(24, 24, 32)
        for j, cell in enumerate(row):
            cx = MARGIN_L + pt(12) + sum(col_widths[:j])
            add_shape(sid, "RECTANGLE", cx, ry, col_widths[j], pt(24), fill_color=row_bg)
            cell_color = GOLD if j == 5 and cell.startswith('+') else (rgb(220, 80, 80) if j == 5 and cell.startswith('-') else LIGHT_GRAY)
            add_text_box(sid, cell, cx + pt(4), ry + pt(4), col_widths[j] - pt(8), pt(16),
                        font_size=7.5, color=cell_color, bold=(j==0), font_family="Montserrat")
    
    slide_number(sid, 12)

# ============================================================
# SLIDE 13 — REVENUE UPSIDE
# ============================================================

def build_slide_13(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "REVENUE UPSIDE — QUARTERLY CADENCE", MARGIN_L + pt(12), MARGIN_T, pt(380))
    add_text_box(sid, "4 events. 4 cities. 1 brand.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=28, bold=True, color=WHITE, font_family="Montserrat")
    add_text_box(sid, "The format doesn't change. The city does.",
                MARGIN_L + pt(12), MARGIN_T + pt(68), CONTENT_W, pt(28),
                font_size=14, italic=True, color=GOLD, font_family="Montserrat")
    
    quarters = [
        ("Q1", "Los Angeles\n/ Malibu", "$10,500 net", "Base case"),
        ("Q2", "Austin, TX", "$10,500 net", "New market debut"),
        ("Q3", "Miami, FL", "$10,500 net", "High-season timing"),
        ("Q4", "New York City", "$17,500 net", "Upside market"),
    ]
    
    qy = MARGIN_T + pt(102)
    qw = (CONTENT_W - pt(36)) // 4
    
    for i, (q, city, net, note) in enumerate(quarters):
        qx = MARGIN_L + pt(12) + i * (qw + pt(12))
        add_shape(sid, "RECTANGLE", qx, qy, qw, pt(210), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", qx, qy, qw, pt(4), fill_color=GOLD)
        
        add_text_box(sid, q, qx + pt(12), qy + pt(10), qw - pt(20), pt(30),
                    font_size=24, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, city, qx + pt(12), qy + pt(44), qw - pt(20), pt(36),
                    font_size=13, bold=True, color=WHITE, font_family="Montserrat", line_spacing=120)
        add_shape(sid, "RECTANGLE", qx + pt(12), qy + pt(84), qw - pt(24), pt(1), fill_color=GOLD)
        add_text_box(sid, net, qx + pt(12), qy + pt(90), qw - pt(20), pt(36),
                    font_size=18, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, note, qx + pt(12), qy + pt(130), qw - pt(20), pt(20),
                    font_size=8, italic=True, color=LIGHT_GRAY, font_family="Montserrat")
        
        # Bar chart bar
        bar_h = int(pt(50) * (i + 1) / 4 * 1.5 + pt(30))
        bar_y = qy + pt(155) + (pt(50) - bar_h) if bar_h < pt(50) else qy + pt(155)
        add_shape(sid, "RECTANGLE", qx + pt(12), qy + pt(205) - min(bar_h, pt(50)), 
                 qw - pt(24), min(bar_h, pt(50)), fill_color=GOLD)
    
    # Totals
    ty = qy + pt(222)
    add_shape(sid, "RECTANGLE", MARGIN_L + pt(12), ty, CONTENT_W, pt(60), fill_color=DARK_CARD)
    add_shape(sid, "RECTANGLE", MARGIN_L + pt(12), ty, CONTENT_W, pt(4), fill_color=GOLD)
    
    add_text_box(sid, "ANNUAL REVENUE (Base Case)", MARGIN_L + pt(22), ty + pt(8), pt(350), pt(22),
                font_size=13, bold=True, color=GOLD, font_family="Montserrat")
    add_text_box(sid, "$118,000", MARGIN_L + pt(22) + pt(360), ty + pt(4), pt(200), pt(30),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    
    add_text_box(sid, "ANNUAL REVENUE (Upside)", MARGIN_L + pt(22), ty + pt(36), pt(350), pt(20),
                font_size=11, color=LIGHT_GRAY, font_family="Montserrat")
    add_text_box(sid, "$156,000", MARGIN_L + pt(22) + pt(360), ty + pt(36), pt(200), pt(22),
                font_size=18, bold=True, color=GOLD, font_family="Montserrat")
    
    add_text_box(sid, "Excludes Mavros management fee · Podcast ad revenue adds $2K–$8K/yr additional · Sponsor relationship value compounds annually",
                MARGIN_L + pt(12), SLIDE_H - pt(38), CONTENT_W, pt(22),
                font_size=8, color=rgb(100,100,110), font_family="Montserrat")
    slide_number(sid, 13)

# ============================================================
# SLIDE 14 — PODCAST INTEGRATION
# ============================================================

def build_slide_14(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "PODCAST INTEGRATION", MARGIN_L + pt(12), MARGIN_T, pt(260))
    add_text_box(sid, "Inside The Capital Table",
                MARGIN_L + pt(12), MARGIN_T + pt(24), pt(500), pt(48),
                font_size=32, bold=True, color=GOLD, font_family="Montserrat", italic=True)
    add_text_box(sid, "Every event becomes an episode.",
                MARGIN_L + pt(12), MARGIN_T + pt(76), pt(500), pt(28),
                font_size=14, color=CREAM, font_family="Montserrat")
    
    pod_points = [
        ("LIVE SEGMENT", 
         "During every dinner, a 20–30 min recorded conversation is captured live — a panel or fireside with 2–3 guests from the room. Professional audio via AV vendor's podcast-grade rig."),
        ("POST-PRODUCTION",
         "Episode edited to 18–25 mins, branded intro/outro, sponsor read embedded. Distributed to Spotify, Apple Podcasts, YouTube within 2 weeks post-event."),
        ("DISTRIBUTION FLYWHEEL",
         "Episode shared to attendees, sponsors, and Mavros's growing HNW network. Each episode drives new guest interest for the next event. Organic waitlist growth."),
        ("SPONSOR VALUE",
         "Title sponsor gets a 30-second branded read in each episode. 4 events = 4 episodes = 4 permanent branded content assets. Sponsors buy exposure they can track."),
        ("LONG-TERM IP",
         "By Q4, Mavros has a 16-episode back catalog from 4 cities. Platform for guests, sponsors, and a media brand that compounds. Exit value: licensing, paid tier, live show."),
        ("MONETIZATION PATH",
         "Podcast ad revenue: $25–50 CPM on 500–2K downloads/episode = $500–$4,000/episode. Year 1: $2K–$8K additional revenue at zero marginal cost."),
    ]
    
    py = MARGIN_T + pt(110)
    pw = (CONTENT_W - pt(24)) // 2
    
    for i, (title, body) in enumerate(pod_points):
        col = i % 2
        row = i // 2
        bx = MARGIN_L + pt(12) + col * (pw + pt(24))
        by = py + row * pt(88)
        add_shape(sid, "RECTANGLE", bx, by, pw, pt(82), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", bx, by, pt(3), pt(82), fill_color=GOLD)
        add_text_box(sid, title, bx + pt(12), by + pt(8), pw - pt(20), pt(18),
                    font_size=8.5, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, body, bx + pt(12), by + pt(28), pw - pt(20), pt(50),
                    font_size=8.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=128)
    
    slide_number(sid, 14)

# ============================================================
# SLIDE 15 — AI ASSIST LAYER
# ============================================================

def build_slide_15(sid):
    set_bg(sid, CHARCOAL)
    add_shape(sid, "RECTANGLE", 0, 0, pt(6), SLIDE_H, fill_color=GOLD)
    section_label(sid, "AI ASSIST LAYER — POWERED BY OPENCLAW", MARGIN_L + pt(12), MARGIN_T, pt(400))
    add_text_box(sid, "Operational leverage. Not replacement.",
                MARGIN_L + pt(12), MARGIN_T + pt(24), CONTENT_W, pt(40),
                font_size=26, bold=True, color=WHITE, font_family="Montserrat")
    add_text_box(sid, "4 lightweight automations that give Mavros 10x the output of a 3-person operations team.",
                MARGIN_L + pt(12), MARGIN_T + pt(68), CONTENT_W, pt(24),
                font_size=11, italic=True, color=LIGHT_GRAY, font_family="Montserrat")
    
    automations = [
        {
            "num": "01",
            "title": "Venue Sourcing",
            "trigger": "TRIGGER: New event created",
            "steps": [
                "Searches web for venues matching Capital Table format (city, capacity, aesthetic)",
                "Outputs ranked shortlist table with pricing, contacts, Mavros fit score",
                "Logs top 5 to CRM / Google Sheets automatically",
            ],
            "time_saved": "4–6 hrs → 12 mins"
        },
        {
            "num": "02",
            "title": "Sponsor Outreach",
            "trigger": "TRIGGER: Sponsor shortlist approved",
            "steps": [
                "Drafts personalized pitch email per company (name, why this room, tier suggestion)",
                "Sends via Gmail with Mavros signature — no manual copy-paste",
                "Tracks open/reply status in CRM, flags non-responders at 48hrs",
            ],
            "time_saved": "3–4 hrs → 8 mins"
        },
        {
            "num": "03",
            "title": "Guest Confirmation",
            "trigger": "TRIGGER: 14 days before event",
            "steps": [
                "Sends personalized confirmation email to each confirmed guest",
                "Flags non-responders after 72hrs for Mavros follow-up",
                "Updates live attendee list in real-time as RSVPs come in",
            ],
            "time_saved": "2–3 hrs → 5 mins"
        },
        {
            "num": "04",
            "title": "Post-Event ROI Summary",
            "trigger": "TRIGGER: Event date + 1 day",
            "steps": [
                "Pulls attendee count, sponsor data, and cost log from CRM",
                "Generates formatted PDF summary with P&L, photos index, sponsor recap",
                "Emails to Isaac + sponsors within 24 hours of event close",
            ],
            "time_saved": "3–5 hrs → 10 mins"
        },
    ]
    
    py = MARGIN_T + pt(98)
    aw = (CONTENT_W - pt(36)) // 4
    
    for i, auto in enumerate(automations):
        ax = MARGIN_L + pt(12) + i * (aw + pt(12))
        add_shape(sid, "RECTANGLE", ax, py, aw, pt(250), fill_color=DARK_CARD)
        add_shape(sid, "RECTANGLE", ax, py, aw, pt(4), fill_color=GOLD)
        
        add_text_box(sid, auto['num'], ax + pt(10), py + pt(8), aw - pt(16), pt(22),
                    font_size=16, bold=True, color=GOLD, font_family="Montserrat")
        add_text_box(sid, auto['title'], ax + pt(10), py + pt(32), aw - pt(16), pt(22),
                    font_size=11, bold=True, color=WHITE, font_family="Montserrat")
        add_shape(sid, "RECTANGLE", ax + pt(10), py + pt(56), aw - pt(20), pt(1), fill_color=GOLD)
        add_text_box(sid, auto['trigger'], ax + pt(10), py + pt(60), aw - pt(16), pt(18),
                    font_size=7.5, bold=True, color=GOLD, font_family="Montserrat")
        
        for j, step in enumerate(auto['steps']):
            sy = py + pt(80) + j * pt(40)
            add_text_box(sid, f"→ {step}", ax + pt(10), sy, aw - pt(16), pt(36),
                        font_size=7.5, color=LIGHT_GRAY, font_family="Montserrat", line_spacing=125)
        
        add_shape(sid, "RECTANGLE", ax + pt(10), py + pt(205), aw - pt(20), pt(1), fill_color=GOLD)
        add_text_box(sid, auto['time_saved'], ax + pt(10), py + pt(210), aw - pt(16), pt(22),
                    font_size=9, bold=True, color=GOLD, font_family="Montserrat")
    
    # Bottom note
    add_text_box(sid, 
                "OpenClaw is the AI operations layer — triggered by Mavros, always under human oversight. "
                "It doesn't replace judgment. It removes the busywork that delays it.",
                MARGIN_L + pt(12), SLIDE_H - pt(46), CONTENT_W, pt(30),
                font_size=9, italic=True, color=LIGHT_GRAY, font_family="Montserrat", align="CENTER")
    slide_number(sid, 15)


# ============================================================
# EXECUTE ALL SLIDE BUILDS (populate requests)
# ============================================================

# We'll call build functions after slides are created
# First batch: create slides + set backgrounds
print("   Executing batch 1: slide creation...")
service.presentations().batchUpdate(
    presentationId=PRESENTATION_ID,
    body={"requests": all_requests}
).execute()

print("   ✅ Slides created")

# Now get fresh slide IDs
pres_fresh = service.presentations().get(presentationId=PRESENTATION_ID).execute()
fresh_slides = pres_fresh['slides']
print(f"   Now have {len(fresh_slides)} slides")

# Map to slide IDs (first was already set above, rest are new)
final_slide_ids = [s['objectId'] for s in fresh_slides]

# ============================================================
# BUILD ALL SLIDE CONTENT
# ============================================================

all_requests = []

build_slide_2(final_slide_ids[1])
build_slide_3(final_slide_ids[2])
build_slide_4(final_slide_ids[3])
build_slide_5(final_slide_ids[4])
build_slide_6(final_slide_ids[5])
build_slide_7(final_slide_ids[6])
build_slide_8(final_slide_ids[7])
build_slide_9(final_slide_ids[8])
build_slide_10(final_slide_ids[9])
build_slide_11(final_slide_ids[10])
build_slide_12(final_slide_ids[11])
build_slide_13(final_slide_ids[12])
build_slide_14(final_slide_ids[13])
build_slide_15(final_slide_ids[14])

print(f"   Executing batch 2: {len(all_requests)} content requests...")

# Google Slides API has a 200-request limit per batchUpdate
BATCH_SIZE = 150
for batch_start in range(0, len(all_requests), BATCH_SIZE):
    batch = all_requests[batch_start:batch_start + BATCH_SIZE]
    print(f"   Sending requests {batch_start}–{batch_start + len(batch)}...")
    service.presentations().batchUpdate(
        presentationId=PRESENTATION_ID,
        body={"requests": batch}
    ).execute()

print("   ✅ All content added!")

# ============================================================
# SHARE WITH ZED
# ============================================================

print("📤 Sharing with zed.truong@vennapp.co...")
drive_service.permissions().create(
    fileId=PRESENTATION_ID,
    body={"type": "user", "role": "writer", "emailAddress": "zed.truong@vennapp.co"},
    sendNotificationEmail=False
).execute()
print("   ✅ Shared!")

print(f"\n🎉 DONE!")
print(f"   Presentation URL: https://docs.google.com/presentation/d/{PRESENTATION_ID}/edit")
print(f"   Slide count: {len(final_slide_ids)}")
