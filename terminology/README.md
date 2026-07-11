# Terminology

Human reference for the code systems and value sets the ODE interface uses. The
**authoritative, buildable** terminology FSH lives in
[`../interfaces/fsh/input/fsh/terminology/terminology.fsh`](../interfaces/fsh/input/fsh/terminology/terminology.fsh);
this folder is the design-first drop zone for terminology discussion and tables.

## ODE-defined (published under `http://ohia-codes.org`)

| Artifact | Id | Notes |
|----------|----|-------|
| CodeSystem | `ode-referral-sub-status` | Task.businessStatus sub-states: received, triaged, scheduled, interim, no-show |
| ValueSet | `ode-referral-sub-status-vs` | all of the above |
| ValueSet | `ode-referral-task-status-vs` | the Task status loop subset (requested…failed) |
| ValueSet | `ode-dental-procedure-vs` | all CDT codes (by system; CDT is ADA-licensed) |
| CodeSystem | `ode-tooth-universal` | Universal/National numbering 1–32, A–T (FDI ISO 3950 pending permission) |
| ValueSet | `ode-tooth-vs` | the tooth codes |

## External systems (referenced, not defined)

| System | URI |
|--------|-----|
| CDT | `http://www.ada.org/cdt` |
| SNODENT | `http://www.ada.org/snodent` |
| ICD-10-CM | `http://hl7.org/fhir/sid/icd-10-cm` |
| CPT | `http://www.ama-assn.org/go/cpt` |
| HCPCS | `https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets` |
| Referral id | `urn:ohia:referral-id` |