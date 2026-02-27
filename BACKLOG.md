# Song Requester — Backlog

## Legend

- **Next** — the single item queued up to work on
- **In Progress** — actively being worked on
- **Upcoming** — ordered queue of future work
- **Done** — completed items (most recent first)

---

## In Progress

### Item 3: Performer Opt-in Flow (Milestone 1)

**Summary:** Build the self-serve performer opt-in flow, reachable from the "Become a Performer" CTA (deferred to audience home screen item) and Settings. Updates the user's `isPerformer` flag and presents Stripe onboarding as an optional next step (Stripe integration comes in a later item).

**Spec:** `docs/specs/01-auth.md` (performer opt-in section)

**Key files:**

- `lib/features/auth/` (update user profile)
- `lib/features/performer_onboarding/` (new)

**Exit criteria:**

- [ ] Opt-in flow accessible from Settings screen
- [ ] Tapping opt-in sets `isPerformer = true` on the user's profile in Supabase
- [ ] Performer mode becomes accessible immediately after opt-in
- [ ] Post-opt-in screen prompts Stripe setup with a clear skip option
- [ ] Skipping Stripe still completes opt-in successfully

---

## Next

### Item 4: Song Management (Milestone 2)

**Summary:** Implement the performer song library. Integrate Spotify API for song search (client credentials flow), store title, artist, and Spotify track ID. Support manual fallback entry. Genre derived from Spotify metadata.

**Spec:** `docs/specs/04-song-management.md`

**Key files:**

- `lib/features/songs/` (new feature directory)
- `supabase/schema.ts` (songs table)

**Exit criteria:**

- [ ] `Song` Freezed model (id, title, artist, spotifyTrackId, genres)
- [ ] Spotify search by title or artist using client credentials flow
- [ ] Manual song entry fallback (title + artist only)
- [ ] Add song to library, remove song from library
- [ ] Song library list UI on Performer Profile page
- [ ] Removing a song does not affect past gig request data
- [ ] Unit tests for song repository and service

---

### Item 5: Add / Edit Gig (Milestone 2)

**Summary:** Screen for performers to create and edit gigs. Venue autocomplete via Google Places API. Date, start time, and end time pickers (end time required). Double-booking advisory warning.

**Spec:** `docs/specs/05-add-edit-gig.md`

**Key files:**

- `lib/features/gigs/` (new feature directory)
- `supabase/schema.ts` (gigs table)

**Exit criteria:**

- [ ] `Gig` Freezed model (id, performerId, venueId, date, startTime, endTime, state)
- [ ] Venue autocomplete using Google Places API
- [ ] Date, start time, end time pickers — all three required
- [ ] Double-booking advisory shown if performer has another gig that day
- [ ] Create gig saves to Supabase
- [ ] Edit gig updates existing record
- [ ] Unit tests for gig repository and service

---

### Item 6: Performer Home Screen (Milestone 2)

**Summary:** The landing screen in Performer mode. Lists the performer's upcoming gigs. FAB navigates to Add Gig. Tapping a gig navigates to the gig screen.

**Spec:** `docs/specs/06-performer-home.md`

**Key files:**

- `lib/features/gigs/presentation/screens/performer_home_screen.dart` (new)

**Exit criteria:**

- [ ] Lists all upcoming gigs for the signed-in performer
- [ ] Gig cards show performer name, venue, date, start/end time
- [ ] Tapping a gig card navigates to the gig screen
- [ ] FAB navigates to the Add Gig screen
- [ ] Empty state shown when no upcoming gigs
- [ ] Loading and error states handled

---

### Item 7: Performer Profile Page (Milestone 2)

**Summary:** Private management page for the performer. Sections for gigs, songs, tips (totals only for MVP), and QR code generation with share/print options.

**Spec:** `docs/specs/07-performer-profile.md`

**Key files:**

- `lib/features/performer_profile/` (new)

**Exit criteria:**

- [ ] Gigs section links to gig management (create/edit/delete)
- [ ] Songs section links to song library management
- [ ] Tips section shows total paid and pending tip amounts
- [ ] QR code section generates per-performer QR code
- [ ] QR code share (system share sheet) and print options available
- [ ] Accessible only in Performer mode

---

### Item 8: Stripe Integration (Milestone 3)

**Summary:** Implement Stripe Connect Express onboarding flow, tip payment processing (7.9% + 30¢ combined fee), "cover fees" gross-up option, and pending/paid tip state management.

**Spec:** `docs/specs/03-stripe-onboarding.md`

**Key files:**

- `lib/features/payments/` (new)
- Supabase edge function for payment processing

**Exit criteria:**

- [ ] Stripe Connect Express account created for performer on KYC initiation
- [ ] Stripe onboarding opens in-app browser; returns to app on completion
- [ ] `charges_enabled` checked after onboarding; performer Stripe status updated
- [ ] Tip payment flow: amount selection, optional tip, cover fees toggle
- [ ] Fee calculation correct: `gross = tip / (1 - 0.079) + 0.30` when covering fees
- [ ] Tips stored with `pending` state; updated to `paid` on Stripe payout
- [ ] Start Gig button blocked with prompt if `charges_enabled = false`

---

### Item 9: Gig Screen — Upcoming & Completed States (Milestone 4)

**Summary:** Build the gig screen scaffold and the Upcoming and Completed state views for both audience and performer modes.

**Spec:** `docs/specs/10-gig-screen.md`

**Key files:**

- `lib/features/gigs/presentation/screens/gig_screen.dart` (new)

**Exit criteria:**

- [ ] Gig screen renders correct view based on gig state (Upcoming / In Progress / Completed)
- [ ] Upcoming: performer name, venue, date/time, full song list
- [ ] Upcoming (performer): Start Gig button with confirmation dialog; blocked if Stripe not complete
- [ ] Completed: ordered list of played songs, gold/silver/bronze badges on top 3
- [ ] Completed (audience): no dollar amounts or request counts
- [ ] Completed (performer): request count + tip amount per song, all/requested toggle

---

### Item 10: Gig Screen — In Progress (Milestone 4)

**Summary:** The live gig experience. Real-time song request list via Supabase Realtime, request song flow with Stripe payment, boost button, performer play/end controls, and auto-end server-side job.

**Spec:** `docs/specs/10-gig-screen.md`

**Key files:**

- `lib/features/gigs/presentation/screens/gig_screen.dart`
- `lib/features/gigs/presentation/screens/request_song_screen.dart` (new)
- Supabase edge function / pg_cron for auto-end job

**Exit criteria:**

- [ ] Real-time request list updates via Supabase Realtime subscription
- [ ] Requests sorted descending by total tip amount
- [ ] Played songs shown at bottom in disabled state
- [ ] Audience: Request Song FAB opens request flow with search and Stripe tip
- [ ] Audience: Boost button adds additional tip to an existing request
- [ ] Performer: Play button marks a song as played
- [ ] Performer: End Gig button transitions to Completed (with confirmation)
- [ ] Server-side auto-end fires 1 hour after scheduled end time
- [ ] State machine is strictly one-directional (no revert to Upcoming)

---

### Item 11: Venue Details Page (Milestone 5)

**Summary:** Public venue page pulling data from Google Places. Shows venue info, upcoming gigs at that venue.

**Spec:** `docs/specs/08-venue-details.md`

**Key files:**

- `lib/features/venues/` (new)

**Exit criteria:**

- [ ] `Venue` Freezed model (id, googlePlacesId, name, address)
- [ ] Venue header with parallax image from Google Places (fallback placeholder)
- [ ] Venue name, address, Get Directions button
- [ ] Venue description from Google Places (shown if available)
- [ ] List of upcoming gigs at this venue

---

### Item 12: Performer Details Page — Public (Milestone 5)

**Summary:** Public-facing performer page. Avatar, name, genre chips (from Spotify metadata), tabs for upcoming gigs and song library. Send a tip FAB.

**Spec:** `docs/specs/09-performer-details.md`

**Key files:**

- `lib/features/performers/` (new)

**Exit criteria:**

- [ ] Performer avatar, name, genre chips
- [ ] Tab 1: upcoming gigs list
- [ ] Tab 2: full song library
- [ ] Send a tip FAB (opens Stripe tip flow, not tied to a gig)
- [ ] Follow performer button (wired up in account features item)

---

### Item 13: Audience Home Screen (Milestone 5)

**Summary:** Default landing screen. Location-based upcoming gig list, performer and location search, personalization for logged-in users, and the "Become a Performer" CTA card.

**Spec:** `docs/specs/11-audience-home.md`

**Key files:**

- `lib/features/home/` (new)

**Exit criteria:**

- [ ] Location-based upcoming gig list (fallback if permission denied)
- [ ] Performer search against app database
- [ ] Location search via Google Places API
- [ ] Followed performers/venues featured at top for logged-in users
- [ ] Gig, venue, performer names all tappable with correct navigation
- [ ] "Become a Performer" CTA card for logged-in non-performers (dismissible)
- [ ] Empty state for no nearby gigs

---

### Item 14: QR Code Flow & Flutter Web (Milestone 6)

**Summary:** Deep linking, per-performer QR code generation on the profile page, Flutter Web target setup, and client-side redirect logic (in-progress gig → next upcoming → performer profile).

**Spec:** `docs/specs/12-guest-qr-flow.md`

**Key files:**

- `lib/app/router/app_router.dart` (deep link handling)
- `lib/features/performer_profile/` (QR code display)
- Flutter Web build config

**Exit criteria:**

- [ ] Flutter Web target builds and deploys
- [ ] Deep link `songrequester://performer/:id` opens correct screen in-app
- [ ] Web fallback resolves same URL in browser
- [ ] Client-side redirect: in-progress → next upcoming → profile
- [ ] QR code displayed on performer profile with share and print options
- [ ] Post-tip account creation prompt shown to guest users

---

### Item 15: Account Features — Follow & Favorite (Milestone 6)

**Summary:** Follow performers and venues, favorite songs, personalized audience home screen, and account creation pitch shown after a guest tips.

**Spec:** `docs/specs/13-account-features.md`

**Key files:**

- `lib/features/account/` (new)

**Exit criteria:**

- [ ] Follow performer from performer details page
- [ ] Follow venue from venue details page
- [ ] Favorite song from any song widget in the app
- [ ] Favorited songs appear at top of Request Song screen
- [ ] Followed performers/venues featured at top of audience home
- [ ] Account creation pitch shown after guest successfully tips
- [ ] Guest anonymous session activity carries over on sign-up (Supabase auth linking)

---

## Done

### Item 2: App Shell & Navigation (Milestone 1)

**Summary:** Removed counter boilerplate, defined the full navigation shell for both Audience and Performer modes, added route guards for performer-only screens, and wired up the mode toggle on the Profile screen.

---

### Item 1: Auth & Account Creation (Milestone 1)

**Summary:** Set up Supabase client, implement Google Sign-In and Apple Sign-In, wire up Supabase anonymous auth for guest users, create the User domain model with performer flag, and establish auth state providers and route guards.

**Spec:** `docs/specs/01-auth.md`
