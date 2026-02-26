# 03 — Stripe & Performer Onboarding

## Overview
Performers use Stripe Connect Express to receive tips. Stripe handles all KYC, identity verification, bank account collection, and 1099-K tax reporting. The app never sees or stores sensitive identity data.

## Stripe Connect account type
- **Express** — Stripe hosts the onboarding flow; the performer is briefly redirected to a Stripe-branded page and then returned to the app

## When onboarding is triggered

### During performer opt-in (optional)
- After a user opts in as a performer, Stripe Express onboarding is presented as a recommended next step
- It is **not required** to complete opt-in or access Performer mode
- Messaging should frame it as: "Set up payouts so you can receive tips from your audience"

### Hard gate: before starting a gig
- A gig **cannot be transitioned to In Progress** until the performer's Stripe account has `charges_enabled = true`
- If a performer tries to start a gig without completing KYC, they are blocked with a clear prompt to complete Stripe onboarding
- Performers can create, edit, and manage gigs freely without Stripe — the gate applies only at the moment of starting

## Onboarding flow
1. App backend creates a Stripe Express account → stores the `account_id` against the performer
2. App generates a Stripe Account Link (one-time URL)
3. App opens the URL (in-app browser or system browser)
4. Performer completes Stripe's hosted KYC flow (name, DOB, SSN last 4 or full, bank account, address)
5. Stripe redirects back to the app (success or refresh URL)
6. App backend checks `charges_enabled` and `payouts_enabled` on the account
7. Performer's Stripe status is updated in the app

## Tips
- Tips are optional but encouraged; suggested amount: **$10**
- Users can opt to **cover Stripe fees** so the performer receives 100% of the tip
- Tips have two states: **pending** (committed but not yet paid out) and **paid** (settled to performer's bank)

## Fee structure
- Stripe charges 2.9% + 30¢ per transaction
- The platform charges an additional **5%** on top of the Stripe fee
- Combined: **7.9% + 30¢** per transaction taken from the tip before the performer receives it
- The "cover fees" option passes the combined fee to the audience member so the performer receives 100% of the intended tip amount
- The grossed-up amount shown to the user = `tip / (1 - 0.079) + 0.30`

## Payout schedule
- **TBD via research** — candidates: Stripe's default daily rolling payout, weekly, or performer-triggered manual payout
- Decision should be informed by performer cash flow expectations and Stripe's payout options for Express accounts

## Open questions
- Handling failed payments or chargebacks — what does the performer and audience see?
- Tax / 1099 considerations: Stripe handles 1099-K automatically for Express accounts; any additional reporting needed?

## Status
🔍 In review — core decisions made; payout schedule TBD
