# Changelog

Tracks changes to the ODE interface across the four views, and promotions to
`staging-transition/`.

## [Unreleased]

### Added — interface v0.3.0 → v0.4.0 · **Claims sharing** (the second profile family)
Propagated across all four views + crosswalk + agent files.

- **`ODEDentalClaim`** — a **non-financial, claims-ready ExplanationOfBenefit**, inheriting
  CARIN Blue Button's `C4BB-ExplanationOfBenefit-Professional-NonClinician-Basis` and
  extending it with the two oral elements the base lacks: **tooth `bodySite`** and **dual
  CDT+CPT coding**. `status` is always `draft`, `outcome` always `queued`; no
  `unitPrice`/`net`/`total`/`adjudication`. A receiving payer or clearinghouse builds its own
  837D / 837P / priced FHIR `Claim` from it.
- **`item.modifier`** — carries the **KX modifier**, which CMS requires (from 2025-07-01) on
  whichever claim form is used, and which Humana MA requires appended to a CDT code. Without
  it, a compliant submission could not be generated for **either** pathway.
- **`careTeam` with both `referring` and `rendering`** — their joint presence *is* the
  medical–dental care-coordination evidence CMS and Humana each require.
- **`diagnosis` required when the receiving payer is medical** (CMS requires ICD-10 on the
  dental claim form as of 2025-07-01).
- New endpoints `POST`/`GET /ExplanationOfBenefit`; new `Claims Sharing` tag.
- Supporting evidence added under `interfaces/claims/` (design rationale, CMS-1500 box-by-box
  crosswalk, and the CMS/Humana sufficiency proof).
- New dependency: `hl7.fhir.us.carin-bb`.

### Changed — tooth terminology now uses the real HL7 code system
- **`ode-tooth-universal` (our invented CodeSystem) is RETIRED.** ODE now uses
  **`http://terminology.hl7.org/CodeSystem/ADAUniversalToothDesignationSystem`** — the ADA
  Universal/National Tooth Designation System **as published in HL7 THO** (verified). ODE
  defines no tooth code system: we reuse published terminology rather than inventing it.
- This was surfaced by a QA finding: the incoming spec coded tooth #30 **two different ways**
  (the referral example used the OHIA system, the claims example used THO). Unified on THO.

### Fixed
- **FDI ISO 3950 gap — CLOSED.** Confirmed with the ADA that FDI notation is not used for US
  dental data. Removed from the deferred-gaps list.
- **HCPCS system URI settled — `http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets`.**
  Verified against the authoritative source: the *Official URL* on the HL7 THO CodeSystem
  `hcpcs-Level-II` (v1.0.2, OID 2.16.840.1.113883.6.285). It is **`http://`, not `https://`** —
  THO corrected this on 2023-11-13 ("Fix technical error with HCPCS uri", JIRA UP-472). The
  repo previously carried the `https://` form, which was the error; corrected across all four
  views, the crosswalk, and both agent files, with the rationale recorded so it is not
  "normalized" back. Recorded as a project anchor alongside the tooth, CDT, and SNODENT systems.
- Renamed the profile in the supporting claims docs from `ODEOralProfessionalEOB` to
  **`ODEDentalClaim`**, matching the interface views.

### Changed — interface v0.2.0 → v0.3.0 (from testing)
Propagated across **all four views** + crosswalk + agent files.

- **Interim clinical content** — new concern: findings arising *during* a referral episode
  (as opposed to the initial submission). New profiles `ODEObservation`,
  `ODEDiagnosticReport` (US Core DiagnosticReport **Note**), `ODEEncounter` (`basedOn` → the
  referral) — all inherit US Core.
- **New operation `$append-interim`** on Task: creates the resources, populates
  `Task.output`, advances `businessStatus` to `interim-results`. The **ODE-native equivalent
  of 360X PCC-59** (Interim Consultation Note) — usable with no bridge, no HL7 v2.
  Added `OperationDefinition/ode-append-interim`.
- **`Task.input` / `Task.output` / `Task.note`** — adopted COW scope. An **informal
  inter-provider information request** is a `Task.note` (the COW "letter" mechanism; the
  request has no dedicated resource).
- **New terminology**: `interim-results` businessStatus code.
- **Uncoded findings rule**: where no established code system exists, use `code.text` and do
  **not** fabricate a coding.
- **UC01 radiation dosimetry gap — RESOLVED by convention**: a site-specific dose is an
  `ODEObservation` with `code.text`, `valueQuantity` in Gy (UCUM), `bodySite` = the tooth,
  delivered via `$append-interim`. No new profile/extension.

### Fixed
- **`ODEEncounter.note` removed — FHIR R4 `Encounter` has no `note` element.** The informal
  information request is carried on `Task.note` (and/or `Observation.note`), both valid in
  R4. The `interimContentBundle` example already places the note on the Observation.

### Added
- Initial scaffolding: four synchronized views of the ODE referral interface under
  `interfaces/` (IG-dev narrative, OpenAPI, Swagger, FSH IG source), the parity crosswalk
  (`interfaces/INTERFACE-VIEWS.md`), the sync protocol (`CONTRIBUTING.md` + PR template),
  and the `staging-transition/` promotion target.

<!--
## [YYYY-MM-DD] — Promotion to staging-transition
### Promoted
- <change set> reached concurrence; FSH copied to staging-transition/.
### Changed
- <which views changed, and the interface change they represent>
-->
