# 07 — Performer Profile Page

## Overview
Private management page for a performer. This is distinct from the public-facing Performer Details page. Accessible only when in Performer mode.

## Sections

### Gigs
- View, create, edit, and delete their gigs

### Songs
- View, create, edit, and delete songs on their profile

### QR Code
- Displays the performer's personal QR code
- Options to **share** (system share sheet) or **print** — similar to Venmo's QR flow
- The QR code encodes the performer's profile URL; the client handles redirecting to the correct gig on scan (see [Guest Access & QR Code Flow](12-guest-qr-flow.md))

### Tips
- **Total paid tips** — tips that have been collected
- **Pending tips** — tips committed but not yet paid out

### Statistics
- TBD — other interesting metrics to surface to the performer
- Candidates: total requests received, most requested song, top tipping fans, gigs performed, etc.

## Open questions
- Is this a single scrollable page or does it use tabs?
- Where does the avatar upload live? (this page, or a separate settings/account screen?)
- What counts as "pending" vs "paid" in the tips context? (tied to Stripe payout schedule)
- What level of detail do we show for tips? (per-gig breakdown, per-song breakdown, or totals only?)
- What statistics are most valuable to a performer for the MVP?
- Is there a way to navigate directly from a gig on this page to the gig screen?
