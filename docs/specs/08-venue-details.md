# 08 — Venue Details Page

## Overview
Public-facing page for a venue. Pulled largely from Google Places data.

## Layout

### Header
- Parallax image of the venue (sourced from Google Places)

### Venue info
- Venue name
- Address
- "Get Directions" button — opens native maps app

### Description
- Venue description sourced from Google Places

### Upcoming gigs
- List of all upcoming gigs at this venue
- Same gig card format as the audience home screen

## Open questions
- What happens if Google Places has no image for the venue? (fallback placeholder?)
- What happens if Google Places has no description?
- Can a user follow the venue from this page?
- Do we show past gigs? If so, how are they separated from upcoming?
- How do we map our internal venues to Google Places entries?
- Do we cache Google Places data or fetch fresh on each visit?
