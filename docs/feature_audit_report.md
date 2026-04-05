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

## 2. Modules Requiring Database/Repository Migration
These modules currently contain visually stunning Flutter UI screens, but a manual sweep of their `presentation` folders reveals they are actively using `StateProvider<List<T>>` with hardcoded **dummy mock data**. They need to be given SQlite tables and Repositories to align with the core.

* **Labor Management (`/labor_management`)**
  * **Current State:** UI complete. Relies on `_dummyWorkers` and `_dummyTasks` in `labor_providers.dart` line 4.
  * **Next Step:** Model `FarmTask` and `Worker` tables in `SqliteService`, and create `LaborRepositoryImpl` to query them.
* **IoT Devices Dashboard (`/iot_devices`)**
  * **Current State:** Real-time visual dashboard complete. Relies on `_dummySensors` in `iot_dashboard_screen.dart` line 9.
  * **Next Step:** Require a remote IoT data pipeline (either MQTT over WebSockets or regular Firestore streams for real-time telemetry).
* **Community Forum (`/community`)**
  * **Current State:** Feed screen complete. Relies on `_dummyPosts` in `community_board_screen.dart` line 8.
  * **Next Step:** Implement standard offline repository for threads and replies.

---

## 3. Read-Only / Reference Modules
These modules query data from external references or read-only Firebase collections. They require minimal writes and adhere successfully.

* **Market & Commodity Prices (`/market_prices`)** 
  * *Syncing remote datasets to local cache via standard polling.*
* **Weather Service (`/weather`)**
  * *External telemetry pipelines.*
* **Expert Knowledge Base (`/knowledge`, `/expert`)**
  * *Static/Admin managed remote configurations cache.*

---

## Conclusion & Recommended Next Pipeline
The primary ERP system and critical transactional features are entirely disconnected from networking bottlenecks. A farmer with no signal can manage their farm, join savings groups, request loans, and log harvested traceability batches with 0 milliseconds of loading screens. 

**Recommended Next Goal:** Address the dummy nodes in **Labor Management** by adding its schema to the v4 SQLite Migration, effectively bringing the farm operational tasks offline.
