# Evidence: ODEDentalClaim Is Sufficient to Generate Either Real-World Submission Path

**Companion to:** `design-rationale.md` (v2 — now includes `item.modifier`)
**Purpose:** not a form-field crosswalk this time — a field-by-field proof that every requirement CMS and Humana *actually state, in their own language*, is carried by a real, named element in the schema. If every row below has a ✅, the schema is provably sufficient to generate a compliant submission via either pathway; nothing downstream has to invent data that isn't already in the FHIR resource.

**Both source documents re-verified directly for this exercise, not recalled from memory:**
- CMS: `https://www.cms.gov/medicare/coverage/dental` and CMS Transmittal 12702 (Change Request 13649)
- Humana: `Claims Payment Policy — Dental Services Inextricably Linked to Medical Services` (Humana MA policy, effective 2025-01-01)

---

## The two real-world pathways, in the payers' own words

**CMS (flexible, provider chooses the claim form):**
> *"Use the appropriate CDT or CPT codes for the services you provide."*
> *"Starting July 1, 2025, you must use the KX modifier to identify dental services inextricably linked to covered medical services."*
> *"Starting July 1, 2025, you must submit an ICD-10 code on the dental (837D or 2024 ADA) claim form."*

**Humana (fixed, one specific requirement):**
> *"Humana Medicare Advantage (MA) plans require providers to append modifier KX to a Current Dental Terminology (CDT) code to indicate that the dental service is inextricably linked to a covered medical service and that there has been integration between the medical and dental providers."*

---

## Requirement-by-requirement proof

| Real-world requirement, in the payer's own words | Who requires it | Schema field | Verified how |
|---|---|---|---|
| A CDT code for the service | CMS (if billing 837D) + Humana (always) | `item[].productOrService.coding[]` (CDT system) | Already in schema — must-support, CDT always present |
| A CPT/HCPCS code for the service | CMS (if billing 837P) | `item[].productOrService.coding[]` (CPT/HCPCS system, second coding in the same array) | Already in schema — present wherever a crosswalk is knowable |
| The KX modifier | CMS (either form) + Humana (mandatory) | `item[].modifier[]` | **Added this session** — real base FHIR element (`Claim.item.modifier` / `ExplanationOfBenefit.item.modifier`, confirmed against HL7's own R4 spec), not invented for this purpose |
| An ICD-10 diagnosis code | CMS (required on the dental form as of 2025-07-01) | `diagnosis[].diagnosisCodeableConcept` | Already in schema |
| Evidence the dental service is medically necessary and linked to a covered medical service | CMS + Humana (both require this as the substantive basis for KX) | `diagnosis[]` (the ICD-10 linkage itself) + the referral chain this profile is built from (UC01's `ClinicalImpression`/`ServiceRequest` already document the medical justification directly) | Already present — this is precisely what UC01's Interaction 3 clearance already produces |
| Evidence of care coordination between medical and dental providers | CMS + Humana (both name this explicitly as a requirement, not optional) | `careTeam[]` — both `referring` and `rendering` roles present, confirmed field-for-field against a real CARIN BB example | Already in schema |
| A specific claim form to route to (837D, 837P, or paper) | CMS (provider's choice); Humana (implicitly 837D, since they specify CDT) | Not a field in the schema — **deliberately**. Per this profile's own stated scope, format selection is downstream work for the receiving system, not something ODE decides on the provider's behalf | Confirmed as an intentional design boundary, not a gap |
| Billing/rendering provider identity, NPI | Both (standard on any claim form) | `provider` (top-level) + `careTeam[].provider` | Already in schema |

---

## What this proves

**Every substantive data requirement stated by either payer is now carried by a named field.** The only thing this schema deliberately does *not* decide is which claim form or which specific code system a given payer wants — and that's correct, not a gap: CMS itself doesn't fix this either (*"use the appropriate CDT or CPT codes"* — the provider's choice), so a schema that pre-decided it would be less correct, not more.

**The one real gap this exercise closed:** before this session, there was no field anywhere in the schema to carry the KX modifier — meaning a compliant submission literally could not have been generated from the prior version, for either CMS or Humana's pathway. `item.modifier` closes that.

## Resolved: the modifier code system URI

**Settled — the canonical HCPCS Level II system is `http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets`.**

Verified directly against the authoritative source: this is the **Official URL** on the HL7
Terminology (THO) CodeSystem `hcpcs-Level-II` (version 1.0.2, active as of 2023-10-11,
responsible party CMS, OID `2.16.840.1.113883.6.285`).

**Note the scheme: it is `http://`, not `https://`.** This matters and is easy to get wrong.
THO's own change history records a revision on **2023-11-13 — "Fix technical error with HCPCS
uri" (JIRA UP-472)** — which corrected the URI. Some older IGs and superseded THO versions
still display the `https://` form; that form was the error. Because FHIR system URIs are
exact-match strings, the two would **not** validate as the same code system.

This is now recorded as a project anchor in `../INTERFACE-VIEWS.md`, alongside the tooth,
CDT, and SNODENT systems, so implementers don't each guess.
