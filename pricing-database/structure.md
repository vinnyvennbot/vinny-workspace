# Venn Social Pricing Database Structure

## Google Drive Folder Organization

```
📁 Venn Pricing Database/
├── 📁 01-Event-Venues/
│   ├── Event Venues Master.csv
│   ├── Historic Venues.csv
│   ├── Modern Event Spaces.csv
│   └── Outdoor Venues.csv
├── 📁 02-Dining-Venues/
│   ├── Dining Venues Master.csv
│   ├── Fine Dining.csv
│   ├── Casual Restaurants.csv
│   └── Private Dining Rooms.csv
├── 📁 03-Vendors/
│   ├── Vendors Master.csv
│   ├── Catering.csv
│   ├── Entertainment.csv
│   ├── Audio-Visual.csv
│   ├── Photography.csv
│   └── Specialty Services.csv
├── 📁 04-Partners/
│   ├── Partners Master.csv
│   ├── Sponsors.csv
│   └── Media Partners.csv
├── 📁 05-Influencers/
│   ├── Influencers Master.csv
│   ├── Local Influencers.csv
│   └── Event Personalities.csv
└── 📊 MASTER-PRICING-OVERVIEW.csv
```

## Spreadsheet Formatting Standards

### Headers (Row 1)
- **Background:** Deep blue (#1c4587)
- **Text:** White, Bold, 12pt
- **Height:** 35px

### Data Rows
- **Alternating colors:** White / Light gray (#f8f9fa)
- **Borders:** Light gray
- **Text:** 11pt Roboto

### Key Columns
- **Status:** Color-coded (Green=Booked, Yellow=Quoted, Red=Declined)
- **Pricing:** Currency format with $ symbol
- **Dates:** MM/DD/YYYY format
- **Ratings:** 1-5 stars visual

### Auto-Features
- **Filters** enabled on all headers
- **Freeze** first row
- **Auto-resize** columns
- **Data validation** on status/rating columns