# 12 — Guest Access & QR Code Flow

## Overview
Users do not need an account to request songs or tip. The QR code is the primary entry point for audience members at a live gig.

## Guest access
- Any user (guest or logged in) can:
  - Browse the audience home screen
  - View gig screens
  - Request songs
  - Apply tips via Stripe
- Account is not required for any of the above

## QR code flow
- Each performer has a single **per-performer QR code** (not per-gig) — they do not need a new QR code for each gig
- Scanning the QR code resolves to the performer's profile URL
- On the client side (app or web), the user is automatically redirected to:
  1. The performer's gig that is currently **In Progress**, if one exists
  2. Otherwise, the performer's **next upcoming gig**
  3. Otherwise, the performer's public profile page (no active or upcoming gig)
- If the app is installed → deep link opens the correct screen in-app
- If the app is not installed → opens the correct screen in the Flutter Web version

## Post-tip account creation prompt
- After a guest user successfully requests a song and completes a tip payment, prompt them to create an account
- The prompt should not block or interrupt the experience — it should feel like a natural follow-up
- Pitch the value of an account (see [Account Features](13-account-features.md))

## Open questions
- ~~Where does the performer access/display their QR code?~~ → **Performer Profile page**, with share and print options (decided)
- ~~Does the web version require a separate build/deployment pipeline?~~ → **Flutter Web** (decided; same codebase, separate web target/deployment)
- ~~What authentication method is used for account creation?~~ → **Google and Apple Sign-In** (decided)
- ~~Does a guest's in-session activity get associated with their new account if they sign up?~~ → **Yes, automatically** via Supabase anonymous auth account linking (decided)
- What does the account creation prompt look like? (modal, bottom sheet, inline banner?)
