# Transfarmation — Product & Design Audit

**Date:** 2026-09-28
**Scope:** Whole Flutter app (`lib/`), Firestore rules, compared against [transfarmation_specifications.md](transfarmation_specifications.md)
**Method:** Code review only. The app was not run.

---

## Summary

The app looks finished but works like a demo. There are ~25 routes, and the most important flows either fake their outcome or show hardcoded numbers as if they were the farmer's own data. For a product built on trust (finance, credit, advice), this is the main risk.

**Recommendation:** ship fewer features and make them real.

---

## P0: Trust breakers (fix before any pilot)

| # | Issue | Location | Impact |
|---|---|---|---|
| 1 | **Loan applications are never saved.** `_submit()` only sets `_submitted = true`, yet the success screen says the application was "saved locally and will be synced". | [apply_loan_screen.dart:62-64](../lib/features/financing/presentation/screens/apply_loan_screen.dart#L62-L64), [:569](../lib/features/financing/presentation/screens/apply_loan_screen.dart#L569) | Financing is the core Phase 1 module. Farmers would wait for a loan that does not exist. |
| 2 | **Repayment estimate is wrong.** It always divides by 6 regardless of the chosen period, applies a flat 12%, and does not update while typing (the controller has no listener). | [apply_loan_screen.dart:435-437](../lib/features/financing/presentation/screens/apply_loan_screen.dart#L435-L437) | Wrong money figures in a lending app are a regulatory and reputational risk. |
| 3 | **Home dashboard is fully hardcoded:** "12 ha", "$2,400", credit score "72", "All data synced · 2 min ago", the Maize loan card, and market prices. | [home_screen.dart:191-590](../lib/features/home/presentation/screens/home_screen.dart#L191-L590) | The first screen shows someone else's data. The home banner says "synced" even when the shell banner shows pending items. |
| 4 | **Credit score is a constant** (farm size 12, Maize, one completed loan). | [credit_scoring.dart:108-117](../lib/features/financing/domain/services/credit_scoring.dart#L108-L117) | Every farmer gets the same score. |
| 5 | **The "AI" diagnosis and expert chat are scripted.** Every crop photo returns *Tuta absoluta* (88%) and every animal returns *Orf*. The chat returns keyword-matched canned replies labelled "Transfarmation AI". | [diagnosis_screen.dart:166-203](../lib/features/diagnosis/presentation/screens/diagnosis_screen.dart#L166-L203), [expert_chat_screen.dart:76-96](../lib/features/expert/presentation/screens/expert_chat_screen.dart#L76-L96) | A fake diagnosis with a confidence percentage and pesticide advice could cause real crop or animal harm. Label it "Demo" or hide it. |
| 6 | **Authentication redirect is disabled.** | [app_router.dart:47-74](../lib/core/router/app_router.dart#L47-L74) | Acceptable during development, but it must sit behind a build flag so it cannot ship this way. |
| 7 | **Firestore rules let any signed-in user read and write every document**, including other farmers' loans and profiles. | [firestore.rules:6-8](../firestore.rules#L6-L8) | Exposes other farmers' financial data. The spec (section 8) requires role-based access control (RBAC). Scope access by `uid` and role. |
| 8 | **Every service tile shows a `?` icon.** `getIconByName` (commit `f7868cc`) matches names such as `'home'`, but the data stores codepoints such as `'57408'`. | [services_screen.dart:10-28](../lib/features/services/presentation/screens/services_screen.dart#L10-L28) vs [services_sqlite.dart:15-20](../lib/features/services/infrastructure/datasource/local/services_sqlite.dart#L15-L20) | Visible regression. |

---

## P1: Navigation and information architecture

- **Navigation differs between form factors.** The desktop rail has 6 destinations. Mobile has 4 bottom tabs, and Services and Advisory are only reachable from the drawer. When the user is on Services or Advisory, the mobile tab logic falls back to highlighting "Home" ([app_shell.dart:205-218](../lib/features/shell/presentation/screens/app_shell.dart#L205-L218)).
- **Inconsistent names:** "Loans" (drawer and rail) vs "Finance" (bottom bar). "Markets" (marketplace) vs "Market Prices" (a separate screen). Use one name per destination.
- **Unreachable features:** `/labor-management`, `/traceability`, `/community` and `/iot-dashboard` have routes but no entry point anywhere in the app.
- **Home is overloaded:** 12 equal-weight action tiles, plus an "All Services" button that lists only 6 services. Replace these with 4–6 tiles chosen by season (planting: inputs and loans; growing: weather and diagnosis; harvest: sell and prices).
- **Dead controls:** the Advisory "See All" button does nothing ([home_screen.dart:143](../lib/features/home/presentation/screens/home_screen.dart#L143)). There are empty `onPressed: () {}` handlers in the labor, IoT and traceability screens.
- **Back navigation breaks** because `context.go` is used for moves deeper within Financing ([loan_status_screen.dart:64](../lib/features/financing/presentation/screens/loan_status_screen.dart#L64)). Use `push` for drill-downs.

## P1: First-run experience

- **The splash screen always waits 3.5 seconds and always routes to onboarding**, including for returning users ([splash_screen.dart:22-27](../lib/features/splash/presentation/screens/splash_screen.dart#L22-L27)). The spec requires loading in under 2 seconds. Route based on "onboarding seen" and "signed in" instead of a timer.
- **Onboarding leads to email login, and phone login is "coming soon".** For rural Zimbabwe, phone number with a one-time code (OTP) should be the main sign-in method.
- **The greeting is always "Good Morning"**, and the fallback name is "New Farmer". Greet by time of day and capture the farmer's name at signup.
- **Forms are pre-filled with fake data** ("Moyo Family Farm", [apply_loan_screen.dart:19](../lib/features/financing/presentation/screens/apply_loan_screen.dart#L19)). Pre-fill from the farmer's real profile instead, which also meets the spec's "minimal forms" requirement.

## P1: Design system and accessibility

- **Dark mode and the colour-blind modes do not work.** Screens reference light-only constants (`AppColors.surface`, `textPrimary`, `background`, `border`) **256 times**, and `colorPaletteProvider` is used **0 times**. In dark mode, cards stay white. Move colours onto `Theme.of(context).colorScheme` or a `ThemeExtension`.
- **Accessibility gaps:**
  - `Semantics` or `semanticLabel` appear in only 2 files.
  - Home tiles use `GestureDetector`, which gives no ripple or focus feedback.
  - `textTertiary` (`#94A894`) on white fails WCAG contrast for body text.
  - Most home labels are 11–12px captions, which is hard to read for older users outdoors on mid-range phones.
- **The spec's low-literacy requirements (section 10.2) are not implemented:**
  - No Shona or Ndebele localisation (`flutter_localizations` is not set up).
  - No voice support.
  - "$" is hardcoded, there is no `NumberFormat`, and ZiG is not handled.
- **Duplicated styles and widgets:** the logo, motto and Poppins styles are copied between the drawer and the rail. The home market-price widget exists twice (row and sidebar), each with its own hardcoded data.

## P2: Offline-first user experience

The sync architecture is solid, but the interface does not yet make it trustworthy:

- Show sync state on each record ("pending", "synced", "failed – tap to retry"), not just a global count.
- "Offline Mode: N items waiting" appears whenever the queue is non-empty, even when the device is online. Base the offline message on connectivity and describe the queue separately.

---

## Product strategy

1. **Limit scope to spec Phase 1 (financing and a basic marketplace).** IoT, traceability, labor, community, contracts and group buying belong to Phases 2–3. Hide them behind feature flags rather than shipping them half-built.
2. **Build one complete, real flow:** register (phone) → farm profile → loan application (persisted) → status → repayments, using a credit score computed from real profile data.
3. **Label anything simulated.** If the demo diagnosis or chat must stay for investor demos, badge it "Demo". Never show a confidence percentage for a fabricated result.
4. **Decide on payments.** The spec calls EcoCash "critical", but no payments module exists.
5. **Add product analytics.** Metrics are listed in spec section 9, but nothing is instrumented, so pilot success cannot be measured.

## Engineering hygiene with product impact

- **Tests:** there are 10 test files, all covering entities and providers. There are no widget or flow tests. At minimum, add a test that a loan application is saved to SQLite and queued for sync.
- **Screens bypass repositories:** [sell_produce_screen.dart:403](../lib/features/marketplace/presentation/screens/sell_produce_screen.dart#L403) reads `databaseProvider` directly, which skips the sync queue.
- **Two storage systems:** Hive is used only for the theme setting, alongside SQLite. Consolidate on SQLite.
- **Outdated doc:** [feature_audit_report.md](feature_audit_report.md) does not mention the simulated flows listed above.

---

## Proposed sequencing

| Phase | Work |
|---|---|
| Week 1 | Fix the service icon bug; tighten Firestore rules; put auth behind a build flag; remove or label all hardcoded data on Home. |
| Weeks 2–3 | Persist loan applications; fix the repayment maths; compute the credit score from real data; route the splash screen by user state. |
| Weeks 4–5 | Unify navigation; make Home seasonal; hide Phase 2–3 modules. |
| Week 6+ | Migrate colours onto the theme so dark mode and accessibility work; add localisation, phone OTP sign-in and analytics. |
