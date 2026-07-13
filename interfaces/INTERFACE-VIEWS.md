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
| **Tooth system** | `http://terminology.hl7.org/CodeSystem/ADAUniversalToothDesignationSystem` (**HL7 THO — ODE defines none**) |
| CARIN BB EOB parent | `.../C4BB-ExplanationOfBenefit-Professional-NonClinician-Basis` |
| SNODENT system | `http://www.ada.org/snodent` |
| ICD-10-CM / CPT / HCPCS | `http://hl7.org/fhir/sid/icd-10-cm` · `http://www.ama-assn.org/go/cpt` · `http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets` |
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
| **Claims sharing (EOB)** | §2.6 / §4 `ODEDentalClaim` | schema `ODEDentalClaim` | `profiles/claims.fsh` |
| **Interim Observation** | §2.5 / §4 `ODEObservation` | schema `ODEObservation` | `profiles/clinical.fsh` |
| **Interim DiagnosticReport** | §2.5 / §4 `ODEDiagnosticReport` | schema `ODEDiagnosticReport` | `profiles/clinical.fsh` |
| **Interim Encounter** | §2.5 / §4 `ODEEncounter` | schema `ODEEncounter` | `profiles/clinical.fsh` |

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
| **Attach interim content** | §2.5 / §6 | `POST /Task/{id}/$append-interim` | `operation append-interim` + `instances/append-interim-operation.fsh` |
| **Interim clinical CRUD** | §2.5 | `POST`/`GET /Observation`, `/DiagnosticReport`, `/Encounter` | Observation / DiagnosticReport / Encounter `create`,`read`,`search` |
| **Informal info request** (COW "letter") | §2.5 | `Task.note` | `Task.note` MS |
| **Share claims-ready package** | §2.6 / §6 | `POST`/`GET /ExplanationOfBenefit` | ExplanationOfBenefit `create`,`read`,`search` |
| Notifications | §5 | `POST /Subscription` | SubscriptionTopic + Subscription `create` |

## Terminology

> **HCPCS URI — settled, do not "fix".** The canonical is
> **`http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets`** — the *Official URL* on the
> HL7 THO CodeSystem `hcpcs-Level-II` (v1.0.2, OID 2.16.840.1.113883.6.285). **HCPCS is
> `http://`, not `https://`.** THO corrected this on 2023-11-13 ("Fix technical error with
> HCPCS uri", JIRA UP-472); older IGs still show the `https://` form, which was the error.
> FHIR system URIs are exact-match strings, so the two would not validate as the same system.


| Artifact | View 1 (md §7) | View 4 (FSH) |
|----------|----------------|--------------|
| Sub-status CodeSystem + VS | present | `terminology/terminology.fsh` |
| Task-status loop VS | present | `terminology/terminology.fsh` |
| Dental procedure (CDT) VS | present | `terminology/terminology.fsh` |
| Tooth CodeSystem + VS | present | `terminology/terminology.fsh` |

## Deferred gaps (identical in all views)

**Radiation dosimetry (DDC) — RESOLVED by convention.** A site-specific dose is an
`ODEObservation` with **`code.text`** (never a fabricated coding), `valueQuantity` in Gy
(UCUM), and `bodySite` = the tooth, delivered via `$append-interim`. No new profile. This is
the general rule for **any finding with no established code system**.

**FDI ISO 3950 — CLOSED.** Confirmed with the ADA that FDI notation is not used for US
dental data. ODE uses the **ADA Universal Tooth Designation System from HL7 THO**; the
interim `ohia-codes.org` tooth CodeSystem is **retired**.

Still open: the **AI screening-result shape** (Observation + RiskAssessment) that is
must-support on `ODEDentalToMedicalReferral`. Also open, from the claims crosswalk: secondary
coverage, diagnosis pointer (24E), the signature/consent boxes (12/13, 31), EPSDT (24H), and
prior-authorization number (23). Any view that later models these must update the other three.

## Keeping the views in sync (finalization)

The interface is finalized when the four views agree on: (a) the profile set and their
parents, (b) the directional coding table above, (c) the must-support / required sets,
(d) the operation ↔ endpoint mapping, and (e) terminology URIs. When something changes,
update this crosswalk first, then propagate to whichever views are affected. `fhir-interfaces.md`
is the human source of intent; `input/fsh/**` is the machine source of truth once built.
