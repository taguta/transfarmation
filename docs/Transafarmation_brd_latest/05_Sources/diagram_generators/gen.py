import textwrap, html, sys

FONT = "Liberation Sans, Arial, Helvetica, sans-serif"
INK = "#1F2933"
C = {
 "blue":   ("#E6EEF6", "#2B5C8A"),
 "teal":   ("#E0F2F1", "#0F6B6B"),
 "green":  ("#E8F1EC", "#1B5E3B"),
 "amber":  ("#FFF3D6", "#8A5A00"),
 "purple": ("#EEE9F7", "#5B4A8A"),
 "grey":   ("#F2F4F5", "#5B6770"),
 "red":    ("#FBE9E9", "#8A2B2B"),
 "white":  ("#FFFFFF", "#5B6770"),
}
warnings = []

class Svg:
    def __init__(self, W, H, title):
        self.W, self.H = W, H
        self.items = []
        self.title = title
    def add(self, s): self.items.append(s)
    def rect(self, x, y, w, h, color="grey", rx=10, sw=1.5, dash=False, fill=None):
        f, s = C[color]
        if fill: f = fill
        d = ' stroke-dasharray="6 4"' if dash else ''
        self.add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{f}" stroke="{s}" stroke-width="{sw}"{d}/>')
    def text(self, x, y, s, size=14, bold=False, anchor="middle", fill=INK, italic=False):
        w = ' font-weight="700"' if bold else ''
        i = ' font-style="italic"' if italic else ''
        self.add(f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-family="{FONT}" font-size="{size}"{w}{i} fill="{fill}">{html.escape(s)}</text>')
    def box(self, x, y, w, h, paras, color="grey", rx=10, dash=False, name=""):
        """paras: list of (text, size, bold) ; wraps and vertically centres."""
        self.rect(x, y, w, h, color, rx, dash=dash)
        lines = []
        for t, size, bold in paras:
            cpl = max(6, int((w - 16) / (size * (0.58 if bold else 0.54))))
            for ln in textwrap.wrap(t, cpl) or [""]:
                lines.append((ln, size, bold))
        lh = [s * 1.25 for _, s, _ in lines]
        total = sum(lh)
        if total > h - 8:
            warnings.append(f"OVERFLOW {self.title}: '{paras[0][0]}' needs {total:.0f} has {h}")
        yy = y + (h - total) / 2
        stroke = C[color][1]
        for (ln, size, bold), l in zip(lines, lh):
            yy += l
            self.text(x + w / 2, yy - size * 0.25, ln, size, bold, fill=(stroke if bold else INK))
    def arrow(self, x1, y1, x2, y2, both=False, color="#4A5560", dash=False):
        d = ' stroke-dasharray="5 4"' if dash else ''
        ms = ' marker-start="url(#ah)"' if both else ''
        self.add(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="1.8"{d}{ms} marker-end="url(#ah)"/>')
    def line(self, x1, y1, x2, y2, color="#4A5560"):
        self.add(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="1.8"/>')
    def path(self, d, color="#4A5560", dash=False):
        dd = ' stroke-dasharray="5 4"' if dash else ''
        self.add(f'<path d="{d}" fill="none" stroke="{color}" stroke-width="1.8"{dd} marker-end="url(#ah)"/>')
    def render(self):
        head = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {self.W} {self.H}" width="{self.W*2}" height="{self.H*2}">'
                '<defs><marker id="ah" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">'
                '<path d="M0 0 L10 5 L0 10 z" fill="#4A5560"/></marker></defs>'
                f'<rect width="{self.W}" height="{self.H}" fill="#FFFFFF"/>')
        return head + "".join(self.items) + "</svg>"

def save(svg, name):
    open(f"/home/claude/diag/{name}.svg", "w").write(svg.render())

# ---------------------------------------------------------------- D1 context
def d1():
    s = Svg(560, 770, "D1")
    s.text(280, 28, "Transfarmation ecosystem: who connects", 18, True)
    grp = [
        (20, 50, 250, 150, "Producers and advisors", ["Farmers (formal and communal)", "Agronomists, extension officers, economists", "Agents"], "green"),
        (290, 50, 250, 150, "Buyers and markets", ["Manufacturers and offtakers", "Retailers and wholesalers", "Consumers", "Tobacco auction floors"], "blue"),
        (20, 445, 250, 135, "Finance, logistics, services", ["Bankers and microfinance", "Logistics and transport", "Input and equipment providers"], "amber"),
        (290, 445, 250, 135, "Government and regulation", ["Government and ministries", "Regulators (TIMB and others)", "Development partners"], "purple"),
    ]
    for x, y, w, h, head, items, col in grp:
        s.box(x, y, w, h, [(head, 15, True)] + [(i, 13, False) for i in items], col)
    s.arrow(145, 200, 145, 236, both=True); s.arrow(415, 200, 415, 236, both=True)
    s.rect(20, 236, 520, 190, "teal", rx=14, sw=2)
    s.text(280, 262, "Transfarmation platform", 17, True, fill=C["teal"][1])
    s.text(280, 282, "One unified data core, role-based workspaces (lenses)", 13)
    chips = ["Farm plan and agronomy", "Finance and escrow", "Markets and auction", "Logistics and storage", "Compliance gateway", "Insights and reports"]
    for i, t in enumerate(chips):
        x = 32 + (i % 3) * 170; y = 300 + (i // 3) * 58
        s.box(x, y, 160, 48, [(t, 13, False)], "white")
    s.arrow(145, 426, 145, 445, both=True); s.arrow(415, 426, 415, 445, both=True)
    s.arrow(280, 426, 280, 606, both=True)
    s.rect(20, 606, 520, 150, "grey", rx=14, sw=2)
    s.text(280, 630, "Connected external systems", 15, True, fill=C["grey"][1])
    ext = ["TIMB biometric registry", "Banks and mobile money", "National ID and KYC", "Weather and satellite data", "Telecom SMS and USSD", "Buyer and floor systems"]
    for i, t in enumerate(ext):
        x = 32 + (i % 3) * 170; y = 644 + (i // 3) * 54
        s.box(x, y, 160, 46, [(t, 13, False)], "white")
    save(s, "01_ecosystem_context")

# ---------------------------------------------------------------- D2 layers
def band(s, y, h, label, color):
    s.rect(12, y, 536, h, color, rx=12)
    s.text(24, y + 20, label, 14, True, anchor="start", fill=C[color][1])

def chips(s, y, items, cols, cw, ch, gap, color, x0=24, size=13):
    for i, t in enumerate(items):
        x = x0 + (i % cols) * (cw + gap); yy = y + (i // cols) * (ch + 8)
        if isinstance(t, tuple):
            s.box(x, yy, cw, ch, [(t[0], size, True), (t[1], 12, False)], "white")
        else:
            s.box(x, yy, cw, ch, [(t, size, False)], "white")

def d2():
    s = Svg(560, 960, "D2")
    s.text(280, 26, "Logical architecture: five layers", 18, True)
    band(s, 40, 168, "1. Channels", "blue")
    chips(s, 68, ["Farmer app (Flutter, offline-first)", "Agent and field app", "Institution web workspaces", "USSD, SMS, WhatsApp", "Floor tablets and scanners", "IoT sensors (cold rooms, barns)"], 3, 164, 62, 8, "blue")
    s.arrow(280, 208, 280, 226, both=True)
    band(s, 226, 132, "2. Access and platform services", "teal")
    chips(s, 254, ["API gateway", "Identity, roles, consent", "Notifications", "Event bus", "Workspace engine (lenses, reports)"], 3, 164, 44, 8, "teal")
    s.arrow(280, 358, 280, 376, both=True)
    band(s, 376, 226, "3. Domain services (modules)", "green")
    dom = [("Farm and agronomy", "Feasibility, crop calendar, Snap and Solve"), ("Finance", "Ledger, input escrow, settlement waterfall"),
           ("Markets", "Contracts, auction and exchange, marketplace"), ("Logistics and storage", "Freight, proof of delivery, cold chain"),
           ("Compliance", "TIMB gateway, levies, side-marketing rules"), ("People and reach", "Advisors, agents, CRM, service providers")]
    chips(s, 404, dom, 2, 252, 58, 8, "green")
    s.arrow(280, 602, 280, 620, both=True)
    band(s, 620, 134, "4. Data core", "amber")
    chips(s, 648, ["Identity and consent store", "Operational database", "Append-only ledger and audit log", "File store (photos, contracts)", "Analytics store (pseudonymised)", "Model registry (AI models)"], 3, 164, 44, 8, "amber")
    s.arrow(280, 754, 280, 772, both=True)
    band(s, 772, 134, "5. External integrations", "grey")
    chips(s, 800, ["TIMB registry", "Banks and mobile money", "National ID and KYC", "Weather and satellite", "Telecom gateways", "Buyer and floor systems"], 3, 164, 44, 8, "grey")
    s.rect(12, 916, 536, 36, "red", rx=10)
    s.text(280, 939, "Across all layers: encryption, key management, zero trust, audit, backup", 13, True, fill=C["red"][1])
    save(s, "02_logical_architecture")

# ---------------------------------------------------------------- D3 offline
def d3():
    s = Svg(560, 820, "D3")
    s.text(280, 26, "Offline-first app and sync", 18, True)
    s.rect(16, 44, 280, 620, "grey", rx=28, sw=2.5)
    s.text(156, 68, "Phone (works with no signal)", 14, True, fill=C["grey"][1])
    s.box(32, 82, 248, 66, [("Lens interface", 14, True), ("Role switcher, hero card, quick actions, local language, voice", 12, False)], "blue")
    s.box(32, 166, 248, 60, [("App logic", 14, True), ("Role permissions, business rules, workflows", 12, False)], "green")
    s.box(32, 246, 120, 92, [("On-device AI", 13, True), ("Snap and Solve, receipt OCR, voice notes", 12, False)], "purple")
    s.box(160, 246, 120, 92, [("Sensors", 13, True), ("GPS, camera, QR scan, fingerprint", 12, False)], "grey")
    s.box(32, 358, 248, 80, [("Encrypted local database", 14, True), ("Outbox queue, media cache, cached prices and calendars", 12, False)], "amber")
    s.box(32, 458, 248, 86, [("Sync engine", 14, True), ("Queue, retry, delta upload, conflict rules, sync status", 12, False)], "teal")
    s.box(32, 564, 248, 70, [("Status for the user", 14, True), ("Green dot and count of items waiting to sync", 12, False)], "white")
    for y1, y2 in [(148, 166), (438, 458), (544, 564)]:
        s.arrow(156, y1, 156, y2)
    s.arrow(92, 226, 92, 246); s.arrow(220, 226, 220, 246)
    s.arrow(92, 338, 92, 358); s.arrow(220, 338, 220, 358)
    s.text(435, 68, "Server side", 14, True, fill=C["teal"][1])
    s.box(330, 340, 210, 80, [("SMS and USSD gateway", 14, True), ("Booking and confirmations on any phone", 12, False)], "grey")
    s.box(330, 458, 210, 86, [("API gateway and sync service", 14, True), ("Auth, delta merge, safe repeat of writes", 12, False)], "teal")
    s.box(330, 578, 210, 72, [("Domain services and data core", 14, True)], "green")
    s.arrow(296, 380, 330, 380, dash=True)
    s.text(313, 368, "no data", 10, False)
    s.arrow(435, 420, 435, 458)
    s.arrow(280, 501, 330, 501, both=True)
    s.text(305, 494, "online", 10, False)
    s.arrow(435, 544, 435, 578, both=True)
    s.box(330, 676, 210, 124, [("Conflict rules", 14, True), ("Money, status, contracts: server wins and the user is told. Notes and logs: merge by time. Photos: append only.", 12, False)], "amber")
    s.box(330, 90, 210, 230, [("Design rules", 14, True), ("Local first: every screen reads from the phone database.", 12, False), ("Sync is background work, so the user is never blocked.", 12, False), ("SMS and USSD keep booking and confirmation working on any phone.", 12, False), ("The server has the final say on money and status.", 12, False)], "white", dash=True)
    s.box(16, 690, 280, 60, [("Every change carries device ID, user, role, and time", 12, False)], "white", dash=True)
    save(s, "03_offline_sync")

# ---------------------------------------------------------------- D4 settlement
def d4():
    s = Svg(560, 850, "D4")
    s.text(280, 26, "Sale settlement: the waterfall", 18, True)
    steps = [
        (50, "1. Sale finalised", "Auction floor or market system records the winning bid and lot", "blue"),
        (132, "2. Verify", "Identity and TIMB registry: grower, contract, lot tags, slot", "teal"),
        (214, "3. Lock grade and price", "Tamper-evident grade record confirmed by both parties", "teal"),
        (296, "4. Run the waterfall", "Settlement engine splits proceeds in the order set by law and contract", "green"),
    ]
    for y, t, sub, col in steps:
        s.box(100, y, 360, 64, [(t, 14, True), (sub, 12, False)], col)
    for y in (114, 196, 278):
        s.arrow(280, y, 280, y + 18)
    outs = [("Statutory levies and fees", "To TIMB and environmental funds; certificate issued"),
            ("Input loan repayment", "To bank or contractor; balance updated"),
            ("Freight and agreed deductions", "Transport escrow released to the trucker"),
            ("Net proceeds to farmer", "Mobile wallet or bank, target within the hour")]
    s.line(280, 360, 280, 380); s.line(78, 380, 491, 380)
    for i, (t, sub) in enumerate(outs):
        x = 14 + i * 137
        s.box(x, 400, 128, 140, [(t, 13, True), (sub, 12, False)], ["amber", "amber", "amber", "green"][i])
        s.arrow(x + 64, 380, x + 64, 400)
        s.line(x + 64, 540, x + 64, 556)
    s.line(78, 556, 491, 556); s.arrow(280, 556, 280, 574)
    s.box(100, 574, 360, 64, [("5. Reconcile and log", 14, True), ("Ledger entries, audit trail, bank and floor reconciliation", 12, False)], "teal")
    s.arrow(280, 638, 280, 664)
    s.box(100, 664, 360, 64, [("6. Notify", 14, True), ("Itemised statement by SMS and app, with a dispute option", 12, False)], "blue")
    s.box(20, 750, 520, 84, [("Notes", 13, True), ("Order of deductions follows law and contract and is configurable. Payout within the hour is a target that depends on bank and payment rails. Every step is written to the audit trail.", 12, False)], "grey", dash=True)
    save(s, "04_settlement_flow")

# ---------------------------------------------------------------- D5 security
def d5():
    s = Svg(560, 900, "D5")
    s.text(280, 26, "Security and data protection zones", 18, True)
    s.box(20, 44, 520, 60, [("Users and devices", 14, True), ("Farmer app, institution web, USSD and SMS, agent tools", 12, False)], "grey")
    s.arrow(280, 104, 280, 122)
    s.rect(12, 122, 536, 110, "blue", rx=12); s.text(24, 142, "Edge zone", 14, True, anchor="start", fill=C["blue"][1])
    for i, t in enumerate(["WAF and DDoS protection", "API gateway: OAuth 2.0 and OpenID Connect, rate limits", "Bot and fraud checks, SIM-swap signals"]):
        s.box(24 + i * 174, 154, 166, 66, [(t, 12, False)], "white")
    s.arrow(280, 232, 280, 250)
    s.rect(12, 250, 536, 108, "green", rx=12); s.text(24, 270, "Application zone", 14, True, anchor="start", fill=C["green"][1])
    for i, t in enumerate(["Role and consent check on every call", "Short-lived tokens, step-up checks for money actions", "Secrets in a vault, data tagged by owner and role"]):
        s.box(24 + i * 174, 282, 166, 66, [(t, 12, False)], "white")
    s.arrow(280, 358, 280, 376)
    s.rect(12, 376, 536, 262, "amber", rx=12); s.text(24, 396, "Data zone", 14, True, anchor="start", fill=C["amber"][1])
    subs = [("Sensitive vault", "Protected biometric templates, ID numbers, consent ledger, keys in KMS or HSM. Reached only through matching and consent services.", "red"),
            ("Operational data", "Encrypted at rest, tagged by person and role, immutable backups, audit log written by trusted services only.", "white"),
            ("Analytics zone", "Pseudonymised, minimum group sizes, no direct identifiers. Feeds government and research views.", "purple")]
    for i, (h, t, col) in enumerate(subs):
        s.box(24 + i * 174, 408, 166, 218, [(h, 13, True), (t, 12, False)], col)
    s.arrow(280, 638, 280, 656, both=True)
    s.rect(12, 656, 536, 96, "grey", rx=12); s.text(24, 676, "Partner zone", 14, True, anchor="start", fill=C["grey"][1])
    for i, t in enumerate(["TIMB and regulators: scoped access, every query logged", "Banks and mobile money: signed calls and webhooks", "Buyers and floors: partner APIs, per-partner limits"]):
        s.box(24 + i * 174, 686, 166, 58, [(t, 12, False)], "white")
    s.rect(12, 768, 536, 118, "red", rx=12); s.text(24, 788, "Operations across all zones", 14, True, anchor="start", fill=C["red"][1])
    for i, t in enumerate(["Central logs and anomaly alerts, 24/7 response", "Incident runbooks and breach notice timelines", "Backup, disaster recovery, annual penetration tests"]):
        s.box(24 + i * 174, 802, 166, 74, [(t, 12, False)], "white")
    save(s, "05_security_zones")

d1(); d2(); d3(); d4(); d5()
print("\n".join(warnings) or "no overflow warnings")
