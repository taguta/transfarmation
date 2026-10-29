# Transfarmation Features & Screens Audit
*Date: 2026-04-05*

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
  * **Architecture:** Applies `Loan` entities directly to the atomic sync queue. 
* **Group Buying & Inputs (`/group_buying`, `/inputs`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Materialized views active via `rollupGroupOrderQuantities`. `GroupBuyingRepositoryImpl` rewritten to instantly store order requests offline.
* **Crop Diagnosis (`/diagnosis`)**
  * **Status:** 🟢 **Complete**
  * **Architecture:** Image inferences and histories saved seamlessly via `sync_queue` payloads.

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
* **Sync queue:** three queued types (`savings_group_join`, `notification_read`, `notification_mark_all_read`) had no handler and were deleted from the queue without ever reaching the cloud, so savings-group joins were lost. Group joins now sync to `savings_group_members` (rule added, not yet deployed). Notification read state is device-only by design. Unknown types now stay queued instead of being dropped. A failed batch now counts retries properly (it used to reset them), and one run sends at most 400 items to stay under Firestore's 500-write limit.
* **Still open in sync:** items are marked synced locally *before* the batch commits, so a failed commit can leave a row showing "synced" while still queued. Fix by marking after commit.
* **Not checked:** other screens may still contain hard-coded sample values. Repayment and offers screens were not reviewed line by line.

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
3. **Per-recipient data-sharing consent** and deletion requests (I4, I5).
4. **Local encryption** of sensitive data.
5. **Partner-bank payments** (M3). Do not build funds-holding.
6. **Re-audit** every module for sync coverage, plus load testing on low-end Android devices.

Nothing in this list should be marketed as live until it ships.
