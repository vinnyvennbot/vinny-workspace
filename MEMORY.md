# Long-Term Memory

## User Preferences
- Event budget typically $40-70/person range
- Values authentic, story-driven experiences  
- Focus on profit maximization without brand dilution
- Prefers comprehensive proposals with detailed financial modeling

## Important Decisions
- **February 2, 2026:** Assigned ownership of full event lifecycle for Venn Social
- **First Projects:** Intimate 30-person dinner (<$70/person) + Western line dancing event
- **Event Targets:** 2/month - one high-production (100+), one mid-production (<100)

## Persistent Facts
- **My Role:** AI employee of Venn Social with operational authority over events
- **Team:** Zed (ops/business), Gedeon & Aidan (tech), all run Venn Social together
- **GitHub Access:** Pacific-Software-Ventures/venn-backend (Go backend, APIs for auth/events/users/matching/chat)  
- **GitHub Access:** Pacific-Software-Ventures/Venn-app (Mobile app)  
- **Brand:** Unique, story-driven SF experiences in historic venues (mansions, boats, ballrooms)
- **Revenue Sources:** Ticket sales, memberships, sponsorships, creative monetization
- **Contact:** vinny@vennapp.co, Google Workspace access confirmed
- **OPERATIONAL CONSTRAINT:** Max retries = 3 for ALL automated processes (email, API calls, vendor outreach) - NO EXCEPTIONS
- **EMAIL VERIFICATION:** Always verify email addresses exist before sending - use Google Places to find correct contact details
- **CONTACT RESEARCH:** Never assume email formats - always research actual contact information through official sources
- **IMPORTANT:** Always share Google Drive files/folders with zed.truong@vennapp.co (writer access) immediately after creation
- **CRITICAL:** Always audit formulas in financial models before presenting - check all cell references and calculations
- **EXCEL FORMULA ERRORS TO AVOID:** 
  * Never create circular references (cell referencing itself like B15=B15+X)
  * Never divide by cells that could be zero or None - always check denominators exist
  * Use absolute references ($B$15) when referencing totals from multiple rows
  * Test formulas with actual data before considering complete
  * Revenue cells should NEVER reference themselves in calculations
  * Always verify each formula references the correct cells (B15 not B16, etc.)
- **FINANCIAL MODEL STRUCTURE:** Inputs → Calculations → Outputs, never circular flows
- **NEVER CREATE DUPLICATES:** Always edit existing files instead of creating new ones for updates/fixes
- **FILE MANAGEMENT:** Keep only the most recent/best version - delete old duplicates immediately
- **GOOGLE SHEETS ORGANIZATION:** 
  * **FOLDER STRUCTURE**: Database/ → Venues/, Vendors/, Partners/, Influencers/
  * One master database per category (Venues, Vendors, Partners, etc.)
  * Place each master sheet in its correct subfolder within Database/
  * Use descriptive, consistent naming conventions
  * Always check if a file already exists before creating new
  * Professional formatting: frozen headers, proper column widths, consistent styling
- **NEVER CREATE DUPLICATES:** Always edit existing files instead of creating new ones for updates/fixes
- **FILE MANAGEMENT:** Keep only the most recent/best version - delete old duplicates immediately
- **GOOGLE SHEETS CLEANUP COMPLETED 2026-02-03:** 
  * Consolidated "Vendors Master Database" → "Vendors Master" (improved structure)
  * Consolidated "Partners Master Database" → "Partners Master" (improved structure) 
  * Deleted duplicate files to prevent clutter
  * **PROPER FOLDER ORGANIZATION:** Created Database/ → Venues/, Vendors/, Partners/, Influencers/ 
  * Moved all master sheets to correct subfolders
  * Shared full Database folder structure with zed.truong@vennapp.co (writer access)
- **FINANCIAL MODEL AUDIT & FIX 2026-02-03:**
  * Found division by zero risk in western_dancing_financial_model.xlsx (D19-D23 divided by empty B15)
  * Fixed broken formula chain: B13 (ticket sales), B14 (sponsorship), B15 (total revenue)
  * Calculated model: $9K revenue, $7.5K costs, $1.5K profit (16.7% margin)
  * **ALSO FIXED:** intimate_dinner_financial_model.xlsx (same division by zero issues)
  * **CRITICAL FINDING:** Intimate dinner costs $72/person, exceeds $70 limit by $2
  * Created FIXED versions of both models with proper calculations
  * Shared both fixed versions with zed.truong@vennapp.co
- **VENDOR DATABASE SYSTEM:** 
  * Location: `/Users/vinnyvenn/.openclaw/workspace/vendor-database/`
  * JSON database: `venue-pricing.json` (structured data)
  * CSV export: `venue-pricing.csv` (ready for Google Sheets)
  * Parser: `parse-pricing-email.py` (intelligent email parsing)
  * **WHEN EMAILS FORWARDED:** Automatically extract venue name, contact info, pricing, capacity
  * **ALWAYS EXPORT TO CSV** after updates for Google Sheets sync
  * **SHARE WITH ZEDS:** Always share database updates with zed.truong@vennapp.co
  * **GOOGLE SHEETS ACCESS:** Use `gog` CLI (already set up) - NOT Maton API
