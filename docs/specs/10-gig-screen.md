# 10 — Gig Screen

## Overview
The gig screen has three states — **Upcoming**, **In Progress**, and **Completed** — each with a different view depending on whether the user is in Audience or Performer mode.

---

## State: Upcoming

### Both modes
- Performer name
- Venue name
- Date, start time, end time
- Performer's full song list (so the audience knows what can be requested)

### Performer only
- Ability to edit the gig
- **Start gig** button to manually transition to In Progress — explicit tap required (signals intent to start receiving tips)
  - If Stripe KYC is not complete: button is disabled with a prompt to complete onboarding — gig cannot be started until `charges_enabled = true`

---

## State: In Progress

### Both modes
- Real-time list of requested songs, sorted descending by total tip amount (live updates via **Supabase Realtime**)
- Already-played songs shown at the bottom of the list in a disabled state

### Audience mode
- **Boost button** on each requested song — adds additional tip money to that song
- **Request Song FAB** at the bottom of the screen

#### Request Song flow (audience)
- Opens a new screen with:
  - Search bar at the top
  - Default list (no search): performer's unplayed songs
    - Top section: user's favorited songs (if logged in)
    - Bottom section: performer's most frequently requested songs (shown as popularity, no dollar amounts)
  - Search filters the song list
- Selecting a song triggers a Stripe payment flow:
  - Tip is optional
  - User is reminded their song is more likely to be played with a tip
  - Suggested tip: **$10**
  - Option to **cover fees** so the performer receives 100% of the tip

### Performer mode
- **Play button** on each requested song — marks the song as being played next
- **End gig** button to manually transition to Completed
- No Request Song FAB
- List updates in real time (same as audience)

### Auto-end
- If the performer does not manually end the gig, it is automatically transitioned to Completed **1 hour after the scheduled end time**
- This is handled server-side (e.g. a scheduled job or Supabase function)
- No action required from the performer

---

## State: Completed

### Both modes
- Performer name, venue, date, start time, end time
- Ordered list of all songs played (in the order they were performed)
- Visual indicator on songs that were requested
- **Gold / Silver / Bronze badges** on the top 3 most-tipped songs

### Audience mode
- No dollar amounts shown
- No request/tip counts shown

### Performer mode
- Request count and tip amount shown per song
- Toggle switch: **All songs** / **Requested songs only**
- Gold/silver/bronze badges same as audience view

---

## State machine
- Gig state is **strictly one-directional**: Upcoming → In Progress → Completed
- There is no revert — once started, a gig cannot return to Upcoming
- Performers should use the confirmation dialog on the Start button to prevent accidental starts

## Open questions
- ~~How is the real-time list updated?~~ → **Supabase Realtime** (decided)
- ~~Can the audience see the gig screen without scanning a QR code?~~ → **Yes** — gig cards are tappable everywhere (home screen, venue page, performer details); QR is just the primary entry point at a live event (decided)
- What does the boost flow look like? Same Stripe flow as a new request, or simpler?
- What does "play next" actually do — does it reorder the list or just mark it?
- Is there a maximum number of songs a user can request per gig?
- Can a user request the same song twice?
