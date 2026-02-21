# Email Tool Limitation - Feb 21, 2026 2:04 PM

## Critical Discovery
`gog gmail` v0.9.0 **cannot read email bodies** - only list/search with metadata.

## What Doesn't Work
- `gog gmail MESSAGE_ID` (doesn't exist)
- `gog gmail get MESSAGE_ID` (doesn't exist)
- `gog gmail show MESSAGE_ID` (doesn't exist)
- `gog gmail messages search --body` (flag doesn't exist)

## What DOES Work
```bash
# Search/list with metadata only
gog gmail search "query" --max 20
gog gmail messages search "query" --max 20
```

Returns: ID, thread, date, from, subject, labels - NO BODY CONTENT

## Impact
- **Cannot autonomously monitor vendor email content**
- **Cannot read responses to determine next actions**
- **Blocks HEARTBEAT.md Tier 1 requirement**: "Email scan for vendor responses"

## Immediate Workaround
Alert Zed to manually check critical vendor threads until tool upgrade.

## Vendor Emails Needing Manual Review (Feb 21 10AM-2PM)
1. The Chapel (tripleseat) - Event Request
2. NEON/Teddy Kramer - 4 messages about booking
3. Peerspace/Aireene E - venue message
4. Giggster/Payam A - 3 messages re: Deco Room
5. Peerspace/Nate B - follow-up
6. Zed forward - 10/31 contract reminder

## Next Steps
- Update TOOLS.md with accurate gog gmail limitations
- Request gog upgrade or alternative email reading solution
- Escalate to Zed: autonomous email monitoring currently impossible
