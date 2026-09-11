# Changelog

Tracks changes to the ODE interface across the four views, and promotions to
`staging-transition/`.

## [Unreleased]

### Changed — interface v0.3.0 → v0.4.0
Propagated across **all four views** + crosswalk. Implements Gap A + Gap B of ISSUE-002
(patient-submitted intraoral photo), surfaced by UC04a teledentistry.

- **New profile `ODEIntraoralPhotoDocumentReference`** (`Parent` US Core DocumentReference) —
  a patient-submitted, non-radiographic intraoral photograph captured on a phone/web app during
  a teledentistry encounter and conveyed with a dental→dental referral. Constrains
  `content.attachment.contentType` = `image/jpeg`, `type` = LOINC `72170-4` (Photographic
  image), `author` = Patient (patient-authored), and `context.encounter` = the virtual visit.
  Added to the `DocumentReference` `supportedProfile` in the CapabilityStatement, to the pull
  path (`GET /DocumentReference/{id}`), and rides in the referral submission Bundle
  `supportingInfo`.
- **`Media` deliberately not used** — removed in R5/R6 while `DocumentReference` is stable
  across the R4→R6 path, US Core profiles `DocumentReference` (there is no US Core Media
  profile), and the bytes survive a 360X/C-CDA bridge either way.
- **Normative R4 tooth-correlation pattern (Gap B)** — R4 `DocumentReference` has no
  `bodySite`, so the affected tooth is bound via a companion `ODEObservation` carrying
  `bodySite` (`ode-tooth`) **and** `derivedFrom` → the photo. Added `derivedFrom` (MS) +
  `^comment` to `ODEObservation` (FSH), a `derivedFrom` array to the OpenAPI/Swagger
  `ODEObservation` schema, and the pattern to the narrative and crosswalk.
- **Two new deferred gaps documented (not modeled)**: the patient-device → platform image
  *upload* path (no governing HL7 IG) and the expected 360X/C-CDA on-image body-site lossiness.
- Distinct from the DICOM radiograph path (`ImagingStudy` + WADO-RS), which is a separate
  artifact that appears only at the in-office visit.

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
