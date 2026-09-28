exec(open('gen.py').read().split("# ---------------------------------------------------------------- D1")[0])

def d6():
    s = Svg(560, 900, "D6")
    s.text(280, 26, "Recommended data architecture", 18, True)
    s.box(20, 44, 520, 84, [("Phones and web (Flutter)", 14, True), ("Local database with an outbox; reads never wait for the network; commands carry idempotency keys", 12, False)], "blue")
    s.arrow(280, 128, 280, 152, both=True)
    s.box(20, 152, 520, 62, [("Sync and real-time layer", 14, True), ("Sync streams to the phone (PowerSync), or Firestore read models if you keep them", 12, False)], "teal")
    s.arrow(280, 214, 280, 238, both=True)
    s.box(20, 238, 520, 70, [("API and functions", 14, True), ("Validate role, consent, and rules; safe repeat of writes; write to Postgres; publish events", 12, False)], "green")
    s.arrow(280, 308, 280, 332)
    s.rect(20, 332, 520, 234, "amber", rx=14, sw=2)
    s.text(280, 356, "PostgreSQL: system of record", 16, True, fill=C["amber"][1])
    subs = ["Identity and consent", "Ledger and escrow (double-entry)", "Contracts, loads, lots, bales", "Audit log (append-only)", "Time series (partitioned)", "Row-level security on every table"]
    for i, t in enumerate(subs):
        x = 32 + (i % 3) * 170; y = 372 + (i // 3) * 76
        s.box(x, y, 160, 66, [(t, 12, False)], "white")
    s.text(280, 542, "Portable: managed provider or self-hosted in country", 12, False, italic=True)
    s.arrow(150, 566, 150, 596)
    s.arrow(410, 566, 410, 596)
    s.box(20, 596, 250, 70, [("Rollup jobs", 14, True), ("Scheduled: districts, portfolios, levies, prices", 12, False)], "purple")
    s.box(290, 596, 250, 70, [("Object storage", 14, True), ("Photos and contracts, signed links", 12, False)], "grey")
    s.arrow(145, 666, 145, 692)
    s.box(20, 692, 250, 84, [("Report tables or snapshots", 14, True), ("A few rows or documents per dashboard", 12, False)], "purple")
    s.arrow(145, 776, 145, 800)
    s.box(20, 800, 250, 70, [("Dashboards", 14, True), ("Regulator, bank, government, floor", 12, False)], "blue")
    s.box(290, 692, 250, 178, [("Why this keeps cost predictable", 13, True), ("Money and reports sit in one place. Report cost does not grow with the number of farmers. Phones read local data, so network use is small.", 12, False)], "white", dash=True)
    save(s, "06_data_architecture")

def d7():
    s = Svg(560, 860, "D7")
    s.text(280, 26, "Firestore collection map (read-model role)", 18, True)
    def grp(x, y, w, h, head, items, col):
        s.rect(x, y, w, h, col, rx=12)
        s.text(x + 12, y + 20, head, 14, True, anchor="start", fill=C[col][1])
        yy = y + 32
        for label, kind in items:
            c = "white"
            s.rect(x + 10, yy, w - 20, 34, c, rx=8, sw=1.2)
            fill = "#1B5E3B" if kind == "client" else "#2B5C8A"
            s.add(f'<rect x="{x+10}" y="{yy}" width="6" height="34" rx="3" fill="{fill}"/>')
            s.text(x + 24, yy + 22, label, 12, anchor="start")
            yy += 40
    grp(16, 44, 262, 232, "Per person", [("users/{id}", "server"), ("users/{id}/home/current", "server"), ("users/{id}/tasks", "server"), ("users/{id}/commands", "client"), ("users/{id}/ledger (drafts)", "client")], "green")
    grp(292, 44, 252, 232, "Farm and season", [("farms/{id}", "client"), ("farms/{id}/logs", "client"), ("refData/{type}/{id}", "server")], "amber")
    grp(16, 292, 262, 192, "Market and movement", [("openLoads/{district}/items", "server"), ("loads/{id}", "server"), ("consignments/{id}", "client")], "blue")
    grp(292, 292, 252, 192, "Reports", [("reportSnapshots/{reportId}", "server")], "purple")
    grp(16, 500, 528, 150, "Access and organisations", [("orgs/{id} and orgs/{id}/members", "server"), ("accessGrants/{grantee}_{grantor}_{scope}", "server"), ("notifications/{id}/items (TTL)", "server")], "grey")
    s.rect(16, 666, 528, 176, "white", rx=12, dash=True)
    s.text(28, 688, "How to read this map", 14, True, anchor="start", fill=C["grey"][1])
    s.add('<rect x="28" y="702" width="6" height="22" rx="3" fill="#1B5E3B"/>'); s.text(42, 719, "Client can write (rules restrict fields; server confirms)", 12, anchor="start")
    s.add('<rect x="28" y="734" width="6" height="22" rx="3" fill="#2B5C8A"/>'); s.text(42, 751, "Server writes only; clients read", 12, anchor="start")
    s.text(28, 782, "Money, identity, consent, and audit records live in Postgres, not here.", 12, anchor="start")
    s.text(28, 802, "Screens read one prepared document or a small limited query.", 12, anchor="start")
    s.text(28, 822, "Reports are precomputed snapshots, not scans of source documents.", 12, anchor="start")
    save(s, "07_firestore_schema")

d6(); d7()
print("\n".join(warnings) or "no overflow warnings")
