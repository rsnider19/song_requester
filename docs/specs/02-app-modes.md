# 02 — App Modes & Navigation

## Overview
The app has two modes: **Audience** and **Performer**. Navigation and available screens differ between them.

## Modes

### Audience mode
- Available to all users (including guests with no account)
- Default mode for any user opening the app

### Performer mode
- Available to any user who has opted in as a performer (self-serve, no approval required)
- Opted-in performers can toggle between Audience and Performer mode
- Stripe KYC does **not** need to be complete to access Performer mode — only to start a gig

## Mode toggle
- Lives on the **Profile / Settings screen** — not globally accessible from every screen
- Only visible to users who have opted in as performers
- Switching modes reloads the navigation structure for the selected mode

## Open questions
- Can a performer browse another performer's gig as an audience member while in Audience mode? (assumed yes)
