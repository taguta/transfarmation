# Transfarmation BRD and design pack (latest)

Prepared 28 September 2026. Copy this folder to `C:\Flutter_Projects\transfarmation\docs\Transafarmation_brd_latest`.

| Folder | Contents |
|--------|----------|
| 01_BRD | Transfarmation_BRD.docx: the full Business Requirements Document (333 requirements, 23 module and architecture sections, roadmap, pilot plan, security and privacy, database decision) |
| 02_Traceability | Transfarmation_Requirements_Traceability.xlsx: every requirement mapped to module, objective, priority, and phase, with a summary sheet |
| 03_Technical_Design | Transfarmation_Firestore_Flutter_Technical_Design.docx: Firestore-only design, ledger and escrow, rules, functions, Flutter and GetX structure, cost controls, risk register. Transfarmation_Supabase_PowerSync_Technical_Design.docx: the alternative Postgres, Supabase, and PowerSync design, with scalability and cost at 100,000+ users |
| 04_Diagrams | Nine architecture diagrams (SVG and PNG): ecosystem, layers, offline sync, settlement, security zones, data architecture, Firestore collections, Firestore-only architecture, Supabase and PowerSync architecture |
| 05_Sources | BRD_full.md, Firestore_Flutter_Technical_Design.md, Supabase_PowerSync_Technical_Design.md, requirements_matrix.json, and the diagram generator scripts, for version control and re-use |
| 06_App_Comparison | app_inventory.ps1 (reads your app), comparison_template.md, and claude_code_prompt.md |

## Status notes

- Database decision: Firestore only, with Flutter and GetX (see the Database Decision section of the BRD and the technical design).
- Both database designs are included. The BRD records Firestore as the current decision and keeps the Supabase and PowerSync design as the tested alternative, with the 100,000+ user scalability and cost comparison.
- Priorities and phases in the traceability matrix are proposals and need team review.
- The Shona and Ndebele consent translations are drafts and need native-speaker and legal review.
- Firestore and Supabase prices were checked in September 2026 at us-central1 rates; check the Johannesburg row.

## How to compare with the existing app

1. Run `06_App_Comparison\app_inventory.ps1` in PowerShell. It only reads the project and writes `app_inventory.txt`.
2. Either share that file with Claude in chat, or run Claude Code in the project folder with the prompt in `claude_code_prompt.md`.
3. Fill in `comparison_template.md`, and save the result as `comparison_report.md`.
