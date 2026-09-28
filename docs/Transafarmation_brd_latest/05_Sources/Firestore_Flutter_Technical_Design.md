# Decision Record and Guardrails

**Decision:** Transfarmation uses Cloud Firestore as its only database and Flutter with GetX for the app. This document is the technical design for that choice.

**Why this is workable.** For a pilot and early scale, Firestore gives offline storage, real-time updates, and phone sign-in with very little code. Its usage-based cost is small at pilot size (see the cost budget below).

**What the choice costs us.** Firestore has no joins, no constraints, and no server-side group-by, and it cannot be self-hosted. The design below therefore adds guardrails for money, reports, and cost. If these guardrails are skipped, the choice will become expensive or unsafe.

| Guardrail | What it protects |
|----------|------------------------------|
| Only Cloud Functions write money and shared data; rules block clients | Ledger and escrow integrity |
| A separate `ledger` database with tight access, and a `vault` database for identity records | Blast radius if an app account is compromised |
| Ledger documents are never edited; corrections are new entries | Audit trail |
| Reports are precomputed snapshots plus BigQuery for ad-hoc queries | Read cost and report flexibility |
| Small, limited listeners; no raw telemetry writes | Predictable bills |
| Daily export to Cloud Storage and BigQuery, and logic kept in functions behind interfaces | An exit path if the choice must change |

![Figure 8: Firestore-only architecture](/home/claude/diag/08_firestore_only_architecture.png){width=11cm}

**Triggers to revisit the decision**

- A single account or counter needs more than about one write per second for long periods, and sharding no longer fits
- Regulators or law require data to be stored in Zimbabwe
- Reports need complex joins or live ad-hoc queries that snapshots and BigQuery cannot serve
- The monthly Firestore bill exceeds the agreed budget for two months in a row after optimisation
- The ledger reaches a volume where reconciliation jobs become slow or costly

# Project Setup

| Item | Choice |
|--------------|-------------------------------------|
| Edition | Firestore Standard edition, native mode; the Enterprise edition prices per unit and is worth evaluating later, but is not needed for the pilot |
| Location | Johannesburg (africa-south1), chosen for latency; check its price row, which differs from us-central1 |
| Databases | `(default)` for app data and read models; `ledger` for money, consent, and audit; `vault` for identity records. Only the default database has the free daily quota |
| Environments | Separate Firebase projects for dev, staging, and production, each with its own budget alert |
| Sign-in | Firebase Auth with phone numbers; custom claims hold short role names, organisation, and verification level. SMS is billed per message, so budget for it |
| Protection | App Check on all databases and functions; Play Integrity on Android |
| Functions | Cloud Functions 2nd gen in the same region as Firestore if available; one function per command type, plus scheduled report builders |
| Storage | Cloud Storage for photos and contracts, and a bucket with a retention lock for daily ledger digests |
| Analytics | Firestore to BigQuery streaming for historic and ad-hoc queries; set a maximum bytes billed on every query |
| Monitoring | Cloud Monitoring alerts on read, write, and delete counts, function errors, and budget thresholds |

# Data Model

The collection map extends the earlier read-model design. In a Firestore-only setup, the ledger and consent collections live in the `ledger` database and are written only by functions.

| Database | Path | Purpose | Who writes |
|---------------|---------------------|--------------------|-------------|
| (default) | users/{uid} | Profile and role summary | Functions |
| (default) | users/{uid}/home/current | One-document dashboard for the app | Functions |
| (default) | users/{uid}/tasks/{id} | Active prompts and to-dos | Functions; client may set status |
| (default) | users/{uid}/commands/{id} | Offline outbox of user actions | Client creates; functions update status |
| (default) | users/{uid}/ledger/{id} | The user's own entries (drafts and confirmed copies) | Client drafts; functions confirm |
| (default) | farms/{id}, farms/{id}/logs/{id} | Plots, seasons, crop logs | Client (owner), functions |
| (default) | openLoads/{district}/items/{id}, loads/{id} | Freight radar and job detail | Functions |
| (default) | consignments/{id} | Truckload of bales or crates | Client at floor, functions |
| (default) | reportSnapshots/{reportId} | Precomputed reports | Functions |
| (default) | refData/{type}/{id} | Crop templates, grades, levy rates, translations | Admin functions |
| (default) | orgs/{id}, orgs/{id}/members/{uid}, accessGrants/{grantee}_{grantor}_{scope} | Organisations, staff, consent lookups | Functions |
| ledger | accounts/{accountId} | Balance and version per account | Functions only |
| ledger | ledgerTxns/{txnId} | Balanced, immutable ledger transactions | Functions only |
| ledger | escrows/{id}, escrows/{id}/events/{id} | Escrow state machine and history | Functions only |
| ledger | payouts/{id} | Outbox for payments to mobile money and banks | Functions only |
| ledger | consents/{id} | Append-only consent records | Functions only |
| ledger | idempotency/{key} | Prevents double processing | Functions only |
| ledger | audit/{id} | Identity and access events | Functions only |
| vault | verifications/{uid} | Verification results, grower number link, no raw biometric images | Functions only |

Use time-ordered IDs for ledger and audit documents. Store money as integer minor units (cents) with a currency code, never as decimals.

# Ledger and Escrow in Firestore

**Transaction document.** One `ledgerTxns/{txnId}` document holds all lines of one transaction, so a transaction is atomic and balanced by construction:

```json
{
  "txnId": "sale_01J9...",
  "type": "sale_settlement",
  "currency": "USD",
  "lines": [
    { "account": "clearing:floor-3",   "deltaMinor": -100000 },
    { "account": "levy:timb",          "deltaMinor":    3000 },
    { "account": "loan:bank-abc:f123", "deltaMinor":   40000 },
    { "account": "escrow:freight:l77", "deltaMinor":    5000 },
    { "account": "wallet:f123",        "deltaMinor":   52000 }
  ],
  "rulesVersion": "2026-09-01",
  "hash": "sha256:...",
  "createdAt": "<server timestamp>"
}
```

**Rules for the ledger**

- Lines in a transaction must sum to zero, and the function checks this before writing
- Documents are created once and never updated or deleted; a reversal is a new transaction that points to the original
- The balance in `accounts/{id}` is updated in the same Firestore transaction as the ledger document, together with a version number
- An `idempotency/{key}` document is created in the same transaction, so a repeated command cannot post twice
- Reads come before writes inside the transaction, and a settlement stays well under the 500-write limit for one transaction
- A daily job recomputes account balances from ledger documents, checks that all transactions sum to zero, compares with bank and mobile-money statements, and stores a signed digest of the day's transactions in the retention-locked bucket

**Hot accounts.** A document sustains about one write per second, so pooled accounts, such as a levy account or a bank's escrow pool, must not be single documents. Use one sub-account per farmer or lot for balances that change often, and for pooled totals use several shard documents that are summed when read or consolidated by a scheduled job.

**Payments outside Firestore.** A transaction cannot call a mobile-money API. Write a `payouts/{id}` document with status `queued` in the same transaction as the ledger entry, and let a separate function send the payment with an idempotency key, then update the status from the provider's response or webhook. A reconciliation job flags payouts stuck in `queued` or `sent`.

**Function skeleton (TypeScript, Admin SDK):**

```ts
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
const ledger = getFirestore(app, 'ledger');

export async function settleSale(saleId: string, grossMinor: number, rules: Rules) {
  await ledger.runTransaction(async (tx) => {
    const keyRef = ledger.doc(`idempotency/${saleId}`);
    if ((await tx.get(keyRef)).exists) return;              // already settled

    const lines = waterfall(grossMinor, rules);              // integer minor units
    assertBalanced(lines);                                   // sum of deltas is zero
    const accountRefs = lines.map(l => ledger.doc(`accounts/${l.account}`));
    await tx.getAll(...accountRefs);                         // reads before writes

    const txnRef = ledger.doc(`ledgerTxns/${saleId}`);
    tx.create(txnRef, { lines, rulesVersion: rules.version,
      hash: sha256(canonicalJson(lines)), createdAt: Timestamp.now() });
    lines.forEach((l, i) => tx.set(accountRefs[i],
      { balanceMinor: FieldValue.increment(l.deltaMinor), version: FieldValue.increment(1) },
      { merge: true }));
    tx.create(keyRef, { txn: txnRef.id });
    tx.create(ledger.doc(`payouts/${saleId}_farmer`),
      { status: 'queued', account: `wallet:${rules.farmerId}`, amountMinor: netMinor(lines) });
  });
}

function waterfall(gross: number, r: Rules): Line[] {
  let left = gross; const out: Line[] = [];
  for (const step of r.order) {                              // order from law and contract
    const amt = Math.min(left, step.dueMinor);               // never take more than is left
    out.push({ account: step.account, deltaMinor: amt }); left -= amt;
  }
  out.push({ account: r.farmerWallet, deltaMinor: left });   // net proceeds
  out.unshift({ account: r.clearingAccount, deltaMinor: -gross });
  return out;
}
```

# Security Rules and Claims

Deny everything by default, then open exact paths. Custom claims carry short role names, and clients may only create commands and edit a few fields of their own documents.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function signedIn() { return request.auth != null; }
    function isOwner(uid) { return signedIn() && request.auth.uid == uid; }
    function hasRole(r) { return signedIn() && r in request.auth.token.roles; }
    function onlyChanges(keys) {
      return request.resource.data.diff(resource.data).affectedKeys().hasOnly(keys);
    }

    match /users/{uid} {
      allow read: if isOwner(uid);
      allow write: if false;
      match /home/{doc} { allow read: if isOwner(uid); allow write: if false; }
      match /tasks/{id} {
        allow read: if isOwner(uid);
        allow update: if isOwner(uid) && onlyChanges(['status']);
      }
      match /commands/{id} {
        allow read: if isOwner(uid);
        allow create: if isOwner(uid)
          && request.resource.data.keys().hasOnly(
               ['type','payload','idempotencyKey','status','createdAt'])
          && request.resource.data.status == 'pending'
          && request.resource.data.type in ['bookTransport','logExpense','postHarvest'];
        allow update, delete: if false;
      }
    }

    match /reportSnapshots/{id} {
      allow read: if hasRole('regulator') || hasRole('government')
        || (hasRole('banker') && resource.data.orgId == request.auth.token.orgId);
    }

    match /{document=**} { allow read, write: if false; }
  }
}
```

- The `ledger` and `vault` databases use rules that deny all client access, and Cloud IAM gives access only to the function service accounts
- Claims are set by a function when a role is granted or revoked, and the app refreshes the token after a change
- Each rule lookup with `get()` or `exists()` bills a read, so keep lookups to direct document IDs, such as `accessGrants/{grantee}_{grantor}_{scope}`
- Test every rule with the emulator and the rules unit-testing library before release

# Indexes and Queries

- Each screen has one query shape, with a limit, and one composite index declared in `firestore.indexes.json`
- Exclude large or unqueried fields from indexing to cut write and storage cost
- Use cursors for paging, never offsets, because offsets bill skipped documents

```json
{
  "indexes": [
    { "collectionGroup": "items", "queryScope": "COLLECTION",
      "fields": [ { "fieldPath": "status", "order": "ASCENDING" },
                  { "fieldPath": "createdAt", "order": "DESCENDING" } ] }
  ],
  "fieldOverrides": [
    { "collectionGroup": "logs", "fieldPath": "photoRef", "indexes": [] }
  ]
}
```

# Reporting Pipeline

| Need | Method | Cost behaviour |
|-------------|--------------------------------|----------------------|
| Simple counts and sums (farmers per district, acreage) | Firestore aggregation queries `count()` and `sum()` run by a scheduled function | Billed by index entries scanned, roughly one read per 1,000 entries |
| Dashboards | Snapshot documents in `reportSnapshots`, built hourly or daily, read by the app | 1 to 60 reads per open |
| Live counters (loads open now, bales scanned today) | Sharded counter documents updated with `FieldValue.increment` | A few writes per event; shard hot counters |
| Historic and ad-hoc analysis, government and regulator exports | Firestore to BigQuery streaming, with partitioned tables and scheduled queries writing snapshots back | Charged by data scanned; cap bytes billed per query |
| Statutory returns | Scheduled function reads the ledger and BigQuery, writes a signed file to Cloud Storage | Small, predictable |

**Scheduled builder skeleton:**

```ts
export const buildDistrictSnapshots = onSchedule('every 60 minutes', async () => {
  const db = getFirestore();
  const period = currentPeriod();
  for (const d of DISTRICTS) {
    const q = db.collection('farms').where('district', '==', d);
    const agg = await q.aggregate({ farms: AggregateField.count(),
                                    acres: AggregateField.sum('acreage') }).get();
    await db.doc(`reportSnapshots/prod_${d}_${period}`).set({
      metrics: agg.data(), asOf: Timestamp.now(), coverage: await coverage(d)
    });
  }
});
```

Snapshots apply minimum group sizes before publishing, so small districts cannot be used to identify a farmer.

# Offline and Sync in Flutter

- Persistence is on by default on mobile; set the cache size deliberately and keep sensitive reads on `Source.server` where the record should not sit in the local cache
- Transactions and batches that need the server do not work offline, so the app never runs money transactions; it writes commands and waits for status changes
- A write made offline resolves its future only when the server confirms, so the UI must not await it; show the item as pending using document metadata (`hasPendingWrites`) and a global pending count
- **Cost trap:** if a listener is offline for more than about 30 minutes, reconnecting can bill reads for the whole result set again; keep every listened result set small and limited
- Conflicts: for plain fields Firestore keeps the last write, so shared or money-related changes go through commands; notes and logs are separate documents so writes do not collide
- Local data is not encrypted by Firestore; rely on device encryption, an app lock, and avoid caching the most sensitive records
- Bale scans, sensor readings, and chat-style events are buffered on the device and written as one summary document per session

```dart
Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.playIntegrity);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024,   // 100 MB; raise only with a reason
  );
}

class CommandRepository {
  final _db = FirebaseFirestore.instance;
  // Do not await this in the UI: offline, the future completes only after the server confirms.
  void send(String uid, String type, Map<String, dynamic> payload) {
    final ref = _db.collection('users').doc(uid).collection('commands').doc();
    ref.set({
      'type': type, 'payload': payload,
      'idempotencyKey': ref.id, 'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
```

# Flutter and GetX App Architecture

**Layers.** Screens depend on controllers, controllers on repositories, repositories on Firestore. Nothing in a screen or controller calls Firestore directly, which keeps a later change of database contained.

```
lib/
  core/            config, theme, i18n (en, sn, nd), services (auth, role, connectivity, sync status)
  data/
    models/        typed models with converters
    repositories/  one per area: farm, ledger_view, load, report, command
  modules/
    home/          binding, controller, view
    farm/  agronomy/  finance/  logistics/  market/  advisor/  agent/  admin/
  workspace/       role switcher, lens layouts
  main.dart
```

| Package | Use |
|-----------------------------|------------------------------------------|
| firebase_core, firebase_auth, firebase_app_check | Setup, phone sign-in, app attestation |
| cloud_firestore, cloud_functions, firebase_messaging | Data, callable functions, push |
| get | State, dependency injection, routing, translations |
| connectivity_plus | Online state for banners and retry hints |
| geolocator, camera, mobile_scanner | GPS field mapping, photos, QR and barcode scans |
| google_mlkit (text recognition), tflite_flutter | Receipt OCR and on-device Snap and Solve models |
| speech_to_text | Voice-note logging |
| flutter_secure_storage | Small secrets and tokens |
| freezed, json_serializable | Immutable models and converters |

**Patterns**

- Services (`GetxService`) hold long-lived state: `AuthService`, `RoleService` (active role, claims), `SyncStatusService` (pending writes, online state), `NotificationService`
- One controller per screen, created in a binding and disposed with the route; every stream subscription is cancelled in `onClose`
- The role switcher writes the active role to `RoleService`; screens rebuild through `Obx`, and the drawer shows only the icons for that role
- Repositories return typed streams with `limit` applied, so no screen can open an unbounded listener

```dart
class HomeController extends GetxController {
  final _uid = Get.find<AuthService>().uid;
  final home = Rxn<HomeModel>();
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = FirebaseFirestore.instance
        .doc('users/$_uid/home/current')
        .withConverter<HomeModel>(
          fromFirestore: (s, _) => HomeModel.fromMap(s.data()!),
          toFirestore: (m, _) => m.toMap())
        .snapshots()
        .listen((s) => home.value = s.data());
  }

  @override
  void onClose() { _sub?.cancel(); super.onClose(); }
}

class RoleService extends GetxService {
  final active = 'farmer'.obs;
  final roles = <String>[].obs;
  Future<void> load() async {
    final t = await FirebaseAuth.instance.currentUser!.getIdTokenResult(true);
    roles.assignAll(List<String>.from(t.claims?['roles'] ?? ['farmer']));
    if (!roles.contains(active.value)) active.value = roles.first;
  }
}
```

# Cost Controls and Budget

**Cost lines.** Firestore reads, writes, deletes, storage, and network; Cloud Functions invocations and compute; Cloud Scheduler; Firebase Auth SMS verification; Cloud Storage; BigQuery streaming, storage, and queries; Cloud Logging for audit logs. Firestore usage-based prices at us-central1 rates are $0.03 per 100,000 reads, $0.09 per 100,000 writes, and $0.01 per 100,000 deletes, with a daily free quota of 50,000 reads, 20,000 writes, and 20,000 deletes on the default database. Check the Johannesburg row before budgeting.

**Read and write budget per active user per day**

| Item | Target |
|----------------------|------------|
| App opens (home document) | 3 reads |
| Tasks and prompts | Up to 20 reads |
| Role-specific screens (freight radar, farm, ledger view) | Up to 60 reads |
| Reference data and reports | Cached, under 15 reads |
| Total reads | Under 100 |
| Writes (commands, drafts, logs) | Under 30 |

At 100,000 active farmers this is about 10 million reads and 3 million writes per day, which is roughly $170 per month on Firestore at us-central1 rates before functions, SMS, and BigQuery.

**Controls**

- Budget alerts at 50, 90, and 100 percent per environment, with a runbook for each
- Dashboards of reads, writes, and deletes per collection, and alerts on sudden jumps
- App Check and per-user rate limits in functions to stop abuse
- A code review checklist: every listener has a limit, no offset paging, no raw event streams, no rule lookups that can be avoided
- A load test before launch that simulates the pilot and 10 times the pilot, and compares reads per user with the budget above
- A programmatic budget shutdown takes the whole project offline, so prefer feature-level throttles and use a shutdown only as a last resort

# Testing, Release, and Exit Path

- Firebase Emulator Suite for Firestore, Auth, and Functions in every test run
- Unit tests for the waterfall, the balance check, and idempotency, with property tests that random waterfalls always sum to zero
- Rules tests for every path and role, including denied cases
- Integration tests on real low-end Android devices on 2G and 3G speeds, with airplane-mode cycles
- Staged release: internal, then the pilot cluster, then wider rollout, with a kill switch for risky features through remote config
- Exit path: daily Firestore export to Cloud Storage, streaming to BigQuery, domain logic kept in functions behind interfaces, and time-ordered IDs, so ledger and read models can be moved to PostgreSQL later without changing the app screens

# Risk Register

| Risk | Impact | Mitigation | Trigger to act |
|------------------|-----------|--------------------------|----------------|
| Ledger errors or double posting | Money loss and disputes | Single transaction per settlement, idempotency keys, daily reconciliation, tests | Any unreconciled difference |
| Hot document contention | Failed or slow writes | Per-farmer sub-accounts and sharded counters | More than 5 percent contention errors |
| Bill spikes from listeners or loops | Budget overrun | Limits on every query, code review, alerts, load tests | Reads per user above budget |
| Weak ad-hoc reporting | Regulator or bank requests cannot be met | Snapshots plus BigQuery | Two requests in a month that snapshots cannot serve |
| Data must stay in Zimbabwe | Legal exposure | Get counsel advice early; plan a move to in-country Postgres | Any residency requirement |
| Vendor lock-in | Costly migration | Repository interfaces, exports, portable IDs | Price or policy change |
| Local cache exposure on shared phones | Data leak | Device encryption, app lock, avoid caching sensitive records, separate PINs | Security review finding |
| SMS verification cost and delivery | Onboarding failure and cost | Budget SMS, test delivery in Zimbabwe, plan a fallback method | Delivery rate below target |
