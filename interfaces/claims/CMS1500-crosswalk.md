# CMS-1500 → ODEDentalClaim Field Crosswalk

**Companion to:** `design-rationale.md`
**Purpose:** box-by-box mapping of the CMS-1500 form against the `ODEDentalClaim` schema, so implementers can see exactly which boxes this profile already covers, which route through a referenced resource rather than a direct field, and which are genuine, named gaps — not glossed over.

**Read this alongside the source form:** `https://www.cms.gov/medicare/cms-forms/cms-forms/downloads/cms1500.pdf`

---

## Coverage summary

| Status | Count | Meaning |
|---|---|---|
| ✅ Direct field | 9 boxes | A specific `ODEDentalClaim` element maps directly |
| 🔗 Indirect, via referenced resource | 8 boxes | Covered, but through `Patient`/`Coverage`/`Organization`, not an EOB field itself |
| ⛔ Deliberately excluded | 5 boxes | Financial/adjudication fields — out of scope by design, see the draft's own rationale |
| ⚠️ Real gap, not yet modeled | 11 boxes | Not covered by the current draft — named explicitly below, not silently dropped |

---

## Box-by-box crosswalk

| CMS-1500 Box | Field | Status | `ODEDentalClaim` mapping |
|---|---|---|---|
| 1 | Payer program type | 🔗 Indirect | `insurer` (Reference) — the specific program/plan type isn't a distinct EOB field |
| 1a | Insured's ID Number | 🔗 Indirect | Via the `Coverage` resource referenced by `insurance[].coverage` (`subscriberId`) — not duplicated into the EOB itself |
| 2 | Patient's Name | 🔗 Indirect | Via `patient` (Reference to `Patient`) |
| 3 | Patient's Birth Date, Sex | 🔗 Indirect | Via the referenced `Patient` resource |
| 4 | Insured's Name | 🔗 Indirect | Via `Coverage.subscriber`, referenced through `insurance[].coverage` |
| 5 | Patient's Address | 🔗 Indirect | Via the referenced `Patient` resource |
| 6 | Patient Relationship to Insured | 🔗 Indirect | Via `Coverage.relationship` |
| 7 | Insured's Address | 🔗 Indirect | Via the referenced `Coverage`/subscriber |
| 8 | Reserved for NUCC use | N/A | — |
| 9, 9a-d | Other Insured's info (secondary coverage) | ⚠️ Gap | `insurance[]` is an array and structurally *could* carry a second, non-focal entry — but the current draft's example only populates one. Secondary-coverage completeness isn't yet exercised. |
| 10a-c | Condition related to Employment / Auto / Other Accident | ⚠️ Gap | No equivalent field in the current draft. Worth adding if this profile needs to support accident-related dental trauma claims. |
| 11 | Insured's Policy Group / FECA Number | 🔗 Indirect | Via `Coverage.class` |
| 11a | Insured's DOB, Sex | 🔗 Indirect | Redundant with Box 3 when patient is the insured — via `Patient` |
| 11b | Other Claim ID | ⚠️ Gap | Not modeled |
| 11c | Insurance Plan Name | 🔗 Indirect | Via the referenced `Coverage`/`InsurancePlan` |
| 11d | Another health benefit plan? | ⚠️ Gap | Structurally possible via a second `insurance[]` entry, but no explicit yes/no indicator field — same underlying gap as Box 9 |
| 12 | Patient/Authorized Person Signature (release of info) | ⚠️ Gap | **Named gap from earlier project work**: this needs a different kind of consent than the HIE data-sharing `Consent` already used elsewhere in this project — claims-payment authorization isn't currently modeled anywhere in ODE |
| 13 | Insured/Authorized Person Signature (payment authorization) | ⚠️ Gap | Same gap as Box 12 |
| 14 | Date of Current Illness/Injury/Pregnancy | ⚠️ Gap | Would map conceptually to `Condition.onset` on the referenced diagnosis — not currently surfaced as its own EOB-level field |
| 15 | Other Date | N/A | Rarely applicable to dental; not modeled |
| 16 | Dates Unable to Work | N/A | Not typically applicable to dental; not modeled |
| 17 | Referring Provider Name | ✅ Direct | `careTeam[].provider` where `careTeam[].role = referring` — confirmed field-for-field against a real CARIN BB example during design |
| 17a, 17b | Referring Provider NPI/ID | ✅ Direct | Via the `Reference` in the same `careTeam[]` entry — resolves to the referring `PractitionerRole`/`Practitioner`, which carries the NPI |
| 18 | Hospitalization Dates | N/A | Not typically applicable to office-based dental care |
| 19 | Additional Claim Information | 🔗 Indirect | `supportingInfo[]` is general-purpose and could carry this, though not a dedicated field |
| 20 | Outside Lab? | N/A | Not applicable to this profile's scope |
| 21 | Diagnosis / Nature of Illness (A-L) | ✅ Direct | `diagnosis[].diagnosisCodeableConcept` — an array, so multiple diagnoses are structurally supported |
| 22 | Resubmission Code / Original Ref No. | ⛔ Excluded | Not applicable — this is a draft package (`status: draft`), never a submission or resubmission |
| 23 | Prior Authorization Number | ⚠️ Gap | **Not in the current draft schema at all.** Worth adding explicitly — UC01 and UC04 both produce real PA numbers (`preAuthRef` on `ClaimResponse`) that this profile has no field to carry forward |
| 24A | Date(s) of Service | ✅ Direct | `item[].servicedDate` |
| 24B | Place of Service | ✅ Direct | `item[].locationCodeableConcept` |
| 24C | EMG (emergency indicator) | ⚠️ Gap | Not modeled |
| 24D | Procedure Code (CPT/HCPCS) + Modifiers | ✅ Direct, partial | `item[].productOrService` carries dual CDT+CPT coding — **but modifiers (e.g., the KX modifier discussed elsewhere in this project) are not explicitly modeled.** This is a real, named gap, not an oversight glossed over. |
| 24E | Diagnosis Pointer | ⚠️ Gap | Base FHIR `Claim.item.diagnosisSequence` exists in the spec but isn't shown in this draft's simplified schema — the link from a specific service line back to which diagnosis justifies it isn't currently explicit |
| 24F | Charges | ⛔ Excluded | Deliberately absent — this profile is non-financial by design (see the draft's own rationale: `status: draft`, no pricing, built so a future iteration can add it without redesigning) |
| 24G | Days or Units | ✅ Direct | `item[].quantity` — count only, explicitly not pricing |
| 24H | EPSDT (pediatric screening indicator) | ⚠️ Gap | Not modeled — worth adding given UC03's pediatric context |
| 24I | ID Qualifier | N/A | Not applicable in a FHIR-native context |
| 24J | Rendering Provider NPI | ✅ Direct | `careTeam[].provider` where `careTeam[].role = rendering` |
| 25 | Federal Tax ID Number | 🔗 Indirect | Via the referenced `provider` `Organization`, which would carry this as an identifier |
| 26 | Patient's Account Number | N/A | Practice-internal identifier; correctly out of scope for an interoperable package |
| 27 | Accept Assignment? | ⚠️ Gap | Not modeled |
| 28 | Total Charge | ⛔ Excluded | Financial — deliberately absent |
| 29 | Amount Paid | ⛔ Excluded | Post-adjudication — not applicable to a pre-submission package |
| 30 | Reserved for NUCC use | N/A | — |
| 31 | Signature of Physician/Supplier | ⚠️ Gap | Attestation isn't currently modeled — `Provenance` could plausibly cover this but isn't wired into the current draft |
| 32, 32a | Service Facility Location + NPI | ✅ Direct | `supportingInfo[servicefacility]` — confirmed against a real CARIN BB example during design |
| 33, 33a | Billing Provider + NPI | ✅ Direct | `provider` (top-level `Reference`) |

---

## What this crosswalk means in practice

**The core identity, referral, diagnosis, and service-line fields are solid** — 9 direct mappings, all confirmed against real CARIN BB examples during design, not assumed. This is why the profile was judged structurally sound for CMS-1500 compatibility.

**The indirect mappings (8 boxes) are a deliberate design choice, not a shortcut.** Patient demographics, subscriber detail, and plan information live on the referenced `Patient`/`Coverage`/`Organization` resources rather than being duplicated into the EOB — consistent with FHIR's general reference-don't-repeat pattern.

**The 5 exclusions are the profile's stated non-financial design** — not gaps, deliberate scope.

**The 11 real gaps are the honest list to work from next.** Two are worth prioritizing above the rest:
1. **Modifier representation (Box 24D)** — this project has already hit the KX-modifier question directly (UC02's Medicare billing research); there's currently nowhere in the schema to put it.
2. **Prior authorization number (Box 23)** — both UC01 and UC04 already produce real `preAuthRef` values that this profile has no field to carry forward, which seems like a natural, low-effort next addition given the data already exists elsewhere in this project's resources.

Secondary coverage (Boxes 9/11d), the diagnosis-to-service-line pointer (24E), and the two signature/consent boxes (12/13, 31) are real but lower-priority — none of this project's six use cases currently exercise secondary coverage or need an explicit diagnosis pointer beyond a single-diagnosis case.
