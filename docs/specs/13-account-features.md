# 13 — Account Features (Follow / Favorite)

## Overview
Value-add features available to logged-in audience users. Designed to incentivize account creation without requiring it.

## Features

### Follow performers
- Users can follow any performer
- Followed performers are featured at the top of the audience home screen

### Follow venues
- Users can follow any venue
- Followed venues are featured at the top of the audience home screen

### Favorite songs
- Users can favorite a song from any song widget anywhere in the app
- Favorited songs appear at the top of the Request Song screen when requesting at a gig

## Impact on Request Song screen
- **Top section** — user's favorited songs (that the performer can play and haven't been played yet in the current gig)
- **Bottom section** — performer's most frequently requested songs
- If user has no favorites, falls back to the performer's most frequently requested songs only

## Account creation pitch
- Triggered after every successful song request + tip by a guest user
- Should highlight:
  - Follow performers and venues
  - Favorite songs for faster requesting
  - Personalized home screen
  - (additional value props TBD)

## Open questions
- Where does the follow action live for performers and venues? (details page, home screen card, both?)
- Is there a screen where a user can see all their followed performers and venues?
- Is there a screen where a user can see all their favorited songs?
- Can a guest user favorite a song temporarily in-session, with a prompt to save it by creating an account?
- How is the account creation pitch presented? (modal, bottom sheet, full screen?)
- What are the additional value props to pitch to guest users?
