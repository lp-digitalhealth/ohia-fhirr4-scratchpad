# CLAUDE.md — agent instructions for this repo

Read this before changing anything. This repo's whole purpose is that **four views describe
ONE interface**. Your primary job when editing is to keep them in sync.

## What this repo is

Design-first scratchpad for the **Oral Health Data Exchange (ODE)** referral interface.
FHIR **R4 (4.0.1)**, inheriting **US Core 6.1.0**. Nothing here is normative until it is
promoted to `staging-transition/`.

## The four views (same interface, different formats)

| View | File | Notes |
|------|------|-------|
| 1 — IG-dev narrative + illustrative FSH | `interfaces/fhir-interfaces.md` | human source of *intent* |
| 2 — OpenAPI 3.0 REST contract | `interfaces/openapi.yaml` | for REST dev teams |
| 3 — Swagger UI | `interfaces/ode-api-swagger.html` | **generated from view 2 — never hand-edit** |
| 4 — FSH IG source | `interfaces/fsh/` (`sushi-config.yaml` + `input/fsh/**`) | machine source of *truth*; the only view promoted |
| — Crosswalk | `interfaces/INTERFACE-VIEWS.md` | the sync backbone; **every change updates this** |

## THE RULE

> **No view changes alone.**

When asked to change the interface:

1. Make the change in the view(s) named.
2. **Propagate the same change to all other affected views** — do not stop at one.
3. Update the affected row(s) of `interfaces/INTERFACE-VIEWS.md`.
4. If `openapi.yaml` changed, regenerate `ode-api-swagger.html` (it embeds the spec as JSON
   in a `var spec = {...}` block; keep the multi-CDN loader and the static fallback intact).
5. Report a short diff summary: what changed, in which views, and anything still unsynced.

If a request would change only one view and leave the others inconsistent, **say so and
propose the full set of edits** rather than silently making a partial change.

## Invariants — never change these silently

Shared anchors (identical in all four views):

| Anchor | Value |
|--------|-------|
| IG canonical | `https://oralhealthalliance.net/fhir` |
| Terminology namespace | `http://ohia-codes.org` |
| Referral identifier system | `urn:ohia:referral-id` |
| CDT | `http://www.ada.org/cdt` |
| SNODENT | `http://www.ada.org/snodent` |
| ICD-10-CM | `http://hl7.org/fhir/sid/icd-10-cm` |
| CPT | `http://www.ama-assn.org/go/cpt` |
| HCPCS | `https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets` |
| FHIR version | R4 4.0.1 · US Core 6.1.0 |

## The model (get this right)

- ODE is **"USCDI + Dental"** — a definitive oral-health data model. **Almost every profile
  inherits from US Core.** Only two inherit base FHIR: **`Task`** (the HL7 COW workflow
  object) and **`List`** (the medication list) — because US Core profiles neither.
- **Three referral profiles**, one per direction (the CARIN Blue Button pattern), each with
  its **own must-support**:

| Direction | Profile | Coding must-support | Imaging |
|-----------|---------|---------------------|---------|
| medical → dental | `ODEMedicalToDentalReferral` | **ICD-10-CM + CPT/HCPCS**; **CDT NOT MS** | **separate push** (`$submit-attachment` after the referral) |
| dental → dental | `ODEDentalToDentalReferral` | **CDT MS**; **SNODENT should**; no medical codes required; **tooth `bodySite` MS (required)** | **support-a-pull** (receiver retrieves via CDex) |
| dental → medical | `ODEDentalToMedicalReferral` | **ICD-10-CM + CPT/HCPCS**; SNODENT should; CDT not MS; **screening result MS** | **separate push** |

- **Unifying rule:** each referral is coded for the world the **receiving clinician acts and
  bills in**, so they never have to look codes up. Whenever the **receiver is on the medical
  side**, imaging is a separate push (no inbound pull); only dental→dental pulls.
- **"Should-support"**: FHIR's only conformance flag is Must Support. A *should* obligation
  (SNODENT, pre-procedure risk observations) is modeled as an **optional (non-MS) slice
  documented as SHOULD-populate** — senders SHOULD populate, receivers MUST support if
  present and MUST NOT reject on absence. Preserve this convention.

## Interim clinical content (findings arising DURING the episode)

The three referral profiles govern the **initial submission** only. Findings that arise
after a referral is open are handled separately:

- `ODEEncounter` (US Core Encounter; `basedOn` → the referral), `ODEDiagnosticReport`
  (US Core DiagnosticReport Note), `ODEObservation` (US Core Observation Clinical Result).
- Attached via **`POST /Task/{id}/$append-interim`** → creates the resources, populates
  **`Task.output`**, advances **`businessStatus`** (typically `interim-results`). This is the
  **ODE-native equivalent of 360X PCC-59** — no bridge, no HL7 v2.
- `Task.input` / `Task.output` are **adopted COW scope**.
- An **informal information request** is a **`Task.note`** (the COW "letter" mechanism, one of
  three: RESTful query / letter / instruction). The request has **no dedicated resource**.
- **FHIR R4 `Encounter` has NO `note` element.** Never add one. Use `Task.note` or
  `Observation.note`.

## UNCODED FINDINGS — the rule

Where **no established code system exists** for a finding: use **`code.text`** and **do NOT
fabricate a coding**. This is how radiation dosimetry (UC01) is handled — an `ODEObservation`
with `code.text`, `valueQuantity` in Gy (UCUM), `bodySite` = the tooth. A convention, not a
profile: if a code system emerges it slots into `code.coding` with no breaking change.

## Deferred gaps — do NOT invent shapes for these

Leave as documented gaps unless explicitly asked to model them:
- **AI screening result** (Observation + RiskAssessment) — must-support on
  `ODEDentalToMedicalReferral`; blocks UC05.
- **FDI ISO 3950** tooth numbering (permission pending; Universal is the default).
- *(Radiation dosimetry is no longer a gap — see the uncoded-findings rule above.)*

## Conventions

- FHIR **R4** only. Do not introduce R5/R6 resources. (`SubscriptionTopic` is present as an
  R4 backport artifact — see `interfaces/fsh/sushi-config.yaml`.)
- Dental professionals ARE doctors — write "dental and medical providers/care"; never
  contrast "dentists" and "doctors."
- Terminology CodeSystems/ValueSets set an explicit `^url` under `http://ohia-codes.org`
  while the IG canonical differs — that mismatch is **intentional**; don't "fix" it.
- Don't hand-edit `interfaces/ode-api-swagger.html`; regenerate it from `openapi.yaml`.
- CDT is ADA-licensed: reference the code **system**, don't enumerate codes.

## Build check

```bash
cd interfaces/fsh && sushi .
```

FSH must build before promotion.

## Promotion (manual — never do this unprompted)

At concurrence, a **human maintainer** copies **only the FSH** (`interfaces/fsh/`) into
`staging-transition/`. Files there are frozen. Never promote on your own initiative; if you
believe a change set is ready, say so and let the maintainer decide.
