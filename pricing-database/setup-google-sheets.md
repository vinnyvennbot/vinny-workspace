# Google Sheets Setup for Venn Pricing Database

## Quick Setup Steps

### 1. Get Maton API Key
1. Go to [maton.ai](https://maton.ai) and sign in
2. Navigate to [Settings](https://maton.ai/settings) 
3. Copy your API key

### 2. Set Environment Variable
```bash
export MATON_API_KEY="your-api-key-here"
```

### 3. Connect Google Account
```bash
curl -s -X POST 'https://ctrl.maton.ai/connections' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d '{"app": "google-sheets"}'
```

This returns a URL - open it in browser to authorize Google Sheets access.

### 4. Create All Spreadsheets
```bash
python3 create-google-sheets.py
```

## What Gets Created

### 📁 Spreadsheets Created:
- **🎯 VENN PRICING MASTER OVERVIEW** - Main dashboard
- **Event Venues Master** - All event spaces
- **Dining Venues Master** - Restaurants and dining
- **Vendors Master** - All service providers  
- **Partners Master** - Sponsors and partnerships
- **Influencers Master** - Content creators

### 🎨 Beautiful Formatting:
- **Blue headers** with white bold text
- **Frozen first row** for easy scrolling
- **Auto-filters** on all columns
- **Alternating row colors** for easy reading
- **Auto-resized columns** for perfect fit

### 🔄 Auto-Sharing:
All spreadsheets automatically shared with:
- zed.truong@vennapp.co (edit access)

## Usage After Setup

When pricing emails are forwarded:
1. **Parse automatically** → Extract venue/vendor data
2. **Update databases** → JSON + CSV + Google Sheets
3. **Notify team** → Auto-share updates

## Manual Import (Alternative)

If API setup has issues, you can manually import:
1. Upload CSV files to Google Drive
2. Convert to Google Sheets format
3. Apply formatting manually
4. Share with team