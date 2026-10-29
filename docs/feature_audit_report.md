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

## 2b. Added after the go-to-market audit (2026-10-29)
* **Farmer Statement (`/statement`)** is built from the ledger and loans (`FarmerStatement`, unit tested). It shows money in, money spent, loans owed and projected take-home.
* **Consent at registration** is stored as `consentVersion` and `consentAt` on the user profile.
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
