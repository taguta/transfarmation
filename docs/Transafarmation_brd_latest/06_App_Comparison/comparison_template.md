# Transfarmation: existing Flutter app vs latest BRD

Fill this from `app_inventory.txt`, or ask Claude Code to fill it (see `claude_code_prompt.md`).
Status values: Done, Partial, Not started, Differs (built differently from the BRD).

## 1. Architecture

| Area | BRD and technical design | Existing app | Status | Action |
|------|--------------------------|--------------|--------|--------|
| Database | Firestore only: (default), ledger, vault databases | | | |
| State management | Flutter with GetX, repositories between controllers and Firestore | | | |
| Offline | Firestore persistence, commands outbox, pending-write indicator | | | |
| Auth | Phone sign-in, custom claims (roles, org, level) | | | |
| Roles and lenses | Multi-role switcher, one identity | | | |
| Security rules | Deny by default, command validation, field-level rules | | | |
| Functions | Command processor, settlement waterfall, payout outbox, report builders | | | |
| Reports | Snapshots, count/sum queries, BigQuery | | | |
| Localisation | English, Shona, Ndebele | | | |
| App Check | Play Integrity | | | |
| Tests | Emulator suite, rules tests, waterfall property tests | | | |

## 2. Modules

| BRD module | Requirement IDs | Existing screens, services, and collections | Status | Gap or action |
|------------|-----------------|---------------------------------------------|--------|---------------|
| Module 1: Feasibility and Offtake | FR1.x | | | |
| TIMB Gateway and Compliance | FR2.x | | | |
| Horticulture Expansion | FR3.x | | | |
| Agronomy | FR7.x | | | |
| Accounting and Input Escrow | FR8.x | | | |
| Logistics and Transport | FR6.x | | | |
| Consumer, Retailer and Offtaker | FR10.x | | | |
| Auction Floors and Exchange | FR11.x | | | |
| Workspace Engine and Dashboard UX | FR9.x, FR12.x | | | |
| Multi-Role | FR13.x | | | |
| Identity Database and Onboarding | FR15.x, FR16.x | | | |
| Marketing and CRM | FR17.x | | | |
| Refrigeration and Storage | FR18.x | | | |
| Ecommerce Marketplace | FR19.x | | | |
| Advisor Desk | FR20.x | | | |
| Agent Console | FR21.x | | | |
| Service Provider Portal | FR22.x | | | |
| Government and Policy Insights | FR23.x | | | |

## 3. Data model

| BRD collection or table | Existing collection | Differences | Migration note |
|-------------------------|---------------------|-------------|----------------|

## 4. Reusable parts
List screens, widgets, services, and models in the app that can be kept as they are.

## 5. Conflicts and decisions needed
List places where the app does something the BRD does differently, and decide which one wins.

## 6. Proposed order of work
1.
2.
3.
