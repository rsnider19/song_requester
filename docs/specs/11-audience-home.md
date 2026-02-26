# 11 — Audience Home Screen

## Overview
The default landing screen for audience users. Shows upcoming gigs near the user, with search functionality.

## Default view
- List of upcoming gigs near the user's location
- Each gig card shows:
  - Performer name
  - Venue name
  - Date
  - Start and end time
- Tapping a gig card navigates to the gig screen
- Tapping a venue name navigates to the venue details page
- Tapping a performer name navigates to the performer details page

## Search
- Search bar at the top of the screen
- Two search types:
  - **Performer search** — queries the app's own database
  - **Location search** — queries Google Places API
- Search results replace the gig list
- Location search results are enriched to indicate whether that location has upcoming gigs
- Clearing the search bar resets the view back to the default gig list

## Personalization (for logged-in users)
- Followed performers and followed venues are featured/highlighted at the top of the list
- Non-followed gigs appear below in the standard list

## "Become a Performer" CTA card (for logged-in non-performer users)
- A dismissible card displayed to logged-in users who have not yet opted in as a performer
- Pitches the value of performer mode (create gigs, accept song requests, receive tips)
- Tapping the card starts the performer opt-in flow
- Card copy also mentions that this can be done from Settings at any time
- Once dismissed, the card does not reappear (stored in user preferences)
- Card is not shown to guests or to users who have already opted in as performers

## Open questions
- How is "near the user" defined? Radius in miles/km? Does the user set this or is it automatic?
- What happens if location permission is denied?
- How are gig cards sorted when there are no followed performers/venues? (by date? by distance?)
- What does an empty state look like (no gigs nearby)?
- Do we paginate or lazy-load the list?
- How are featured/followed gigs visually distinguished from the rest of the list?
- Does the search bar search both performer and location simultaneously, or does the user pick a mode?
