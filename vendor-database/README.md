# Venn Social Vendor Database

Intelligent storage and management of venue/vendor pricing information.

## Quick Usage

When Venn team forwards pricing emails:

1. **Parse email:** Extract venue name, contact info, and pricing automatically
2. **Store in JSON:** Structured data in `venue-pricing.json` 
3. **Export to CSV:** Ready for Google Sheets import
4. **Share with team:** Send updated CSV to zed.truong@vennapp.co

## Files

- `venue-pricing.json` - Main database (structured JSON)
- `venue-pricing.csv` - Google Sheets compatible export
- `parse-pricing-email.py` - Email parsing engine
- `README.md` - This file

## Email Parsing Features

**Automatically extracts:**
- Venue/vendor name
- Contact info (phone, email, website)
- Pricing (rental fees, per-person costs, minimums, deposits)
- Capacity information
- Booking status

**Smart pattern recognition for:**
- Dollar amounts ($3,500, 45 per person, etc.)
- Phone numbers (various formats)
- Email addresses
- Websites
- Pricing context (rental, per person, minimum, deposit)

## Usage Examples

```bash
# Test the parser
python3 parse-pricing-email.py test

# Export to CSV for Google Sheets
python3 parse-pricing-email.py export
```

## Integration

- **Max retries:** 3 for all automated processes
- **Always CC Zed:** zed.truong@vennapp.co on vendor communications
- **File sharing:** Auto-share Google Drive files with team
- **Continuous improvement:** Track all vendor interactions for optimization

## Data Structure

Each venue entry includes:
- Basic info (name, address, contact)
- Capacity (seated, standing, outdoor)
- Pricing (rental, per person, minimums, deposits)
- Amenities and restrictions
- Notes and Venn rating (1-5)
- Booking status tracking