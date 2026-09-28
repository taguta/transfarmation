# Executive Summary

Transfarmation is positioned as a single-player-value platform: farmers get standalone utility from day one, with no dependency on other users joining first. The pilot vertical is Zimbabwe's tobacco industry, where over 90% of production runs through contract farming regulated by the Tobacco Industry and Marketing Board (TIMB) under the Tobacco Industry and Marketing Act [Chapter 18:20]. The platform embeds compliance, financing, and operational workflows directly into the farmer's experience, making it indispensable to the smallholder while solving side-marketing, financing, and compliance problems for contractors and regulators. The same architecture is designed to generalize to perishable horticulture (starting with tomatoes) without structural rewrites.

# Business Objectives

- Make Transfarmation indispensable to the individual communal farmer without requiring network effects to deliver value
- Replace opaque paper contract farming with a transparent, financeable digital process
- Reduce side-marketing losses to contractors and the national economy through biometric grower and GPS verification
- Automate statutory levy collection and environmental (deforestation) compliance at point of sale
- De-risk input financing for banks and merchants via real-time credit-scoring data
- Prove a reusable module architecture that extends from tobacco to horticulture (tomatoes) and other verticals with minimal rework

# Scope

**In scope (pilot):**

- Module 1: Bankable Feasibility & Offtake Agreements for communal tobacco farmers in Zimbabwe
- TIMB Regulatory Gateway: biometric grower registration sync, side-marketing prevention, statutory levy and environmental compliance automation
- Architecture designed for extension to horticulture (tomatoes), including cold-chain and spot-market logistics

**Out of scope (pilot phase):**

- Full Logistics & Transport Module (freight-matching and escrow settlement), proposed as a follow-on phase
- Verticals beyond tobacco and tomatoes
- Markets outside Zimbabwe

# Stakeholders

| Stakeholder | Role / Interest |
|------------------|----------------------------------------------|
| Formal & communal farmers | Primary end users; need bankable feasibility, offtake certainty, agronomy support, and financial management tools usable standalone |
| Advisors, agronomists, economists | Provide expert input into the agronomy and feasibility modules; need structured farm data and clear farmer context |
| Consumers | End buyers of farm produce/product; benefit from traceability and consistent quality via the platform |
| Contract farming intermediaries | Need reduced default risk, verified deliveries, and streamlined agreement management |
| Bankers | Extend input credit; need real-time credit-scoring data to de-risk lending |
| Service providers (farming implements, inputs, etc.) | Need visibility into farmer demand and a direct channel to transact with growers |
| Government | Needs statutory returns, economic data, and a formal transaction record to inform policy |
| Regulators (e.g. TIMB) | Needs biometric registration sync, statutory compliance enforcement, and side-marketing prevention |
| Manufacturers (offtakers) | Need reliable, quality-graded volume commitments and traceable sourcing |
| Tobacco Auction Floors | Need verified, compliant bales arriving with clean chain-of-custody data |
| Agents | Need a transparent way to represent farmers and earn commission without disintermediating them |
| Logistics and transport providers | Need freight-matching, load tracking, and fast payment on delivery confirmation |
| Retailers | Need a reliable supply pipeline (e.g., tomatoes/horticulture) with quality and delivery-time visibility |
| Sustainable Afforestation Association / environmental partners | Track approved woodlot usage for curing, reforestation levy compliance |

# Value Propositions by Platform Player

**Farmers (formal & communal)**: delivered through a suite of standalone modules so a farmer can extract value without waiting on any other player:

- Bankable feasibility studies & upstream offtake agreements (Module 1)
- Agronomy module (crop/soil guidance, input schedules)
- Accounting & financial management module
- Distribution & logistics module
- Marketing & CRM module
- Refrigeration & storage module

**Government**: visibility into statutory returns, tax and levy collection, and formalized transaction data across the sector, strengthening policy-making and economic planning.

**Regulators (TIMB and equivalents)**: a compliance layer that enforces the underlying law (e.g., the Tobacco Industry and Marketing Act [Chapter 18:20]) automatically, making the platform infrastructure rather than an obstacle.

**Bankers**: a live, verifiable credit-scoring ledger built from real input-utilization and delivery data, reducing the cost of extending credit to the smallest growers.

**Manufacturers / offtakers**: guaranteed, traceable, quality-graded volumes sourced directly from registered growers.

**Retailers**: a dependable, trackable supply pipeline (notably for horticulture) with visibility into quality and delivery timing.

**Agents, logistics/transport providers, service providers**: a transparent transactional channel. Agents represent farmers without disintermediating them, transporters get freight-matching and fast pay-on-delivery, and input/equipment providers get direct demand signals from farmers.

*Design principle:* every player's value proposition must hold on its own. The platform is not allowed to depend on network effects to be useful to its lowest common denominator user (the communal farmer, the individual transporter, the individual agent).

# Functional Requirements: Module 1, Bankable Feasibility & Offtake Agreements

**Standalone farmer utility (offline-first, no network needed to start)**

- FR1.1: Farmer can drop a GPS pin on their land via smartphone to register the plot
- FR1.2: System auto-detects soil type, historical rainfall patterns, and acreage from the GPS location, integrating with TIMB's biometric mapping standards
- FR1.3: System auto-generates a 24-month projected cash-flow statement, input requirement schedule, and projected yield model without requiring an extension officer or bank clerk
- FR1.4: Farmer is presented with pre-vetted, standardized offtake contract templates from licensed contractors
- FR1.5: Every contract clause (minimum input packages, grading standards) is translated into plain Shona and Ndebele on screen

**Contractor and banker integration**

- FR1.6: System generates a cryptographically secured digital contract upon farmer sign-off
- FR1.7: System maintains a live credit-scoring ledger from real-time input-utilization tracking, viewable by financiers to reduce physical verification costs

**Pain points solved**

- Farmers: opaque paper contracts, debt traps, high default risk, and weeks of waiting for an extension officer or bank clerk to prepare a plan
- Contractors and banks: applications with unrealistic numbers and no standard basis for comparing growers
- Both sides: disputes about what a clause meant, because the contract was never explained in the farmer's language

**Standalone value.** The farmer gets a working farm plan, a cash-flow forecast, and a plain-language reading of any offered contract on a phone, offline, without any contractor, bank, or transporter on the platform.

**Additional requirements**

- FR1.8: What-if tools let the farmer change acreage, input package, expected price, and yield and see the effect on cash flow and break-even before committing
- FR1.9: The feasibility report explains its assumptions in plain language in English, Shona, and Ndebele, shows a range rather than a single figure, and states the main risks and the break-even price
- FR1.10: Soil, rainfall, price, and cost benchmarks carry a source and date; the farmer can override any figure, and each override is logged
- FR1.11: The report can be printed, exported as PDF, or shared with a lender through a consent link, and is stamped with its date and assumption version
- FR1.12: Contract comparison shows offers from several contractors side by side on input cost, deductions, grading basis, interest, and repayment terms, and flags unusual clauses
- FR1.13: Any clause can be explained on request, and the farmer can ask a human advisor to review a contract before signing
- FR1.14: Contract lifecycle tracking covers signature, amendments, renewal, termination, and disputes, with reminders of each party's obligations
- FR1.15: An input package and repayment schedule calculator tied to the contract feeds the debt view (FR8.7)
- FR1.16: A bankable-readiness checklist shows the farmer what records and plan they still need before applying for credit
- FR1.17: Yield and cost models are versioned and validated against pilot outcomes, with results fed back to improve them

**Design considerations and risks**

- Model accuracy and liability: label outputs as estimates, show ranges, and use conservative defaults so a plan does not push a farmer into over-borrowing
- Independence: contractors are customers, so the platform must show unfavourable terms plainly and have TIMB or an independent body review templates
- Legal validity: confirm with counsel that digital signatures and electronic contracts are enforceable under Zimbabwean law
- Data freshness: stale prices and rainfall data mislead, so show the date and refresh often
- Affordability: include a debt-to-income style check before recommending a loan

# Functional Requirements: TIMB Regulatory Gateway & Compliance Engine

**Biometric grower registration sync**

- FR2.1: Platform integrates directly with TIMB's Biometric Grower Registration System
- FR2.2: Farmer's digital ID, biometric thumbprint hash, and farm GPS coordinates are bound to their platform profile
- FR2.3: When a tobacco bale is logged for transport or delivery, smart contracts cross-reference the grower number and GPS origin
- FR2.4: System automatically flags unauthorized sales or third-party usage before the crop reaches the auction or contract floor

**Statutory levies & environmental compliance**

- FR2.5: System automates reforestation levy deductions and statutory marketing fee collection at point of sale
- FR2.6: System logs, in real time, whether a farmer uses sustainable coal, approved eucalyptus woodlots (e.g., via the Sustainable Afforestation Association), or illegal indigenous timber
- FR2.7: System issues immediate compliance clearances required for export permits based on that logged data

**Pain points solved**

- Regulator: side-marketing losses, manual registration queues, and manual tracking of levies and environmental compliance
- Growers: queues for registration and renewal, unclear levy deductions, and delays getting compliance clearance for export permits
- Contractors: contracted tobacco sold to other buyers, with no early warning

**Standalone value.** The regulator gets a live grower registry view and compliance dashboard from the first registered growers, and each grower sees their registration status and obligations without queuing.

**Additional requirements**

- FR2.8: Grower registration status view shows the grower number, validity, renewal dates, and reminders
- FR2.9: Registration and renewal workflow with document upload, an offline queue, submission to TIMB, and booking of appointment slots where the biometric capture needs a visit
- FR2.10: Grower and contractor contracts are registered digitally with TIMB where the law requires it
- FR2.11: Configurable side-marketing rules (for example bales delivered versus contracted area and expected yield, grower-number mismatches, unusual GPS origins, repeat deliveries) raise alerts to TIMB and the contractor
- FR2.12: Case management for flagged cases: evidence, investigation steps, farmer response, and outcome, with human review before any penalty
- FR2.13: Regulator dashboard shows registered growers, area planted, expected versus delivered volumes, flagged cases, and levies collected, by district with drill-down
- FR2.14: Statutory returns are generated automatically in the prescribed format, with submission history
- FR2.15: Levy ledger calculates, deducts, and remits levies to the correct bodies, reconciles them, and gives the farmer a receipt
- FR2.16: Environmental compliance record covers curing fuel source, woodlot registration and area, and verification photos, and issues certificates linked to export permits
- FR2.17: Inspector mobile tools let TIMB and AGRITEX officers verify farms, woodlots, and barns with offline checklists and geo-tagged evidence
- FR2.18: Statutory rates, levy rules, and compliance rules are configurable with effective dates and version history, so a change in law needs no code release

**Design considerations and risks**

- Regulator dependency: engage TIMB early and agree the data-sharing scope in a memorandum of understanding before building
- False positives: flagged cases need human review before any penalty, and farmers must be able to respond (see FR5.3)
- Neutrality: the platform must be transparent and even-handed between contractors, growers, and the regulator, or it will lose trust
- Minimum necessary data: share with the regulator only what the law requires, and log every access
- Legal effect: confirm with counsel what automated flags and digital records mean in law
- Integration readiness: if TIMB systems are not ready, use manual verification with a later automated sync

# Functional Requirements: Horticulture Expansion (Tomatoes)

- FR3.1: Storage and logistics module swaps tobacco bale tracking for cold-room telemetry and perishable shelf-life timers
- FR3.2: Bidding and floor management engine adapts into an automated spot-market aggregator for fresh produce markets (e.g., Mbare Musika or regional hubs)
- FR3.3: System matches daily tomato harvests with urban supermarket chains and informal traders before spoilage occurs
- FR3.4: Underlying architecture (farm profiling, offtake matching, compliance engine) requires zero structural rewiring, only parameter changes, to move from tobacco to horticulture

**Pain points solved**

- Farmers: perishable crops, price volatility, gluts when everyone harvests together, post-harvest losses, and reliance on informal traders
- Buyers: inconsistent grade and quantity, and no advance view of supply
- Transporters and markets: unpredictable loads and idle capacity

**Standalone value.** A tomato grower can plan planting dates, follow a crop calendar, see market prices, and post a harvest for sale without any other party on the platform.

**Additional requirements**

- FR3.5: Horticulture crop templates (tomatoes first) hold varieties, cycle lengths, spacing, input schedules, pest and disease lists, and grading classes, so new vegetables are added by configuration
- FR3.6: A staggered planting planner spreads harvest dates to avoid gluts, using market demand signals
- FR3.7: Harvest and post-harvest guidance covers maturity stage, handling, packing, and pre-cooling, with shelf-life estimates by variety and storage condition, labelled as estimates
- FR3.8: Daily price and demand signals from key markets such as Mbare Musika (see FR10.7 and FR11.17), with alerts when prices pass a threshold the farmer sets
- FR3.9: One-tap harvest-ready listing posts expected or actual quantity, grade, and pickup location to buyers and transporters
- FR3.10: Grading and packing standards for crates, size classes, and ripeness tiers, with photo evidence at packing
- FR3.11: Post-harvest loss tracking records losses by cause (delay, cold chain, rejection) and reports how to reduce them
- FR3.12: Food safety records log pesticide applications and pre-harvest intervals from the agronomy log, for supermarket and export residue requirements
- FR3.13: Cluster harvest coordination lets neighbouring farmers combine loads to fill a truck (see FR10.18)
- FR3.14: Forward contract options with processors and supermarkets (see FR10.4) for growers who want price certainty

**Design considerations and risks**

- Price volatility and gluts: staggered planting and forward contracts help, but neither removes the risk
- Different from tobacco: there is no single auction floor, and informal traders often prefer cash, so the spot market must fit local habits
- Food safety liability: keep records accurate and require pre-harvest interval checks before listing
- Cold chain gaps: rural cold rooms are scarce, so start with aggregation points and shared storage (see the Refrigeration and Storage module)
- Untested claim: reuse of the tobacco architecture with only parameter changes must be tested in the Mutoko cluster, not assumed

# Functional Requirements: Additional Platform Modules

**Agronomy module**

- FR4.1: Provide crop- and soil-specific guidance, input schedules, and pest/disease alerts tied to the farmer's registered plot
- FR4.2: Allow advisors/agronomists/economists to review farmer data and issue structured recommendations (see the Agronomy Module section for the full specification, FR7.1 to FR7.14)

**Accounting & financial management module**

- FR4.3: Track farmer income, expenses, and loan/input-credit balances against the feasibility plan
- FR4.4: Generate statements usable as supporting evidence for future credit applications (see the Accounting, Financial Management & Input Escrow Module section, FR8.1 to FR8.20)

**Marketing & CRM module**

- FR4.5: Let farmers and intermediaries manage buyer/contact relationships and communication history
- FR4.6: Support outbound marketing of surplus produce (notably for horticulture spot-market matching); see the Marketing & CRM Module, FR17.1 to FR17.10

**Distribution & logistics module**

- FR4.7: Support freight-matching between farmers/traders and transporters
- FR4.8: Track a load from farm gate to delivery, with status visible to all relevant parties

**Refrigeration & storage module**

- FR4.9: Track cold-room/storage capacity, occupancy, and perishable shelf-life timers
- FR4.10: Alert relevant parties as shelf-life windows close, to trigger urgent sale/dispatch; see the Refrigeration & Storage Module, FR18.1 to FR18.12

**Ecommerce / marketplace layer**

- FR4.11: Provide a transactional marketplace where produce/product listings can be discovered and purchased by manufacturers, retailers, and consumers
- FR4.12: Support order, payment, and delivery-confirmation workflows end to end within the platform; see the Ecommerce Marketplace section, FR19.1 to FR19.14

# Functional Requirements: Agronomy Module (Digital Extension Officer)

The Agronomy Module is the digital extension officer and crop science engine of the platform. It delivers standalone value to a farmer before they link to any bank, contractor, or transporter, and bridges the gap between agricultural best practice and daily farm execution.

**Pain points solved**

- Farmers: delayed or inaccurate pest and disease identification; generic fertilizer application that wastes money or burns crops; no localized weather tracking; reliance on visiting agronomists who may arrive too late
- Contractors and agronomists: cannot scale advice across hundreds of remote smallholders at once; no visibility of crop stress until it is too late to save yield; manual record-keeping of crop milestones

**Step 1: GPS field mapping and crop telemetry**

- FR7.1: Farmer maps field boundaries with smartphone GPS during profile setup, reusing the plot registered in Module 1
- FR7.2: Module connects to localized meteorological and satellite data feeds to issue hyper-local warnings, such as frost alerts for tobacco seedlings, heavy storm warnings, and prolonged dry spells that need irrigation scheduling

**Step 2: "Snap & Solve" AI diagnostics (offline-first)**

- FR7.3: Farmer photographs an affected leaf (for example Barn Spot or Frog-eye on tobacco, or blight-related leaf curl on tomatoes) and an offline-capable image recognition model runs on the phone
- FR7.4: Model identifies the pest or pathogen and rates severity
- FR7.5: Module outputs an exact localized remedy, such as a specific chemical dosage or an organic intervention, plus where to source the input locally
- FR7.6: Each diagnosis shows a confidence level; low-confidence or high-severity cases are escalated to a human agronomist
- FR7.7: With the farmer's consent, labelled images and outcomes improve the model over time

**Step 3: Crop-specific growth calendars**

- FR7.8: Tobacco calendar covers seedbed management, topping, priming, curing, and grading; tomato calendar covers transplanting, vegetative growth, flowering, and harvesting windows
- FR7.9: Timed prompts by push notification or SMS tell the farmer exactly when to apply basal fertilizer, top-dress, or prepare curing facilities, based on the registered planting date
- FR7.10: SMS and USSD fallback so prompts reach farmers without smartphones or data

**Ecosystem integration**

- FR7.11: When the module recommends a chemical or fertilizer application, it creates a draft expense entry in the Financial Management Module
- FR7.12: If the inputs are tied to a credit facility, it signals the Input Escrow
- FR7.13: The digital crop log is a tamper-evident audit trail that shows good agricultural practices (GAP) were followed all season, for TIMB and export markets
- FR7.14: Contractor and agronomist dashboard shows crop stress and milestones across many smallholders, with bulk advisories to groups of farmers

**Design considerations and risks**

- Diagnosis accuracy and liability: show confidence, keep a human escalation path, and validate models with local agronomists and research bodies such as the Tobacco Research Board before release
- Advice on chemicals must use products registered for use in Zimbabwe and respect residue limits demanded by export markets
- Keep advice independent of input sales: sourcing suggestions must not be paid placement that biases the remedy
- Models must run on low-cost Android phones with little storage and no connection
- Farm photos, field boundaries, and crop logs are personal data: share with contractors or banks only with explicit consent (see the privacy sections)

# Functional Requirements: Logistics & Transport Module (Freight Matching & Escrow Settlement)

Many agricultural platforms fail on logistics because they force a complex, centralized fleet-management model onto fragmented rural environments. Transfarmation instead treats transport as a decentralized, multi-modal freight network with automated escrow settlement, built for rural road challenges, fuel price volatility, and the high risk of post-harvest loss for perishable tomatoes and bulky tobacco bales. The module lets a trucker be booked, track a tobacco or tomato load from the farm gate, and be paid instantly when electronic delivery is confirmed.

**Pain points solved**

- Farmers (communal and small-scale): extortionate spot prices, no reliable vehicle in peak harvest windows, and crop spoilage from delayed transit
- Transporters (truckers, kombi drivers, tractor and cart owners): empty return legs, delayed cash payment by erratic buyers, and fuel liquidity problems
- Contractors and buyers: stolen or delayed loads, no transit visibility, and no accountability for damage en route

**Standalone value.** A transporter, whether running a 2-tonne truck, a local tractor, or a long-distance tobacco haulage rig, can download Transfarmation purely as a job-finding tool and earn without using any other module. A farmer can likewise book transport without any bank or contractor link.

**Multi-modal vehicle tiers**

| Tier | Vehicles | Typical use |
|----------|--------------------|------------------------------------|
| First mile | Donkey carts, local tractors | Deep-rural plots to local collection hubs |
| Middle and long mile | 2-tonne trucks, kombis, heavy commercial carriers | Collection hubs to urban markets, processing plants, or auction floors (for example Karoi or Mvurwi collection points, Harare auction floors, Mbare Musika) |

**Load lifecycle**

| Stage | What happens | Who acts |
|-------------|------------------------------------------|-------------|
| 1. Load posting | Farmer, agent, contractor, or buyer posts the load: crop, bales/crates/weight, pickup GPS pin, destination, time window, cold-chain need | Shipper |
| 2. Matching | System suggests verified transporters by route, capacity, vehicle type, rating, and price; shows the rate before booking | Transporter |
| 3. Booking & escrow funding | Transporter accepts; the payer funds escrow via mobile money or bank before pickup; funds are held, not paid out | Payer, payment provider |
| 4. Compliance check | Tobacco: grower number, GPS origin, and levy documents verified before dispatch. Horticulture: required permits and grading attached | System, TIMB |
| 5. Pickup | Driver checks in at the farm gate by QR scan; quantity, weight, and a photo are recorded | Driver, shipper |
| 6. In transit | GPS tracking with delay and route-deviation alerts; cold-chain temperature readings; data buffered offline | System |
| 7. Delivery confirmation | Receiver confirms by QR scan or one-time code; records quantity and condition, with photo | Receiver |
| 8. Settlement | Escrow releases the freight fee to the transporter instantly; balance and levy deductions settle to the farmer | System |
| 9. Dispute | Shortfall or damage triggers a partial hold, evidence review, and a fixed resolution window; ratings update | Support / arbiter |

**Requirements**

- FR6.1: Transporter onboarding with verification of driver's licence, vehicle registration, operator licence, and identity
- FR6.2: Load posting works offline and syncs when a connection returns; USSD/SMS fallback for booking
- FR6.3: Matching by route, capacity, vehicle type, refrigeration, rating, and price, with fixed-rate or bid options
- FR6.4: Escrow held with a licensed payment service provider; release only on delivery confirmation or dispute resolution
- FR6.5: Instant settlement to transporter and farmer mobile-money wallets or bank accounts
- FR6.6: Pre-dispatch compliance gate that blocks tobacco loads lacking a valid grower number, GPS origin match, or levy clearance
- FR6.7: Live tracking visible to shipper, receiver, and, where permitted, regulator; alerts for delay, deviation, and temperature breach
- FR6.8: Two-factor delivery confirmation (QR plus one-time code) to reduce collusion, with photo and quantity evidence
- FR6.9: Dispute workflow with evidence upload, timeline, partial release, and audit trail
- FR6.10: Transporter and shipper reputation scores feeding a payment history usable for future credit (with consent)
- FR6.11: Return-load (backhaul) suggestions to reduce empty trips
- FR6.12: Optional cargo insurance and fuel-advance integrations (nice to have)

**Multi-modal, backhaul, and ecosystem requirements**

- FR6.13: Transporters can use the module standalone with only a phone number, mobile wallet, and vehicle details, with no other module required
- FR6.14: Tiered vehicle pairing matches the payload to first-mile (carts, tractors) or middle/long-mile (trucks, kombis, heavy carriers) transport, and can chain several legs into one journey with handover between tiers
- FR6.15: A unique QR code is generated on the farmer's app, scanned by the driver at loading and by the receiver at drop-off (auction floor, processing plant, or municipal market) to confirm quantity and condition
- FR6.16: Backhaul notifications alert a transporter dropping inputs in a rural area to scheduled crop pickups nearby, so the return leg carries paying cargo
- FR6.17: Fuel liquidity support: optional fuel advance or voucher against an escrowed job, repaid from the settlement
- FR6.18: Perishable priority: tomato loads carry a shelf-life timer, get priority matching, and peak-harvest demand alerts go to transporters in the area
- FR6.19: Condition photos at loading and drop-off establish who is accountable for damage or loss in transit
- FR6.20: For TIMB, transport tracking records verify that bales leaving a farm gate match that grower's registered quota and flag unregistered transit routes used in side-marketing
- FR6.21: Transport costs are logged automatically in the farmer's Financial Management Module against projected profits

**Module risks to design for**

- Cash preference and low trust in escrow: show funds status clearly and pay out in minutes
- Collusion at delivery or fake loads: two-factor confirmation, identity checks, and anomaly monitoring
- Weak connectivity on rural routes: offline capture and delayed sync of tracking data
- Payment licensing: confirm escrow and payment-service requirements with the Reserve Bank of Zimbabwe and local counsel before launch
- Data protection: driver and load location data are personal data; apply the privacy requirements in this BRD
- Fuel price volatility: suggest rates indexed to a published fuel price and show the fuel component clearly, so neither side is surprised
- Rural road conditions: route and time estimates must allow for poor roads and rainy-season closures
- Peak-season capacity: forecast harvest volumes from the crop calendars so transporters can be lined up early
- Fragmented, low-tech fleets: keep onboarding to a phone number and a wallet, and support USSD and agent-assisted booking

# Functional Requirements: Accounting, Financial Management & Input Escrow Module

This module is the core financial engine of Transfarmation. In high-stakes environments such as Zimbabwe's tobacco and commercial horticulture, cash-flow visibility, input tracking, and debt recovery make or break both the farmer and the financier. It is designed to be the simplest accounting ledger a communal farmer has ever used, while acting as a reliable financial audit trail for banks and contractors.

**Pain points solved**

- Farmers: complex bookkeeping, surprise debts at season end, confusion between household spending and farm capital, and vulnerability to informal loan sharks
- Financiers and contractors: high default rates, diversion of input loans (for example fertilizer meant for tobacco sold on the open market), and no verifiable financial statements on which to approve loans
- Service providers and input suppliers: delayed collections, credit risk, and no record of which farmers actually paid for implements or chemicals

**Standalone value.** A farmer who has never used QuickBooks, Excel, or a bank ledger can manage farm finances entirely from a phone through a visual dashboard, with no bank, contractor, or other module required.

**Step 1: Automated digital ledger (voice and image)**

- FR8.1: Visual dashboard usable by a farmer with no bookkeeping experience, phone only
- FR8.2: Receipt photo capture with OCR extracts amount, date, and vendor for casual labour, fuel, and spare parts, and files each into a category such as operating costs, labour, or crop maintenance, for the farmer to confirm
- FR8.3: Voice-note logging in English, Shona, and Ndebele; a note such as "Ndapedza 50 dollars pakutenga petrol yama pump ya tomato" or "Ngithenge petrol ye 50 dollars" is transcribed into a ledger entry for the farmer to confirm; audio is stored offline and transcribed on sync if needed
- FR8.4: Separate household and farm categories or wallets, so household spending does not mix with farm capital
- FR8.5: Draft entries are created automatically from agronomy recommendations (FR7.11) and transport costs (FR6.21)
- FR8.6: Season budget versus actual, compared with the feasibility plan from Module 1
- FR8.7: Debt view showing every loan, balance, due date, and forecast repayment, with alerts so there are no surprise debts at season end

**Step 2: Input escrow and smart credit management**

- FR8.8: Input loans from a bank or contract sponsor are held in a ring-fenced Input Escrow account, or issued as physical inputs or voucher codes, and never paid to the farmer as a lump sum of cash
- FR8.9: Milestone-based disbursement: funds or voucher codes for specific inputs unlock only when the Agronomy Module confirms the crop stage (for example land preparation complete, ready for basal fertilizer); the lender can configure the milestones
- FR8.10: Vouchers are redeemed at approved input suppliers, who confirm redemption and are paid promptly from escrow
- FR8.11: Diversion detection flags anomalies, such as inputs bought but not applied or resold, and alerts the lender
- FR8.12: Escrow is held with a licensed payment service provider, consistent with FR6.4

**Step 3: Real-time profitability mirror (the "Colours" financial dashboard)**

- FR8.13: Live cost-versus-revenue tracking as sales occur, whether through the tobacco auction or contract floor or wholesale tomato buyers, with revenue flowing through the platform
- FR8.14: Automatic waterfall distribution before the farmer receives cash: statutory levies and taxes (such as TIMB fees) are cleared, input loan repayment is routed to the bank or contractor, agreed deductions such as freight are settled, and net profit goes to the farmer's mobile-money or bank wallet; the order of priority follows law and contract and is configurable
- FR8.15: Itemised settlement statement showing every deduction, with a dispute option for the farmer
- FR8.16: Rules for shortfalls, partial repayment, and rollover when a sale does not cover the loan

**Value for bankers, financiers, and suppliers**

- FR8.17: Read-only, consent-based lender view of a tamper-evident ledger, with exportable statements, which sharply reduces the cost of physical audit visits
- FR8.18: Credit score built from multiple seasons of platform-verified data; farmers with clean history can qualify for larger follow-on loans without title deeds, where the lender's policy allows
- FR8.19: Repayment at the point of sale through escrow, before the farmer's payout, to lower non-performing loans
- FR8.20: Supplier view of payment status for implements and chemicals, so collections are timely and credit risk is visible

**Design considerations and risks**

- Claims of near-zero default are a target to measure in the pilot, not a promise: farmers can still sell outside the platform, so the waterfall works only where sales route through it
- Legal basis: the waterfall needs the farmer's informed consent to assign sale proceeds, and the priority between levies and loan repayment must follow law and contract; confirm with counsel and the Reserve Bank of Zimbabwe, including lending, microfinance, and payment-service rules
- OCR and voice accuracy: handwritten receipts and local-language speech will be imperfect, so always ask the farmer to confirm and allow easy correction
- Keep the household-versus-farm separation simple and optional so it does not feel intrusive
- Financial records are personal data: share with lenders only with explicit consent and apply the privacy sections of this BRD
- Escrow float, interest, and who bears settlement costs must be defined in the revenue model

# Functional Requirements: Consumer, Retailer & Offtaker Integration Module

This module completes the end-to-end loop of Transfarmation. It bridges raw farm production and the final market, whether that is an international tobacco merchant, an industrial food processor (for tomatoes and grain), or a domestic supermarket retailer. It connects the demand side of the ecosystem, meaning manufacturers and processors, supermarket chains, informal traders, and consumers, to registered farmers. By giving buyers stable supply and producers transparent, friction-free market access, it lets buyers lock in supply through forward contracts and spot purchases and gives them traceability and quality assurance. It builds on the offtake matcher in Module 1 and the spot-market aggregator in the horticulture requirements.

**Pain points solved**

- Manufacturers and processing offtakers: unpredictable raw material quality, volume shortfalls, volatile spot markets, and supply disruption from side-marketing, plus late deliveries and no traceability to source
- Retailers (supermarkets and fresh produce wholesalers, including informal traders): high shrinkage and spoilage, erratic delivery timelines, inconsistent grading, no origin traceability, no view of what harvests are coming, and quality disputes
- Consumers: high prices from excessive middleman markups, and no visibility of food safety or farming practices
- Farmers: unpredictable buyers, opaque prices, and late payment

**Standalone value.** A retailer or manufacturer can use this workspace as a sourcing and supplier-management tool on its own: post demand, see forecast supply, and buy, without needing farmers to use any other module first.

**Step 1: Demand posting and supply forecast**

- FR10.1: Buyer onboarding with business verification for manufacturers, retailers, and traders
- FR10.2: Buyers post demand by crop, grade, volume, delivery window, and price range
- FR10.3: Supply forecast by crop, region, and harvest window, built from crop calendars and planting dates, aggregated and shown only with farmer consent, with an accuracy indicator

**Step 2: Forward contracts and offtake lock-in**

- FR10.4: Standardised forward contract templates covering volume, grade, price mechanism (fixed, floor, or indexed), delivery window, and penalties, in plain language and linked to the digital contract sign-off in FR1.4 to FR1.6
- FR10.5: Fulfilment tracking of contracted versus delivered volume and quality, with early warnings of shortfalls

**Step 3: Spot-market aggregator for perishables**

- FR10.6: Daily listings, bids, and matching for tomatoes and other perishables before spoilage, extending FR3.2 and FR3.3
- FR10.7: Published reference prices and price trends by market (for example Mbare Musika and regional hubs)

**Step 4: Quality, traceability, and delivery**

- FR10.8: Standard grading and quality specifications per crop (tobacco grades, tomato classes), with photo evidence at collection and receiving
- FR10.9: Batch or lot IDs and QR traceability from farm to shelf, showing origin, GAP compliance (FR7.13), and transport and cold-chain history
- FR10.10: Consumer scan of a QR code shows the farming cluster, harvest date, sustainable production credentials, and compliance status, supporting local and international export compliance standards; farmer personal details appear only with the farmer's consent
- FR10.11: Quality dispute workflow with evidence, partial acceptance, and price adjustment

**Step 5: Payment, integration, and reputation**

- FR10.12: Escrow-backed payment on acceptance, feeding the waterfall in FR8.14 so farmers are paid quickly
- FR10.13: Supplier scorecards (reliability, quality, on-time delivery) for buyers, and buyer scorecards (payment timeliness) for farmers
- FR10.14: APIs to integrate with buyers' procurement, ERP, and point-of-sale systems and with auction floor systems
- FR10.15: Compliance and sustainability reporting for buyers, such as GAP, levy, and curing-fuel compliance records
- FR10.16: Direct consumer orders, such as bulk produce boxes delivered through the Logistics Module (nice to have)

**Additional requirements: forward aggregation, grading lock, and cold chain**

- FR10.17: Virtual commodity exchange: manufacturers and retail buyers post projected seasonal demand (volume, target delivery dates, and grade specifications for tobacco or horticulture) months before harvest
- FR10.18: Algorithmic aggregation: the platform groups regional farming clusters and matches corporate demand with verified collective production capacity, so buyers deal with clusters instead of thousands of individual smallholders; contracts state how volume and payment are shared among cluster members
- FR10.19: Standardised digital grading logs recorded at harvest and packing by farmers or certified local extension officers (for tobacco, leaf style and maturity; for tomatoes, size and ripeness tier)
- FR10.20: Smart quality lock: the buyer reviews the digital grade profile before dispatch, and the accepted grade record becomes tamper-evident, so both parties work from one ledger of product specifications and gate disputes fall away; residual disputes follow FR10.11 and FR11.9
- FR10.21: Cold-chain telemetry: storage units and transport links feed temperature and humidity data into the platform, with alerts on breach, to keep the cold chain intact from farm gate to supermarket shelf (see FR3.1 and FR6.7)
- FR10.22: Buyer dashboards for procurement teams showing contracted versus forecast supply by cluster, grade mix, and delivery status

**Design considerations and risks**

- Contract enforceability and buyer side-selling: pair contracts with escrow and clear grading rules so both sides can rely on them
- Grading subjectivity: use objective specifications, photo evidence, and optional third-party graders
- Forecast accuracy and privacy: forecasts use aggregated data and farmer consent, and are labelled with confidence
- Payment terms: large retailers often prefer credit terms, so offer options such as short payment terms backed by a financing partner
- Competition law: share prices and volumes only in aggregated form to avoid collusion concerns
- Perishable price volatility: support indexed and floor prices to protect farmers
- Scope discipline: the consumer marketplace is a later-phase feature; the pilot needs only the offtake basics and grading
- Buyer and consumer data are personal data where individuals are involved; apply the privacy sections of this BRD
- Cluster fairness: rules for allocating volume and splitting payment among cluster members must be transparent, so stronger growers do not crowd out weaker ones
- Grading honesty: farmer self-grading can be biased, so use certified extension officers, photo evidence, and random spot checks before a grade is locked
- Price claims: lower consumer prices from fewer middlemen are a hypothesis to measure, not a guaranteed outcome

# Functional Requirements: Tobacco Auction Floors & Commodity Exchange Module

This module handles one of the most high-stakes, high-volume bottlenecks in Southern African agriculture. In Zimbabwe, the tobacco marketing season drives millions of dollars of liquidity across the economy. To make Transfarmation a necessary, trusted marketplace rather than a bypassable tool, the module digitalizes the physical bottleneck of the auction floors (such as those in Harare's industrial belt) while protecting growers, auctioneers, and buyers alike.

**Pain points solved**

- Farmers: long physical queues at the floors, sleeping rough outside warehouses while waiting for bales to be processed, delayed payments, and opaque dispute resolution over leaf grading
- Auction floors and buyers: floor congestion, manual bale identification errors, side-marketing leakage, and slow payment reconciliation between commercial banks and growers
- Regulators (TIMB): tracking multi-party ownership, ensuring levy compliance, and verifying that contracted tobacco is not illegally dumped on the auction floor

**Standalone value.** A farmer or transporter knows exactly when their tobacco will be processed, which removes days of wasted waiting and accommodation costs in the city. A floor gets an intake and reconciliation dashboard without depending on any other module.

**Step 1: Pre-booking and virtual slot scheduling (ending the queue)**

- FR11.1: Digital bale tagging: before loading, each bale is scanned and given a unique tamper-evident QR or RFID tag linked to the grower's TIMB biometric profile
- FR11.2: Slot allocation: the platform assigns a digital arrival and drop-off slot (for example Floor 3, Bay B, Tuesday 08:00) instead of trucks arriving at once and jamming the gates
- FR11.3: Slot management with capacity limits per floor and bay, rescheduling, congestion alerts, and queue status by SMS and USSD
- FR11.4: Slots are linked to the freight booking and the pre-dispatch compliance gate (FR6.6), so a load cannot be dispatched without a valid slot

**Step 2: Digital floor management and electronic bidding integration**

- FR11.5: Fast-track intake: a floor clerk scans the bale tag, and weight, moisture, and preliminary grade sync instantly to the auction management dashboard, with an offline mode
- FR11.6: Reconciliation of arrived bales against tagged and expected bales, flagging missing, extra, or mismatched bales
- FR11.7: Hybrid bidding engine: licensed buyers see live floor inventory on workspace tablets and submit electronic bids alongside traditional floor bids, all in one audit trail, subject to approval by TIMB and the floor operators
- FR11.8: Bid integrity: authenticated licensed buyers only, time-stamped tamper-evident bid log, and a manual fallback if connectivity fails
- FR11.9: Real-time grade arbitration: if a farmer disputes a grade, an independent AGRITEX or TIMB inspector records a digital verdict with photo evidence within a fixed time window, so disputes do not stall the floor
- FR11.10: Ownership and side-marketing checks: each bale's grower registration and contract status are verified, and contracted tobacco dumped on the floor is flagged (see FR2.4)
- FR11.11: Multi-party ownership tracking, so TIMB can see who owns each bale at each stage

**Step 3: Instant automated settlement and waterfall deduction**

- FR11.12: When the hammer drops and the sale is finalised, the system runs the settlement waterfall (FR8.14): loan repayment is routed to the financier, statutory levies and reforestation and environmental fees (TIMB and EMA dues) are cleared, transport escrow is released to the trucker, and net proceeds go to the farmer's mobile wallet or bank account; the order of priority follows law and contract
- FR11.13: Target payout within the hour, subject to bank and payment-rail capability, with real-time status shown to the farmer
- FR11.14: Automated reconciliation between buyers' banks, floors, TIMB, and the platform ledger, with exception handling
- FR11.15: Itemised settlement statement to the farmer, with a dispute option

**Universalising to other commodities (tomatoes and grain)**

- FR11.16: The same engine runs as a Digital Spot Market and Fresh Produce Exchange, modelled on high-volume markets such as Mbare Musika or regional grain depots, with configurable grading and rules per commodity
- FR11.17: Dynamic pricing boards show real-time supply and demand for perishable tomatoes or maize based on daily arrivals
- FR11.18: Instant lot clearing: bulk buyers such as supermarkets and food processors bid on incoming truckloads before they enter the market yard, using in-transit data from the Logistics Module, to reduce post-harvest spoilage
- FR11.19: Aggregated price and volume data feeds the reference prices in FR10.7

**Design considerations and risks**

- Incumbent cooperation: floors, buyers, and TIMB must agree to any electronic bidding and slot system, so engage them before building; the module supports the floors and does not replace them
- Payout speed: a within-the-hour payout depends on bank integrations and payment-rail limits, so treat it as a target and agree service levels with the banks
- Bid and grade integrity: bidding must be tamper-evident and auditable, and arbitration must be independent and time-boxed to be trusted
- Physical constraints: tags must survive handling and weather, and floors need reliable scanners and connectivity, with offline fallback
- Competition law: bid data shared with the market should be aggregated to avoid collusion concerns
- Change management: floor clerks, graders, and buyers need training, and the first season should run alongside the manual process
- Personal data: grower identity and payment data follow the privacy sections of this BRD

# Functional Requirements: Marketing & CRM Module

This module helps farmers, agents, transporters, contractors, and service providers manage their relationships with buyers, suppliers, and customers, and promote their produce or services. For a smallholder it is deliberately simple: a contact book with reminders and a shareable produce profile.

**Pain points solved**

- Farmers: do not know who the buyers are, and lose enquiries in notebooks or chat threads
- Agents and transporters: cannot keep track of clients, follow-ups, and repeat business
- Service providers: cannot reach farmers in a targeted, respectful way
- Everyone: no trusted record of who delivered on their word

**Standalone value.** A user can keep contacts, notes, follow-up reminders, and a shareable profile on their own phone, offline, with no other module needed.

**Requirements**

- FR17.1: Contact and relationship book for buyers, suppliers, neighbours, and agents, with notes, history, and follow-up reminders, working offline
- FR17.2: Simple deal pipeline (enquiry, quote, agreed, delivered, paid) per buyer or client
- FR17.3: Shareable profile page for a farmer or business showing produce or services, volume, grade, location, and ratings, with a link and QR code that work in WhatsApp
- FR17.4: Broadcast messaging by SMS, WhatsApp, or push to contacts or groups (for example an agent to farmers in a cluster), using templates in English, Shona, and Ndebele
- FR17.5: Offers and campaigns, such as seasonal input offers, targeted by crop, area, and role using only consented data
- FR17.6: Ratings and reviews after completed transactions, with controls against fake reviews and a route to dispute a rating
- FR17.7: Automated follow-ups for delivery confirmation, payment due, and re-order reminders
- FR17.8: Simple analytics on enquiries, conversions, and response times
- FR17.9: Opt-in consent, frequency limits, and honoured opt-outs for all marketing messages, in line with the privacy sections
- FR17.10: Deals convert directly into contracts or orders (FR10), freight bookings (FR6), and ledger entries (FR8)

**Design considerations and risks**

- Spam and misuse: limit message volumes, require opt-in, and let recipients block senders
- Fake profiles and reviews: tie profiles to verified identities (FR15) and monitor rating patterns
- Simplicity: keep the smallholder view to the contact book, reminders, and profile, and hide advanced campaign tools
- Privacy: contacts are personal data, so store and share them only under the consent rules in this BRD

# Functional Requirements: Refrigeration & Storage Module

This module tracks and books the places where produce waits: cold rooms for tomatoes, curing barns and bale stores for tobacco, and warehouses or silos for grain. It reduces post-harvest loss and lets storage owners earn from idle capacity.

**Pain points solved**

- Farmers: produce spoils before sale, cold rooms are unknown or unavailable, and humidity or heat damages stored bales and grain
- Storage owners: idle capacity and no reliable way to find customers or collect payment
- Buyers: no proof that produce was stored correctly
- All: power cuts and no alerts when conditions go wrong

**Standalone value.** A farmer can log stored lots, see shelf-life timers, and receive temperature alerts for their own store. An owner can list capacity and earn, without the rest of the platform.

**Requirements**

- FR18.1: Storage asset register for cold rooms, curing barns, warehouses, and silos, with capacity, location, owner, power backup, and rates
- FR18.2: Storage booking: owners list capacity and prices, and farmers or traders book space by crate, pallet, or bale per day, with payment through escrow
- FR18.3: Inventory tracking of lots in and out with lot IDs and QR codes (see FR10.9), recording quantity, grade, date in, and expected shelf life
- FR18.4: Shelf-life timers and alerts per crop and storage condition, with prompts for urgent sale or dispatch (see FR4.10)
- FR18.5: Low-cost sensor telemetry for temperature and humidity, with offline buffering, thresholds, and SMS alerts
- FR18.6: Manual reading entry for stores without sensors, so the module works from day one
- FR18.7: Excursion handling records temperature or humidity breaches against the affected lots and notifies the owner, buyer, and insurer
- FR18.8: Curing barn monitoring for tobacco records curing stages and fuel used, linked to the environmental compliance record (FR2.16)
- FR18.9: Power and fuel resilience alerts for outages, generator or solar status, and fuel level
- FR18.10: Digital storage receipts record deposited quantity and grade, and can later support loans against stored produce where the law allows (nice to have)
- FR18.11: Hygiene and safety checklists for stores
- FR18.12: Storage and energy costs flow into the farmer's ledger (see FR8.5)

**Design considerations and risks**

- Sensor cost, theft, and connectivity: start with manual readings and a few low-cost sensors at shared aggregation points
- Liability for spoilage: agree in the booking terms who bears loss when conditions fail, and keep evidence from the telemetry
- Power reliability: cold rooms depend on power, so include backup and alerts in the requirements for listed stores
- Legal status of storage receipts: confirm with counsel before using them as collateral
- Owner trust: verify owners and inspect facilities before listing

# Functional Requirements: Ecommerce Marketplace

The marketplace lets farmers buy inputs and equipment, lets suppliers reach farmers, and lets buyers and consumers order produce. It builds on the escrow, logistics, and traceability modules, and comes after the pilot wedge.

**Pain points solved**

- Farmers: high input prices, few suppliers, fake seed and chemicals, and no way to compare offers
- Suppliers: limited reach and slow payment
- Buyers and consumers: no easy way to buy traceable produce direct from farmers

**Standalone value.** A farmer can browse and compare input prices from suppliers, and a supplier can list products and take orders, with no other module needed.

**Requirements**

- FR19.1: Product catalogue for inputs (seed, fertilizer, chemicals), equipment, and produce, with units, specifications, images, and a registered-product flag
- FR19.2: Seller onboarding with verification of business registration and licences, including agrochemical and seed licences (level 3 in the identity model)
- FR19.3: Search and price comparison by location, with delivery options and a catalogue cached for offline browsing
- FR19.4: Orders and quotes, including bulk orders and group buying by farmer clusters
- FR19.5: Checkout by mobile money, bank, escrow, or cash on delivery with confirmation, and receipts that flow into the ledger
- FR19.6: Input vouchers from escrow (FR8.8 to FR8.10) are redeemable in the catalogue only for approved items
- FR19.7: Anti-counterfeit checks: scan a batch code on seed or chemicals, sell only registered agrochemicals, and report fakes
- FR19.8: Delivery through the Logistics Module or collection at pickup points
- FR19.9: Ratings, returns, refunds, and disputes, with escrow held during a dispute
- FR19.10: Seller tools for inventory, pricing, order management, and settlement (see the Service Provider Portal)
- FR19.11: Equipment-as-a-Service rental of tractors, planters, and sprayers by hour, day, or acre, with an availability calendar, deposit, and usage tracking
- FR19.12: Transparent fees and commissions shown before checkout
- FR19.13: Consumer produce orders with traceable QR codes (see FR10.16)
- FR19.14: Tax invoices and receipts as required by law, and rules for restricted goods

**Design considerations and risks**

- Counterfeit and unsafe inputs: verify sellers, check batch codes, and act fast on complaints
- Advice and sales must stay separate: agronomy recommendations must not favour a paying seller (see the Agronomy module)
- Regulated products: agrochemical sales carry licensing and safety duties that the platform must respect
- Platform bypass: keep escrow, ratings, and vouchers valuable enough that buyers and sellers stay on the platform
- Delivery cost: rural delivery can erase small margins, so support pickup points and group orders
- Scope: this module follows the pilot wedge, and the pilot only needs voucher redemption and equipment booking

# Functional Requirements: Advisor Desk (Agronomists, Extension Officers, Economists)

The Advisor Desk is the workspace for agronomists, extension officers, and economists. It lets one advisor look after hundreds of farmers by focusing their time where crops are under stress, and gives private advisors a way to earn.

**Pain points solved**

- Advisors: cannot visit every farm, do not know which crops are in trouble, keep manual records, and have no tools to reach farmers at scale
- Farmers: advice comes late or not at all
- Lenders and contractors: no independent view of crop condition and plan quality

**Standalone value.** An advisor gets a caseload manager, a visit tool, and a knowledge library for the farmers who consent to follow them, without any other party being on the platform.

**Requirements**

- FR20.1: Caseload dashboard of the farmers an advisor follows, showing crop stage, alerts, and last contact, with the farmer's consent
- FR20.2: Crop stress and risk map built from diagnostics, weather, and satellite signals, to prioritise visits
- FR20.3: Remote advice by chat, voice note, or photo in local languages, with templates and bulk advisories to groups (see FR7.14)
- FR20.4: Escalation queue for low-confidence or high-severity Snap & Solve cases, routed to a human advisor with a response-time target (see FR7.6)
- FR20.5: Farm visit tools with offline checklists, geo-tagged photos, notes, recommendations, and follow-up tasks
- FR20.6: Feasibility review: advisors can review, annotate, and endorse feasibility plans, and an endorsement badge is visible to lenders
- FR20.7: Knowledge library of crop guides, pest and disease pages, best practice, and short videos in English, Shona, and Ndebele, with moderation
- FR20.8: Certified extension officers can log and verify grades (see FR10.19), with their credentials shown
- FR20.9: Economist tools give anonymised market, cost, and yield analytics and price outlook reports
- FR20.10: Paid advice marketplace: private advisors list services and fees and are booked and paid through escrow, while public extension stays free
- FR20.11: Performance tracking of advice given, adoption, and outcomes such as yield change
- FR20.12: Conflict-of-interest disclosure for advisors who sell inputs or earn commissions, with independent status flagged (see FR13.8)
- FR20.13: Credential verification and accreditation, with ratings

**Design considerations and risks**

- Advice liability: keep a record of advice given, and make clear when it is a recommendation and not a guarantee
- Data access: advisors see farmer data only with consent, and only for farmers they follow
- Quality control: moderate library content and remove poor advice, and review escalation performance
- Workload: alerts must prioritise, or advisors will be swamped
- Independence: advisors who also sell must disclose it, and independent roles must stay independent

# Functional Requirements: Agent Console

The Agent Console is the workspace for agents who onboard farmers, help them transact, and aggregate produce. It turns an informal role into a trackable, fairly paid business and protects the platform from fraud.

**Pain points solved**

- Agents: lose track of farmers, dispute commissions, carry cash, and lack tools to prove their work
- Farmers: rely on agents to act for them and have no record of what was done
- Platform and lenders: risk of ghost farmers and misreported deliveries

**Standalone value.** An agent gets a client roster, task list, and commission tracker for their own business, without needing any other party on the platform.

**Requirements**

- FR21.1: Agent registration and verification (level 3), with accreditation and assigned territory
- FR21.2: Assisted transactions, such as onboarding, freight booking, and sale logging on a farmer's behalf, only with consent or a recorded delegation (see FR15.6 and FR16)
- FR21.3: Client roster showing activation stage, needs, and follow-ups, linked to the CRM (FR17)
- FR21.4: Collection point management: aggregate produce or bales from several farmers into a batch, record weights and grades, split shares per farmer (see FR10.18), and issue receipts
- FR21.5: Commission engine with configurable rules (per onboarding, per transaction, per kilogram, tiered), automatic calculation, payment through escrow, statements, and a dispute route (see FR13.14)
- FR21.6: Cash handling controls: minimise cash, use mobile money floats, reconcile daily, set caps, and keep an audit trail
- FR21.7: Performance dashboard and quality checks covering onboardings, activation, retention, and error rates, with a supervisor view
- FR21.8: Training and certification modules with refreshers
- FR21.9: Conduct rules, conflict-of-interest disclosure, and a complaints route
- FR21.10: Fraud controls: duplicate and ghost-farmer detection, geo-verification of onboardings, and device binding for agent accounts
- FR21.11: Separate books when an agent also acts in another role, such as transporter (see FR13.7)
- FR21.12: Offline-first operation with sync

**Design considerations and risks**

- Agent fraud: pay for verified activity, audit samples, and use geo and device checks
- Incentives: commissions that reward volume alone invite abuse, so reward quality and retention
- Cash risk: reduce cash handling and protect agents on the road
- Status of intermediaries: check whether any licensing rule applies to agents
- Churn: agents leave, so keep client records with the platform and not with the individual

# Functional Requirements: Service Provider Portal (Inputs and Mechanisation)

The Service Provider Portal is the workspace for input suppliers, equipment and mechanisation providers, and other service businesses. It gives them demand visibility, secure payment, and credit tracking.

**Pain points solved**

- Suppliers: delayed collections, credit risk, no view of demand, and competition from counterfeit products
- Equipment owners: idle machines and difficulty collecting fees
- Farmers: uncertain product quality and no proof of what they bought

**Standalone value.** A supplier or equipment owner can list products or machines, take bookings, and get paid, without needing farmers to use any other module.

**Requirements**

- FR22.1: Business onboarding and verification of registration and licences, such as agrochemical registration and seed certification
- FR22.2: Catalogue and price management with bulk upload
- FR22.3: Demand insights from consented, aggregated crop areas and planting calendars by district, so suppliers can plan stock
- FR22.4: Voucher redemption: scan or enter a code, verify the item and farmer, confirm hand-over, and receive payment from escrow (see FR8.10)
- FR22.5: Orders and fulfilment, with delivery scheduling through the Logistics Module
- FR22.6: Equipment-as-a-Service management with booking calendar, operators, pricing per hour or acre, GPS or QR usage logs, and a maintenance schedule
- FR22.7: Receivables tracker showing who owes what and ageing, with repayment through the waterfall (FR8.14) and, with consent, a risk view of customers
- FR22.8: Payment reconciliation, statements, and tax invoices
- FR22.9: Product authenticity registry with batch codes and recall notices to buyers
- FR22.10: Customer communication and after-sales support, linked to the CRM (FR17)
- FR22.11: Performance analytics on sales, redemptions, returns, and ratings
- FR22.12: APIs to connect supplier inventory, ERP, and point-of-sale systems

**Design considerations and risks**

- Platform bypass: escrow-backed payment and demand insight must be worth more to suppliers than selling off-platform
- Price transparency: suppliers may resist price comparison, so show value through volume and secure payment
- Credit exposure: suppliers extending credit carry risk, so the receivables tracker must be accurate and consent-based
- Recalls: define how a recall reaches buyers quickly
- Agronomy independence: supplier promotions must never change the agronomy advice a farmer sees

# Functional Requirements: Government & Policy Insights

This workspace gives ministries, AGRITEX, local authorities, the national statistics agency, and development partners a view of the agricultural economy built from platform data, without exposing individual farmers. It also supports the delivery of programmes to verified farmers.

**Pain points solved**

- Government: no timely production statistics, unclear farmer numbers, levy leakage, late warning of drought and pest outbreaks, and difficulty targeting support
- Development partners: cannot verify who received support or what changed
- Farmers: programmes and subsidies that miss them or arrive late

**Standalone value.** Officials get live aggregated dashboards and early-warning maps from the first participating cluster, with no requirement that farmers use any government service.

**Requirements**

- FR23.1: Government workspace with role-based access for ministries, AGRITEX, local authorities, the statistics agency, and approved partners
- FR23.2: Production and area dashboards by crop, district, and season showing planted area, expected yield, and harvest progress, using minimum group sizes so individuals cannot be identified (see FR9.11)
- FR23.3: Livelihood indicators such as farm income, costs, and debt levels in aggregate, disaggregated by gender and age where consented
- FR23.4: Market and price monitoring covering prices, volumes, and post-harvest loss
- FR23.5: Levy and revenue tracking showing levies collected versus expected by district, with leakage indicators (see FR2.15)
- FR23.6: Early warning maps for drought, floods, and pest or disease outbreaks, built from platform signals and shared as alerts to affected areas
- FR23.7: Programme targeting and delivery, such as subsidised inputs sent to verified farmers as escrow vouchers, with tracking and a legal basis
- FR23.8: Policy scenario tools to test the effect of levy changes or price floors
- FR23.9: A formal data-request workflow with legal-basis check, approval, minimum-data rule, and logging
- FR23.10: Periodic public reports and an API for approved researchers, using anonymised data only
- FR23.11: Coverage indicators showing what share of farmers are on the platform, so users can see the bias in the data
- FR23.12: Data governance with data-sharing agreements and, where required, hosting options that keep data in country

**Design considerations and risks**

- Privacy and surveillance fears: aggregate by default, publish the rules, and never give officials individual farm data without a legal basis and consent
- Political misuse: the platform must stay neutral, and the data-request workflow must be strict and logged
- Coverage bias: early data comes only from participating farmers, so label it as such
- Small-area re-identification: suppress or merge small groups before showing results
- Data ownership: agree in writing that farmers own their data and that governments receive aggregates

# Architecture: Role-Based Workspace Engine

To serve all 12+ ecosystem participants without becoming a bloated or fragmented web of software, Transfarmation uses a Role-Based Workspace Engine, inspired by modular framework architectures. Instead of building 12 standalone applications, it runs one unified data core with specialised "lenses" (workspaces). Each participant logs into the same ecosystem but sees only the tools, metrics, and workflows relevant to their function, while every action feeds a shared data flywheel.

**Design principles**

- One identity, many roles: a person can be a farmer and a transporter at once and switch workspace without logging out
- Shared modules, configured into workspaces: a new workspace or crop vertical is configuration, not a new application
- Data access follows role, consent, and need: each participant sees only what their function requires
- Standalone-value test: every workspace must be useful to its user alone before it depends on any other party
- Mobile-first and offline-first for farmers, transporters, and agents; web dashboards for institutions

**1. Architectural blueprint: the Workspace Matrix**

| Participant | Workspace (lens) | Core modules used | Key reports and metrics | Main channel |
|----------|--------|------------------|------------------|--------|
| Farmers (formal and communal) | My Farm | Module 1, Agronomy, Accounting and Escrow, Logistics booking, Storage, Marketing and CRM | Cash flow, profitability, crop calendar, debt balance, settlement statements | Mobile app, USSD/SMS |
| Advisors, agronomists, economists | Advisory Desk | Agronomy dashboard, feasibility review, consented farm data | Crop stress across farms, advice response time, yield versus plan | Mobile and web |
| Consumers | Marketplace and Traceability | Ecommerce, traceability QR codes | Order history, product origin and quality | Mobile web |
| Contract farming intermediaries | Contract Command | Offtake and contracts, input escrow issuance, agronomy monitoring, side-marketing flags | Portfolio by grower, deliveries versus contract, input recovery, default risk | Web and mobile |
| Bankers | Credit Desk | Credit ledger, escrow, financial statements | Loan book, repayments via waterfall, credit scores, non-performing loans, diversion alerts | Web |
| Service providers (implements, inputs) | Supplier Portal | Marketplace, voucher redemption, leads | Orders, redemptions, payment status, demand signals | Web and mobile |
| Government | Policy Insights | Anonymised aggregate analytics | Production, farmer income, levy collection, regional statistics | Web dashboards |
| Regulators (TIMB and equivalents) | Compliance Gateway | Biometric sync, side-marketing flags, levy compliance, audit trail | Registered growers, flagged transactions, levies collected, compliance certificates | Web |
| Manufacturers (offtakers) | Offtaker Portal | Offtake, traceability, quality grading, supply forecasting | Volume commitments versus supply, quality, origin traceability | Web |
| Tobacco auction floors | Floor Operations | Bale intake verification, grower checks, settlement | Expected versus arrived bales, compliance status, sales settlement | Web, tablets and scanners |
| Agents | Agent Console | Farmer onboarding, assisted booking, commissions | Farmers onboarded, activity, commissions earned | Mobile and USSD assist |
| Logistics and transport providers | Driver and Fleet Hub | Freight matching, escrow, proof of delivery, backhaul | Jobs, earnings, payment status, ratings, utilisation | Mobile and USSD |
| Retailers | Retail Sourcing | Spot-market aggregator, supply forecast, delivery tracking, cold chain | Incoming supply, quality, delivery times, price trends | Web and mobile |

**2. Workspace engine requirements**

- FR9.1: One identity and one unified data core, with each account holding one or more roles
- FR9.2: Workspaces are composed from shared modules through configuration; adding a workspace or crop vertical needs no new application
- FR9.3: Each workspace shows only the tools, metrics, and workflows for that role, with data access controlled by role and consent
- FR9.4: Users with several roles can switch workspace without logging out
- FR9.5: Every workspace has a default dashboard and standard reports that can be filtered, exported (PDF, Excel, CSV), and scheduled
- FR9.6: The farmer workspace has a single master dashboard combining crop calendar, cash position, debt, loads in transit, and alerts
- FR9.7: Delegated access: a farmer can grant a bank, contractor, or advisor time-limited, revocable access to defined data
- FR9.8: Notifications are routed by role, channel (push, SMS, USSD, email), and language preference
- FR9.9: A cross-workspace event bus means one event, such as a signed proof of delivery, updates settlement, the ledger, and the regulator record in near real time
- FR9.10: Country- and vertical-specific parameters (crop, regulator rules, levies, currency, language) are configurable without code changes
- FR9.11: Aggregated, anonymised analytics for government and research use minimum group sizes so individuals cannot be identified
- FR9.12: An audit log records who viewed or changed what in every workspace

**3. The data flywheel**

- Farmer activity creates verified data: crop logs, ledger entries, deliveries, and repayments
- Verified data feeds bankers' credit scores, which lowers the cost of input credit and lets farmers grow
- Compliance data gives regulators confidence, which keeps market access open
- Transport and market data improve freight matching, pricing, and feasibility forecasts for the next season

**Design considerations**

- Avoid bloat: one design system, shared components, and progressive disclosure so each user sees a simple screen
- Strict data isolation between roles and organisations, with consent recorded for every share
- Farmers own their data; institutions see it only through consent or law
- Performance on low-cost Android phones and weak networks comes first for the farmer, transporter, and agent workspaces
- Implementation note (non-binding): a Flutter mobile app with modular feature packages and GetX state management fits the mobile workspaces, and Firestore offers offline persistence and role-based security rules; for the financial ledger and escrow, keep balances, settlements, and immutable records in server-side logic and a store built for transactional integrity rather than relying on client-side writes

# Unified Master Dashboard UX

The Unified Master Dashboard must handle the layered complexity of 12+ ecosystem participants while keeping the simplicity of a consumer app. Drawing on the Colours architecture, where real-time metric mirrors and performance accountability drive clarity, the UX avoids dense text and overwhelming menus. It uses a Contextual Lens Interface built on progressive disclosure, and it delivers the workspaces defined in the Role-Based Workspace Engine (see FR9.6 for the farmer master dashboard).

**1. Core UX architecture: the Lens switcher**

- FR12.1: On opening the app or web platform, the user lands on a clean, high-contrast home screen in their last-used lens
- FR12.2: A simple top-bar toggle switches between the user's verified active roles without changing applications (see the Multi-Role Hub, FR13.1 to FR13.4)
- FR12.3: The Global Metric Mirror (top header) is a live ticker of financial health, pending escrow actions, active task alerts, and weather and market indices, configured per role
- FR12.4: The modular drawer (bottom or side navigation) lights up icons dynamically for the active role, such as Feasibility, Agronomy, Accounting, Logistics, or Auction Floor

**2. Role-specific layouts (examples)**

*Farmer lens (communal or formal)*

- FR12.5: Hero card shows the immediate seasonal status and next action, for example "Tobacco growth stage: Topping. Next action: apply NPK top dressing in 3 days"
- FR12.6: Quick-action dial with three prominent buttons: Snap & Solve (camera for AI pest check or receipt OCR), Book Transport (one-tap request for a local haulage truck), and My Ledger (visual cash-in versus cash-out with no accounting jargon)
- FR12.7: Offline-first indicator: a subtle green dot shows sync status, so the farmer knows data is safely cached in areas with intermittent coverage

*Transporter lens*

- FR12.8: Live Freight Radar: a split screen with a local map of available farm-gate pickup pins (tobacco bales, tomato crates) matched against the vehicle's current capacity
- FR12.9: Escrow Vault status shows funds locked for active jobs in real time, removing payment anxiety
- FR12.10: One-tap proof of delivery: a large camera or QR scanner trigger used at collection points and at auction floor or market drop-offs to unlock escrow funds

*Banker and contractor lens*

- FR12.11: Risk Portfolio Heatmap: a macro view of all funded farmers colour-coded by performance health (green on track, yellow minor crop stress, red default or side-marketing risk)
- FR12.12: Automated Waterfall Dashboard: live tallies of input loan recoveries arriving from auction floor sales
- FR12.13: Other lenses (regulator, auction floor, retailer, agent, and so on) follow the same design system and layout pattern

**3. Design principles for extreme simplicity**

- FR12.14: Zero training required: if a farmer can use WhatsApp or mobile money, they can navigate Transfarmation; text is minimised, and icons, voice input, and visual colour-coding lead
- FR12.15: Native Shona and Ndebele toggles across all agronomy, financial, and transport prompts (see NFR3)
- FR12.16: Progressive disclosure: a new user sees only basic features (weather, agronomy, ledger); advanced modules such as Bankable Feasibility and Forward Contracting unlock as the farm profile matures, and can always be opened on request
- FR12.17: Accessibility: high contrast readable in sunlight, large touch targets, colour never the only signal, voice input and output, and screen-reader support

**Design considerations and risks**

- Progressive disclosure must not hide the bankable feasibility plan from farmers who need it early; keep unlock rules simple and overridable
- The offline indicator should also show how many items are waiting to sync, since a delayed proof of delivery delays payment
- Heatmap colours are risk indicators for review, not verdicts: a human checks before any adverse action, and only farmers who have consented are shown (see FR5.3)
- Never rely on colour alone, so users with colour blindness can read the heatmap through icons and labels
- Test with real users in Shona and Ndebele, including low-literacy farmers, before launch, and track task completion rate and time to first action
- Set performance budgets for low-cost Android devices and weak networks, and keep all lenses on one design system to avoid fragmentation

# Multi-Role User Architecture and the Multi-Role Hub

To reflect agricultural realities in Zimbabwe and across Africa, the platform must discard the rigid assumption that a user belongs to only one box. A communal or small-scale farmer often runs a small truck or ox-cart and doubles as a transporter for neighbours. A local extension officer or agronomist often acts as an informal agent or contract intermediary. A prosperous commercial farmer may also be an input service provider or a processor. With a Multi-Role User Architecture, one person can toggle between, or simultaneously act in, several participant profiles under one unified account and digital ID. This extends the one-identity principle in FR9.1 and FR9.4.

**Common multi-role patterns**

| Primary role | Also acts as | What the platform must support |
|------------|-------------|------------------------------------|
| Communal or small-scale farmer | Transporter (small truck, ox-cart) | Book own loads and accept neighbours' jobs, with farm income and freight income kept separate |
| Extension officer or agronomist | Agent or contract intermediary | Advisory Desk plus Agent Console, commission tracking, and disclosure of conflicts of interest |
| Commercial farmer | Input service provider or processor | Farm workspace plus Supplier Portal or Offtaker Portal, selling to other farmers |
| Contract farming intermediary | Input service provider | Contract Command plus Supplier Portal, with input sales kept separate from contract advice |

**1. Redesigned Unified Master Dashboard UX: the Multi-Role Hub**

- FR13.1: A Dynamic Multi-Role Switcher on the home screen shows all of the user's active roles and switches between them in one tap (this replaces the single-role toggle in FR12.2)
- FR13.2: An optional combined home view merges tasks, alerts, and metrics across roles, each tagged by role, for users who act in several roles at once
- FR13.3: The active role is always visible, and every transaction is recorded under the role it belongs to, to prevent mistakes such as booking freight as a farmer when acting as a transporter
- FR13.4: Adding a role is a simple guided step with role-specific verification (for example driver's licence and vehicle for a transporter, identity checks for an agent, business registration for a service provider); users start with the roles they qualify for and add others later, in line with progressive disclosure in FR12.16

**2. Architecture requirements**

- FR13.5: One account and one digital ID per person; roles are profiles of the person, not separate accounts
- FR13.6: Permissions, data, and workspace are defined per role, and every action is checked against the role it is performed in, with least privilege
- FR13.7: Separate books per role: ledger entries are tagged by role so farm, freight, and service income stay separate, with a consolidated personal net-position view (extends FR8.4)
- FR13.8: Conflict-of-interest rules stop or flag a user acting on both sides of the same transaction, for example a farmer booking their own truck through escrow, an agent approving their own client's loan, or an advisor recommending inputs they sell; required disclosures are recorded
- FR13.9: With consent, the credit profile combines verified income across roles, which can raise a multi-role user's eligibility
- FR13.10: Statutory and licence obligations attach to the role (for example a transporter's operator licence, a supplier's tax registration, a grower's TIMB levies), with a consolidated compliance view
- FR13.11: Roles can be suspended or revoked independently, so losing a transporter licence does not remove the farmer role, and every role change is logged
- FR13.12: Consent and data sharing are set per role: data shared with a bank for the farming role is not automatically visible to counterparties in the freight role
- FR13.13: Shared-device support: several people, such as family members, can use one phone with separate PINs and separate profiles
- FR13.14: Commission and fee handling for informal agents and intermediaries, paid through escrow with itemised statements

**Design considerations and risks**

- Keep simplicity: a user sees only the roles they hold, and multi-role features stay hidden until a second role is added
- Identity risk: one ID holding many roles raises the impact of account takeover, so require strong authentication and step-up checks for sensitive actions such as releasing escrow or changing bank details
- Independence: advisors who also sell inputs, and agents who also assess loans, create conflicts; arbitration and grade-inspector roles must stay independent of the parties
- Legal and tax: acting in extra roles may trigger licensing or tax duties, so the platform shows guidance at role activation and leaves the legal duty with the user
- Data protection: data collected for one role is used for another only with clear consent and purpose limits (see the privacy sections)

# Technical Requirements: Multi-Role Identity Database

The multi-role identity database is the foundation for the Cluster-Zero pilot and every later phase. It holds one record per person, links that person to one or more role profiles, and controls who can see what. It must be ready before the first participants are onboarded.

**Core data model**

| Entity | Key fields | Purpose |
|-----------|----------------------------|-------------------------|
| Person | Platform ID, name, mobile number, national ID number, language, status | One record per human, the single digital ID (FR13.5) |
| Credential | Type (national ID, TIMB grower number, biometric template reference), verification date, source | Proof of identity, kept apart from the profile |
| Role profile | Role type, status (pending, active, suspended, revoked), verification level, effective dates, role attributes | One per role the person holds |
| Organisation | Legal name, registration number, type (bank, contractor, floor, supplier, retailer), status | Institutions and businesses that people act for |
| Membership | Person, organisation, job function, permission scope, dates | A credit officer at a bank, a clerk at a floor |
| Asset | Type (plot with GPS boundary, vehicle, storage unit), owner, attributes | Farms, trucks, carts, and cold rooms tied to a role |
| Delegation | Grantor, delegate, scope, expiry | A family member or agent acting for a farmer |
| Consent record | Person, role, purpose, recipient, language, version, time, withdrawal | Append-only proof of consent |
| Verification event | Person or role, method, verifier, result, time | History of every check |
| Device and PIN | Device ID, person, PIN or biometric unlock, status | Supports shared phones with separate PINs |
| Audit log | Actor, action, target, time, hash of previous entry | Tamper-evident record of identity and access events |

**Verification levels**

| Level | How it is verified | What it unlocks |
|-----------|---------------------------|-------------------------|
| 0: Phone verified | Mobile number and one-time code | Weather, agronomy tips, and basic ledger |
| 1: ID verified | National ID number and photo check, or agent-assisted check | Feasibility plans, full ledger, and freight booking |
| 2: Grower verified | Biometric enrolment and TIMB grower number match | Contracts, input escrow, levies, and auction floor booking |
| 3: Business or licence verified | Business registration, transporter or operator licence, or institutional onboarding | Acting for others: transporter, agent, service provider, or institution |

**Requirements**

- FR15.1: One person record with a unique platform ID; roles are linked profiles, not separate accounts (see FR13.5)
- FR15.2: Identity matching and de-duplication on national ID number, mobile number, and biometric template, with an audited merge process to stop duplicate and ghost accounts
- FR15.3: Verification level is stored per person and per role, and each role and module states the minimum level it needs
- FR15.4: Role profile schema with type, status, effective dates, and role-specific attributes (for example vehicle capacity and licence expiry for a transporter, business registration number for a supplier, service area for an agent)
- FR15.5: Organisation accounts with staff memberships and permission scopes, so a bank, contractor, or floor can manage its own users
- FR15.6: Delegation and shared-device support: delegations carry a scope and an expiry date, and each person on a shared phone has a separate PIN and profile (see FR13.13)
- FR15.7: Biometric templates are stored as protected templates or hashes in a separate store, raw images are not kept, and access is only through the matching service
- FR15.8: An append-only consent ledger records purpose, role, recipient, language, version, time, and withdrawal for every consent (see FR5.1)
- FR15.9: Every data record is tagged with its owner person and role, and access checks combine role, verification level, and consent (see FR13.6 and FR13.12)
- FR15.10: Tamper-evident audit logs for identity creation, verification, role changes, delegation, and data access
- FR15.11: TIMB linkage stores the grower number and sync status, runs a reconciliation job, and flags mismatches for review
- FR15.12: Offline enrolment captures identity and role data on the device with local encryption, syncs later under the conflict rules in NFR12, and keeps the record pending until verified
- FR15.13: Account recovery for a lost phone or changed SIM uses agent-assisted verification, step-up authentication, SIM-swap checks, and a cooling-off period before high-risk actions
- FR15.14: Data subject rights: export, correction, and deletion, subject to legal retention (see FR5.2)
- FR15.15: Standards-based integration: OAuth 2.0 and OpenID Connect for sign-in and partner access, and APIs to national ID, TIMB, and mobile money KYC where available (see NFR8)
- FR15.16: Pseudonymised identifiers for aggregate analytics, so government and research views cannot identify individuals (see FR9.11)
- FR15.17: Sized for the 500 pilot participants but designed for millions of persons, with defined targets for sign-in speed and availability

**Design considerations and risks**

- Ghost farmers and identity fraud: fake or duplicate identities could claim inputs, so require level 2 verification before any escrow or input voucher, and check against the TIMB register
- People without national ID: allow a lower level with agent-assisted verification so nobody is locked out of basic tools, and limit what that level can do
- Name and number variations: local spellings and shared or changed phone numbers cause false mismatches, so match on several fields and allow manual review
- Biometric legality and trust: biometric capture needs explicit consent and a data protection impact assessment, and must follow the privacy sections of this BRD
- TIMB dependency: if the TIMB interface is not ready by pilot start, use manual verification of grower numbers with a later automated sync
- Implementation note (non-binding): with Flutter and Firebase, phone-number sign-in with one-time codes fits levels 0 and 1; keep custom claims to short role names (custom claims are limited to about 1 KB) and store detailed permissions, memberships, and delegations in Firestore with security rules that check role and consent; keep biometric templates, the consent ledger, and audit logs in server-side controlled storage written only by trusted functions, and plan for the limits of Firestore on complex relational queries

# Launch Onboarding Script (Cluster-Zero)

This script guides a field agent or extension officer through onboarding one farmer in about 20 to 25 minutes, in English, Shona, or Ndebele. It follows the verification levels in the identity database section, gives the farmer a quick win before asking for anything, and records consent in the farmer's own language. Level 2 grower verification can be done in a second visit.

**Onboarding principles**

- Give value first: show a weather alert or a leaf check before collecting detailed data
- One step at a time, with no forced transactions on day 1
- Consent in the farmer's language, read aloud, with a yes or no for each purpose
- Verify only as far as needed for what the farmer wants to do today; more can be added later
- Use teach-back: ask the farmer to say in their own words what they agreed to

**Step-by-step flow**

| Step | What the agent says or does | Data captured | Level |
|-----------|------------------------------|-------------------|-----|
| 1. Welcome and purpose (2 min) | Introduce yourself, explain what Transfarmation does in one sentence, and say that using it is free | None | None |
| 2. Language | Farmer chooses English, Shona, or Ndebele; the app and audio switch | Language | None |
| 3. Phone verification | Enter the farmer's number; farmer reads back the one-time code | Mobile number | 0 |
| 4. Consent, part 1: basic use | Read the basic consent aloud and record yes or no; do the teach-back check | Consent record with language, time, and agent ID | 0 |
| 5. ID check | Enter national ID number and take a photo; if no ID, use the agent-assisted route and mark a limited level | Name, ID number, photo | 1 |
| 6. Farm profile | Walk or pin the field boundary with GPS; record crops, acreage, and planting date | Plot boundary, crop, planting date | 1 |
| 7. Quick win | Show the weather alert and the crop calendar for their planting date; let them try Snap & Solve on a leaf | None new | 1 |
| 8. Other roles | Ask: "Do you also carry loads, work as an agent, or sell inputs or equipment?"; if yes, start that role and list what verification it needs, or skip it for later | Role type and role attributes (vehicle, capacity, licence) | 1 to 3 |
| 9. Grower verification (tobacco growers, may be a second visit) | Explain the fingerprint and TIMB grower number check, read the separate biometric and sharing consents, then enrol | Biometric template reference, TIMB grower number, consents | 2 |
| 10. PIN and household | Farmer sets a PIN; add other household members on a shared phone, each with their own PIN | Device and PIN records | Same |
| 11. What happens next | Explain the offline green dot, when input vouchers and freight booking start, and how to get help | None | None |
| 12. Confirmation | Send an SMS or give a printed slip with the farmer's ID number, language, and helpline | Onboarding complete, agent ID, time | Same |

**Key consent lines (English)**

- Basic consent: "We will keep your name, phone number, ID number, and farm location so the app can give you advice, weather alerts, and farm records. We will not share your information with a bank, contractor, buyer, or the government unless you say yes for each one. You can say no, and you can change your mind at any time. Do you agree?"
- Biometric consent: "We would like to record your fingerprint so that nobody else can use your grower number. We keep a protected code, not a picture of your fingerprint. Do you agree?"
- Sharing consent (asked later, one at a time): "Do you agree to share your farm records with [bank or contractor name] so they can decide on a loan or inputs for you?"

**Key lines in three languages (draft translations)**

| Purpose | English | Shona | Ndebele |
|--------|------------|-------------|-------------|
| Greeting | Hello, my name is [name] and I am from Transfarmation | Mhoroi, ndinonzi [name], ndiri kubva kuTransfarmation | Sawubona, ngingu [name], ngivela eTransfarmation |
| Consent to keep data | We ask your permission to keep your information | Tinokumbira mvumo yenyu yekuchengeta ruzivo rwenyu | Sicela imvume yakho yokugcina ulwazi lwakho |
| No sharing without consent | We will not share it without your permission | Hatizoripa vamwe pasina mvumo yenyu | Kasiyikulunika abanye ngaphandle kwemvume yakho |
| Right to refuse | You can say no and change your mind at any time | Munogona kuramba uye kushandura pfungwa chero nguva | Ungala futhi ungaphinda ushintshe umqondo nanini |
| Role question | Do you also carry loads or work as an agent? | Munoitawo basa rekutakura zvinhu kana kuita mumiriri here? | Uyasebenza njalo ngokuthwala impahla kumbe ukuba ngumthumeli yini? |
| Help | If you need help, call [number] | Kana muchida rubatsiro, fonerai [nhamba] | Nxa udinga usizo, fonela [inombolo] |

These translations are drafts. Native Shona and Ndebele speakers, and the legal team for the consent wording, must review and test them with farmers before use.

**Agent rules**

- Do not promise loans, prices, or approvals
- Do not rush or skip consent, and record refusals as valid answers
- Do not charge farmers for onboarding
- Do not collect information you cannot explain
- Record your own agent ID on every onboarding

**Agent training and quality control**

- One day of training in the flow, the consent script, and the teach-back check, with role play in local languages
- Supervisor spot checks and a consent audit of a sample of onboardings each week
- Pay agents for activated and correctly verified farmers, not for sign-ups alone, to discourage ghost accounts

**Onboarding tool requirements**

- FR16.1: Offline agent app with a guided step-by-step flow that can be paused and resumed
- FR16.2: Read-aloud audio for every screen and consent line in English, Shona, and Ndebele
- FR16.3: Consent capture with language, version, time, and agent ID, stored in the consent ledger (FR15.8)
- FR16.4: A teach-back check that the agent must complete before basic consent is accepted
- FR16.5: GPS boundary capture with an accuracy indicator and a warning when accuracy is poor
- FR16.6: Role questions that start each role's verification path and show what is still needed (FR13.4)
- FR16.7: Household and shared-phone setup with a separate PIN per person (FR13.13)
- FR16.8: SMS or printed confirmation slip with the farmer's ID, language, and helpline
- FR16.9: Agent dashboard showing onboardings, completion rate, verification level reached, and quality-check results

**Risks and adjustments**

- Translation accuracy: consent wording must be exact, so verify with native speakers and test with real farmers
- Low literacy: rely on audio and the agent, and avoid any step that needs reading long text
- Consent fatigue: keep consents short, ask for sharing consents only when needed, and never bundle them
- Agent conflicts: agents who are also contractors' staff or input sellers must disclose this at the start (see FR13.8)
- Inclusion: plan sessions that reach women and young farmers, and support shared phones
- Time and power: allow charging points and a second visit for level 2, so the process does not tire farmers out
- Data quality: check GPS accuracy and duplicate identities at the time of onboarding, not later

# System Architecture Diagrams

This section shows the platform in five views: the ecosystem it connects, its logical layers, how the phone app works offline and syncs, how a sale is settled, and how security and data protection are zoned. The diagrams are also delivered as separate SVG and PNG files.

**Key architecture decisions**

- One unified data core and one identity service; workspaces are configuration on top, not separate applications (FR9.2, FR13.5)
- Offline-first clients: every screen reads from the phone's local database, and the server has the final say on money and status
- An event bus connects the modules, so one event, such as a signed proof of delivery, updates the ledger, escrow, and regulator record (FR9.9)
- Sensitive data (biometric templates, ID numbers, consent ledger) sits in an isolated vault, and analytics use pseudonymised data only
- Partners such as TIMB, banks, and buyers connect only through scoped, logged APIs
- Recommendation (non-binding): build the pilot as a modular application with clear module boundaries, and split modules into separate services only when scale or team size requires it

**Figure 1: Ecosystem context.** The 13 participant roles fall into four groups around one platform, which connects to six external systems such as the TIMB registry, banks and mobile money, and national ID.

![Figure 1: Transfarmation ecosystem and external systems](/home/claude/diag/01_ecosystem_context.png){width=12cm}

**Figure 2: Logical architecture.** Five layers run from channels, through access and platform services and the domain modules, to the data core and external integrations, with security across all of them.

![Figure 2: Logical architecture in five layers](/home/claude/diag/02_logical_architecture.png){width=11cm}

**Figure 3: Offline-first app and sync.** The phone keeps working without signal, queues changes in an encrypted local database, and syncs when it can; SMS and USSD keep booking and confirmation available on any phone. Conflict rules keep money and status correct (see NFR12).

![Figure 3: Offline-first app and sync](/home/claude/diag/03_offline_sync.png){width=12cm}

**Figure 4: Sale settlement.** After a sale, the platform verifies the grower and lot, locks the grade and price, splits the proceeds in the order set by law and contract, and reconciles, logs, and notifies (see FR8.14 and FR11.12).

![Figure 4: Sale settlement waterfall](/home/claude/diag/04_settlement_flow.png){width=11.5cm}

**Figure 5: Security and data protection zones.** Traffic passes an edge zone and an application zone before reaching separated data zones; partners use a controlled partner zone, and operations cover every zone (see the Security and Data Privacy sections).

![Figure 5: Security and data protection zones](/home/claude/diag/05_security_zones.png){width=11.5cm}

# Database Strategy and Data Model

The goal is real-time information and fast reports at low, predictable cost, on a platform that also holds money, identity, and consent. This section gives a recommendation, a cost comparison, and the data model for the chosen approach. Prices were checked in September 2026 and change often, so recheck them before committing.

**Recommendation**

Use PostgreSQL as the system of record for identity, consent, contracts, the ledger and escrow, audit logs, and all reports. Run it on Supabase for the pilot, and keep it portable so it can move to another managed provider or be self-hosted in country. Do not use Firestore as the source of truth for money, identity, consent, or reports. Firestore is still a good fit as an offline-first, real-time read model on the phone, so if you want to keep it, use it in that role only. Postgres with an offline sync layer is simpler to run and its cost is easier to predict.

**Options**

| Option | Best for | Main risk | Cost behaviour |
|-----------|-------------------|-------------------|-------------------|
| A. Supabase Postgres with an offline sync layer such as PowerSync (recommended) | One source of truth, SQL reports, strong money integrity, predictable cost | Team must learn SQL and a sync layer; offline sync is not built in | Fixed monthly instance plus storage and egress; spend cap on by default |
| B. Postgres system of record plus Firestore read models for phones | Keeping the Firestore offline SDK and real-time listeners you know | Two systems to keep consistent; extra sync code | Postgres fixed cost plus Firestore reads and writes for read models only |
| C. Firestore only | Fastest start for a small pilot | Ledger, joins, and reports are hard; usage-based bills can spike; no self-hosting | Pay per read and write; near zero at pilot size, harder to forecast at scale |

**Comparison**

| Factor | Firestore | Postgres on Supabase |
|-------------|--------------------------|--------------------------|
| Billing model | Per document read, write, and delete, plus index entries read for aggregations | Fixed compute instance, plus storage and egress above included amounts |
| Cost predictability | Depends on usage patterns; real-time listeners and dashboards multiply reads; no hard spend cap | Fixed monthly compute; the cost step comes when you outgrow an instance size |
| Money and ledger integrity | Transactions exist, but no constraints or joins, and each document has a sustained write limit of about one per second | Full transactions, constraints, double-entry checks, and triggers |
| Reporting | No joins or group-by; needs precomputed aggregates | SQL, rollup tables, materialised views, and BI tools |
| Offline-first mobile | Built-in offline cache and real-time listeners | Needs a sync layer (PowerSync syncs Postgres to a local SQLite database) or a custom outbox |
| Real-time | Excellent for small, bounded queries | Supabase Realtime and sync streams; connection limits depend on plan and compute |
| Access control | Security rules; cross-document checks cost reads | Row-level security with joins to roles and consents |
| Data residency and exit | A Johannesburg location is available; proprietary and not self-hostable | Open source and portable; can be self-hosted if data must stay in country |
| Team fit | Matches your Flutter, GetX, and Firestore skills | Needs SQL skills; Flutter support is good |

**Verified price points (checked September 2026)**

- Firestore Standard edition, us-central1 rates: reads $0.03 per 100,000 documents, writes $0.09 per 100,000, deletes $0.01 per 100,000; free daily quota of 50,000 reads, 20,000 writes, and 20,000 deletes; each document change delivered to a real-time listener is billed as a read; aggregation queries such as count and sum are billed by index entries read; prices vary by location, so check the Johannesburg (africa-south1) row. Source: [Firestore pricing](https://cloud.google.com/firestore/pricing) and [Standard edition billing](https://firebase.google.cn/docs/firestore/standard-edition). A newer Enterprise edition bills per unit and prices real-time updates separately: [Enterprise pricing](https://firebase.google.com/docs/firestore/enterprise/pricing).
- Supabase: Pro is $25 per month per organisation and includes an 8 GB database, 250 GB egress, and 100,000 monthly active users, with a $10 compute credit that covers one Micro instance; compute is billed separately (Micro about $10, Small about $15, Medium about $60 per month) and is always on; database storage beyond 8 GB is about $0.125 per GB; Pro has a spend cap turned on by default. Sources: [Supabase pricing guide](https://www.jetadmin.io/blog/supabase-pricing-2026-guide-to-plans-limits-and-real-world-costs/), [Supabase cost explained](https://www.cloudzero.com/blog/supabase-pricing/), and [pricing calculator](https://makerkit.dev/pricing-calculator/supabase).
- PowerSync keeps a local SQLite database in the Flutter app in sync with Supabase Postgres, and offers a free plan and a self-hostable open edition: [Supabase and PowerSync guide](https://docs.powersync.com/integration-guides/supabase-+-powersync).

**Cost model (illustrative, not a quote)**

Firestore monthly cost is roughly 30 x (daily reads x $0.30 per million + daily writes x $0.90 per million), plus storage and bandwidth. All figures below use us-central1 rates and the stated assumptions.

| Scenario | Assumption | Firestore estimate |
|-----------|---------------------------|----------------------|
| Pilot, 500 users | 100 reads and 30 writes per user per day = 50,000 reads and 15,000 writes | At the edge of the free daily quota, so about $0, and cents beyond it |
| 100,000 farmers, read-model design | 100 reads and 30 writes per farmer per day = 10 million reads and 3 million writes | About $170 per month |
| 100,000 farmers, naive design | 5 times the reads and 3 times the writes from listeners on large collections and fan-out | About $690 per month |
| 5,000 sensors writing every 10 seconds | 43 million writes per day | About $1,170 per month |
| Same sensors writing hourly summaries | 120,000 writes per day | About $3 per month |

The lesson is that a good design keeps Firestore cheap, and one design mistake, such as raw sensor writes or a listener on a large collection, can cost more than everything else. Postgres on Supabase at the same scale is set by the instance size you choose, typically tens to a few hundred dollars per month, plus the sync layer's plan. Its risk is outgrowing a size, not a surprise bill.

**Recommended data architecture (Figure 6)**

- Phones read from and write to a local database and never wait for the network
- Changes leave the phone as commands with idempotency keys, and the server validates them against role, consent, and business rules before writing to Postgres
- Postgres is the only place where money, identity, consent, and audit records are stored
- Scheduled rollup jobs compute report tables or small snapshot documents, so dashboards read a few rows or documents, not thousands
- Photos and contracts live in object storage and are opened with short-lived signed links

![Figure 6: Recommended data architecture](/home/claude/diag/06_data_architecture.png){width=11cm}

**PostgreSQL system of record: core tables**

| Area | Tables | Notes |
|-----------|--------------------------|--------------------------|
| Identity | persons, credentials, role_profiles, organisations, memberships, delegations, devices | One person, many roles; biometric templates in a separate protected schema |
| Consent | consents (append-only), access_grants | Every read by another party is checked against an active grant |
| Farm | farms, plots, seasons, crop_logs, feasibility_plans | Plot boundaries stored as geometry; monthly partitions for logs |
| Contracts | contracts, contract_events, input_loans | Every state change is an event row |
| Money | ledger_accounts, ledger_entries, escrow_accounts, settlements, settlement_lines | Double-entry: entries in a transaction must sum to zero, enforced by a constraint; no updates or deletes |
| Movement | loads, load_events, consignments, lots, bales, storage_units | Bale tags indexed for fast intake scans |
| Time series | sensor_readings | Partitioned by month, with hourly rollups kept longer than raw data |
| Audit | audit_log | Append-only and hash-chained, written only by trusted functions |
| Reports | mv_district_production, mv_levy_by_district, mv_portfolio_health, mv_price_by_market | Rollup tables or materialised views refreshed on a schedule |

Use time-ordered unique IDs (such as UUIDv7) so records created offline on a phone never collide, and so IDs stay the same if data moves between systems. Apply row-level security to every table, keyed to the person, role, organisation, and active consent.

**Firestore data model (for the phone read-model role, or Firestore-first pilot)**

If Firestore is used, treat it as a read model and command inbox. The design rules are: one document per screen where possible, server-written summaries for anything shared, small bounded queries, and no raw event streams.

| Path | Purpose | Key fields | Limits and notes |
|----------------|--------------|--------------------|--------------------------|
| /users/{personId} | Profile and role summary | name, language, level, roles, orgIds, updatedAt | Roles also in custom claims, as short names only |
| /users/{personId}/home/current | Master dashboard read model | hero (stage, nextAction, dueAt), tiles (cashIn, cashOut, debt, escrowLocked), alerts (up to 10) | Server-written; one read per app open |
| /users/{personId}/tasks/{taskId} | Active prompts and to-dos | type, dueAt, status, refPath | Up to 50 active; TTL delete after completion |
| /users/{personId}/commands/{cmdId} | Offline outbox | type, payload, idempotencyKey, status, result | Client creates; a function processes; TTL 30 days |
| /users/{personId}/ledger/{entryId} | The farmer's own entries for offline use | role, category, amount, currency, date, status | Draft until the server confirms; the canonical record is in Postgres |
| /farms/{farmId} | Plot and current season | ownerId, district, cluster, crop, plantingDate, acreage, stage, calendar (array of milestones) | Calendar held in one document |
| /farms/{farmId}/logs/{logId} | Crop log entries | date, type, product, dose, photoRef, byRole | About 100 per season; monthly summary kept in the farm document |
| /openLoads/{district}/items/{loadId} | Freight radar read model | crop, weightKg, pickupGeohash, window, rate | Driver listens to at most 30 documents; removed on match |
| /loads/{loadId} | Job detail | shipperId, transporterId, status, escrow and delivery status, last events (up to 20) | Full history stays in Postgres |
| /consignments/{id} | Truckload of bales or crates | growerId, tags (array of tag, weight, grade), slot, status | One write per scan session, with scans buffered on the device |
| /reportSnapshots/{type}_{scope}_{period} | Precomputed report | metrics, asOf, coverage | Dashboards read 1 to 60 documents; written by a scheduled job |
| /refData/{type}/{id} | Reference data | crop templates, grade classes, levy rates with effective dates, translations | Delivered as bundles or CDN files and cached |
| /orgs/{orgId} and /orgs/{orgId}/members/{personId} | Organisations and staff | name, type, status; member function and scope | Small collections |
| /accessGrants/{granteeId}_{grantorId}_{scope} | Consent and delegation lookup | status, expiresAt | Document ID lets security rules use a direct lookup, not a query |
| /notifications/{personId}/items/{id} | In-app messages | title, body, refPath, readAt | TTL 30 days |

![Figure 7: Firestore collection map](/home/claude/diag/07_firestore_schema.png){width=11cm}

**Rules for low reads and writes**

- Read models: the app reads one prepared document per screen, not many source documents
- Report snapshots: dashboards read precomputed documents by scope and period, so cost does not grow with the number of farmers
- Listeners only on single documents or small queries with a limit; use one-time reads with pull-to-refresh for reports
- Never scan a large collection to build a report, and never use offset pagination, which bills skipped documents; use cursors
- Batch writes, and buffer scans, sensor readings, and chat-style events on the device, writing summaries instead of every event
- Keep raw telemetry, ledger entries, and audit logs out of Firestore
- Keep security rules to direct lookups; each lookup in a rule bills a read, so use custom claims for roles and document IDs that can be checked directly
- Exclude large fields from indexes, and avoid indexes you do not query, to cut write and storage cost
- Use TTL deletes for short-lived documents such as notifications and processed commands
- Shard any counter that many users update, since one document sustains about one write per second
- Ship reference data as bundles or cached files, not per-user reads
- Set budget alerts at 50, 90, and 100 percent, turn on App Check, rate-limit clients, and test with realistic listeners before launch

**Report retrieval pattern**

| Screen | Source | Reads per open |
|-----------|--------------------|--------------------|
| Farmer home | /users/{id}/home/current | 1 |
| Farmer tasks | /users/{id}/tasks, limited | Up to 20 |
| Transporter freight radar | /openLoads/{district}/items, limited | Up to 30 |
| Bank portfolio heatmap | reportSnapshots by district | 1 per district, up to about 60 |
| Regulator dashboard | reportSnapshots by district and metric | 30 to 60 |
| Government dashboard | reportSnapshots, aggregated only | 30 to 60 |
| Floor intake for one truck | /consignments/{id} | 1 |

A scan of 100,000 farm documents for one regulator view would bill 100,000 reads, while a snapshot design bills about 60. Refreshing 60 districts across 10 report types every hour is about 14,400 writes per day, roughly $0.013 per day (about 40 cents a month) at us-central1 rates.

**Decision checkpoints**

- Run a two-week spike comparing Supabase with PowerSync against Firestore read models on real 2G and 3G connections: offline conflicts, sync time, battery use, and cost per active user
- Build the settlement ledger and waterfall first in Postgres, with tests, before anything else depends on it
- Confirm data residency needs with counsel; if data must stay in Zimbabwe, plan for self-hosted Postgres in country
- Revisit the choice if real-time reports are needed for many thousands of simultaneous viewers, or if usage grows beyond one Postgres instance
- Keep the commands pattern and time-ordered IDs, so the client and the data model survive a change of provider

# Database Decision: Firestore and Flutter

**Decision (September 2026):** Transfarmation uses Cloud Firestore as its only database, with Flutter and GetX for the app. This overrides the earlier recommendation of PostgreSQL as system of record, and the guardrails below are the conditions that make the choice safe. The full technical design, with security rules, function and Flutter code, indexes, reporting pipeline, and risk register, is in the separate document "Firestore and Flutter Technical Design".

**What stays true from the earlier analysis.** Firestore has no joins or constraints, cannot be self-hosted, and bills by usage. So money, reports, and cost need explicit design.

**Guardrails**

- Only Cloud Functions write money and shared data, and security rules block clients from doing so
- Separate databases in one project: `(default)` for app data and read models, `ledger` for the ledger, escrow, consents, and audit, and `vault` for identity records; the last two are reachable only by function service accounts
- Ledger documents are balanced, integer-based, and never edited; corrections are new entries; a daily job reconciles balances and stores a signed digest in a retention-locked bucket
- Payments to mobile money and banks go through a payout outbox with idempotency keys, not inside the database transaction
- Pooled accounts are sharded, and per-farmer sub-accounts avoid the limit of about one write per second per document
- Reports come from precomputed snapshot documents, aggregation queries for simple counts, and BigQuery streaming for historic and ad-hoc queries
- Every listener is small and limited, telemetry is summarised on the device, and there are budget alerts and load tests
- Daily export to Cloud Storage and logic behind repository interfaces keep an exit path open

**Cost budget.** Target under 100 reads and 30 writes per active user per day. At 100,000 active farmers that is about 10 million reads and 3 million writes per day, roughly $170 per month on Firestore at us-central1 rates, before functions, SMS, and BigQuery. The Johannesburg price differs, so check it before budgeting.

![Figure 8: Firestore-only architecture](/home/claude/diag/08_firestore_only_architecture.png){width=11cm}

**Triggers to revisit the decision**

- A single account or counter needs sustained writes above about one per second and sharding no longer fits
- Data must be stored in Zimbabwe by law or regulator requirement
- Reports need joins or live ad-hoc queries that snapshots and BigQuery cannot serve
- The monthly Firestore bill exceeds budget for two months in a row after optimisation
- Ledger reconciliation becomes slow or costly

# Alternative Database Design and Scale at 100,000+ Users

A second technical design, "Supabase, PostgreSQL and PowerSync Technical Design", describes Postgres as the only database, with PowerSync syncing a local SQLite database on each phone, and Flutter with GetX for the app. It exists so the Firestore decision can be tested against a serious alternative and revisited if a trigger fires. Figure 9 in that document shows the architecture.

**Will Supabase with PowerSync scale to 100,000+ users?** Yes. 100,000 users making 30 writes a day is about 35 writes per second on average and perhaps 350 at a peak, which one mid-sized PostgreSQL instance handles. The limits arrive in the sync layer: peak concurrent phones (Pro allows up to 3,000 by default, Team up to 10,000, configurable to 50,000 or more on request) and data synced per month. Keep high-volume tables such as sensor readings out of the sync publication.

**Would Firestore stay affordable without exponential cost?** Yes, with the read-model rules. Firestore cost is linear in operations, but a few patterns multiply operations: many listeners on one shared document, listeners on large collections, fan-out writes, report scans, raw sensor writes, trigger loops, and rule lookups. Budget alerts and a load test before launch guard against them.

**Illustrative monthly cost at 100,000 registered users (30,000 active)**

| Option | Estimate | Notes |
|----------------------|--------------------|----------------------------------|
| Supabase with PowerSync, Pro plan, peak up to 3,000 phones | About $560 to $760 | Assumes 300 GB synced a month, 50 GB hosted, 100 GB database; before SMS, functions, and BI |
| Supabase with PowerSync, Team plan, peak up to 10,000 phones | About $1,320 to $1,520 | Same assumptions; higher plan for auction-day peaks |
| Firestore, read-model design | About $170 for operations, plus functions, BigQuery, and SMS | us-central1 rates; the Johannesburg price differs |
| Firestore, naive design | About $690 for operations, plus the same extras | Shows the cost of ignoring the rules |

At this scale the infrastructure difference is small compared with team cost. Choose Postgres if ledger integrity in the database, SQL reporting, portability, and possible in-country hosting matter most. Choose Firestore if the fastest path to offline and real-time with existing skills matters most, and the guardrails are followed. Estimates are illustrative and rest on stated assumptions; measure real usage in the pilot before committing.

![Figure 9: Supabase and PowerSync architecture](/home/claude/diag/09_supabase_powersync_architecture.png){width=11cm}

# Non-Functional Requirements

- NFR1: Offline-first. Module 1's core farm profiling and feasibility generation must function without network connectivity, syncing when a connection becomes available
- NFR2: Security. Digital contracts and biometric data must be cryptographically secured end to end
- NFR3: Localization. All contract terms and key UI content available in Shona and Ndebele, in addition to English
- NFR4: Low-bandwidth resilience. Suitable for rural connectivity conditions typical of communal farming areas
- NFR5: Auditability. Grower registration, levy deductions, and compliance clearances must be traceable for regulatory audit
- NFR6: Interoperability. Must integrate with TIMB's existing Biometric Grower Registration System and mapping standards without requiring TIMB to replace its own systems
- NFR7: Scalability. Cloud-native, multi-tenant architecture able to scale from a single pilot vertical (tobacco, Zimbabwe) to additional crops and countries without re-architecture
- NFR8: API-first design. Well-documented APIs for TIMB, banks, payment processors, and future third-party integrations
- NFR9: Data privacy & protection. Compliance with Zimbabwe's Cyber and Data Protection Act and relevant regional data-protection regulation, with farmer biometric and financial data encrypted at rest and in transit
- NFR10: Payment security. PCI-DSS-aligned handling for any card/mobile-money payment flows introduced by the ecommerce/marketplace layer
- NFR11: Role-based access control. Distinct permission levels for farmers, advisors, bankers, regulators, agents, and administrators
- NFR12: Offline-sync conflict resolution. Deterministic merge rules when offline-captured farm/module data reconciles with the server on reconnect
- NFR13: Availability & disaster recovery. Defined uptime target for transacting modules (offtake sign-off, payments) plus backup/restore procedures for farmer and compliance data
- NFR14: Analytics & reporting. Dashboards/exports to satisfy government and regulator statutory reporting obligations
- NFR15: Accessibility. Usable on low-cost Android devices and by low-literacy users, consistent with the plain-language/local-language requirement in Module 1
- NFR16: Multi-currency support. USD and local currency handling for financial and marketplace transactions
- NFR17: Erasure-compatible architecture, with personal data kept out of immutable ledgers (see GDPR section)
- NFR18: Data protection impact assessment completed before each biometric or credit-scoring release
- NFR19: Transfer register and Standard Contractual Clauses for EU-related data flows

# Feature Prioritization: Must Have vs Nice to Have

Must-have features are those without which the lowest-denominator user (a communal farmer, an individual transporter or agent) gets no standalone value, or without which the platform fails statutory compliance. Everything else is nice to have and is sequenced after the pilot proves out.

**Must have (pilot / MVP)**

- Offline-first mobile app (Android priority) with local-language UI (English, Shona, Ndebele)
- Farmer registration with GPS farm pinning and TIMB biometric grower registration sync
- Auto-generated bankable feasibility study (24-month cash flow, input schedule, yield model)
- Standardized offtake contract templates with plain-language translation and cryptographic digital sign-off
- Input-utilization tracking feeding a financier credit-scoring ledger
- Bale/load logging with grower-number and GPS cross-check for side-marketing flags
- Automated statutory levy and reforestation-levy calculation, with compliance certificates
- Mobile-money and bank payment integration
- Role-based access for farmers, contractors, bankers, regulators, and admins
- Basic accounting (income, expenses, loan balances)
- Audit logging, data encryption, and consent management
- USSD/SMS fallback for low-connectivity or feature-phone users
- Crop growth calendar with timed SMS/push prompts from the registered planting date, plus basic local weather alerts (core of the standalone Agronomy Module)

**Nice to have (post-pilot)**

- Snap & Solve offline pest/disease diagnosis (trialled in the pilot, full release after), satellite and hyper-local weather feeds, and AI agronomy assistant
- Freight-matching and escrow settlement with live load tracking
- Ecommerce marketplace and spot-market aggregator for horticulture
- Cold-room IoT telemetry and shelf-life timers
- Marketing and CRM tools for farmers and agents
- Farmer community, peer learning, and video training content
- Crop and input insurance (including parametric weather insurance) integrations
- Carbon-credit and sustainability traceability reporting
- Traceability QR codes for consumers and retailers
- Voice-based interface in local languages
- Cross-border trade, multi-currency settlement, and AfCFTA documentation support
- Open developer APIs and partner marketplace for service providers
# Security Requirements 2026–2030

The platform holds biometric identity, farm location, credit, and payment data for vulnerable users, so security is a launch gate, not a later phase. Requirements are grouped by domain, with the horizon by which each must be in place. Standards named here should be re-verified at each annual security review.

| Domain | Requirement | Horizon |
|-------------|------------------------------------------|-----------|
| Identity & access | Multi-factor authentication for institutional users; passkeys/FIDO2 where devices allow; PIN + biometric unlock for farmers; least-privilege role-based access | 2026 (launch) |
| Zero trust | No implicit trust between services or networks; per-request authorization, short-lived tokens, and network segmentation | 2026–2027 |
| Data protection | Encryption at rest and in transit; encrypted local storage for offline data; field-level encryption and hashing for biometric templates (store hashes, not raw prints) | 2026 (launch) |
| Biometric integrity | Liveness detection and deepfake/spoof resistance for any face, voice, or fingerprint capture; device attestation to block rooted or tampered apps | 2026–2027 |
| Key management | Keys held in a managed KMS/HSM, rotated on schedule, with separation of duties | 2026–2027 |
| Digital contracts | Tamper-evident signatures, timestamping, and immutable audit trail for every contract, levy, and compliance event | 2026 (launch) |
| Fraud & payments | Mobile-money and bank fraud monitoring, SIM-swap and account-takeover detection, transaction limits, and PCI DSS alignment for card flows | 2026–2027 |
| AI security | Guardrails, prompt-injection and data-leak testing, human review for high-stakes AI advice, and model/data governance for any AI features | 2027–2028 |
| Post-quantum readiness | Cryptographic inventory and crypto-agility so algorithms can be swapped; plan migration to NIST-standardized post-quantum algorithms, since NIST guidance signals retiring today's public-key schemes around 2030 | Inventory 2027; migration 2028–2030 |
| Supply chain | Software bill of materials (SBOM), dependency scanning, signed builds, and vetted third-party SDKs | 2026–2027 |
| Secure development | Threat modelling, code review, SAST/DAST in CI/CD, and annual independent penetration testing; optional bug-bounty programme | 2026 onward |
| Monitoring & response | Centralized logging, anomaly detection, 24/7 alerting, documented incident-response and breach-notification runbooks with regulator notification timelines | 2026–2027 |
| Resilience | Immutable, tested backups; ransomware recovery plan; defined RTO/RPO for transacting modules | 2026–2027 |
| Privacy & compliance | Compliance with Zimbabwe's Cyber and Data Protection Act and each expansion country's data-protection law; explicit consent, data minimization, and retention limits; data-residency options where required | 2026 onward |
| Certification | Target ISO/IEC 27001 alignment, then SOC 2 or equivalent attestation as institutional partners (banks, regulators) require | 2027–2028 |
| API & partner security | OAuth 2.0-based access, rate limiting, signed webhooks, and partner security due diligence for banks, TIMB, and payment providers | 2026–2027 |

**Security principles**

- Security must not break offline-first usability: protections work on low-cost Android devices and intermittent connectivity
- Farmers own their data and can see who accessed it; sharing with banks or buyers requires explicit consent
- Regulator and financier access is scoped, logged, and revocable
- Threat landscape is reviewed annually and this section updated accordingly through 2030

# Data Privacy & Protection Compliance

Transfarmation processes biometric identifiers, farm GPS locations, financial records, and contract data, which are treated as sensitive or high-risk personal data in most legal regimes. Zimbabwe is the binding jurisdiction at launch; every other regime below applies only when the platform serves people, partners, or infrastructure in that jurisdiction. This section is a requirements summary, not legal advice: each row must be confirmed by qualified local counsel before launch in that market, and laws should be re-checked at least annually.

| Jurisdiction | Law and regulator | Key obligations for Transfarmation | When it applies |
|---------|--------------------|------------------------------|-------------|
| Zimbabwe | Cyber and Data Protection Act [Chapter 12:07]; regulator is POTRAZ, the designated Data Protection Authority. Licensing rules in S.I. 155 of 2024 | Obtain a data controller licence (Form DP1, valid 12 months, renew three months ahead); appoint a Data Protection Officer; lawful, transparent processing with technical and organisational safeguards; biometric data is expressly defined in the regulations; licensing offences carry fines and possible imprisonment | Launch. Applies to Transfarmation and, where relevant, its partners as controllers or processors |
| South Africa | Protection of Personal Information Act (POPIA), 2013; regulator is the Information Regulator | Eight conditions for lawful processing; biometric information is special personal information needing a lawful basis or authorisation; register an Information Officer; notify the regulator and affected people of breaches; restrictions on cross-border transfers | Any South African farmers, buyers, banks, or logistics partners; SA-based processing |
| Africa (continental) | African Union Malabo Convention (in force since 2023) as the regional framework, plus national laws such as Kenya's Data Protection Act 2019, Nigeria's Data Protection Act 2023, Ghana's Data Protection Act 2012, Uganda's Data Protection and Privacy Act 2019, Zambia's Data Protection Act 2021, Malawi's Data Protection Act 2024, and Tanzania's Personal Data Protection Act 2022 | Country-by-country: controller/processor registration, DPO appointment, consent and purpose limits, breach notification (often 72 hours), localization or transfer conditions, local representation | Each expansion market, before launch there; maintain a per-country compliance register |
| European Union | General Data Protection Regulation (GDPR); national supervisory authorities | Documented lawful basis and consent; biometric data for identification is special-category data; data protection impact assessment for high-risk processing; breach notice to the authority within 72 hours; data subject rights (access, erasure, portability); transfer safeguards such as Standard Contractual Clauses; EU representative if no EU establishment; fines up to EUR 20 million or 4% of global turnover; EU AI Act duties for any AI features | EU-based buyers, manufacturers, retailers, consumers, or diaspora users; also where the platform offers services to or monitors people in the EU |
| United Kingdom | UK GDPR and Data Protection Act 2018, as amended by the Data (Use and Access) Act 2025; regulator is the ICO | Broadly GDPR-equivalent duties; UK-specific transfer tools (International Data Transfer Agreement or UK Addendum); UK representative if no UK establishment; breach notice to the ICO within 72 hours | UK-based buyers, importers, investors, or users |
| United States | No single federal privacy law. State laws such as California's CCPA/CPRA and other state comprehensive privacy laws; Illinois Biometric Information Privacy Act (BIPA); federal sector laws such as GLBA for financial data and COPPA for children under 13; FTC Act Section 5; breach notification laws in all states | Notice, opt-out and deletion rights; opt-in consent for biometric data where required (BIPA carries a private right of action); reasonable security; contractual flow-down with vendors; breach notification per state | US residents' data, US-based partners or investors, or US-hosted processing |

**Platform-wide privacy requirements (design once, apply everywhere)**

- Privacy by design and by default: collect only data each module needs, with purpose and retention limits recorded per data type
- Consent management: explicit, granular, revocable consent in Shona, Ndebele, and English; separate consent for biometric capture and for sharing data with banks, buyers, or regulators
- Biometrics: store hashed templates rather than raw fingerprints; run a data protection impact assessment before launch and before each new use
- Data subject rights: self-service access, correction, export, and deletion requests, tracked to legal deadlines
- Data inventory and records of processing for every module, partner, and country
- Cross-border transfers: maintain a transfer register with the legal mechanism per route; support in-country or regional data hosting where laws require it
- Vendor management: data processing agreements with cloud, payment, SMS/USSD, and analytics providers
- Breach response: one runbook covering the shortest notification deadline across all live jurisdictions (72 hours or less), with regulator and user templates
- Governance: appoint a Data Protection Officer, keep a privacy compliance calendar (licence renewals, audits, impact assessments), and train staff and field agents
- Regulator access: TIMB, tax, and law-enforcement data requests handled through a documented, logged, legally reviewed process
- Children and vulnerable users: age checks and guardian consent where minors' data may be captured, for example on family farms

**Sources for Zimbabwe row:** [Manokore Attorneys guide to S.I. 155 of 2024](https://afriwise.com/blog/a-quick-start-guide-to-zimbabwes-data-protection-regulations), [MISA Zimbabwe on the data controller licence](https://misa.org/blog/misa-zimbabwe-analysis-and-position-on-new-data-regulations/), [MISA Zimbabwe compliance overview](https://misa.org/blog/navigating-the-data-protection-act-requirements-ensuring-compliance-for-zimbabwean-data-controllers/). Other jurisdictions are summarized from general knowledge and not yet verified against primary texts.

# GDPR Impact on This BRD's Requirements

The BRD itself contains no personal data, so GDPR does not restrict the document. It does change what the platform must do, but only when the platform has an EU connection: EU-based buyers, manufacturers, or retailers, EU-resident users or investors, EU-hosted processing, or partners who impose GDPR-level terms by contract. A Zimbabwe-only pilot with no EU data subjects falls under Zimbabwe's Cyber and Data Protection Act instead. Because GDPR is the strictest common regime, designing to it from the start avoids rework later.

| Area of the BRD | How GDPR changes it |
|--------------------------|--------------------------------------------------|
| Biometric registration (TIMB sync, FR2.1–FR2.4) | Biometric data used to identify a person is special-category data; needs explicit consent or another Article 9 condition and a data protection impact assessment before launch |
| Credit-scoring ledger (FR1.7) and side-marketing flags (FR2.4) | These can be automated decisions with significant effects; provide human review, explanations, and a way to contest a decision. Credit scoring of individuals is also treated as high-risk under the EU AI Act |
| Digital contracts and audit trail (FR1.6, NFR2, NFR5) | Immutable or blockchain-style records conflict with the right to erasure; keep personal data off-chain or in erasable storage and record only hashes or references |
| Data sharing with banks, contractors, TIMB, buyers | Define controller, joint-controller, or processor roles in writing; use data processing agreements; share only what each party needs, with consent |
| Farm GPS and financial data | Data minimization, purpose limits, and defined retention periods per data type |
| Cross-border hosting and transfers (NFR7, cloud) | Use adequacy decisions or Standard Contractual Clauses with a transfer risk assessment for data moving from the EU to Zimbabwe or other African countries |
| Breach handling (NFR13) | Notify the supervisory authority within 72 hours where the breach is likely to harm people |
| Governance | Appoint a DPO, keep records of processing, and name an EU representative if there is no EU establishment |
| Marketing (Go-to-Market sections) | Opt-in consent for direct marketing to EU individuals; easy withdrawal |

**Recommended additions to the requirements**

- FR5.1: Consent capture and withdrawal for each data use, with a timestamped consent record
- FR5.2: Self-service data access, correction, export, and deletion requests
- FR5.3: Human review path and explanation view for any automated credit or compliance decision
- NFR17: Erasure-compatible architecture, with personal data kept out of immutable ledgers
- NFR18: Data protection impact assessment completed before each biometric or credit-scoring release
- NFR19: Transfer register and Standard Contractual Clauses for EU-related data flows

Penalties for serious GDPR breaches reach EUR 20 million or 4% of global annual turnover, whichever is higher. Have EU counsel confirm applicability and scope before onboarding any EU party.

# Assumptions & Constraints

- Assumes TIMB will grant API-level integration access to its Biometric Grower Registration System and mapping standards
- Assumes smartphone penetration among target communal farmers is sufficient for GPS-based profiling
- Constrained by the Tobacco Industry and Marketing Act [Chapter 18:20], which governs all contract farming activity in scope
- Assumes participating banks/merchants will accept the platform's credit-scoring ledger in place of physical verification
- Logistics & Transport (freight-matching, escrow settlement) is specified in this BRD but built after the pilot wedge

# Go-to-Market Strategy: Zimbabwe

The Zimbabwe launch wins by entering through the players who control access to farmers (contractors, TIMB, financiers), then reaching communal farmers with tools that work on their own. Because the platform must deliver value to a single farmer alone, marketing sells a free, immediately useful product first and monetizes the transactions that follow.

**Positioning**

- Tagline direction: "Transforming Farming": the farmer's digital farm office, bank-ready plan, and fair contract in one app
- Farmer message: free feasibility plan and contract translation in Shona/Ndebele in minutes, no clerk or extension officer queue
- Institutional message: compliance and side-marketing control delivered as infrastructure, not interference

**Channels and target segments**

| Segment | Entry channel | Hook |
|-------------|------------------------------|---------------------|
| Communal & smallholder tobacco farmers | Contractor-run field days, extension officers, farmer group leaders, community radio, WhatsApp groups, USSD/SMS for low-data users | Free bankable feasibility plan and plain-language contract |
| Contractors / merchants | Direct B2B sales, pilot with one or two licensed contractors | Lower default and side-marketing losses, digital contract sign-off |
| Banks & microfinanciers | Partnership pitch with pilot data from contractor cohorts | Live credit-scoring ledger cutting verification costs |
| TIMB and government | Formal engagement and MoU before public launch | Automated levy, compliance, and registration sync |
| Farmer bodies (e.g. Zimbabwe Farmers Union) | Endorsement and member onboarding drives | Member benefits and collective bargaining data |
| Transporters and agents | Mobile-money-linked onboarding through agent networks | Freight matching and pay-on-delivery |

**Tactics**

- Pilot in one or two tobacco-growing districts with a single contractor, measure results, then publish the outcomes
- Recruit and pay local farmer champions and agri-agents as onboarding ambassadors
- Integrate with mobile money (e.g. EcoCash) for payments and for identity-friendly sign-up
- Offer USSD and WhatsApp fallbacks so no farmer needs a data-heavy smartphone flow
- Run demos through contractor input-distribution events, when farmers are already gathered
- Sequence launch so the compliance value proposition is agreed with TIMB before farmer-facing marketing starts

# Go-to-Market Strategy: Africa

Africa expansion follows the same principle as Zimbabwe: enter each country through its regulator and dominant offtakers, keep the farmer-facing product useful on its own, and reuse the module architecture by changing parameters (crop, law, currency, language) rather than rebuilding.

**Candidate priority markets (to be validated by market research)**

| Market | Why it fits | Likely entry vertical |
|-----------|----------------------------------|----------------|
| Malawi, Zambia | Neighbouring tobacco economies with contract farming and similar regulatory models | Tobacco |
| Kenya, Uganda, Tanzania | Strong smallholder horticulture and mature mobile-money adoption | Tomatoes and horticulture |
| Nigeria, Ghana | Large domestic produce markets and high tomato and staples demand | Tomatoes and staples |
| South Africa, Mozambique | Regional trade and logistics links to Zimbabwe | Cross-border freight and marketplace |

**Expansion approach**

- Country playbook: regulator engagement, local-language content, mobile-money and bank integrations, then a pilot with one anchor offtaker
- Partner-led entry: local telcos, mobile-money operators, agri-input companies, banks, and development finance institutions rather than building distribution from scratch
- Align with regional trade frameworks such as the African Continental Free Trade Area (AfCFTA) to support cross-border marketplace and logistics features
- Position for donor and impact funding (development agencies, agri-finance programmes) as a digital public-good-style infrastructure play
- Localize per market: languages, currencies, crop parameters, and statutory rules configured, not hard-coded
- Build a reference case from Zimbabwe (measured farmer income, default reduction, compliance gains) to use in every new-country pitch

**Brand and awareness**

- Consistent "Transfarmation" brand across countries, with local-language campaign names
- Content marketing through farmer success stories, short video, radio, and WhatsApp
- Presence at agricultural shows, industry conferences, and regulator/board events
- Farmer referral incentives and agent commissions to drive organic growth

**Marketing metrics**

- Farmers onboarded and activated (first feasibility plan generated) per channel
- Cost per activated farmer by channel
- Contractor, bank, and regulator partners signed per country
- Share of transactions completed in-platform (offtake sign-offs, payments, freight bookings)

# Revenue Model Options

The core principle is that the farmer pays nothing to start, and revenue comes from the parties who gain measurable value: contractors, banks, payers, and, in time, buyers and service providers. All prices below are hypotheses to test in the pilot, not benchmarks.

**Design principles**

- Free for the smallholder: feasibility plan, contract translation, and basic accounting are the acquisition engine
- Charge the party with a quantifiable gain (losses avoided, cost saved, loans originated)
- Never make fees look like a new tax on the farmer's net price; deduct visibly and only where the farmer gets faster or safer payment
- Keep pricing simple and published; confirm any fee deducted at settlement is lawful with the regulator and counsel
- Every stream is tested with real partners before it goes into the financial model

**Revenue streams**

| Stream | Who pays | Pricing hypothesis | Phase |
|-----------|----------|--------------------------------|--------|
| Farmer core tools | No one (free) | Free to drive onboarding | Pilot |
| Contractor platform subscription | Contractors / merchants | Per registered grower per season, or tiered software fee, justified by reduced side-marketing, default, and verification costs | Pilot |
| Bank and financier services | Banks, microfinanciers | Per verified loan file or per originated loan, or subscription to the credit ledger | Pilot to Phase 2 |
| Grants and impact funding | Donors, development finance institutions | Results-based or programme funding tied to farmers onboarded and income gains | Pilot onward |
| Escrow and payment fee | Payer (buyer or contractor) | Small percentage or flat fee per settlement, priced below the cost of cash handling and delays | Phase 2 |
| Freight-matching commission | Shipper and/or transporter | Percentage of the freight fee or flat fee per booked load | Phase 2 |
| Compliance service | TIMB / government | Service contract for levy, registration, and compliance automation; sensitive, so agreed in the MoU and not charged to farmers | Phase 2 |
| Input and service-provider leads | Input suppliers, equipment dealers | Listing or lead fee for reaching registered farmers | Phase 2 |
| Marketplace commission | Sellers and/or buyers | Percentage of transaction value on the horticulture spot market | Phase 3 |
| Insurance and finance referrals | Insurers, lenders | Referral commission per policy or loan | Phase 3 |
| Aggregated data insights | Researchers, agri-companies | Consented, anonymised analytics only, within privacy law limits | Phase 3 |

**Recommended pilot mix**

- Contractor per-grower fee as the first paying stream
- Grant or impact funding to cover farmer onboarding while the base builds
- A small escrow and freight fee trial with one contractor and a few transporters

**Numbers to model before launch**

- Contractor loss avoided per grower (side-marketing, default, verification cost) versus the fee
- Cost per activated farmer by channel, from the Go-to-Market metrics
- Escrow float, settlement costs, and mobile-money charges per transaction
- Break-even number of growers and monthly transaction volume
- Fees as a share of the farmer's net income, to check farmers are clearly better off

# Success Metrics / KPIs

- Reduction in side-marketing incidents flagged/prevented at bale logging vs. baseline
- Number of communal farmers onboarded with a digitally signed offtake agreement
- Time from farm profiling to generated bankable feasibility report
- Volume of input credit extended by banks/merchants using the platform's credit-scoring ledger
- Statutory levy and export compliance clearance turnaround time
- Successful replication of the module architecture into the tomato vertical (time and effort required)

# Phased Deployment Roadmap

To scale as a self-sustaining utility without artificial network dependencies, execution follows four phases. Each phase must deliver value on its own, and the next phase starts only when its gate is met.

| Phase | What is deployed | Gate to proceed |
|--------|------------------------------|-------------------------|
| 1. Standalone farmer tools | Module 1 and Accounting: offline farm profiler, digital ledger, and automated feasibility generator, so a communal farmer gets daily value without buyers or transporters on board | Farmers activate and keep using the app; feasibility plans are accepted by at least one lender or contractor |
| 2. Regulatory and compliance gateways | TIMB biometric grower registry sync and automated levy and compliance tracking, making the platform indispensable to statutory bodies | Signed MoU and working integration with TIMB; data-protection licence obtained |
| 3. Decentralized logistics and escrow engine | Freight-matching marketplace and instant escrow settlement for first-mile and long-mile transit | Transporters paid on delivery confirmation within target time; low dispute rate |
| 4. Offtakers and retailers | Enterprise procurement dashboard for manufacturers and supermarket chains, forward contracts, and automated waterfall repayments | Forward contracts signed and repaid through the waterfall in the pilot cluster |

The auction floor module, the agronomy diagnostics, and the consumer marketplace are sequenced within or after these phases as the pilot results justify.

**Pilot rollout:** the Cluster-Zero pilot below applies these phases in a 90-day test in one closed-loop cluster.

# Phase 1 Pilot Strategy: The "Cluster-Zero" Launch

To test all 12+ user roles, cross-role functionality, and end-to-end modules without overwhelming the market, Transfarmation runs a localized, high-impact pilot named "Cluster-Zero". It uses Zimbabwe's tobacco and horticulture heartlands, for example a smallholder tobacco cluster around Karoi or Mvurwi combined with a tomato-producing horticulture cluster in Mutoko, so the pilot proves standalone value and scaling mechanics at the same time.

**1. Pilot scope and target cohort (the 12-role micro-ecosystem)**

Instead of a scattered national rollout, Phase 1 gathers a closed-loop ecosystem of about 500 multi-role participants within a tightly defined geographic radius. Participants are onboarded with overlapping roles on purpose, to test the multi-role engine.

| Participant group | Number | What it tests |
|-----------------------|------|--------------------------------|
| Core smallholder farmers, who also act as local transporters with ox-carts or small trucks | 100 | Standalone tools, multi-role switching, escrow, and freight for neighbours |
| Agronomists and extension officers, who also act as local collection agents | 10 | Advisory Desk, Agent Console, and batch aggregation |
| Contract farming intermediaries and merchants | 3 | Input distribution and side-marketing prevention |
| Local commercial bank or microfinance partner | 1 | Automated input escrow and waterfall repayments |
| Input and mechanisation service providers | 2 | Equipment-as-a-Service bookings |
| Regional auction floor or fresh produce market hub | 1 | Digital queue and electronic bidding |
| Ministry and regulators (TIMB, AGRITEX field officers) | To be agreed | Macro-intelligence and compliance gateway |
| Anchor supermarket retailer or tobacco processor | 1 | Forward contracting and automated procurement |

*Open point:* the named groups above add up to about 120 participants, so the remaining participants of the 500 need defining, for example more farmers, neighbouring households that book freight, or transport users.

**2. Phased rollout timeline (90-day execution plan)**

| Period | Action | Focus | Check before moving on |
|----------|-----------|----------------------|-----------|
| Days 1 to 30: standalone onboarding and profiling (the hook) | Deploy the offline-first app to the participants | Users test Module 1 (Bankable Feasibility) and the Agronomy Module (Snap & Solve); no complex transactions are forced yet; farmers register land profiles and set up secondary roles, such as transporter or local agent | Share of farmers activated and still active; feasibility plans generated |
| Days 31 to 60: operational transactions and escrow (the core engine) | Introduce the Accounting and Input Escrow Module and the Logistics Dispatch Module | Fertilizer and seed inputs are disbursed as digital vouchers locked in escrow; farmers book transport for early harvest preparation and, in the multi-role test, haul neighbours' loads | Vouchers redeemed correctly; loads booked and settled; disputes logged |
| Days 61 to 90: the market live-fire test (auction floor and offtaker integration) | Synchronise with the physical auction floor or regional fresh produce exchange | Test the digital queue, electronic lot matching, and the instant waterfall settlement: on sale, funds split into loan repayment, levies, and net wallet payout, with payout inside the hour as the target | Payout time, correct waterfall splits, and reconciliation with the bank and floor |

**3. Scaling mechanics: how Phase 1 drives organic expansion**

Phase 1 embeds three scaling mechanics so that growth does not depend on artificial network effects.

- **A. Single-player utility retention loop.** A farmer or transporter adopts the platform because it solves an immediate individual problem, such as free weather alerts, offline pest diagnosis, or a paying backhaul cargo, not because everyone else is on it. Retention through day-to-day farm management builds a dense, verified cluster of active users over one season.
- **B. Multi-role viral loop.** A communal farmer who earns extra cash through the transporter lens becomes an advocate among neighbours, so growth spreads through trusted peers who are already earning in several roles.
- **C. Data-driven pull from institutions.** As transaction volume builds, banks and regulators such as TIMB see lower defaults and automated compliance reporting, and start to mandate or subsidise use across their portfolios, driving top-down adoption in later phases. Defaults are expected to fall, and the pilot measures by how much.

**4. Pilot readiness checklist (before day 1)**

- Data controller licence and Data Protection Officer in place with POTRAZ, and a data protection impact assessment done for biometric and credit data
- Memorandum of understanding with TIMB, and agreements with the bank, contractors, auction floor, and anchor buyer
- Escrow and payment partner confirmed, with Reserve Bank of Zimbabwe requirements reviewed by counsel
- Farmer consent forms and contracts in English, Shona, and Ndebele
- Devices, connectivity, and offline plan for the cluster, plus a field support team and local agents
- Security review of the identity database and multi-role permissions (see the Security section and FR13.5 to FR13.14)

**5. Pilot success metrics**

- Activation and retention: farmers active at day 30, 60, and 90
- Feasibility plans generated and accepted by a lender or contractor
- Ledger entries per farmer and share of inputs redeemed through escrow
- Loads booked and settled, transporter earnings, and backhaul matches
- Payout time from sale to farmer wallet, and accuracy of waterfall splits
- Loan repayment rate through the waterfall compared with a matched group not on the platform
- Disputes per 100 transactions and time to resolve
- Referrals per active farmer, to measure the viral loop
- Cost per activated farmer by channel

**Pilot risks and adjustments**

- Crop calendar: a tobacco crop typically takes six to eight months from seedbed to sale, so a 90-day window starting now cannot reach the auction floor with tobacco; enrol at planting and run the market test in the marketing season, or use the shorter tomato cycle in Mutoko for an earlier market test; confirm season dates with TIMB and AGRITEX
- Distance to the floor: the participating auction floor is likely to be in Harare, so the freight leg runs from Karoi, Mvurwi, or Mutoko to the city
- Too many roles at once: onboard basic features first and add roles progressively, as in the plan above
- Real money at stake: start with small input-loan amounts, agreed limits, and a clear dispute process
- Fair measurement: compare the pilot cohort with a similar group not on the platform, or the results will be hard to prove
- Support load: plan local agents and a helpline in Shona and Ndebele from day 1

# Next Steps

The Logistics & Transport Module is now specified in this BRD. Recommended next actions:

1. Test the revenue model options in this BRD with contractors and banks and set prices
2. Validate the farmer value proposition in a pilot with one contractor and 30 to 50 farmers
3. Open engagement with TIMB and POTRAZ, and agree a memorandum of understanding
4. Commission legal review of data-protection licensing and escrow/payment-service requirements
5. Choose the single wedge feature to build first and freeze the rest of the scope until the pilot reports

# Appendix A: Requirements Traceability Matrix

This appendix links every requirement in the BRD to its module, the business objective it serves, its priority, and the deployment phase in which it is needed. It contains 333 requirements. The same matrix is also delivered as an Excel file with filters.

**How to read it**

- Priority: Must = needed for the pilot or for legal and statutory compliance; Should = important but not blocking; Could = later or optional
- Phase: 1 to 4 follow the Phased Deployment Roadmap (1 standalone farmer tools, 2 regulatory gateways, 3 logistics and escrow, 4 offtakers and retailers); Post-pilot means after the Cluster-Zero pilot
- Objective: BO1 farmer standalone value; BO2 transparent digital contracts; BO3 side-marketing reduction; BO4 statutory and environmental compliance; BO5 de-risked input financing; BO6 reusable architecture for other crops; All = cross-cutting

**Module expansion status**

| Module | Requirements | Status |
|--------------------|-----|------------------------------------|
| Module 1: Feasibility & Offtake | 17 | Fully expanded |
| TIMB Gateway & Compliance | 18 | Fully expanded |
| Horticulture Expansion | 14 | Fully expanded |
| Agronomy | 16 | Fully expanded |
| Accounting & Input Escrow | 22 | Fully expanded |
| Logistics & Transport | 23 | Fully expanded |
| Consumer, Retailer & Offtaker | 22 | Fully expanded |
| Auction Floors & Exchange | 19 | Fully expanded |
| Workspace Engine | 12 | Fully expanded |
| Dashboard UX | 17 | Fully expanded |
| Multi-Role | 14 | Fully expanded |
| Identity Database | 17 | Fully expanded |
| Onboarding | 9 | Fully expanded |
| Privacy & Data Protection | 3 | Covered by the privacy, GDPR, and security sections |
| Marketing & CRM | 12 | Fully expanded |
| Refrigeration & Storage | 14 | Fully expanded |
| Ecommerce Marketplace | 16 | Fully expanded |
| Advisor Desk | 13 | Fully expanded |
| Agent Console | 12 | Fully expanded |
| Service Provider Portal | 12 | Fully expanded |
| Government & Policy Insights | 12 | Fully expanded |
| Platform (Non-Functional) | 19 | Covered by the NFR list and the security section |

Every functional module now has its own pain-point, standalone-value, requirements, and risk write-up. The Refrigeration and Storage, Ecommerce, and Marketing modules are mostly post-pilot, and their pilot-critical parts are voucher redemption, equipment booking, and simple stock tracking.

**Summary by module and priority**

| Module | Must | Should | Could | Total |
|--------------------|----|----|----|----|
| Module 1: Feasibility & Offtake | 8 | 9 | 0 | 17 |
| TIMB Gateway & Compliance | 9 | 9 | 0 | 18 |
| Horticulture Expansion | 0 | 8 | 6 | 14 |
| Agronomy | 5 | 10 | 1 | 16 |
| Accounting & Input Escrow | 14 | 7 | 1 | 22 |
| Logistics & Transport | 10 | 9 | 4 | 23 |
| Consumer, Retailer & Offtaker | 6 | 10 | 6 | 22 |
| Auction Floors & Exchange | 7 | 6 | 6 | 19 |
| Workspace Engine | 7 | 4 | 1 | 12 |
| Dashboard UX | 12 | 5 | 0 | 17 |
| Multi-Role | 7 | 5 | 2 | 14 |
| Identity Database | 12 | 4 | 1 | 17 |
| Onboarding | 6 | 3 | 0 | 9 |
| Privacy & Data Protection | 1 | 2 | 0 | 3 |
| Marketing & CRM | 1 | 3 | 8 | 12 |
| Refrigeration & Storage | 0 | 5 | 9 | 14 |
| Ecommerce Marketplace | 1 | 7 | 8 | 16 |
| Advisor Desk | 0 | 9 | 4 | 13 |
| Agent Console | 5 | 7 | 0 | 12 |
| Service Provider Portal | 2 | 4 | 6 | 12 |
| Government & Policy Insights | 2 | 4 | 6 | 12 |
| Platform (Non-Functional) | 13 | 5 | 1 | 19 |
| **Total** | **128** | **135** | **70** | **333** |

**Summary by phase and priority**

| Phase | Must | Should | Could | Total |
|--------------------|----|----|----|----|
| 1: Standalone farmer tools | 69 | 28 | 0 | 97 |
| 2: Regulatory and compliance gateways | 15 | 21 | 1 | 37 |
| 3: Logistics and escrow | 28 | 48 | 0 | 76 |
| 4: Offtakers and retailers | 16 | 36 | 0 | 52 |
| Post-pilot | 0 | 2 | 69 | 71 |

Phase 1 carries 69 Must requirements. That is a lot for a first release meant to be the simplest tool a farmer has used, so review this list before build and defer anything not needed for day-1 farmer value.

**Full matrix**

| ID | Requirement | Module | Obj. | Priority | Phase |
|------|----------------------------|-------------|----|-----|-----|
| FR1.1 | Farmer can drop a GPS pin on their land via smartphone to register the plot | Module 1: Feasibility & Offtake | BO1 | Must | 1 |
| FR1.2 | System auto-detects soil type, historical rainfall patterns | Module 1: Feasibility & Offtake | BO1 | Must | 1 |
| FR1.3 | System auto-generates a 24-month projected cash-flow statement | Module 1: Feasibility & Offtake | BO1 | Must | 1 |
| FR1.4 | Farmer is presented with pre-vetted, standardized offtake contract templates from licensed contractors | Module 1: Feasibility & Offtake | BO2 | Must | 3 |
| FR1.5 | Every contract clause (minimum input packages, grading standards) is translated into plain Shona and Ndebele on screen | Module 1: Feasibility & Offtake | BO2 | Must | 3 |
| FR1.6 | System generates a cryptographically secured digital contract upon farmer sign-off | Module 1: Feasibility & Offtake | BO2 | Must | 3 |
| FR1.7 | System maintains a live credit-scoring ledger from real-time input-utilization tracking | Module 1: Feasibility & Offtake | BO5 | Must | 3 |
| FR1.8 | What-if tools let the farmer change acreage | Module 1: Feasibility & Offtake | BO1 | Should | 1 |
| FR1.9 | The feasibility report explains its assumptions in plain language in English | Module 1: Feasibility & Offtake | BO1 | Must | 1 |
| FR1.10 | Soil, rainfall, price, and cost benchmarks carry a source and date | Module 1: Feasibility & Offtake | BO1 | Should | 1 |
| FR1.11 | The report can be printed, exported as PDF | Module 1: Feasibility & Offtake | BO5 | Should | 3 |
| FR1.12 | Contract comparison shows offers from several contractors side by side on input cost | Module 1: Feasibility & Offtake | BO2 | Should | 3 |
| FR1.13 | Any clause can be explained on request, and the farmer can ask a human advisor to review a contract before signing | Module 1: Feasibility & Offtake | BO2 | Should | 3 |
| FR1.14 | Contract lifecycle tracking covers signature | Module 1: Feasibility & Offtake | BO2 | Should | 3 |
| FR1.15 | An input package and repayment schedule calculator tied to the contract feeds the debt view (FR8.7) | Module 1: Feasibility & Offtake | BO5 | Should | 3 |
| FR1.16 | A bankable-readiness checklist shows the farmer what records and plan they still need before applying for credit | Module 1: Feasibility & Offtake | BO5 | Should | 1 |
| FR1.17 | Yield and cost models are versioned and validated against pilot outcomes, with results fed back to improve them | Module 1: Feasibility & Offtake | BO6 | Should | Post-pilot |
| FR2.1 | Platform integrates directly with TIMB's Biometric Grower Registration System | TIMB Gateway & Compliance | BO3 | Must | 2 |
| FR2.2 | Farmer's digital ID, biometric thumbprint hash, and farm GPS coordinates are bound to their platform profile | TIMB Gateway & Compliance | BO3 | Must | 2 |
| FR2.3 | When a tobacco bale is logged for transport or delivery, smart contracts cross-reference the grower number and GPS origin | TIMB Gateway & Compliance | BO3 | Must | 2 |
| FR2.4 | System automatically flags unauthorized sales or third-party usage before the crop reaches the auction or contract floor | TIMB Gateway & Compliance | BO3 | Must | 2 |
| FR2.5 | System automates reforestation levy deductions and statutory marketing fee collection at point of sale | TIMB Gateway & Compliance | BO4 | Must | 2 |
| FR2.6 | System logs, in real time, whether a farmer uses sustainable coal | TIMB Gateway & Compliance | BO4 | Should | 2 |
| FR2.7 | System issues immediate compliance clearances required for export permits based on that logged data | TIMB Gateway & Compliance | BO4 | Should | 2 |
| FR2.8 | Grower registration status view shows the grower number, validity, renewal dates, and reminders | TIMB Gateway & Compliance | BO1 | Should | 2 |
| FR2.9 | Registration and renewal workflow with document upload | TIMB Gateway & Compliance | BO3 | Should | 2 |
| FR2.10 | Grower and contractor contracts are registered digitally with TIMB where the law requires it | TIMB Gateway & Compliance | BO2 | Should | 2 |
| FR2.11 | Configurable side-marketing rules… | TIMB Gateway & Compliance | BO3 | Must | 2 |
| FR2.12 | Case management for flagged cases: evidence | TIMB Gateway & Compliance | BO3 | Should | 2 |
| FR2.13 | Regulator dashboard shows registered growers | TIMB Gateway & Compliance | BO3 | Must | 2 |
| FR2.14 | Statutory returns are generated automatically in the prescribed format, with submission history | TIMB Gateway & Compliance | BO4 | Should | 2 |
| FR2.15 | Levy ledger calculates, deducts, and remits levies to the correct bodies, reconciles them, and gives the farmer a receipt | TIMB Gateway & Compliance | BO4 | Must | 2 |
| FR2.16 | Environmental compliance record covers curing fuel source | TIMB Gateway & Compliance | BO4 | Should | 2 |
| FR2.17 | Inspector mobile tools let TIMB and AGRITEX officers verify farms | TIMB Gateway & Compliance | BO4 | Should | 2 |
| FR2.18 | Statutory rates, levy rules, and compliance rules are configurable with effective dates and version history | TIMB Gateway & Compliance | BO4 | Must | 2 |
| FR3.1 | Storage and logistics module swaps tobacco bale tracking for cold-room telemetry and perishable shelf-life timers | Horticulture Expansion | BO6 | Could | Post-pilot |
| FR3.2 | Bidding and floor management engine adapts into an automated spot-market aggregator for fresh produce markets… | Horticulture Expansion | BO6 | Could | Post-pilot |
| FR3.3 | System matches daily tomato harvests with urban supermarket chains and informal traders before spoilage occurs | Horticulture Expansion | BO6 | Should | 4 |
| FR3.4 | Underlying architecture (farm profiling, offtake matching, compliance engine) requires zero structural rewiring | Horticulture Expansion | BO6 | Should | 4 |
| FR3.5 | Horticulture crop templates (tomatoes first) hold varieties | Horticulture Expansion | BO6 | Should | 4 |
| FR3.6 | A staggered planting planner spreads harvest dates to avoid gluts, using market demand signals | Horticulture Expansion | BO6 | Could | Post-pilot |
| FR3.7 | Harvest and post-harvest guidance covers maturity stage | Horticulture Expansion | BO6 | Should | 4 |
| FR3.8 | Daily price and demand signals from key markets such as Mbare Musika (see FR10.7 and FR11.17) | Horticulture Expansion | BO6 | Should | 4 |
| FR3.9 | One-tap harvest-ready listing posts expected or actual quantity, grade, and pickup location to buyers and transporters | Horticulture Expansion | BO6 | Should | 4 |
| FR3.10 | Grading and packing standards for crates, size classes, and ripeness tiers, with photo evidence at packing | Horticulture Expansion | BO6 | Should | 4 |
| FR3.11 | Post-harvest loss tracking records losses by cause (delay, cold chain, rejection) and reports how to reduce them | Horticulture Expansion | BO6 | Could | Post-pilot |
| FR3.12 | Food safety records log pesticide applications and pre-harvest intervals from the agronomy log | Horticulture Expansion | BO6 | Should | 4 |
| FR3.13 | Cluster harvest coordination lets neighbouring farmers combine loads to fill a truck (see FR10.18) | Horticulture Expansion | BO6 | Could | Post-pilot |
| FR3.14 | Forward contract options with processors and supermarkets (see FR10.4) for growers who want price certainty | Horticulture Expansion | BO2 | Could | Post-pilot |
| FR4.1 | Provide crop- and soil-specific guidance, input schedules, and pest/disease alerts tied to the farmer's registered plot | Agronomy | BO1 | Should | 1 |
| FR4.2 | Allow advisors/agronomists/economists to review farmer data and issue structured recommendations… | Agronomy | BO1 | Should | 1 |
| FR4.3 | Track farmer income, expenses, and loan/input-credit balances against the feasibility plan | Accounting & Input Escrow | BO1 | Must | 1 |
| FR4.4 | Generate statements usable as supporting evidence for future credit applications… | Accounting & Input Escrow | BO5 | Must | 1 |
| FR4.5 | Let farmers and intermediaries manage buyer/contact relationships and communication history | Marketing & CRM | BO1 | Could | Post-pilot |
| FR4.6 | Support outbound marketing of surplus produce (notably for horticulture spot-market matching) | Marketing & CRM | BO1 | Could | Post-pilot |
| FR4.7 | Support freight-matching between farmers/traders and transporters | Logistics & Transport | BO1 | Should | 3 |
| FR4.8 | Track a load from farm gate to delivery, with status visible to all relevant parties | Logistics & Transport | BO1 | Should | 3 |
| FR4.9 | Track cold-room/storage capacity, occupancy, and perishable shelf-life timers | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR4.10 | Alert relevant parties as shelf-life windows close, to trigger urgent sale/dispatch | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR4.11 | Provide a transactional marketplace where produce/product listings can be discovered and purchased by manufacturers | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR4.12 | Support order, payment, and delivery-confirmation workflows end to end within the platform | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR7.1 | Farmer maps field boundaries with smartphone GPS during profile setup, reusing the plot registered in Module 1 | Agronomy | BO1 | Must | 1 |
| FR7.2 | Module connects to localized meteorological and satellite data feeds to issue hyper-local warnings | Agronomy | BO1 | Must | 1 |
| FR7.3 | Farmer photographs an affected leaf (for example Barn Spot or Frog-eye on tobacco, or blight-related leaf curl on tomatoes) and… | Agronomy | BO1 | Should | 1 |
| FR7.4 | Model identifies the pest or pathogen and rates severity | Agronomy | BO1 | Should | 1 |
| FR7.5 | Module outputs an exact localized remedy | Agronomy | BO1 | Should | 1 |
| FR7.6 | Each diagnosis shows a confidence level; low-confidence or high-severity cases are escalated to a human agronomist | Agronomy | BO1 | Should | 1 |
| FR7.7 | With the farmer's consent, labelled images and outcomes improve the model over time | Agronomy | BO1 | Could | Post-pilot |
| FR7.8 | Tobacco calendar covers seedbed management, topping, priming, curing, and grading | Agronomy | BO1 | Must | 1 |
| FR7.9 | Timed prompts by push notification or SMS tell the farmer exactly when to apply basal fertilizer | Agronomy | BO1 | Must | 1 |
| FR7.10 | SMS and USSD fallback so prompts reach farmers without smartphones or data | Agronomy | BO1 | Must | 1 |
| FR7.11 | When the module recommends a chemical or fertilizer application | Agronomy | BO5 | Should | 3 |
| FR7.12 | If the inputs are tied to a credit facility, it signals the Input Escrow | Agronomy | BO5 | Should | 3 |
| FR7.13 | The digital crop log is a tamper-evident audit trail that shows good agricultural practices (GAP) were followed all season | Agronomy | BO4 | Should | 2 |
| FR7.14 | Contractor and agronomist dashboard shows crop stress and milestones across many smallholders | Agronomy | BO5 | Should | 3 |
| FR6.1 | Transporter onboarding with verification of driver's licence, vehicle registration, operator licence, and identity | Logistics & Transport | BO1 | Must | 3 |
| FR6.2 | Load posting works offline and syncs when a connection returns; USSD/SMS fallback for booking | Logistics & Transport | BO1 | Must | 3 |
| FR6.3 | Matching by route, capacity, vehicle type, refrigeration, rating, and price, with fixed-rate or bid options | Logistics & Transport | BO1 | Must | 3 |
| FR6.4 | Escrow held with a licensed payment service provider; release only on delivery confirmation or dispute resolution | Logistics & Transport | BO5 | Must | 3 |
| FR6.5 | Instant settlement to transporter and farmer mobile-money wallets or bank accounts | Logistics & Transport | BO5 | Must | 3 |
| FR6.6 | Pre-dispatch compliance gate that blocks tobacco loads lacking a valid grower number, GPS origin match, or levy clearance | Logistics & Transport | BO3 | Must | 3 |
| FR6.7 | Live tracking visible to shipper, receiver, and, where permitted, regulator; alerts for delay, deviation, and temperature breach | Logistics & Transport | BO1 | Should | 3 |
| FR6.8 | Two-factor delivery confirmation (QR plus one-time code) to reduce collusion, with photo and quantity evidence | Logistics & Transport | BO1 | Must | 3 |
| FR6.9 | Dispute workflow with evidence upload, timeline, partial release, and audit trail | Logistics & Transport | BO1 | Should | 3 |
| FR6.10 | Transporter and shipper reputation scores feeding a payment history usable for future credit (with consent) | Logistics & Transport | BO1 | Could | Post-pilot |
| FR6.11 | Return-load (backhaul) suggestions to reduce empty trips | Logistics & Transport | BO1 | Should | 3 |
| FR6.12 | Optional cargo insurance and fuel-advance integrations (nice to have) | Logistics & Transport | BO1 | Could | Post-pilot |
| FR6.13 | Transporters can use the module standalone with only a phone number | Logistics & Transport | BO1 | Must | 3 |
| FR6.14 | Tiered vehicle pairing matches the payload to first-mile (carts, tractors) or middle/long-mile (trucks, kombis, heavy carriers)… | Logistics & Transport | BO1 | Should | 3 |
| FR6.15 | A unique QR code is generated on the farmer's app | Logistics & Transport | BO1 | Must | 3 |
| FR6.16 | Backhaul notifications alert a transporter dropping inputs in a rural area to scheduled crop pickups nearby | Logistics & Transport | BO1 | Should | 3 |
| FR6.17 | Fuel liquidity support: optional fuel advance or voucher against an escrowed job, repaid from the settlement | Logistics & Transport | BO1 | Could | Post-pilot |
| FR6.18 | Perishable priority: tomato loads carry a shelf-life timer | Logistics & Transport | BO6 | Could | Post-pilot |
| FR6.19 | Condition photos at loading and drop-off establish who is accountable for damage or loss in transit | Logistics & Transport | BO1 | Should | 3 |
| FR6.20 | For TIMB, transport tracking records verify that bales leaving a farm gate match that grower's registered quota and flag… | Logistics & Transport | BO3 | Must | 3 |
| FR6.21 | Transport costs are logged automatically in the farmer's Financial Management Module against projected profits | Logistics & Transport | BO1 | Should | 3 |
| FR8.1 | Visual dashboard usable by a farmer with no bookkeeping experience, phone only | Accounting & Input Escrow | BO1 | Must | 1 |
| FR8.2 | Receipt photo capture with OCR extracts amount | Accounting & Input Escrow | BO1 | Should | 1 |
| FR8.3 | Voice-note logging in English, Shona, and Ndebele | Accounting & Input Escrow | BO1 | Should | 1 |
| FR8.4 | Separate household and farm categories or wallets, so household spending does not mix with farm capital | Accounting & Input Escrow | BO1 | Could | 2 |
| FR8.5 | Draft entries are created automatically from agronomy recommendations (FR7.11) and transport costs (FR6.21) | Accounting & Input Escrow | BO1 | Should | 3 |
| FR8.6 | Season budget versus actual, compared with the feasibility plan from Module 1 | Accounting & Input Escrow | BO1 | Must | 1 |
| FR8.7 | Debt view showing every loan, balance, due date, and forecast repayment, with alerts so there are no surprise debts at season end | Accounting & Input Escrow | BO1 | Must | 1 |
| FR8.8 | Input loans from a bank or contract sponsor are held in a ring-fenced Input Escrow account | Accounting & Input Escrow | BO5 | Must | 3 |
| FR8.9 | Milestone-based disbursement: funds or voucher codes for specific inputs unlock only when the Agronomy Module confirms the crop… | Accounting & Input Escrow | BO5 | Must | 3 |
| FR8.10 | Vouchers are redeemed at approved input suppliers, who confirm redemption and are paid promptly from escrow | Accounting & Input Escrow | BO5 | Must | 3 |
| FR8.11 | Diversion detection flags anomalies, such as inputs bought but not applied or resold, and alerts the lender | Accounting & Input Escrow | BO5 | Should | 3 |
| FR8.12 | Escrow is held with a licensed payment service provider, consistent with FR6.4 | Accounting & Input Escrow | BO5 | Must | 3 |
| FR8.13 | Live cost-versus-revenue tracking as sales occur | Accounting & Input Escrow | BO1 | Should | 4 |
| FR8.14 | Automatic waterfall distribution before the farmer receives cash: statutory levies and taxes (such as TIMB fees) are cleared | Accounting & Input Escrow | BO5 | Must | 4 |
| FR8.15 | Itemised settlement statement showing every deduction, with a dispute option for the farmer | Accounting & Input Escrow | BO1 | Must | 4 |
| FR8.16 | Rules for shortfalls, partial repayment, and rollover when a sale does not cover the loan | Accounting & Input Escrow | BO5 | Must | 4 |
| FR8.17 | Read-only, consent-based lender view of a tamper-evident ledger | Accounting & Input Escrow | BO5 | Must | 3 |
| FR8.18 | Credit score built from multiple seasons of platform-verified data | Accounting & Input Escrow | BO5 | Should | Post-pilot |
| FR8.19 | Repayment at the point of sale through escrow, before the farmer's payout, to lower non-performing loans | Accounting & Input Escrow | BO5 | Must | 4 |
| FR8.20 | Supplier view of payment status for implements and chemicals, so collections are timely and credit risk is visible | Accounting & Input Escrow | BO5 | Should | 3 |
| FR10.1 | Buyer onboarding with business verification for manufacturers, retailers, and traders | Consumer, Retailer & Offtaker | BO2 | Must | 4 |
| FR10.2 | Buyers post demand by crop, grade, volume, delivery window, and price range | Consumer, Retailer & Offtaker | BO2 | Must | 4 |
| FR10.3 | Supply forecast by crop, region | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR10.4 | Standardised forward contract templates covering volume | Consumer, Retailer & Offtaker | BO2 | Must | 4 |
| FR10.5 | Fulfilment tracking of contracted versus delivered volume and quality, with early warnings of shortfalls | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR10.6 | Daily listings, bids, and matching for tomatoes and other perishables before spoilage, extending FR3.2 and FR3.3 | Consumer, Retailer & Offtaker | BO6 | Could | Post-pilot |
| FR10.7 | Published reference prices and price trends by market (for example Mbare Musika and regional hubs) | Consumer, Retailer & Offtaker | BO6 | Could | Post-pilot |
| FR10.8 | Standard grading and quality specifications per crop (tobacco grades, tomato classes) | Consumer, Retailer & Offtaker | BO2 | Must | 4 |
| FR10.9 | Batch or lot IDs and QR traceability from farm to shelf | Consumer, Retailer & Offtaker | BO4 | Should | 4 |
| FR10.10 | Consumer scan of a QR code shows the farming cluster | Consumer, Retailer & Offtaker | BO6 | Could | Post-pilot |
| FR10.11 | Quality dispute workflow with evidence, partial acceptance, and price adjustment | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR10.12 | Escrow-backed payment on acceptance, feeding the waterfall in FR8.14 so farmers are paid quickly | Consumer, Retailer & Offtaker | BO5 | Must | 4 |
| FR10.13 | Supplier scorecards (reliability, quality, on-time delivery) for buyers, and buyer scorecards (payment timeliness) for farmers | Consumer, Retailer & Offtaker | BO2 | Could | Post-pilot |
| FR10.14 | APIs to integrate with buyers' procurement, ERP, and point-of-sale systems and with auction floor systems | Consumer, Retailer & Offtaker | BO6 | Should | 4 |
| FR10.15 | Compliance and sustainability reporting for buyers, such as GAP, levy, and curing-fuel compliance records | Consumer, Retailer & Offtaker | BO4 | Should | 4 |
| FR10.16 | Direct consumer orders, such as bulk produce boxes delivered through the Logistics Module (nice to have) | Consumer, Retailer & Offtaker | BO6 | Could | Post-pilot |
| FR10.17 | Virtual commodity exchange: manufacturers and retail buyers post projected seasonal demand… | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR10.18 | Algorithmic aggregation: the platform groups regional farming clusters and matches corporate demand with verified collective… | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR10.19 | Standardised digital grading logs recorded at harvest and packing by farmers or certified local extension officers… | Consumer, Retailer & Offtaker | BO2 | Must | 4 |
| FR10.20 | Smart quality lock: the buyer reviews the digital grade profile before dispatch | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR10.21 | Cold-chain telemetry: storage units and transport links feed temperature and humidity data into the platform | Consumer, Retailer & Offtaker | BO6 | Could | Post-pilot |
| FR10.22 | Buyer dashboards for procurement teams showing contracted versus forecast supply by cluster, grade mix, and delivery status | Consumer, Retailer & Offtaker | BO2 | Should | 4 |
| FR11.1 | Digital bale tagging: before loading | Auction Floors & Exchange | BO3 | Must | 3 |
| FR11.2 | Slot allocation: the platform assigns a digital arrival and drop-off slot (for example Floor 3, Bay B, Tuesday 08:00) instead… | Auction Floors & Exchange | BO1 | Should | 4 |
| FR11.3 | Slot management with capacity limits per floor and bay, rescheduling, congestion alerts, and queue status by SMS and USSD | Auction Floors & Exchange | BO1 | Should | 4 |
| FR11.4 | Slots are linked to the freight booking and the pre-dispatch compliance gate (FR6.6) | Auction Floors & Exchange | BO3 | Should | 4 |
| FR11.5 | Fast-track intake: a floor clerk scans the bale tag | Auction Floors & Exchange | BO1 | Must | 4 |
| FR11.6 | Reconciliation of arrived bales against tagged and expected bales, flagging missing, extra, or mismatched bales | Auction Floors & Exchange | BO3 | Must | 4 |
| FR11.7 | Hybrid bidding engine: licensed buyers see live floor inventory on workspace tablets and submit electronic bids alongside… | Auction Floors & Exchange | BO2 | Could | Post-pilot |
| FR11.8 | Bid integrity: authenticated licensed buyers only | Auction Floors & Exchange | BO2 | Could | Post-pilot |
| FR11.9 | Real-time grade arbitration: if a farmer disputes a grade | Auction Floors & Exchange | BO2 | Should | 4 |
| FR11.10 | Ownership and side-marketing checks: each bale's grower registration and contract status are verified | Auction Floors & Exchange | BO3 | Must | 4 |
| FR11.11 | Multi-party ownership tracking, so TIMB can see who owns each bale at each stage | Auction Floors & Exchange | BO3 | Should | 4 |
| FR11.12 | When the hammer drops and the sale is finalised | Auction Floors & Exchange | BO5 | Must | 4 |
| FR11.13 | Target payout within the hour, subject to bank and payment-rail capability, with real-time status shown to the farmer | Auction Floors & Exchange | BO1 | Should | 4 |
| FR11.14 | Automated reconciliation between buyers' banks, floors, TIMB, and the platform ledger, with exception handling | Auction Floors & Exchange | BO5 | Must | 4 |
| FR11.15 | Itemised settlement statement to the farmer, with a dispute option | Auction Floors & Exchange | BO1 | Must | 4 |
| FR11.16 | The same engine runs as a Digital Spot Market and Fresh Produce Exchange | Auction Floors & Exchange | BO6 | Could | Post-pilot |
| FR11.17 | Dynamic pricing boards show real-time supply and demand for perishable tomatoes or maize based on daily arrivals | Auction Floors & Exchange | BO6 | Could | Post-pilot |
| FR11.18 | Instant lot clearing: bulk buyers such as supermarkets and food processors bid on incoming truckloads before they enter the… | Auction Floors & Exchange | BO6 | Could | Post-pilot |
| FR11.19 | Aggregated price and volume data feeds the reference prices in FR10.7 | Auction Floors & Exchange | BO6 | Could | Post-pilot |
| FR17.1 | Contact and relationship book for buyers | Marketing & CRM | BO1 | Should | 3 |
| FR17.2 | Simple deal pipeline (enquiry, quote, agreed, delivered, paid) per buyer or client | Marketing & CRM | BO1 | Could | Post-pilot |
| FR17.3 | Shareable profile page for a farmer or business showing produce or services | Marketing & CRM | BO1 | Should | 4 |
| FR17.4 | Broadcast messaging by SMS, WhatsApp | Marketing & CRM | BO1 | Should | 3 |
| FR17.5 | Offers and campaigns, such as seasonal input offers, targeted by crop, area, and role using only consented data | Marketing & CRM | BO1 | Could | Post-pilot |
| FR17.6 | Ratings and reviews after completed transactions, with controls against fake reviews and a route to dispute a rating | Marketing & CRM | BO1 | Could | Post-pilot |
| FR17.7 | Automated follow-ups for delivery confirmation, payment due, and re-order reminders | Marketing & CRM | BO1 | Could | Post-pilot |
| FR17.8 | Simple analytics on enquiries, conversions, and response times | Marketing & CRM | BO1 | Could | Post-pilot |
| FR17.9 | Opt-in consent, frequency limits, and honoured opt-outs for all marketing messages, in line with the privacy sections | Marketing & CRM | All | Must | 3 |
| FR17.10 | Deals convert directly into contracts or orders (FR10), freight bookings (FR6), and ledger entries (FR8) | Marketing & CRM | BO1 | Could | Post-pilot |
| FR18.1 | Storage asset register for cold rooms | Refrigeration & Storage | BO6 | Should | 4 |
| FR18.2 | Storage booking: owners list capacity and prices | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR18.3 | Inventory tracking of lots in and out with lot IDs and QR codes (see FR10.9) | Refrigeration & Storage | BO6 | Should | 4 |
| FR18.4 | Shelf-life timers and alerts per crop and storage condition, with prompts for urgent sale or dispatch (see FR4.10) | Refrigeration & Storage | BO6 | Should | 4 |
| FR18.5 | Low-cost sensor telemetry for temperature and humidity, with offline buffering, thresholds, and SMS alerts | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR18.6 | Manual reading entry for stores without sensors, so the module works from day one | Refrigeration & Storage | BO6 | Should | 4 |
| FR18.7 | Excursion handling records temperature or humidity breaches against the affected lots and notifies the owner, buyer, and insurer | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR18.8 | Curing barn monitoring for tobacco records curing stages and fuel used, linked to the environmental compliance record (FR2.16) | Refrigeration & Storage | BO4 | Should | 4 |
| FR18.9 | Power and fuel resilience alerts for outages, generator or solar status, and fuel level | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR18.10 | Digital storage receipts record deposited quantity and grade | Refrigeration & Storage | BO5 | Could | Post-pilot |
| FR18.11 | Hygiene and safety checklists for stores | Refrigeration & Storage | BO6 | Could | Post-pilot |
| FR18.12 | Storage and energy costs flow into the farmer's ledger (see FR8.5) | Refrigeration & Storage | BO1 | Could | Post-pilot |
| FR19.1 | Product catalogue for inputs (seed, fertilizer, chemicals) | Ecommerce Marketplace | BO6 | Should | 3 |
| FR19.2 | Seller onboarding with verification of business registration and licences | Ecommerce Marketplace | BO6 | Should | 3 |
| FR19.3 | Search and price comparison by location, with delivery options and a catalogue cached for offline browsing | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR19.4 | Orders and quotes, including bulk orders and group buying by farmer clusters | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR19.5 | Checkout by mobile money, bank, escrow, or cash on delivery with confirmation, and receipts that flow into the ledger | Ecommerce Marketplace | BO5 | Should | 3 |
| FR19.6 | Input vouchers from escrow (FR8.8 to FR8.10) are redeemable in the catalogue only for approved items | Ecommerce Marketplace | BO5 | Must | 3 |
| FR19.7 | Anti-counterfeit checks: scan a batch code on seed or chemicals, sell only registered agrochemicals, and report fakes | Ecommerce Marketplace | BO6 | Should | 3 |
| FR19.8 | Delivery through the Logistics Module or collection at pickup points | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR19.9 | Ratings, returns, refunds, and disputes, with escrow held during a dispute | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR19.10 | Seller tools for inventory, pricing, order management, and settlement (see the Service Provider Portal) | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR19.11 | Equipment-as-a-Service rental of tractors | Ecommerce Marketplace | BO1 | Should | 3 |
| FR19.12 | Transparent fees and commissions shown before checkout | Ecommerce Marketplace | BO6 | Should | 3 |
| FR19.13 | Consumer produce orders with traceable QR codes (see FR10.16) | Ecommerce Marketplace | BO6 | Could | Post-pilot |
| FR19.14 | Tax invoices and receipts as required by law, and rules for restricted goods | Ecommerce Marketplace | BO4 | Should | 3 |
| FR20.1 | Caseload dashboard of the farmers an advisor follows, showing crop stage, alerts, and last contact, with the farmer's consent | Advisor Desk | BO1 | Should | 1 |
| FR20.2 | Crop stress and risk map built from diagnostics, weather, and satellite signals, to prioritise visits | Advisor Desk | BO1 | Should | 3 |
| FR20.3 | Remote advice by chat, voice note, or photo in local languages, with templates and bulk advisories to groups (see FR7.14) | Advisor Desk | BO1 | Should | 1 |
| FR20.4 | Escalation queue for low-confidence or high-severity Snap & Solve cases | Advisor Desk | BO1 | Should | 1 |
| FR20.5 | Farm visit tools with offline checklists, geo-tagged photos, notes, recommendations, and follow-up tasks | Advisor Desk | BO1 | Should | 1 |
| FR20.6 | Feasibility review: advisors can review, annotate, and endorse feasibility plans, and an endorsement badge is visible to lenders | Advisor Desk | BO5 | Should | 3 |
| FR20.7 | Knowledge library of crop guides | Advisor Desk | BO1 | Could | Post-pilot |
| FR20.8 | Certified extension officers can log and verify grades (see FR10.19), with their credentials shown | Advisor Desk | BO2 | Should | 4 |
| FR20.9 | Economist tools give anonymised market, cost, and yield analytics and price outlook reports | Advisor Desk | BO6 | Could | Post-pilot |
| FR20.10 | Paid advice marketplace: private advisors list services and fees and are booked and paid through escrow | Advisor Desk | BO1 | Could | Post-pilot |
| FR20.11 | Performance tracking of advice given, adoption, and outcomes such as yield change | Advisor Desk | BO1 | Could | Post-pilot |
| FR20.12 | Conflict-of-interest disclosure for advisors who sell inputs or earn commissions, with independent status flagged (see FR13.8) | Advisor Desk | All | Should | 3 |
| FR20.13 | Credential verification and accreditation, with ratings | Advisor Desk | BO1 | Should | 1 |
| FR21.1 | Agent registration and verification (level 3), with accreditation and assigned territory | Agent Console | BO3 | Must | 1 |
| FR21.2 | Assisted transactions, such as onboarding | Agent Console | BO1 | Should | 3 |
| FR21.3 | Client roster showing activation stage, needs, and follow-ups, linked to the CRM (FR17) | Agent Console | BO1 | Should | 1 |
| FR21.4 | Collection point management: aggregate produce or bales from several farmers into a batch | Agent Console | BO2 | Should | 3 |
| FR21.5 | Commission engine with configurable rules (per onboarding, per transaction, per kilogram, tiered) | Agent Console | BO5 | Should | 3 |
| FR21.6 | Cash handling controls: minimise cash, use mobile money floats, reconcile daily, set caps, and keep an audit trail | Agent Console | BO3 | Should | 1 |
| FR21.7 | Performance dashboard and quality checks covering onboardings, activation, retention, and error rates, with a supervisor view | Agent Console | BO3 | Must | 1 |
| FR21.8 | Training and certification modules with refreshers | Agent Console | BO1 | Must | 1 |
| FR21.9 | Conduct rules, conflict-of-interest disclosure, and a complaints route | Agent Console | All | Should | 1 |
| FR21.10 | Fraud controls: duplicate and ghost-farmer detection, geo-verification of onboardings, and device binding for agent accounts | Agent Console | BO3 | Must | 1 |
| FR21.11 | Separate books when an agent also acts in another role, such as transporter (see FR13.7) | Agent Console | All | Should | 3 |
| FR21.12 | Offline-first operation with sync | Agent Console | BO1 | Must | 1 |
| FR22.1 | Business onboarding and verification of registration and licences, such as agrochemical registration and seed certification | Service Provider Portal | BO5 | Must | 3 |
| FR22.2 | Catalogue and price management with bulk upload | Service Provider Portal | BO5 | Should | 3 |
| FR22.3 | Demand insights from consented, aggregated crop areas and planting calendars by district, so suppliers can plan stock | Service Provider Portal | BO6 | Could | Post-pilot |
| FR22.4 | Voucher redemption: scan or enter a code | Service Provider Portal | BO5 | Must | 3 |
| FR22.5 | Orders and fulfilment, with delivery scheduling through the Logistics Module | Service Provider Portal | BO6 | Could | Post-pilot |
| FR22.6 | Equipment-as-a-Service management with booking calendar | Service Provider Portal | BO1 | Should | 3 |
| FR22.7 | Receivables tracker showing who owes what and ageing | Service Provider Portal | BO5 | Should | 4 |
| FR22.8 | Payment reconciliation, statements, and tax invoices | Service Provider Portal | BO5 | Should | 3 |
| FR22.9 | Product authenticity registry with batch codes and recall notices to buyers | Service Provider Portal | BO6 | Could | Post-pilot |
| FR22.10 | Customer communication and after-sales support, linked to the CRM (FR17) | Service Provider Portal | BO6 | Could | Post-pilot |
| FR22.11 | Performance analytics on sales, redemptions, returns, and ratings | Service Provider Portal | BO6 | Could | Post-pilot |
| FR22.12 | APIs to connect supplier inventory, ERP, and point-of-sale systems | Service Provider Portal | BO6 | Could | Post-pilot |
| FR23.1 | Government workspace with role-based access for ministries | Government & Policy Insights | BO6 | Should | 2 |
| FR23.2 | Production and area dashboards by crop | Government & Policy Insights | BO6 | Should | 2 |
| FR23.3 | Livelihood indicators such as farm income, costs, and debt levels in aggregate, disaggregated by gender and age where consented | Government & Policy Insights | BO6 | Could | Post-pilot |
| FR23.4 | Market and price monitoring covering prices, volumes, and post-harvest loss | Government & Policy Insights | BO6 | Could | Post-pilot |
| FR23.5 | Levy and revenue tracking showing levies collected versus expected by district, with leakage indicators (see FR2.15) | Government & Policy Insights | BO4 | Should | 2 |
| FR23.6 | Early warning maps for drought | Government & Policy Insights | BO6 | Could | Post-pilot |
| FR23.7 | Programme targeting and delivery | Government & Policy Insights | BO6 | Could | Post-pilot |
| FR23.8 | Policy scenario tools to test the effect of levy changes or price floors | Government & Policy Insights | BO6 | Could | Post-pilot |
| FR23.9 | A formal data-request workflow with legal-basis check, approval, minimum-data rule, and logging | Government & Policy Insights | All | Must | 2 |
| FR23.10 | Periodic public reports and an API for approved researchers, using anonymised data only | Government & Policy Insights | BO6 | Could | Post-pilot |
| FR23.11 | Coverage indicators showing what share of farmers are on the platform, so users can see the bias in the data | Government & Policy Insights | All | Should | 2 |
| FR23.12 | Data governance with data-sharing agreements and, where required, hosting options that keep data in country | Government & Policy Insights | All | Must | 2 |
| FR9.1 | One identity and one unified data core, with each account holding one or more roles | Workspace Engine | BO6 | Must | 1 |
| FR9.2 | Workspaces are composed from shared modules through configuration; adding a workspace or crop vertical needs no new application | Workspace Engine | BO6 | Must | 1 |
| FR9.3 | Each workspace shows only the tools, metrics, and workflows for that role, with data access controlled by role and consent | Workspace Engine | BO1 | Must | 1 |
| FR9.4 | Users with several roles can switch workspace without logging out | Workspace Engine | BO1 | Must | 1 |
| FR9.5 | Every workspace has a default dashboard and standard reports that can be filtered, exported (PDF, Excel, CSV), and scheduled | Workspace Engine | BO1 | Should | 1 |
| FR9.6 | The farmer workspace has a single master dashboard combining crop calendar, cash position, debt, loads in transit, and alerts | Workspace Engine | BO1 | Must | 1 |
| FR9.7 | Delegated access: a farmer can grant a bank, contractor, or advisor time-limited, revocable access to defined data | Workspace Engine | BO5 | Should | 3 |
| FR9.8 | Notifications are routed by role, channel (push, SMS, USSD, email), and language preference | Workspace Engine | BO1 | Must | 1 |
| FR9.9 | A cross-workspace event bus means one event | Workspace Engine | BO6 | Should | 3 |
| FR9.10 | Country- and vertical-specific parameters (crop, regulator rules, levies, currency, language) are configurable without code… | Workspace Engine | BO6 | Should | 4 |
| FR9.11 | Aggregated, anonymised analytics for government and research use minimum group sizes so individuals cannot be identified | Workspace Engine | BO4 | Could | Post-pilot |
| FR9.12 | An audit log records who viewed or changed what in every workspace | Workspace Engine | All | Must | 1 |
| FR12.1 | On opening the app or web platform, the user lands on a clean, high-contrast home screen in their last-used lens | Dashboard UX | BO1 | Must | 1 |
| FR12.2 | A simple top-bar toggle switches between the user's verified active roles without changing applications… | Dashboard UX | BO1 | Must | 1 |
| FR12.3 | The Global Metric Mirror (top header) is a live ticker of financial health | Dashboard UX | BO1 | Should | 1 |
| FR12.4 | The modular drawer (bottom or side navigation) lights up icons dynamically for the active role | Dashboard UX | BO1 | Must | 1 |
| FR12.5 | Hero card shows the immediate seasonal status and next action | Dashboard UX | BO1 | Must | 1 |
| FR12.6 | Quick-action dial with three prominent buttons: Snap & Solve (camera for AI pest check or receipt OCR) | Dashboard UX | BO1 | Must | 1 |
| FR12.7 | Offline-first indicator: a subtle green dot shows sync status | Dashboard UX | BO1 | Must | 1 |
| FR12.8 | Live Freight Radar: a split screen with a local map of available farm-gate pickup pins (tobacco bales, tomato crates) matched… | Dashboard UX | BO1 | Must | 3 |
| FR12.9 | Escrow Vault status shows funds locked for active jobs in real time, removing payment anxiety | Dashboard UX | BO1 | Must | 3 |
| FR12.10 | One-tap proof of delivery: a large camera or QR scanner trigger used at collection points and at auction floor or market… | Dashboard UX | BO1 | Must | 3 |
| FR12.11 | Risk Portfolio Heatmap: a macro view of all funded farmers colour-coded by performance health… | Dashboard UX | BO5 | Should | 4 |
| FR12.12 | Automated Waterfall Dashboard: live tallies of input loan recoveries arriving from auction floor sales | Dashboard UX | BO5 | Should | 4 |
| FR12.13 | Other lenses (regulator, auction floor, retailer, agent, and so on) follow the same design system and layout pattern | Dashboard UX | BO6 | Should | 2 |
| FR12.14 | Zero training required: if a farmer can use WhatsApp or mobile money, they can navigate Transfarmation | Dashboard UX | BO1 | Must | 1 |
| FR12.15 | Native Shona and Ndebele toggles across all agronomy, financial, and transport prompts (see NFR3) | Dashboard UX | BO1 | Must | 1 |
| FR12.16 | Progressive disclosure: a new user sees only basic features (weather, agronomy, ledger) | Dashboard UX | BO1 | Should | 1 |
| FR12.17 | Accessibility: high contrast readable in sunlight | Dashboard UX | BO1 | Must | 1 |
| FR13.1 | A Dynamic Multi-Role Switcher on the home screen shows all of the user's active roles and switches between them in one tap… | Multi-Role | BO1 | Must | 1 |
| FR13.2 | An optional combined home view merges tasks | Multi-Role | BO1 | Could | Post-pilot |
| FR13.3 | The active role is always visible | Multi-Role | BO1 | Must | 1 |
| FR13.4 | Adding a role is a simple guided step with role-specific verification… | Multi-Role | BO1 | Must | 1 |
| FR13.5 | One account and one digital ID per person; roles are profiles of the person, not separate accounts | Multi-Role | BO1 | Must | 1 |
| FR13.6 | Permissions, data, and workspace are defined per role | Multi-Role | BO1 | Must | 1 |
| FR13.7 | Separate books per role: ledger entries are tagged by role so farm | Multi-Role | BO1 | Should | 3 |
| FR13.8 | Conflict-of-interest rules stop or flag a user acting on both sides of the same transaction | Multi-Role | BO1 | Should | 3 |
| FR13.9 | With consent, the credit profile combines verified income across roles, which can raise a multi-role user's eligibility | Multi-Role | BO5 | Could | Post-pilot |
| FR13.10 | Statutory and licence obligations attach to the role… | Multi-Role | BO4 | Should | 3 |
| FR13.11 | Roles can be suspended or revoked independently | Multi-Role | BO1 | Should | 3 |
| FR13.12 | Consent and data sharing are set per role | Multi-Role | All | Must | 1 |
| FR13.13 | Shared-device support: several people, such as family members, can use one phone with separate PINs and separate profiles | Multi-Role | BO1 | Must | 1 |
| FR13.14 | Commission and fee handling for informal agents and intermediaries, paid through escrow with itemised statements | Multi-Role | BO1 | Should | 3 |
| FR15.1 | One person record with a unique platform ID; roles are linked profiles, not separate accounts (see FR13.5) | Identity Database | BO1 | Must | 1 |
| FR15.2 | Identity matching and de-duplication on national ID number | Identity Database | BO3 | Must | 1 |
| FR15.3 | Verification level is stored per person and per role, and each role and module states the minimum level it needs | Identity Database | BO1 | Must | 1 |
| FR15.4 | Role profile schema with type, status | Identity Database | BO1 | Must | 1 |
| FR15.5 | Organisation accounts with staff memberships and permission scopes, so a bank, contractor, or floor can manage its own users | Identity Database | BO5 | Must | 2 |
| FR15.6 | Delegation and shared-device support: delegations carry a scope and an expiry date | Identity Database | BO1 | Must | 1 |
| FR15.7 | Biometric templates are stored as protected templates or hashes in a separate store | Identity Database | All | Must | 1 |
| FR15.8 | An append-only consent ledger records purpose | Identity Database | All | Must | 1 |
| FR15.9 | Every data record is tagged with its owner person and role | Identity Database | All | Must | 1 |
| FR15.10 | Tamper-evident audit logs for identity creation, verification, role changes, delegation, and data access | Identity Database | All | Must | 1 |
| FR15.11 | TIMB linkage stores the grower number and sync status, runs a reconciliation job, and flags mismatches for review | Identity Database | BO3 | Must | 2 |
| FR15.12 | Offline enrolment captures identity and role data on the device with local encryption | Identity Database | BO1 | Must | 1 |
| FR15.13 | Account recovery for a lost phone or changed SIM uses agent-assisted verification | Identity Database | BO1 | Should | 1 |
| FR15.14 | Data subject rights: export, correction, and deletion, subject to legal retention (see FR5.2) | Identity Database | All | Should | 2 |
| FR15.15 | Standards-based integration: OAuth 2.0 and OpenID Connect for sign-in and partner access | Identity Database | BO6 | Should | 2 |
| FR15.16 | Pseudonymised identifiers for aggregate analytics, so government and research views cannot identify individuals (see FR9.11) | Identity Database | All | Could | Post-pilot |
| FR15.17 | Sized for the 500 pilot participants but designed for millions of persons, with defined targets for sign-in speed and availability | Identity Database | BO6 | Should | 1 |
| FR16.1 | Offline agent app with a guided step-by-step flow that can be paused and resumed | Onboarding | BO1 | Must | 1 |
| FR16.2 | Read-aloud audio for every screen and consent line in English, Shona, and Ndebele | Onboarding | BO1 | Must | 1 |
| FR16.3 | Consent capture with language, version, time, and agent ID, stored in the consent ledger (FR15.8) | Onboarding | All | Must | 1 |
| FR16.4 | A teach-back check that the agent must complete before basic consent is accepted | Onboarding | All | Should | 1 |
| FR16.5 | GPS boundary capture with an accuracy indicator and a warning when accuracy is poor | Onboarding | BO1 | Must | 1 |
| FR16.6 | Role questions that start each role's verification path and show what is still needed (FR13.4) | Onboarding | BO1 | Must | 1 |
| FR16.7 | Household and shared-phone setup with a separate PIN per person (FR13.13) | Onboarding | BO1 | Must | 1 |
| FR16.8 | SMS or printed confirmation slip with the farmer's ID, language, and helpline | Onboarding | BO1 | Should | 1 |
| FR16.9 | Agent dashboard showing onboardings, completion rate, verification level reached, and quality-check results | Onboarding | BO1 | Should | 1 |
| NFR1 | Offline-first. Module 1's core farm profiling and feasibility generation must function without network connectivity | Platform (Non-Functional) | BO1 | Must | 1 |
| NFR2 | Security. Digital contracts and biometric data must be cryptographically secured end to end | Platform (Non-Functional) | All | Must | 1 |
| NFR3 | Localization. All contract terms and key UI content available in Shona and Ndebele, in addition to English | Platform (Non-Functional) | BO1 | Must | 1 |
| NFR4 | Low-bandwidth resilience. Suitable for rural connectivity conditions typical of communal farming areas | Platform (Non-Functional) | BO1 | Must | 1 |
| NFR5 | Auditability. Grower registration, levy deductions, and compliance clearances must be traceable for regulatory audit | Platform (Non-Functional) | BO4 | Must | 2 |
| NFR6 | Interoperability. Must integrate with TIMB's existing Biometric Grower Registration System and mapping standards without… | Platform (Non-Functional) | BO3 | Must | 2 |
| NFR7 | Scalability. Cloud-native, multi-tenant architecture able to scale from a single pilot vertical (tobacco, Zimbabwe) to… | Platform (Non-Functional) | BO6 | Should | 1 |
| NFR8 | API-first design. Well-documented APIs for TIMB, banks, payment processors, and future third-party integrations | Platform (Non-Functional) | BO6 | Should | 2 |
| NFR9 | Data privacy & protection. Compliance with Zimbabwe's Cyber and Data Protection Act and relevant regional data-protection… | Platform (Non-Functional) | All | Must | 1 |
| NFR10 | Payment security. PCI-DSS-aligned handling for any card/mobile-money payment flows introduced by the ecommerce/marketplace layer | Platform (Non-Functional) | BO5 | Must | 3 |
| NFR11 | Role-based access control. Distinct permission levels for farmers, advisors, bankers, regulators, agents, and administrators | Platform (Non-Functional) | All | Must | 1 |
| NFR12 | Offline-sync conflict resolution. Deterministic merge rules when offline-captured farm/module data reconciles with the server… | Platform (Non-Functional) | BO1 | Must | 1 |
| NFR13 | Availability & disaster recovery. Defined uptime target for transacting modules (offtake sign-off, payments) plus… | Platform (Non-Functional) | All | Should | 3 |
| NFR14 | Analytics & reporting. Dashboards/exports to satisfy government and regulator statutory reporting obligations | Platform (Non-Functional) | BO4 | Should | 2 |
| NFR15 | Accessibility. Usable on low-cost Android devices and by low-literacy users | Platform (Non-Functional) | BO1 | Must | 1 |
| NFR16 | Multi-currency support. USD and local currency handling for financial and marketplace transactions | Platform (Non-Functional) | BO6 | Should | 3 |
| NFR17 | Erasure-compatible architecture, with personal data kept out of immutable ledgers (see GDPR section) | Platform (Non-Functional) | All | Must | 1 |
| NFR18 | Data protection impact assessment completed before each biometric or credit-scoring release | Platform (Non-Functional) | All | Must | 1 |
| NFR19 | Transfer register and Standard Contractual Clauses for EU-related data flows | Platform (Non-Functional) | All | Could | Post-pilot |
| FR5.1 | Consent capture and withdrawal for each data use, with a timestamped consent record | Privacy & Data Protection | All | Must | 1 |
| FR5.2 | Self-service data access, correction, export, and deletion requests | Privacy & Data Protection | All | Should | 2 |
| FR5.3 | Human review path and explanation view for any automated credit or compliance decision | Privacy & Data Protection | All | Should | 2 |
