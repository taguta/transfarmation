# Transfarmation Features & Screens Audit
*Date: 2026-04-05. Updated 2026-10-29.*

A comprehensive architectural and functional scan of the `lib/features` codebase against the new **Day 1 Offline-First Single-Source-of-Truth Standard**.

---

## 1. Production-Ready & Architecturally Compliant Features
These modules have been successfully transitioned from scattered networks/snapshot streams to the strict **Instant Local-Queue Pattern**. The UI operates with zero latency, reads only from local SQLite, and syncs via the Delta Poller.

* **Farm Records (`/farm`, `/farm_records`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Full SQLite offline syncing. Sub-objects (Fields, Livestock) are efficiently embedded in a single batch-write via `SyncService` preventing N+1 Firestore reads.
* **Traceability (`/traceability`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Dummy data successfully stripped. UI queries `farm_fields` joined to `farms` on SQLite filtering `harvested` items to instantly render verifiable batches.
* **Savings & Groups (`/savings`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Eager `sendTransaction()` network requests removed from repository. Cloud Function `rollupSavingsTransactions` deployed to maintain materialized `totalSaved` views.
* **Farming Contracts (`/contracts`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Migrated strict offline pattern. Contract application IDs generated instantly on the client (`contractId_farmerId`).
* **Micro-Financing (`/financing`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Applies `Loan` entities directly to the atomic sync queue. Applications carry the whole application and, if the farmer agrees, a feasibility summary. Offers come from verified lenders. A lender decides in the Credit Desk. The farmer records repayments (see section 2c). 
* **Group Buying & Inputs (`/group_buying`, `/inputs`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Materialized views active via `rollupGroupOrderQuantities`. `GroupBuyingRepositoryImpl` rewritten to instantly store order requests offline.
* **Crop Diagnosis (`/diagnosis`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Image inferences and histories saved seamlessly via `sync_queue` payloads. A symptom checker ranks conditions with a capped confidence, and a farmer can send a case to a human agronomist (see section 2c).

---

## 2. Previously Mock-Data Modules (now migrated)
The April audit found these on hardcoded dummy data. A code search on 2026-10-29 finds no `_dummy` lists and no `StateProvider<List<...>>` mocks; each now has a repository and provider. **Review depth before pilot:** data is local-first, but sync coverage and screens have not been re-audited end to end.

* **Labor Management (`/labor_management`)** uses `LaborRepositoryImpl` with `labor_sqlite.dart`.
* **IoT Devices (`/iot_devices`)** reads `sensorsProvider`. Not needed for the pilot; no live telemetry pipeline yet.
* **Community Forum (`/community`)** uses `CommunityRepositoryImpl` with local SQLite.

---

## 2a. Corrections found in the second pass (2026-10-29)
My first re-check searched only for `_dummy` and so missed hard-coded data. A fuller read found:
* **`/financing` ("My Financing") showed four invented loans, a made-up "Credit Score 72/100" and fixed totals.** It now reads the farmer's real loans, has working filters, an empty state and a loan-file PDF button. The invented credit score is gone, and nothing replaces it: a score is a regulated claim and needs a real method first.
* **Demo data seeding** (`DataSeeder`, a farm and loans under the guest id `farmer-001`) ran on every start. It now runs only when `REQUIRE_AUTH=false`.
* **Language picker did nothing.** Shona and Ndebele could be tapped but changed nothing. English is the only available language until reviewed translations exist.
* **Sync queue:** three queued types (`savings_group_join`, `notification_read`, `notification_mark_all_read`) had no handler and were deleted from the queue without ever reaching the cloud, so savings-group joins were lost. Group joins now sync to `savings_group_members` (rule deployed). Notification read state is device-only by design. Unknown types now stay queued instead of being dropped. A failed batch now counts retries properly (it used to reset them), and one run sends at most 400 items to stay under Firestore's 500-write limit.
* **Still open in sync:** items are marked synced locally *before* the batch commits, so a failed commit can leave a row showing "synced" while still queued. Fix by marking after commit.
* **Not checked:** other screens may still contain hard-coded sample values. The repayment and offers screens have since been rebuilt on real data (section 2c); the rest were not reviewed line by line.

## 2a-ii. Privacy gaps still open (found 2026-10-29)
* **Local data was not scoped per farmer (fixed 2026-10-29).** `LedgerRepository.getEntries()` read every row with no `farmerId` filter, so on a shared phone the second person could see the first person's ledger. Now:
  * The device remembers whose data it holds (`dataOwnerUid`). When a different account signs in, the previous person's per-farmer tables, sync queue and sync timestamps are cleared first (`AccountGuard`, `LocalDataCleaner`), so queued items can never be sent under someone else's account.
  * **Sign out** first tries to send pending changes. If some cannot be sent (no signal) the person must confirm that they will be deleted. It then clears the data and forgets the owner.
  * The app's providers are rebuilt whenever a signed-in person leaves, so nothing stays in memory.
  * The ledger query is also filtered by farmer, as a second layer.
  * **Residual gaps:** other local repositories still read without a farmer filter and rely on the clearing above. A device that held data before this change has no recorded owner and is treated as belonging to the first account that signs in. Guest mode (`REQUIRE_AUTH=false`) shares one demo identity. A person who force-closes the app without signing out leaves their data on the phone until the next person signs in, when it is cleared.
* **Sharing is recorded, not enforced.** The new sharing screen records who the farmer has shared with. Lenders and contractors are not yet restricted to active shares on the server.

## 2b. Added after the go-to-market audit (2026-10-29)
* **Farmer Statement (`/statement`)** is built from the ledger and loans (`FarmerStatement`, unit tested). It shows money in, money spent, loans owed and projected take-home.
* **Consent at registration** is stored as `consentVersion` and `consentAt` on the user profile.
* **Per-recipient sharing consent** (`data_shares`, schema v16): share four scopes with a named recipient, stop in one tap, history kept, loan-file export records the share.
* **Loan file (PDF)** built from the loan, ledger and shared plan (`LoanFilePdf`, tested).
* **Data deletion request**, **optional gender and age band** at registration, and **compressed chat photos**.
* **Sign-in guard** is on by default. Use `--dart-define=REQUIRE_AUTH=false` for testing.

## 2c. Second build round (2026-10-29)
What was added after the corrections above, and how far each piece has been checked.

**Farmer tools**
* **Ledger and sale settlement (`/ledger`, `/ledger/sale`).** A sale records gross value, levy and any loan deduction as linked lines, so the balance equals the net payout. Deleting one line removes the group, locally and in the cloud. Checked in a browser and by unit test.
* **Feasibility plan (`/feasibility`).** 24-month cash flow for tobacco and tomato templates, a bankable test (DSCR of at least 1.25) and a PDF to share with a lender. **The tobacco levy is a 2% placeholder, not a real rate.**
* **Crop and livestock check (`/diagnosis/check`).** Symptom matching returns a ranked list with a confidence that is capped by how many symptoms were ticked (50% for one, 70% for two, 80% for three, 85% from four). It never claims certainty and suggests a human review for serious conditions.
* **Alerts.** Weather and crop-stage alerts are generated on the device with fixed IDs, so they do not repeat. There is no push notification yet.
* **Repayments (`/financing/repayments`).** The farmer records payments they made to their lender; the app does not move money. The schedule is an even split of the amount borrowed over the repayment period, with paid, part paid and overdue states. **It excludes interest and fees, because a loan does not store its lender's rate; the screen says so.** Payments are append-only and sync to `loan_payments`.
* **Profile numbers** (farm size, loans, plans) come from real records.

**Professional desks (verified roles)**
* **Verification.** Nobody can make themselves an expert, lender or admin. An admin approves an application, which writes `verified_experts/{uid}`; admins are added by hand in `admins/{uid}`. Firestore rules read those records.
* **Advisory Desk (`/advisory-desk`).** A verified agronomist or veterinarian sees waiting cases, replies, and may change only the reply fields. The farmer sees the reply on the diagnosis card.
* **Credit Desk (`/credit-desk`).** A verified lender reviews pending applications (with an indicative score from the shared plan), approves or rejects with a note, and publishes or withdraws offers. A lender may change only the decision fields, and only on a pending application.
* **Admin (`/admin/experts`).** Approve or reject expert and lender applications.

**Checked live, with throwaway accounts that were deleted afterwards:** farmer to expert to farmer reply; lender decision reaching the farmer; offer publish; admin approval; owner rules (19 checks) and the `loan_payments` rule (8 checks). **Not checked:** attaching a photo to an escalation (a headless browser cannot open a file picker); the repayment screen in a browser (covered by a widget test); anything on a real Android or iOS device.

**Sync and security changes**
* Queued changes are now sent every 45 seconds and on sign-in, and the cloud is checked every minute (it was every 5). Before this, a change saved while online waited for the next launch.
* Screens now reload after a cloud pull (`syncTickProvider`). Before this, a reply or decision arrived in the database but the screen stayed stale.
* Workers, tasks, sensors, listings, bookings and notifications are now owner-only in Firestore (they were readable and writable by any signed-in user). Sync stamps `farmerId` on them. `iot_devices` and `traceability_logs`, which nothing uses, are closed. Records written before this change have no owner and are unreadable to their former writer until re-saved from the device.
* **Deployed rules match `firestore.rules`** as of 2026-10-29.

**Still open**
* Sync still marks a row "synced" locally before the batch commits (section 2a). Fix by marking after commit.
* Repayments are self-reported, with no lender confirmation.
* Demo seeding for guest mode (`REQUIRE_AUTH=false`) means guest data must never be carried into a real account. This was a deliberate decision, not an omission.
* Replies and decisions can take up to about two minutes to appear (45 second send, one minute pull), not instantly.

## 3. Read-Only / Reference Modules
These modules query data from external references or read-only Firebase collections. They require minimal writes and adhere successfully.

* **Market & Commodity Prices (`/market_prices`)** 
  * *Syncing remote datasets to local cache via standard polling.*
* **Weather Service (`/weather`)**
  * *External telemetry pipelines.*
* **Expert Knowledge Base (`/knowledge`, `/expert`)**
  * *Static/Admin managed remote configurations cache.*

---

## Conclusion and Next Steps
Core farmer features work offline. Remaining work before real farmers use it, in priority order (details in `transfarmation_specifications.md`):

1. **USSD/SMS fallback** for balance, delivery confirmation and alerts (A1).
2. **Shona and Ndebele** for farmer-facing text (A3).
3. **Enforce data-sharing consent on the server** for lender and contractor reads (I4). Recording consent and deletion requests (I5) are built; staff handling of deletion is not.
4. **Local encryption** of sensitive data.
5. **Partner-bank payments** (M3). Do not build funds-holding.
6. **Re-audit** every module for sync coverage, fix the mark-before-commit issue, run on real Android and iOS devices (including an upgrade from an older database), and load test on low-end Android.

Nothing in this list should be marketed as live until it ships.
