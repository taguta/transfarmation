# Decision Record and Summary

**Purpose.** This document designs Transfarmation on Supabase (PostgreSQL) as the only database, with PowerSync keeping a local SQLite database on each phone in sync, and Flutter with GetX for the app. It is the alternative to the Firestore-only design, and it answers two questions for 100,000 or more users: will this scale, and would Firestore stay affordable.

**Short answers**

- **Does Supabase with PowerSync scale to 100,000+ users?** Yes. The database load is small for PostgreSQL: 100,000 users making 30 writes a day is about 35 writes per second on average, and perhaps 350 per second at a peak, which is well within one mid-sized instance. The limits you will meet first are on the sync layer, not the database: peak concurrent phones and data synced per month (see the cost table), and replication load if high-volume tables such as sensor data are synced by mistake.
- **Would Firestore work at 100,000+ users without exponential cost?** Yes, if it is designed with the read-model rules. Firestore cost grows in line with operations, not exponentially, but a few patterns multiply the operations behind the scenes (shared-document listeners, fan-out writes, unbounded listeners, raw telemetry, and trigger loops). A disciplined Firestore design at this scale costs roughly the same order as Supabase with PowerSync, and can be cheaper in infrastructure spend. The trade-off is engineering risk for money and reports, not the bill.
- **Which to choose?** At 100,000 users the infrastructure difference is small compared with team cost. Choose Postgres if ledger integrity, SQL reporting, portability, and possible in-country hosting matter most. Choose Firestore if the fastest path to offline and real-time with the team's existing skills matters most, and you accept the guardrails.

**When to choose this option**

- Regulators, banks, or law may require data stored in Zimbabwe, which needs a portable, self-hostable database
- Reports and statutory returns will need joins, ad-hoc queries, and BI tools
- The ledger and escrow must be enforced by the database, not only by application code
- The team is willing to learn SQL and sync rules

![Figure 9: Supabase and PowerSync architecture](/home/claude/diag/09_supabase_powersync_architecture.png){width=11cm}

# Scalability Assessment at 100,000+ Users

**Load assumptions (adjust with pilot data)**

| Item | Assumption |
|--------------------|--------------------------------------------|
| Registered users | 100,000 farmers plus agents, transporters, and institutions |
| Daily active users | 30,000 |
| Peak concurrent phones | About 3,000 on a normal day; up to 10,000 on auction or sales days |
| Writes from phones | About 30 per active user per day, so 3 million a day, about 35 per second on average and 350 per second at a 10 times peak |
| Ledger volume | About 500,000 settlements per season with about 6 entries each, so about 3 million entries a season |
| Sensors | 5,000 units; raw readings every 10 seconds would be 43 million rows a day, so store hourly summaries or keep raw data for a short time |

**Where it can break, and what to do**

| Area | Risk at scale | Design response |
|--------------------|--------------------------|--------------------------------|
| Peak concurrent phones on PowerSync | Plan limits: Pro allows up to 3,000 by default, Team up to 10,000 (configurable to 50,000 or more on request), Enterprise custom | Forecast concurrency from pilot data; start on Pro, move to Team before auction season, or self-host PowerSync |
| Data synced per month | Billed per GB beyond the included amount, so a chatty sync design costs more | Sync only the user's own working set, keep rows small, avoid syncing large shared tables to everyone |
| Data hosted on PowerSync | Every bucket stores a copy of the data it serves | Avoid duplicating the same rows in many buckets; keep reference data in one shared bucket |
| Logical replication | High write volume in synced tables lengthens replication lag | Keep sensor readings, audit logs, and other high-volume tables out of the sync publication |
| Hot ledger accounts | Every posting to one account takes a row lock, so a single pooled account becomes a queue | Per-farmer sub-accounts, sharded pooled accounts, and short transactions |
| Database connections | Many API calls can exhaust connections | Use the pooler, keep functions short, and have PowerSync uploads batch their calls |
| Reports competing with writes | Heavy queries slow the app | Rollup tables refreshed on a schedule, and a read replica for exports and BI |
| Table growth | Logs, ledger entries, and events grow without limit | Monthly partitions, archive old partitions, and index only what is queried |
| Auction-day bursts | Many scans and settlements at once | Batch scans on the device, queue payouts, load test at 10 times the pilot |
| Re-sync storms | After an outage all phones reconnect together | Staged reconnect with backoff in the app, and PowerSync capacity headroom |

**Conclusion.** PostgreSQL handles this load without special tuning beyond good indexing, partitions, and a right-sized instance. The design work is in the sync rules, the ledger, and keeping high-volume data out of sync.

# Cost Model at 100,000 Users (illustrative, not a quote)

**Verified price points (checked September 2026)**

- PowerSync Cloud: Pro from $49 per month, including 30 GB synced, 10 GB hosted, and 1,000 peak concurrent clients, then $1 per GB synced, $1 per GB hosted, and $30 per extra 1,000 clients, with a default maximum of 3,000 clients; Team from $599 per month with a default maximum of 10,000 clients, configurable to 50,000 or more; Enterprise is custom; a free plan and a self-hosting option exist. Source: [PowerSync pricing](https://powersync.com/pricing)
- Supabase: Pro is $25 per month with an 8 GB database, 250 GB egress, and 100,000 monthly active users, plus a $10 compute credit covering one Micro instance; compute is billed separately (Micro about $10, Small about $15, Medium about $60 per month, larger sizes cost more); database storage beyond 8 GB is about $0.125 per GB; the Pro spend cap is on by default. Sources: [Supabase pricing guide](https://www.jetadmin.io/blog/supabase-pricing-2026-guide-to-plans-limits-and-real-world-costs/), [Supabase cost explained](https://www.cloudzero.com/blog/supabase-pricing/)
- Firestore Standard edition at us-central1 rates: $0.03 per 100,000 reads, $0.09 per 100,000 writes, $0.01 per 100,000 deletes. Source: [Firestore pricing](https://cloud.google.com/firestore/pricing)

**Supabase with PowerSync at 100,000 registered users**

Assumptions: 300 GB synced a month (about 3 MB per user), 50 GB hosted on the sync service, and a 100 GB database.

| Line | Pro plan, peak up to 3,000 phones | Team plan, peak up to 10,000 phones |
|----------------------|-----------------------|-----------------------|
| PowerSync base | $49 | $599 |
| Extra concurrent clients | $60 (2,000 extra) | $270 (9,000 extra) |
| Data synced above included | $270 | $270 |
| Data hosted above included | $40 | $40 |
| PowerSync subtotal | About $420 | About $1,180 |
| Supabase Pro plan | $25 | $25 |
| Larger compute instance | About $100 to $300 (Medium is $60; larger sizes cost more) | About $100 to $300 |
| Database storage (100 GB) | About $12 | About $12 |
| Total before SMS, functions, and BI | About $560 to $760 | About $1,320 to $1,520 |

If you self-host PowerSync instead, the per-GB and per-client fees go away, and you pay for servers and operations.

**Firestore at 100,000 registered users (30,000 active)**

| Design | Reads and writes per active user per day | Firestore operations cost per month |
|------------------------|------------------------------|--------------------------|
| Read-model design | 100 reads, 30 writes | About $170 at us-central1 rates |
| Naive design | 500 reads, 90 writes | About $690 |
| Add | Functions, BigQuery, SMS, and the Johannesburg price difference | Depends on volume; budget separately |

Reading the two tables together: in infrastructure spend both are in the hundreds of dollars a month at this scale, and both scale roughly linearly beyond it. Postgres with PowerSync moves in steps (a bigger instance, a higher plan), and Firestore moves smoothly with usage.

**Why Firestore does not go exponential, and what does multiply its cost**

Cost is per operation, so it is linear in operations. It feels exponential when one action causes many operations. Watch for these:

| Pattern | Why it multiplies | Example | Response |
|------------------|--------------------------|-------------------------|--------------------------|
| Shared document with many listeners | Each change is billed once per listener | A price document updated 100 times a day with 30,000 listeners is 3 million reads a day, about $27 a month | Use a short refresh interval, or read on demand |
| Listener on a large collection | Opening it bills every document, and a long disconnection can bill the whole result again | 30,000 users opening 3 times a day with 500 documents each is 45 million reads a day, about $405 a month | Limit every query and keep result sets small |
| Fan-out writes | One event writes a copy for each recipient | A broadcast to 30,000 users is 30,000 writes | Use topics or a single shared document |
| Report by scanning | A dashboard reads every source document | 100,000 farm documents per view | Precomputed snapshots and aggregation queries |
| Raw telemetry | Every reading is a write | 5,000 sensors every 10 seconds is about $1,170 a month | Summarise on the device |
| Trigger loops and retries | A function that writes to the collection it listens to | 1,000 writes a second is about $78 a day | Guard triggers, and set budget alerts and a runbook |
| Security rule lookups | Each `get()` or `exists()` in a rule bills a read | One extra read per request | Use custom claims and direct document IDs |

**Postgres with PowerSync has its own cliffs.** Peak concurrent phones and data synced per month are the two meters, and each plan has a maximum for concurrent phones. Crossing a plan limit needs a plan change or a request to the vendor, so review usage before each season.

# Project Setup

| Item | Choice |
|------------------|-------------------------------------------|
| Supabase | One project per environment (dev, staging, production); Pro plan for production with the spend cap on until usage is understood |
| Region | Choose the closest region to users, and confirm the region list on the Supabase dashboard; use a self-hosted or in-country Postgres if residency law requires it |
| Postgres | Row-level security on every table; `app` schema synced to phones; `ledger`, `vault`, `audit`, and `sensors` schemas not exposed through the public API |
| Extensions | PostGIS for plot boundaries, pg_cron for scheduled rollups, pgcrypto for hashing, and a partition helper for time-series tables |
| Auth | Supabase Auth with phone sign-in; a custom access-token hook adds `person_id`, roles, organisation, and verification level to the token. SMS is billed by the SMS provider, so budget for it |
| PowerSync | One PowerSync instance per environment, connected to the database with a replication role and a publication that lists only the synced tables |
| Storage | Supabase Storage buckets for photos and contracts, with signed links; files do not travel through sync |
| Jobs | pg_cron for rollups and reconciliation; a small worker or Edge Function for payouts and notifications |
| Migrations | Supabase CLI migrations in source control, reviewed like code |
| Monitoring | Database metrics, PowerSync usage dashboard and alerts, function logs, and budget alerts |

# Data Model

Keep all identifiers as UUIDs generated on the device (time-ordered where possible), so records created offline never collide. Add `owner_id` to every child table that is synced, so sync rules can filter with a simple condition.

**Schemas and tables**

| Schema | Tables | Notes |
|----------|-------------------------------------|-----------------------------|
| app | persons, role_profiles, organisations, memberships, delegations, consents, access_grants | Identity and consent; synced for the user's own rows |
| app | farms, crop_logs, seasons, feasibility_plans, contracts, contract_events, input_loans | Farm and contract data |
| app | loads, load_events, consignments, lots, bales, storage_units | Movement and storage |
| app | commands, tasks, notifications | Offline outbox and prompts |
| ref | crop_templates, grade_classes, levy_rates, translations | Shared reference data with effective dates |
| ledger | accounts, txns, entries, escrows, escrow_events, payouts, idempotency | Private; written only by SQL functions |
| vault | verifications | Verification results and grower number links, no raw biometric images |
| audit | log | Append-only, hash-chained |
| sensors | readings | Partitioned by month; not in the sync publication |
| reports | district_production, levy_by_district, portfolio_health, price_by_market | Rollup tables refreshed by pg_cron |

**Core DDL (excerpt)**

```sql
create schema if not exists app; create schema if not exists ledger;
create schema if not exists vault; create schema if not exists audit;
create schema if not exists reports; create schema if not exists sensors;

create table app.persons (
  id uuid primary key,
  auth_user_id uuid unique,
  full_name text not null,
  phone text unique,
  language text not null default 'en',
  verification_level smallint not null default 0,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table app.role_profiles (
  id uuid primary key,
  person_id uuid not null references app.persons(id),
  owner_id uuid not null,                              -- same as person_id, for sync rules
  role text not null check (role in ('farmer','transporter','agent','advisor','supplier',
        'banker','contractor','regulator','government','buyer','floor')),
  status text not null default 'pending',
  verification_level smallint not null default 0,
  attributes jsonb not null default '{}',
  unique (person_id, role)
);

create table app.consents (                            -- append-only
  id uuid primary key,
  owner_id uuid not null references app.persons(id),
  role text, purpose text not null, recipient_type text, recipient_id uuid,
  granted boolean not null, language text, version text, agent_id uuid,
  recorded_at timestamptz not null default now()
);

create table app.farms (
  id uuid primary key,
  owner_id uuid not null references app.persons(id),
  district text not null, cluster_id uuid, crop text not null,
  acreage numeric(10,2), boundary geography(polygon, 4326),
  planting_date date, stage text, calendar jsonb not null default '[]',
  updated_at timestamptz not null default now()
);
create index on app.farms (owner_id);
create index on app.farms (district, crop);

create table app.commands (                            -- offline outbox, id made on the phone
  id uuid primary key,
  owner_id uuid not null references app.persons(id),
  type text not null, payload jsonb not null,
  status text not null default 'pending', result jsonb,
  created_at timestamptz not null default now(), processed_at timestamptz
);
create index on app.commands (status, created_at);
```

**Ledger and escrow DDL (excerpt)**

```sql
create table ledger.accounts (
  id uuid primary key,
  code text unique not null,                           -- e.g. wallet:f123, levy:timb
  owner_id uuid, type text not null, currency char(3) not null,
  balance_minor bigint not null default 0, version bigint not null default 0
);

create table ledger.txns (
  id uuid primary key default gen_random_uuid(),
  type text not null, idempotency_key text not null unique,
  rules_version text, created_at timestamptz not null default now(), hash text
);

create table ledger.entries (
  id bigint generated always as identity primary key,
  txn_id uuid not null references ledger.txns(id),
  account_id uuid not null references ledger.accounts(id),
  delta_minor bigint not null, currency char(3) not null,
  created_at timestamptz not null default now()
);
create index on ledger.entries (account_id, created_at);

create function ledger.check_balanced() returns trigger language plpgsql as $$
begin
  if exists (select 1 from ledger.entries where txn_id = new.txn_id
             group by currency having sum(delta_minor) <> 0) then
    raise exception 'unbalanced transaction %', new.txn_id;
  end if;
  return null;
end $$;
create constraint trigger entries_balanced after insert on ledger.entries
  deferrable initially deferred for each row execute function ledger.check_balanced();

create function ledger.apply_entry() returns trigger language plpgsql as $$
begin
  update ledger.accounts set balance_minor = balance_minor + new.delta_minor,
         version = version + 1 where id = new.account_id;
  return new;
end $$;
create trigger entries_apply after insert on ledger.entries
  for each row execute function ledger.apply_entry();

create function ledger.block_change() returns trigger language plpgsql as $$
begin raise exception 'ledger rows are immutable'; end $$;
create trigger entries_immutable before update or delete on ledger.entries
  for each row execute function ledger.block_change();
revoke all on schema ledger from anon, authenticated;

create table ledger.payouts (                          -- outbox for mobile money and banks
  id uuid primary key default gen_random_uuid(),
  txn_id uuid references ledger.txns(id), account_id uuid, amount_minor bigint not null,
  status text not null default 'queued'
    check (status in ('queued','sent','confirmed','failed')),
  provider_ref text, attempts int not null default 0,
  next_attempt_at timestamptz default now(), updated_at timestamptz default now()
);
```

**Settlement function (waterfall) in one database transaction**

```sql
create or replace function ledger.post_settlement(
  p_key text, p_gross bigint, p_currency char(3), p_steps jsonb,
  p_clearing uuid, p_farmer_wallet uuid)
returns uuid language plpgsql security definer set search_path = ledger, pg_temp as $$
declare v_txn uuid; v_left bigint := p_gross; v_step jsonb; v_amt bigint;
begin
  insert into ledger.txns (type, idempotency_key) values ('sale_settlement', p_key)
    on conflict (idempotency_key) do nothing returning id into v_txn;
  if v_txn is null then                                  -- already posted: return the same result
    select id into v_txn from ledger.txns where idempotency_key = p_key; return v_txn;
  end if;

  insert into ledger.entries (txn_id, account_id, delta_minor, currency)
    values (v_txn, p_clearing, -p_gross, p_currency);
  for v_step in select * from jsonb_array_elements(p_steps) loop   -- order set by law and contract
    v_amt := least(v_left, (v_step->>'due_minor')::bigint);
    if v_amt > 0 then
      insert into ledger.entries (txn_id, account_id, delta_minor, currency)
        values (v_txn, (v_step->>'account')::uuid, v_amt, p_currency);
      v_left := v_left - v_amt;
    end if;
  end loop;
  insert into ledger.entries (txn_id, account_id, delta_minor, currency)
    values (v_txn, p_farmer_wallet, v_left, p_currency);
  insert into ledger.payouts (txn_id, account_id, amount_minor)
    values (v_txn, p_farmer_wallet, v_left);
  return v_txn;
end $$;
```

**Payout worker.** A worker selects queued payouts with `for update skip locked`, calls the mobile-money or bank API with the payout ID as the idempotency key, and updates the status from the response or webhook. A reconciliation job flags payouts stuck in `queued` or `sent`.

**Audit chain.** `audit.log` stores the previous row's hash and its own hash. To avoid contention, chain per day or per partition and store a daily digest in a retention-locked storage bucket.

**Time series.** `sensors.readings` is partitioned by month with an automatic partition helper. Keep raw rows for a short period and hourly summaries longer. The table is not in the PowerSync publication.

# Security: Row-Level Security and Sync Rules

**Two layers protect data**

- Row-level security protects the database API and any direct access
- PowerSync sync rules decide which rows reach each phone; they are the read authorisation for synced data, so they must match the security intent of the policies

```sql
alter table app.farms enable row level security;
create policy farms_owner on app.farms for select
  using (owner_id = (auth.jwt() ->> 'person_id')::uuid);
create policy farms_granted on app.farms for select using (exists (
  select 1 from app.access_grants g
  where g.grantor_id = farms.owner_id
    and g.grantee_id = (auth.jwt() ->> 'person_id')::uuid
    and g.scope = 'farm_records' and g.status = 'active' and g.expires_at > now()));
create policy farms_insert on app.farms for insert
  with check (owner_id = (auth.jwt() ->> 'person_id')::uuid);
```

- Clients write only their own rows and the `commands` table; money changes go through SQL functions called by trusted code
- The token carries short role names and the `person_id`, set by an access-token hook when roles change; the app refreshes the token after a change
- The `ledger`, `vault`, and `audit` schemas are not exposed through the public API, and only the service role and function owners can reach them

**PowerSync sync rules (sample to validate against current documentation)**

```yaml
bucket_definitions:
  by_user:
    parameters: select request.user_id() as user_id
    data:
      - select * from app.persons where id = bucket.user_id
      - select * from app.role_profiles where owner_id = bucket.user_id
      - select * from app.farms where owner_id = bucket.user_id
      - select * from app.crop_logs where owner_id = bucket.user_id
      - select * from app.commands where owner_id = bucket.user_id
      - select * from app.tasks where owner_id = bucket.user_id

  reference_data:
    data:
      - select * from ref.crop_templates
      - select * from ref.grade_classes
      - select * from ref.levy_rates
      - select * from ref.translations

  open_loads_by_district:
    parameters: select district from app.user_districts where user_id = request.user_id()
    data:
      - select * from app.open_loads where district = bucket.district
```

- Keep the number of buckets per user small; the service has a per-user limit, so check the current value
- Denormalise `owner_id` onto child tables so rules stay simple filters
- Do not sync ledger tables to phones; show the farmer's balance and history from a read model in the `app` schema written by the ledger functions
- Sync Streams are a newer way to define partial sync; check the current documentation before choosing between them

# Write Path: Commands and Uploads

- The app writes to the local database only; PowerSync queues each change and calls `uploadData` when online
- Simple owned data (farm edits, crop logs, tasks) is upserted through the Supabase API under row-level security
- Business actions (book transport, log expense, post harvest, settle a sale) are rows in `app.commands`; a database trigger or worker validates them, calls the SQL functions, and writes the result back to the command row, which syncs to the phone
- Every command has a client-made ID, so a repeated upload is harmless
- Uploads that fail for a permanent reason are marked failed and completed in the queue, so one bad row cannot block all later changes; temporary failures are retried

# Flutter, GetX, and PowerSync

```
lib/
  core/            config, theme, i18n (en, sn, nd), services (auth, role, sync status)
  data/
    powersync/     schema.dart, connector.dart, database.dart
    repositories/  farm, ledger_view, load, report, command
  modules/         home, farm, agronomy, finance, logistics, market, advisor, agent, admin
  workspace/       role switcher and lens layouts
  main.dart
```

```dart
// schema.dart
const schema = Schema([
  Table('farms', [
    Column.text('owner_id'), Column.text('district'), Column.text('crop'),
    Column.real('acreage'), Column.text('planting_date'),
    Column.text('stage'), Column.text('calendar'),
  ]),
  Table('commands', [
    Column.text('owner_id'), Column.text('type'), Column.text('payload'),
    Column.text('status'), Column.text('result'), Column.text('created_at'),
  ]),
  Table('tasks', [
    Column.text('owner_id'), Column.text('title'), Column.text('due_at'), Column.text('status'),
  ]),
]);

// connector.dart
class TfConnector extends PowerSyncBackendConnector {
  final SupabaseClient _sb = Supabase.instance.client;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = _sb.auth.currentSession;
    if (session == null) return null;
    return PowerSyncCredentials(endpoint: Env.powersyncUrl, token: session.accessToken);
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final batch = await database.getCrudBatch(limit: 50);
    if (batch == null) return;
    try {
      for (final op in batch.crud) {
        final table = _sb.from(op.table);
        switch (op.op) {
          case UpdateType.put:
            await table.upsert({...?op.opData, 'id': op.id});
          case UpdateType.patch:
            await table.update(op.opData!).eq('id', op.id);
          case UpdateType.delete:
            await table.delete().eq('id', op.id);
        }
      }
      await batch.complete();
    } on PostgrestException catch (e) {
      if (isPermanent(e)) { await batch.complete(); }   // log and drop bad rows
      else { rethrow; }                                 // temporary: PowerSync retries
    }
  }
}

// database.dart
Future<PowerSyncDatabase> openDb() async {
  final dir = await getApplicationSupportDirectory();
  final db = PowerSyncDatabase(schema: schema, path: join(dir.path, 'tf.db'));
  await db.initialize();
  await db.connect(connector: TfConnector());
  return db;
}

// A GetX controller reading only from the local database
class TasksController extends GetxController {
  final PowerSyncDatabase db = Get.find();
  final tasks = <Map<String, dynamic>>[].obs;
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = db.watch(
      'SELECT * FROM tasks WHERE status = ? ORDER BY due_at LIMIT 50', parameters: ['open'],
    ).listen((rows) => tasks.assignAll(rows.map((r) => Map<String, dynamic>.from(r))));
  }

  Future<void> complete(String id) =>
      db.execute('UPDATE tasks SET status = ? WHERE id = ?', ['done', id]);

  @override
  void onClose() { _sub?.cancel(); super.onClose(); }
}
```

- Encrypt the local database with the SQLCipher-enabled PowerSync package if it is supported for your target devices; confirm before committing
- Use an app lock, separate PINs on shared phones, and clear local data on sign-out
- Show sync status and the count of items waiting to upload, using the database status stream
- Photos are uploaded to Supabase Storage in a background task, and the database stores the path
- Run the on-device models (Snap and Solve, OCR) locally and store the results as rows

# Reporting

- Rollup tables in `reports` are refreshed by pg_cron (hourly for operations, daily for government), using `insert ... on conflict do update` from source tables
- Heavier views use materialised views refreshed concurrently, off-peak
- Dashboards read from a read replica or from the rollup tables, never from raw event tables
- Snapshots apply minimum group sizes before publication, so small districts cannot identify a farmer
- Statutory returns are generated by scheduled functions and stored as signed files in storage
- Live counters for operations (loads open now, bales scanned today) are small tables updated by triggers or by the command processor
- Web dashboards can use the same PowerSync sync for small working sets, or plain queries against the rollup tables

# Implementation Plan

Estimated durations for a team of about two Flutter developers, one backend and SQL engineer, and part-time testing and operations support. They assume the roadmap phases in this BRD.

| Phase | Weeks | Deliverables | Exit criteria |
|------------------|-----|----------------------------|----------------------------|
| 0. Spike and decisions | 2 | Supabase and PowerSync prototype with farm and command tables; 2G and 3G sync tests; cost measurements; SQLCipher check; decision review | Sync works offline for 50 test phones; measured data per user per month |
| 1. Foundation | 6 | Environments, migrations, Auth with phone sign-in and token hook, identity and consent tables, RLS, sync rules, Flutter shell with role switcher, onboarding flow, audit log | New farmer onboarded offline and synced; RLS tests pass |
| 2. Standalone farmer tools | 6 | Farm profile with GPS, feasibility plan, crop calendar, weather prompts, basic ledger view, local-language UI | Pilot farmers use the app daily without any other party |
| 3. Money and logistics | 8 | Ledger, escrow, settlement function, payout worker, reconciliation, input vouchers, freight matching, proof of delivery | Settlement tests pass; reconciliation shows zero difference in staging |
| 4. Reports, floors, hardening | 6 | Rollup tables, dashboards for regulator, bank, and government, auction floor intake, load test at 10 times the pilot, security review, runbooks | Load test meets targets; penetration test findings closed |

**Cross-cutting work**

- Database tests with pgTAP for ledger balance, immutability, idempotency, and row-level security
- Property tests: random waterfalls always sum to zero and never overdraw
- Offline test matrix: airplane mode cycles, long offline periods, app updates with sync rule changes, clock changes
- Load tests: simulated phones connecting to PowerSync, bursts of settlements, and report refreshes together
- Release: staged rollout with feature flags and a kill switch for risky features

# Operations

- Backups: daily backups on Pro; add point-in-time recovery for production because it is a paid add-on and money data needs it; test restores every quarter
- Disaster recovery: PowerSync holds a cache of Postgres data, so recovery means restoring Postgres and letting phones re-sync; plan a staged reconnect to avoid a re-sync storm
- Sync rule changes: version rules, test on staging with real device data, and keep old app versions working through a migration window
- Monitoring: database CPU, connections, replication lag and slot size, PowerSync usage and concurrent clients, payout queue depth, and reconciliation differences
- Access: least-privilege database roles, no shared service keys in the app, key rotation, and audit of all admin actions
- Exit path: standard PostgreSQL, so data can move to another managed provider or self-hosted servers; PowerSync can also be self-hosted

# Risk Register

| Risk | Impact | Mitigation | Trigger to act |
|------------------|-----------|--------------------------|----------------|
| Sync rules leak data | Privacy breach | Filter by owner or consented grant, test with two users, review every rule change | Any cross-user test failure |
| Concurrent clients exceed plan | Sync refused at peak | Forecast peaks, move plan early, or self-host | Peak above 70 percent of plan limit |
| Data synced per user grows | Rising bill and slow phones | Limit working set, prune old rows, avoid duplicate buckets | Over 5 MB per user per month |
| Replication lag from heavy tables | Stale data on phones | Keep sensors and logs out of publication | Lag above target for 5 minutes |
| Hot ledger accounts | Slow settlements | Sub-accounts, sharded pooled accounts | Lock wait alerts |
| Team learning curve on SQL and sync | Slower delivery | Spike first, pair with an experienced engineer, templates for rules and policies | Phase 1 slips by more than 2 weeks |
| Vendor changes to PowerSync or Supabase pricing | Cost change | Track usage, keep self-hosting option, keep standard SQL | Price change notice |
| Local database exposure on shared phones | Data leak | Encrypted local database, app lock, PINs | Security review finding |
