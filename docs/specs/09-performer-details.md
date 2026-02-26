# 09 — Performer Details Page

## Overview
Public-facing page for a performer. Audience users can browse this page to learn about a performer and tip them.

## Layout

### Header
- Performer avatar (uploaded by the performer)
- Performer name

### Genre chips
- Chips displaying the genres the performer plays
- Derived automatically from the songs added to their profile

### Tabs

#### Tab 1 — Upcoming gigs
- List of the performer's upcoming gigs
- Same gig card format as the audience home screen

#### Tab 2 — Songs
- List of all songs the performer has added to their profile

### Floating action button
- "Send a tip" — allows any user to send the performer a tip not tied to a specific gig

## Open questions
- Can a user follow the performer from this page? If so, where does that action live?
- How are songs displayed in the Songs tab? (song title, artist, both?)
- How are genres determined from songs? (manual genre tag per song, or inferred?)
- What does the tip FAB flow look like? (goes to Stripe, same as song tip flow?)
- What is the empty state for each tab?
- Should the Songs tab show favoriting UI?
