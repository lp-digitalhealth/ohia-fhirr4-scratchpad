# Changelog

Tracks changes to the ODE interface across the four views, and promotions to
`staging-transition/`.

## [Unreleased]

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
