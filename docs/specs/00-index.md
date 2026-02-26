# Song Requester — Feature Specs Index

Each file covers one feature area. Use these as the basis for drilling down into requirements before implementation.

## Status legend
- 🔲 Not started
- 🔍 In review / being defined
- ✅ Ready to build

---

## Features

Specs are ordered by dependency — earlier specs must be understood (and generally built) before later ones.

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 01 | [Auth & Account Creation](01-auth.md) | 🔲 | Foundation for all user-specific features |
| 02 | [App Modes & Navigation](02-app-modes.md) | 🔲 | Routing, mode toggle, guards |
| 03 | [Stripe & Performer Onboarding](03-stripe-onboarding.md) | 🔍 | Core decisions made; fee structure + payout schedule TBD |
| 04 | [Song Management (Performer)](04-song-management.md) | 🔲 | Performer song library; required before gigs |
| 05 | [Add / Edit Gig](05-add-edit-gig.md) | 🔲 | Gig creation; required before gig screen |
| 06 | [Performer Home Screen](06-performer-home.md) | 🔲 | Performer's gig list |
| 07 | [Performer Profile Page](07-performer-profile.md) | 🔲 | Private performer management screen |
| 08 | [Venue Details Page](08-venue-details.md) | 🔲 | Public venue page (Google Places) |
| 09 | [Performer Details Page](09-performer-details.md) | 🔲 | Public performer page |
| 10 | [Gig Screen](10-gig-screen.md) | 🔲 | Core audience + performer experience |
| 11 | [Audience Home Screen](11-audience-home.md) | 🔲 | Discovery; depends on gigs, venues, performers |
| 12 | [Guest Access & QR Code Flow](12-guest-qr-flow.md) | 🔲 | QR entry point + web fallback (MVP requirement) |
| 13 | [Account Features (Follow / Favorite)](13-account-features.md) | 🔲 | Value-add for logged-in audience users |

---

## Open questions / TBD
- Payout schedule — TBD via research (spec 03)
- Performer confirmation process (manual review vs. automated — spec 01)
- Music data source for song search (Spotify, MusicBrainz, manual — spec 04)
- Statistics to show on the performer profile page (spec 07)
- Account value prop copy (what to pitch to guest users after a tip — spec 13)
- Web version deployment pipeline (confirmed MVP requirement — spec 12)
