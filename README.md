# Transfarmation

*People busy transforming their farming activities.*

An offline-first Flutter app (Android, web, desktop) that makes Zimbabwe's tobacco value chain transparent, financeable and compliant for smallholder farmers, designed to extend to horticulture and other African markets. Live web build: https://transfarmation.web.app

## Documents

| File | Purpose |
|---|---|
| [docs/transfarmation_specifications.md](docs/transfarmation_specifications.md) | Current product and requirements specification |
| [docs/go_to_market_audit.md](docs/go_to_market_audit.md) | Market research, validation and risks behind the spec |
| [docs/feature_audit_report.md](docs/feature_audit_report.md) | What is built and how ready it is |
| [docs/Transfarmation_Value_Proposition.docx](docs/Transfarmation_Value_Proposition.docx) | Stakeholder and partner document |
| [docs/archive/](docs/archive/) | Superseded material (original AgroLink spec) |

## Run

```bash
flutter pub get
flutter run -d chrome                           # sign-in is required
flutter run -d chrome --dart-define=REQUIRE_AUTH=false   # browse without an account (testing only)
flutter test
```

## Structure

Feature-first Clean Architecture: `lib/features/<feature>/{domain,infrastructure,presentation}`. The UI reads only from local SQLite; writes go to a sync queue that reaches Firestore when online. Cloud Functions are in `functions/`; Firestore rules are in `firestore.rules`.

## Before onboarding real farmers

The data-controller licence from POTRAZ, a data protection officer, and legal review of contracts and payment wording come first. See section 4 of the specification.
