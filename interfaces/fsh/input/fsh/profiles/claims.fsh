// ============================================================================
// CLAIMS SHARING — the second major profile of the ODE IG.
//
// The referral profiles carry CLINICAL data exchange. This one carries the
// claims-ready package a receiving system needs to construct a reimbursement
// submission (837D, 837P/CMS-1500, or a priced FHIR Claim).
//
// It is NON-FINANCIAL by design: status is always `draft`, outcome always
// `queued`, and there is no unitPrice / net / total / adjudication. ODE does not
// make pricing, adjudication, or claim-form decisions on an implementer's behalf.
// The shape is designed to accept financial elements later without restructuring.
//
// Derived from CARIN Blue Button's Professional/NonClinician Basis EOB profile,
// extended with the oral must-support elements: tooth bodySite and dual CDT+CPT
// coding.
// ============================================================================

Profile: ODEDentalClaim
Parent: $c4bbEOBProf
Id: ode-dental-claim
Title: "ODE Dental Claim (claims-sharing EOB)"
Description: "Non-financial, oral-optimized ExplanationOfBenefit. Derived from CARIN Blue Button's C4BB-ExplanationOfBenefit-Professional-NonClinician-Basis, extended with oral must-support elements. NOT a claim submission: status is always draft and outcome is always queued; no unitPrice/net/total/adjudication. CDT coding on item.productOrService is always required (HIPAA); CPT/HCPCS is included alongside it wherever a crosswalk is knowable. Tooth bodySite is required and uses the ADA Universal Tooth Designation System (HL7 THO)."

* status = #draft (exactly)
* status ^short = "Always 'draft' — this is not a submission."
* use = #claim (exactly)
* outcome = #queued (exactly)
* outcome ^short = "Always 'queued' — adjudication has not occurred."
* type MS
* type ^short = "Professional-oriented claim type per the base CARIN BB profile."

* patient 1..1 MS
* patient only Reference($ucPatient)
* insurer 1..1 MS
* provider 1..1 MS
* billablePeriod MS
* created MS

// Care coordination — CMS and Humana both require EVIDENCE of medical/dental coordination.
* careTeam 1..* MS
* careTeam.provider 1..1 MS
* careTeam.role 1..1 MS
* careTeam.role from ODEClaimCareTeamRoleVS (extensible)
* careTeam ^short = "MUST include both the referring and the rendering/performing roles — this is the evidence of medical-dental care coordination that CMS and Humana each require."

// Diagnosis — CMS requires an ICD-10 code on the dental claim form as of 2025-07-01.
* diagnosis MS
* diagnosis.diagnosisCodeableConcept MS
* diagnosis ^short = "Always present when known. REQUIRED when the receiving payer is medical (CMS requires ICD-10 on the dental claim form as of 2025-07-01); payer's-discretion for dental-only payers."

* insurance MS
* insurance.focal MS
* insurance.coverage MS
* insurance.coverage only Reference($ucCoverage)

* supportingInfo MS
* supportingInfo ^short = "Includes servicefacility (CMS-1500 Box 32)."

// ---- Service lines ----
* item 1..* MS
* item.sequence 1..1 MS

// Dual coding: CDT is always required (HIPAA); CPT/HCPCS rides alongside where knowable.
* item.productOrService 1..1 MS
* item.productOrService.coding ^slicing.discriminator.type = #value
* item.productOrService.coding ^slicing.discriminator.path = "system"
* item.productOrService.coding ^slicing.rules = #open
* item.productOrService.coding contains cdt 1..1 MS and cpt 0..* MS and hcpcs 0..*
* item.productOrService.coding[cdt].system = $cdt (exactly)
* item.productOrService.coding[cdt] ^short = "REQUIRED — a CDT coding is always present (HIPAA)."
* item.productOrService.coding[cpt].system = $cpt (exactly)
* item.productOrService.coding[cpt] ^short = "SHOULD be included alongside CDT wherever a crosswalk is knowable — this is what lets a medical payer adjudicate."
* item.productOrService.coding[hcpcs].system = $hcpcs (exactly)

// Tooth — the oral extension of the CARIN BB base. REAL HL7 THO code system.
* item.bodySite 1..1 MS
* item.bodySite from ODEToothVS (required)
* item.bodySite ^short = "REQUIRED. ADA Universal Tooth Designation System (HL7 THO) — confirmed with the ADA that FDI notation is not used for US dental data."

* item.servicedDate MS
* item.locationCodeableConcept MS
* item.locationCodeableConcept ^short = "Place of service (CMS-1500 Box 24B)."

// Modifiers — carries KX. Real base FHIR element, not invented for this purpose.
* item.modifier MS
* item.modifier ^short = "Billing modifiers. Carries the KX modifier, which CMS requires (as of 2025-07-01) on whichever claim form is used, and which Humana MA requires appended to a CDT code, to indicate the dental service is inextricably linked to a covered medical service."

* item.quantity MS
* item.quantity ^short = "Count only — NOT pricing."

// Financial elements are intentionally absent in this iteration:
//   no item.unitPrice, item.net, total, or adjudication.
// The shape accepts them later without restructuring.
