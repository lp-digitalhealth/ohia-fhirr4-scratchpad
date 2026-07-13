# OHIA FHIR R4 Scratchpad — the Oral Health Data Exchange (ODE) interface

**Where the ODE interface gets designed, argued over, and agreed — before it becomes an Implementation Guide.**

Today, a patient is the integration engine between the dental office and the medical office. They carry the radiograph. They repeat the medication list. They relay what the oncologist said. This repository is where the coalition designs the interface that ends that — an open, FHIR-based referral loop between dental and medical care.

This is a **scratchpad**, not the IG. Nothing here is normative. Work here reaches consensus, and then the FHIR Shorthand is promoted to [`staging-transition/`](./staging-transition) on its way to the HL7 ballot. OHIA is an implementer coalition, not a standards development organization: **OHIA leads the work, HL7 owns the ballot.**

| | |
|---|---|
| **FHIR version** | R4 (`4.0.1`) |
| **Inherits** | US Core 6.1.0 |
| **Current interface version** | `0.3.0-draft` |
| **License** | [CC0 1.0](./LICENSE) — per HL7/FHIR IG convention |
| **Destination** | HL7 Oral Health Data Exchange IG (PIE Work Group, PSS-2714) |

---

## Start here — by role

| If you are… | Read this | Then |
|-------------|-----------|------|
| **New to ODE** | The two sections below: *What ODE is* and *The one rule that matters* | Skim [`use-cases/`](./use-cases) — the five scenarios that drive every design decision |
| **A REST / app developer** | [`interfaces/openapi.yaml`](./interfaces/openapi.yaml) | Open [`interfaces/ode-api-swagger.html`](./interfaces/ode-api-swagger.html) in a browser, or import the YAML into Postman / Stoplight |
| **An IG author or standards reviewer** | [`interfaces/fhir-interfaces.md`](./interfaces/fhir-interfaces.md) | It carries the rationale, the must-support tables, and the open gaps |
| **The FSH developer** | [`interfaces/fsh/`](./interfaces/fsh) | `cd interfaces/fsh && sushi .` |
| **A clinical / policy stakeholder** | *The model* section below | Comment on the must-support tables in [`interfaces/fhir-interfaces.md`](./interfaces/fhir-interfaces.md) — that's where the clinical judgment lives |
| **An AI coding agent** | [`CLAUDE.md`](./CLAUDE.md) or [`.cursor/rules/`](./.cursor/rules) | They encode the sync protocol and the invariants |

---

## What ODE is

The **Oral Health Data Exchange (ODE)** is a definitive data model for oral health — think of it as **"USCDI + Dental."** It is the oral-health analog of US Core: **almost every ODE profile inherits from a US Core profile** and adds only what dental requires. (Exactly two inherit base FHIR — `Task` and `List` — because US Core profiles neither.)

The workflow backbone is HL7 **Clinical Order Workflows (COW)**: a `Task` + `ServiceRequest` pattern. ODE harmonizes the ecosystem — US Core, Da Vinci (CRD / DTR / PAS / CDex / PDex / Plan-Net), CARIN Blue Button, SDC, Subscriptions, and SMART — into one coherent contract for dental–medical exchange. **We constrain upstream profiles; we do not reinvent them.**

FHIR here is **additive**. It extends proven EDI and IHE 360X infrastructure — it does not replace them.

---

## The one rule that matters

> **Each referral is coded for the world the *receiving clinician* acts and bills in — so they never have to look codes up.**

That single principle produces **three referral profiles**, one per direction that involves dental (the CARIN Blue Button pattern: not one profile, but a family, each with its own must-support).

| Direction | Profile | Coding must-support | Tooth | Imaging |
|-----------|---------|---------------------|-------|---------|
| **medical → dental** | `ODEMedicalToDentalReferral` | **ICD-10-CM + CPT/HCPCS**<br>*CDT is **not** must-support* | should | **separate push** |
| **dental → dental** | `ODEDentalToDentalReferral` | **CDT** must-support<br>SNODENT should · no medical codes required | **required** | **support-a-pull** |
| **dental → medical** | `ODEDentalToMedicalReferral` | **ICD-10-CM + CPT/HCPCS**<br>SNODENT should · screening result must-support | n/a | **separate push** |

**Why the asymmetry?** A medical system doesn't speak CDT and shouldn't have to — so a medical→dental referral carries the medical billing codes the dental provider needs. A dental→dental referral is CDT-native. And whenever the *receiver* is on the medical side, imaging is a separate push, because medical systems expose no inbound pull; only dental→dental can pull on demand.

**Why the tooth is required.** A table-top exercise asked a blunt question: *can a dental provider actually perform the service from what's documented?* For a dental→dental extraction, no — you cannot extract "a tooth." Tooth/site became must-support, along with supporting imaging and the pre-procedure risk observations. Each profile's must-support is designed to be a **performance layer**, not just an intake layer.

### Two conventions worth knowing

- **"Should-support."** FHIR has exactly one conformance flag: Must Support. Where ODE means *should*, it uses an **optional slice documented as SHOULD-populate** — senders should populate when available; receivers must support it if present and must not reject on absence. (SNODENT and the pre-procedure risk observations work this way.)
- **Uncoded findings.** Where **no established code system exists**, use `code.text` — **never fabricate a coding**. This is how site-specific radiation dosimetry is handled (an `ODEObservation` with `code.text`, a value in Gy, and the tooth as `bodySite`). An honest text finding beats an invented code; if a code system emerges later, it slots into `code.coding` with no breaking change.

### Content that arrives *after* the referral

The three profiles above govern the initial submission. Findings that arise **during** an episode attach to the open referral with **`$append-interim`** — which creates the resources, populates `Task.output`, and advances `businessStatus`. It's the **ODE-native equivalent of a 360X PCC-59** (Interim Consultation Note), usable with **no bridge and no HL7 v2**. An informal request for that data is simply a `Task.note` (the COW "letter" mechanism).

---

## The interface, as four synchronized views

The same interface, in four formats — so every stakeholder can work in the one they know. They are **not merged**. They are kept in sync.

| | View | File | Audience |
|---|------|------|----------|
| **1** | IG-development narrative *(+ illustrative FSH)* | [`interfaces/fhir-interfaces.md`](./interfaces/fhir-interfaces.md) | IG authors, standards reviewers — **the human source of intent** |
| **2** | OpenAPI 3.0 REST contract | [`interfaces/openapi.yaml`](./interfaces/openapi.yaml) | REST / application dev teams |
| **3** | Swagger UI | [`interfaces/ode-api-swagger.html`](./interfaces/ode-api-swagger.html) | anyone — open it in a browser. **Generated from view 2; never hand-edited** |
| **4** | Compilable FSH IG source | [`interfaces/fsh/`](./interfaces/fsh) | the FSH developer — **the machine source of truth**, and the only view promoted |
| — | **Parity crosswalk** | [`interfaces/INTERFACE-VIEWS.md`](./interfaces/INTERFACE-VIEWS.md) | the sync backbone — proves all four describe one interface |

---

## How we work

### The rule

> **No view changes alone.**

Change a view, and the same change propagates to the others. The crosswalk is how we prove it happened.

```
   edit a view ──► update INTERFACE-VIEWS.md ──► mirror to the other views ──► CONCURRENCE
                                                                                    │
                                                          manual promotion (FSH only)│
                                                                                    ▼
                                                                        staging-transition/
                                                                             (frozen)
```

1. **Edit** the view you're comfortable with, in a pull request. You don't have to be able to edit all four.
2. **Update the crosswalk** row(s) you touched in [`interfaces/INTERFACE-VIEWS.md`](./interfaces/INTERFACE-VIEWS.md).
3. **Flag** which other views need the same change — the [PR template](./.github/PULL_REQUEST_TEMPLATE.md) asks.
4. **Mirror.** If you changed the OpenAPI, regenerate the Swagger. If you changed a must-support, it lands in all four.
5. **Concurrence**, then a maintainer **manually copies the FSH** into `staging-transition/`. Only the FSH is promoted. Promotion is a decision, not an automation.

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the full protocol and view ownership.

### Invariants — never change these silently

| Anchor | Value |
|--------|-------|
| IG canonical | `https://oralhealthalliance.net/fhir` |
| Terminology namespace | `http://ohia-codes.org` |
| Referral identifier | `urn:ohia:referral-id` |
| CDT · SNODENT | `http://www.ada.org/cdt` · `http://www.ada.org/snodent` |
| ICD-10-CM · CPT · HCPCS | `http://hl7.org/fhir/sid/icd-10-cm` · `http://www.ama-assn.org/go/cpt` · `https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets` |

### Letting an agent do the syncing

The protocol is machine-readable. **Claude Code** reads [`CLAUDE.md`](./CLAUDE.md); **Cursor** reads [`.cursor/rules/`](./.cursor/rules). Both encode the invariants, the three directional profiles, the imaging rule, the should-support convention, and the gaps they must *not* invent shapes for. Ask for a change and they propagate it across all four views and update the crosswalk.

They enforce the protocol. **They don't own the decision** — review the PR. The table-top exercise that caught the missing tooth must-support is not something an agent would have done for you. Promotion stays human-only.

---

## Build the FSH

```bash
cd interfaces/fsh
sushi .
```

Requires **US Core 6.1.0** (declared in [`interfaces/fsh/sushi-config.yaml`](./interfaces/fsh/sushi-config.yaml)). Known finalization points are listed in [`interfaces/fsh/README.md`](./interfaces/fsh/README.md). The FSH must build before it is promoted.

---

## Repository structure

```
interfaces/            the interface, as four synchronized views — the consensus surface
  fhir-interfaces.md     view 1 · IG-development narrative
  openapi.yaml           view 2 · OpenAPI 3.0 contract
  ode-api-swagger.html   view 3 · Swagger UI (generated)
  fsh/                   view 4 · compilable FSH IG source  ← the only view promoted
  INTERFACE-VIEWS.md     the parity crosswalk
terminology/           code systems & value sets (human reference)
examples/              mock R4 payload instances
use-cases/             UC01–UC05 — the scenarios that drive the design
staging-transition/    landing zone for the agreed FSH. Frozen.
CLAUDE.md
.cursor/rules/         the sync protocol, encoded for AI coding agents
CONTRIBUTING.md        the protocol, for humans
CHANGELOG.md           what changed, and what's been promoted
```

---

## The five use cases

Every design decision traces back to one of these. They're in [`use-cases/`](./use-cases).

| | Scenario | Direction |
|---|----------|-----------|
| **UC01** | Head & neck cancer — dental clearance before radiation | medical → dental |
| **UC02** | Surgical extraction (Medicaid PA · commercial + implant) | dental → dental |
| **UC03** | Pediatric periodontitis & Type 1 diabetes, routed via an HIE | medical → dental |
| **UC04** | After-hours teledentistry referral (commercial · Medicaid) | dental → dental |
| **UC05** | AI sleep-apnea screening at a routine cleaning | dental → medical |

---

## Status

**Settled.** The three directional profiles and their must-support sets · the coding rule · the imaging push/pull asymmetry · tooth as must-support on dental→dental · the medication list · interim content and `$append-interim` · the uncoded-findings convention (which resolved the radiation-dosimetry question).

**Open.**
- **AI screening result** — the shape of the OSA risk score + facial-scan provenance (`Observation` + `RiskAssessment`). Must-support on `ODEDentalToMedicalReferral`; it currently blocks UC05.
- **FDI ISO 3950 tooth numbering** — an alternate to the Universal/National default, pending permission.

Please **don't invent shapes for the open items** — they're open on purpose.

---

## A note on language

Dental professionals are doctors. Throughout this repository we write **"dental and medical providers"** and **"dental and medical care."** We never contrast "dentists" with "doctors."

---

## The coalition

The Oral Health Interoperability Alliance is a multi-stakeholder coalition — dental practice management systems, clearinghouses, payers, HIEs, QHINs, standards bodies, patient advocacy and research organizations, and federal observers — advancing dental–medical interoperability through open, FHIR-based standards.

Competitors who don't always see eye to eye are aligned here. The standards are ready, the technology is ready. **This time is different.**

→ [oralhealthalliance.net](https://oralhealthalliance.net)
