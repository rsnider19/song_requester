# 01 — Authentication & Account Creation

## Overview
Auth is the foundation for all user-specific features. The app supports both guest access and full accounts. There is one account type — all users start as audience members and can opt in to performer mode at any time.

## Guest access
- Any user can open the app, browse, and request songs without an account
- Guest sessions are backed by **Supabase anonymous auth** — a real user record is created silently on first app open, giving guests a persistent identity without requiring sign-up
- Guest activity (requests, tips, in-session favorites) is stored against this anonymous user ID
- When a guest signs up via Google or Apple, Supabase **links the anonymous account to the new authenticated account** — all prior activity is automatically associated with their profile
- After a successful tip, guests are prompted to create an account (see [Account Features](13-account-features.md))

## Sign up / Login methods
- **Google Sign-In** and **Apple Sign-In** only — no email/password
- Apple Sign-In is required by App Store guidelines when any social login is offered

## Account types

All accounts are created via the same sign-up flow. There is no separate performer sign-up.

### Standard account (all users)
- Created via sign-up; no approval required
- Default mode: Audience
- Unlocks: follow performers/venues, favorite songs, personalized home screen

### Performer opt-in
- Any logged-in user can opt in to become a performer at any time
- Entry points: "Become a Performer" CTA card on the Audience home screen, or via Settings
- Opting in unlocks Performer mode immediately — no review or approval required
- Stripe Express onboarding is presented as part of the opt-in flow but is **optional at this stage**
- Performers can create and manage gigs without completing Stripe
- **Stripe KYC must be complete before a gig can be started** (see [Stripe & Performer Onboarding](03-stripe-onboarding.md))

## Auth state and routing
- Unauthenticated users land on the Audience home screen
- Authenticated users land on the Audience home screen (personalized)
- Users who have opted in as performers can toggle between Audience and Performer modes (see [App Modes](02-app-modes.md))
- Router guards prevent access to performer-only screens for non-performer accounts

