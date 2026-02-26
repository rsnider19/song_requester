# 05 — Add / Edit Gig

## Overview
Screen for a performer to create a new gig or edit an existing one. Stripe KYC is **not** required to create or edit a gig — only to start one (see [Stripe & Performer Onboarding](03-stripe-onboarding.md)).

## Required fields
- **Venue** — autocomplete powered by Google Places API
- **Date** — date picker
- **Start time** — time picker
- **End time** — time picker (required; used to calculate auto-end if performer forgets to end the gig)

## Double-booking guard
- When the performer selects a date, if they already have a gig scheduled on that day, display an info box alerting them
- This is advisory only (does not block saving)

## Open questions
- Can a performer have multiple gigs on the same day? (the warning implies yes, but should we allow it?)
- Should venue selection create a new venue record in our database, or purely rely on the Google Places ID?
- What happens if the performer selects a venue that doesn't exist in Google Places?
- Should there be any additional optional fields? (e.g. notes, cover charge, event URL)
- When editing, which fields can be changed after a gig has started or completed?
- Is there a delete gig action on this screen, or elsewhere?
