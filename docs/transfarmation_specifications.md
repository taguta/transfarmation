# Transfarmation: Product and Requirements Specification

*Version 2.1, 2026-10-29. Replaces the earlier AgroLink spec (archived in `docs/archive/agrolink_chat_history.md`).*
*Related: `Transfarmation_Value_Proposition.docx` (stakeholder document), `go_to_market_audit.md` (evidence and rationale), `feature_audit_report.md` (build status).*

Priorities: **P0** = needed for the first 30–50 farmer pilot, **P1** = before the ~500-participant Cluster-Zero pilot, **P2** = later.
Status: **Built** = in the codebase, **Partial** = some of it exists, **Not built**.

---

## 1. Product

**Name:** Transfarmation. Tagline: *People busy transforming their farming activities.*

**Vision:** one offline-first platform that makes Zimbabwe's tobacco value chain transparent, financeable and compliant, then reuses the same core for horticulture (tomatoes first) and other African markets.

**Wedge:** communal and small-scale tobacco growers, reached through contractors, extension officers and field agents. Farmer tools are free and must be useful with no other party present (the "standalone-value test"). Revenue comes from the parties who gain measurable value (contractors, banks, funders).

**Market facts used in this spec** (directional, from TIMB figures in the press; re-verify before external use):
- 2026 season: about 357M kg sold for about US$889M, down 24% from US$1.17B in 2025.
- About 115K registered growers (85% small-scale, about 97K contracted). 48 licensed contractors.
- TIMB runs a biometric grower registry, mandatory for sales in 2026.

## 2. Users and workspaces

One identity can hold several roles. Each role sees its own workspace (a configuration of shared modules).

**How a professional role is granted:** a person applies in the app with a licence number. An admin approves, which writes a verified record that the Firestore rules check. Choosing a role at sign-up only changes the workspace shown; it grants no access to other people's data.

| Role | Workspace | Core needs |
|---|---|---|
| Farmer | My Farm | Ledger, statement, plan, contracts, advice, loans |
| Lender | Credit Desk | Loan book, applications, repayments, risk |
| Buyer / contractor | Offtaker / Contract view | Deliveries against contract, traceability |
| Expert / agronomist | Advisory Desk | Farmer cases, diagnosis review, escalation |
| Admin | Platform | Expert approval, moderation |
| Agent / transporter / TIMB | Later phases | Not in pilot |

## 3. Functional requirements

### 3.1 Farmer core (Phase 1)

| ID | Requirement | Pri | Status |
|---|---|---|---|
| F1 | Farm and field records with GPS plot capture, working offline | P0 | Built |
| F2 | Farm ledger: income and expense entries, sale recording with levy and loan deductions shown line by line | P0 | Built (the levy rate is a placeholder until the real rate is confirmed) |
| F3 | **Farmer statement:** plain-language view of money in, money spent, loans still owed, and projected take-home (can be negative) | P0 | Built (`/statement`) |
| F4 | Feasibility plan (24-month cash flow) with PDF export that can be shared with a lender | P0 | Built (tobacco and tomato templates; tobacco levy is a placeholder) |
| F5 | Contract view in plain language with offer acceptance | P1 | Partial |
| F6 | Crop diagnosis with confidence level and escalation to a human agronomist | P1 | Built (symptom match with confidence capped by the number of symptoms ticked; escalation queue and replies in the Advisory Desk; photo attachment not yet tested end to end) |
| F7 | Weather and crop-stage alerts, proactive rather than on demand | P1 | Partial (generated on the device from weather and crop stage; no push notifications yet) |
| F8 | Savings groups, group buying, inputs, traceability, labour, community, market prices | P1 | Built (SQLite-backed; review depth before pilot) |
| F9 | IoT sensors dashboard | P2 | Built, not needed for pilot |

### 3.2 Money and trust

| ID | Requirement | Pri | Status |
|---|---|---|---|
| M1 | Loan application, offers and repayment tracking | P0 | Built (offers published by verified lenders; Credit Desk approve or reject with a note; repayments are recorded by the farmer, the schedule is principal only, and nothing is confirmed by the lender yet) |
| M2 | Bank-ready loan file export from ledger and plan data, tested with a bank officer | P1 | Partial (PDF built from the loan, ledger and shared plan; **not yet tested with a bank officer**) |
| M3 | Input credit and payouts through a **licensed bank or PSP partner**. Transfarmation does not hold funds | P1 | Not built |
| M4 | Escrow and settlement waterfall (levies, loan, freight, farmer) | P2 | Not built |
| M5 | Contractor view of deliveries against contract and side-marketing risk flags | P1 | Partial |
| M6 | TIMB integration (registry and bale data) with a written fallback if access is refused | P2 | Not built |

### 3.3 Access and reach

| ID | Requirement | Pri | Status |
|---|---|---|---|
| A1 | USSD/SMS fallback for: view balance, confirm a delivery, receive alerts | P0 | Not built |
| A2 | Field-agent assisted onboarding that works fully offline, with consent recorded | P0 | Partial |
| A3 | Shona and Ndebele for all farmer-facing text, reviewed by native speakers. Voice later | P1 | Partial (translation mechanism and language setting built; only the statement screen is wired; **no Shona or Ndebele text exists yet**, so both are shown as unavailable) |
| A4 | Low-data mode: compressed images, sync tolerant of days offline | P0 | Partial (photos in diagnosis and expert chat compressed to 1024px at quality 60; multi-day offline sync not yet stress-tested) |
| A5 | Track women's and youth participation from day one | P1 | Partial (optional gender and age band collected at registration; no reporting view yet) |

### 3.4 Identity and access

| ID | Requirement | Pri | Status |
|---|---|---|---|
| I1 | Sign-in required by default. Testing without an account uses `--dart-define=REQUIRE_AUTH=false` | P0 | Built |
| I2 | Role-based access in the app and in Firestore rules | P0 | Built (lender, expert and admin roles are granted only by an admin-written record; every farmer-owned collection is owner-only; tested against the live database with throwaway accounts) |
| I3 | Explicit consent at registration, stored with a version and timestamp (`consentVersion`, `consentAt`) | P0 | Built |
| I4 | Consent for sharing farmer data with a named lender or contractor, per recipient, revocable | P1 | Partial (farmer can share four scopes with a named recipient, stop in one tap, history kept, synced; exporting a loan file asks who it is for and records the share. **Not yet enforced on the server for lender or contractor reads**) |
| I6 | One person's data is removed from a shared device when they sign out or another account signs in; unsent changes are warned about, never sent under another account | P0 | Built (see feature audit for residual gaps) |
| I5 | Data deletion request handled within a stated period | P1 | Partial (in-app request queued and synced to `deletion_requests`, rules deployed; staff process and the stated period are still to be defined) |

## 4. Regulatory and legal requirements

| ID | Requirement | Pri |
|---|---|---|
| R1 | POTRAZ data-controller licence and a data protection officer **before onboarding the first pilot farmers** (processing of 50 or more people, and any biometric data, requires a licence under the Cyber and Data Protection Act and SI 155 of 2024). Verify current fees and rules with POTRAZ | P0 |
| R2 | No holding of farmer or contractor funds. Escrow-style flows run through a bank-held account or licensed PSP. Counsel approves any public use of "escrow", "guaranteed" or "bankable" | P0 |
| R3 | Data-sharing agreement with each pilot contractor: what they see, what the farmer is told | P0 |
| R4 | Written TIMB position: what data we receive, who owns the biometric record, what happens if access is withdrawn | P0 |
| R5 | Every figure in sales or investor material carries a source and a date. Unsourced claims are removed | P0 |
| R6 | Legal review of digital signatures on contracts and of any credit-related licence need | P1 |

## 5. Non-functional requirements

- **Offline-first:** the UI reads only from local SQLite. Writes go to a local sync queue and reach Firestore when online: queued changes are sent every 45 seconds while the app is open and on sign-in, and the cloud is checked every minute. States: pending, syncing, synced, failed. Retry uses backoff.
- **Performance:** first meaningful screen under 3 seconds on a low-end Android phone on 3G; no screen blocks on the network.
- **Security:** Firebase Auth, Firestore rules per role and owner, field validation on loans, no secrets in the client. A loan decision records the lender, time and note on the loan itself; a separate append-only audit log is **not yet built**. Local encryption of sensitive data is **P1, not yet done**.
- **Privacy:** data minimisation, per-recipient sharing consent, deletion on request.
- **Availability:** aim for 99.5% for sync and auth. The farmer's own tools must keep working with no availability at all.
- **Platforms:** Android first (pilot), web (Firebase Hosting, responsive shell), iOS and desktop later. **So far tested on web and in automated tests; not yet run on a real Android or iOS device.**
- **Accessibility:** large touch targets, icon-led layout, plain language, English now, Shona and Ndebele next.

## 6. Architecture

```text
Flutter (Android, web, desktop)
        |
Presentation (Riverpod providers, screens)
        |
Domain (entities, pure-Dart services such as FarmerStatement, SaleSettlement, FeasibilityCalculator)
        |
Repositories (offline-first)
   |                      |
SQLite (local, source     Sync queue -> Firestore  -> Cloud Functions (rollups)
of truth for the UI)
```

- Feature-first folders under `lib/features/<feature>/{domain,infrastructure,presentation}`.
- Domain logic stays free of Flutter and Firebase and is unit tested.
- Cloud Functions maintain materialised views (savings totals, group order quantities).
- Future: PostgreSQL or a ledger service for money movement if volumes require it, behind the licensed payment partner.

## 7. Roadmap and gates

| Phase | Scope | Gate to start next |
|---|---|---|
| 0 (now to about 3 months) | Licences (R1), pilot contractor, legal review, corrected claims, field interviews (15–20) | POTRAZ licence in hand, one contractor signed |
| 1 (planting season) | Standalone farmer tools: ledger, statement, plan, contract, diagnosis (parity). 30–50 farmers, then about 500 | Activation and retention targets met; a lender or contractor accepts a plan or loan file |
| 2 (March to August 2027 marketing season) | Settlement through the partner bank; contractor view; TIMB conversation using pilot data | Payout time and repayment better than the matched group |
| 3 | Logistics and escrow, cold storage | Low dispute rate; licensed rails in place |
| 4 | Offtakers, auction floor, marketplace | Forward contracts repaid through the pilot waterfall |

Horticulture (tomatoes) runs as a small parallel test with its own buyer. It is not assumed to be configuration only.

## 8. Success metrics

Define baselines **before** launch, then track:

- **Activation:** a farmer opens their statement twice in 30 days (not app installs).
- **Retention:** weekly active farmers by onboarding channel (agent, contractor, extension officer).
- **Money:** payout time from sale to farmer, repayment rate against a matched group, input credit extended using the ledger.
- **Compliance:** side-marketing incidents flagged against baseline.
- **Cost:** cost per activated farmer.
- **Inclusion:** share of women and youth among active farmers.

## 9. Monetisation

| Stream | Payer | When |
|---|---|---|
| Farmer core tools | Nobody (free) | Pilot |
| Contractor subscription, per grower per season, capped below their measured default losses | Contractors | Pilot |
| Verified loan file or ledger subscription | Banks and MFIs | Pilot to Phase 2 |
| Grants tied to farmers onboarded (check each funder's tobacco policy first) | Donors and DFIs | Pilot onward |
| Escrow, freight and compliance fees | Payer | Phase 2–3 |
| Marketplace commission | Buyers and sellers | Phase 3+ |

Fees are shown to the farmer, only where payment gets faster or safer, and are confirmed lawful before launch.

## 10. Risks

See `go_to_market_audit.md` section 6 for the ranked table. The top five: TIMB access, licensing delay, contractor resistance to transparency, funder exclusion of tobacco, and the price slump shrinking the grower base.

## 11. Open questions

- TIMB's willingness and timeline for API access, and ownership of biometric data.
- Current POTRAZ fees and RBZ licensing text.
- Whether farmers value a feasibility plan or a debt statement more (field interviews).
- Contractor default rates and the real size of side-marketing losses.
- Funder exclusion policies for tobacco.
- Acquisition cost and unit economics for comparable smallholder platforms.

---

## 12. Design notes for items not yet built

### Per-recipient data-sharing consent (I4)
**Built (client side):** `data_shares` table (schema v16), `DataShare`/`ShareScope`, a "Who can see my data" screen under Profile, and a share prompt on loan-file export. Shares are synced to a `data_shares` collection that only the farmer can read. **Still to do:** make lender and contractor workspaces read farmer data only through an active share (needs a recipient identity, see the open question below), and show recipients what they may see.

- **Model:** a `data_shares` record per (farmer, recipient, scope) with `grantedAt`, `revokedAt`, and a consent version. Scopes: `ledger_summary`, `plan`, `farm_location`, `loan_file`.
- **Rule of use:** a lender or contractor workspace may read a farmer's data only while an unrevoked share exists for that scope. Enforce this in Firestore rules, not only in the app.
- **UX:** the farmer picks the recipient and sees, in plain words, exactly what will be shared. Revoking is one tap. Exporting the loan file to a named lender should create the share.
- **Open question:** who counts as a recipient (a named bank branch, a contractor company, or an individual officer). Decide with the first pilot partners.

### Local encryption (P1)
- **Risk:** the SQLite database and the sync queue hold names, phone numbers, farm locations, ledger and loan data in clear text on the device. A lost or shared phone exposes them.
- **Options:** an encrypted SQLite build (SQLCipher) on Android, with the key held in the platform keystore; on web, browser storage cannot be made secure against someone with the device, so keep sensitive fields minimal there.
- **Constraints:** a key-loss path (the farmer forgets a PIN) must not destroy synced data, and encryption must not break offline start-up time on low-end phones. Needs a spike on a real low-end device before committing.

### USSD/SMS (A1)
- **Blocker:** choose an aggregator or telco (for example through Econet) first. Then build a small endpoint that maps a phone number to a farmer, returns the statement summary, and accepts a delivery confirmation.
- **Data needed on the server:** ledger and loan data already sync to Firestore, so the endpoint can read them. Phone numbers are stored on the user profile.
