# ODE interface — four views, one contract

The ODE referral interface is maintained as **four views of the same interface**, for
stakeholders who develop differently. They are **not** merged; each is loaded/used
independently. This document is the crosswalk that keeps them **functionally equivalent**,
so a change to one is easy to mirror in the others during finalization.

| # | View | File | Audience |
|---|------|------|----------|
| 1 | IG-development narrative + illustrative FSH | `fhir-interfaces.md` | IG authors, standards reviewers |
| 2 | OpenAPI 3.0 contract | `openapi.yaml` | application / REST dev teams |
| 3 | Swagger UI rendering of view 2 | `ode-api-swagger.html` | anyone browsing the API |
| 4 | **Compilable IG source (this package)** | `input/fsh/**` + `sushi-config.yaml` | the FSH developer building the IG |

## Shared anchors (identical in all four)

| Anchor | Value |
|--------|-------|
| IG canonical (profiles, capabilities, search, subscription) | `https://oralhealthalliance.net/fhir` |
| Terminology namespace (CodeSystems / ValueSets) | `http://ohia-codes.org` |
| Referral identifier system | `urn:ohia:referral-id` |
| CDT system | `http://www.ada.org/cdt` |
| SNODENT system | `http://www.ada.org/snodent` |
| ICD-10-CM / CPT / HCPCS | `http://hl7.org/fhir/sid/icd-10-cm` · `http://www.ama-assn.org/go/cpt` · `https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets` |
| FHIR version | R4 (4.0.1); inherits US Core 6.1.0 |

## Profiles / structures

| Concept | View 1 (md) | View 2 (OpenAPI) | View 4 (FSH) |
|---------|-------------|------------------|--------------|
| Referral base | §4 `ODEReferralServiceRequest` | schema `ODEReferralBase` | `profiles/referrals.fsh` |
| Medical→dental | §2.2 / §4 | schema `ODEMedicalToDentalReferral` | `profiles/referrals.fsh` |
| Dental→dental | §2.3 / §4 | schema `ODEDentalToDentalReferral` | `profiles/referrals.fsh` |
| Dental→medical | §2.4 / §4 | schema `ODEDentalToMedicalReferral` | `profiles/referrals.fsh` |
| Workflow Task | §4 `ODEReferralTask` | schema `ODEReferralTask` | `profiles/workflow.fsh` |
| Supporting doc/imaging | §4 `ODEReferralDocumentReference` | `$submit-attachment` body / `DocumentReference` | `profiles/clinical.fsh` |
| Dental procedure (CDT) | §4 `ODEDentalProcedure` | (referenced) | `profiles/clinical.fsh` |
| Periodontal obs | §4 `ODEPeriodontalObservation` | (referenced) | `profiles/clinical.fsh` |
| Medication list | §4 `ODEMedicationList` | schema `ODEMedicationList` | `profiles/clinical.fsh` |
| Tooth extension | §4 `ode-tooth` | `bodySite.extension` in examples | `extensions/ode-tooth.fsh` |

## Directional coding — the crux (must match exactly)

| Direction | reasonCode (diagnosis) | code (service) | tooth `bodySite` | required in OpenAPI (`allOf` adds) | must-support in FSH |
|-----------|------------------------|----------------|------------------|-------------------------------------|---------------------|
| **medical→dental** | **ICD-10-CM MS** | **CPT/HCPCS MS; no CDT** | SHOULD | `reasonCode`, `code` | `reasonCode[icd10]`, `code.coding[cpt/hcpcs]` MS |
| **dental→dental** | SNOMED/clinical MS | **CDT MS; SNODENT should**; no medical codes | **MS (required)** | `code`, `bodySite` | `code.coding[cdt]` MS, `bodySite.extension[tooth]` 1..1 MS, `code.coding[snodent]` optional |
| **dental→medical** | **ICD-10-CM MS** | **CPT/HCPCS MS; SNODENT should; no CDT** | n/a | `reasonCode`, `code`, `supportingInfo` | `reasonCode[icd10]`, `code.coding[cpt/hcpcs]` MS, screening result in `supportingInfo` MS |

"Should-support" (SNODENT, pre-procedure risk observations) is modeled the same way in all
views: an **optional slice documented as SHOULD-populate**, because FHIR's only conformance
flag is Must Support.

## Operations ↔ REST endpoints

| Operation | View 1 (md §6) | View 2 (OpenAPI path) | View 4 (FSH capability) |
|-----------|----------------|------------------------|--------------------------|
| Submit referral (transaction Bundle) | §6.1 | `POST /` | `rest.interaction #transaction` |
| Follow status | §6.2 | `GET /Task?referral-id=` | Task `read`/`search-type` + `referral-id` |
| Advance workflow | §6.3 | `PUT` / `PATCH /Task/{id}` | Task `update`/`patch` |
| Imaging — dental→dental **pull** | §6.4 | `GET /DocumentReference/{id}` | DocumentReference `read`/`search` |
| Imaging — medical-side **push** | §6.4 | `POST /DocumentReference/$submit-attachment` | `operation submit-attachment` |
| Medication list | §6.5 | `GET /MedicationRequest?patient=` · `GET /List/{id}` | MedicationRequest + List `read`/`search` |
| Coverage & PA (reused Da Vinci) | §6.6 | (out of core paths) | (reused, not profiled) |
| Notifications | §5 | `POST /Subscription` | SubscriptionTopic + Subscription `create` |

## Terminology

| Artifact | View 1 (md §7) | View 4 (FSH) |
|----------|----------------|--------------|
| Sub-status CodeSystem + VS | present | `terminology/terminology.fsh` |
| Task-status loop VS | present | `terminology/terminology.fsh` |
| Dental procedure (CDT) VS | present | `terminology/terminology.fsh` |
| Tooth CodeSystem + VS | present | `terminology/terminology.fsh` |

## Deferred gaps (identical in all views)

Radiation dosimetry (DDC) for medical→dental clearance, and the AI screening-result shape
(Observation + RiskAssessment) that is must-support on `ODEDentalToMedicalReferral`, are
**intentionally unmodeled** pending agreement. FDI ISO 3950 tooth numbering is pending
permission. Any view that later models these must update the other three.

## Keeping the views in sync (finalization)

The interface is finalized when the four views agree on: (a) the profile set and their
parents, (b) the directional coding table above, (c) the must-support / required sets,
(d) the operation ↔ endpoint mapping, and (e) terminology URIs. When something changes,
update this crosswalk first, then propagate to whichever views are affected. `fhir-interfaces.md`
is the human source of intent; `input/fsh/**` is the machine source of truth once built.
