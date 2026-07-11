// ============================================================================
// The referral family — base + three directional profiles.
// Coding is directional: each referral is coded for the world the RECEIVING
// clinician acts and bills in. (See INTERFACE-VIEWS.md §"Directional coding".)
// ============================================================================

Profile: ODEReferralServiceRequest
Parent: $ucServiceRequest
Id: ode-referral-servicerequest
Title: "ODE Referral (ServiceRequest)"
Description: "The dental-medical referral order, inheriting US Core ServiceRequest. The 360X bridge maps PCC-55 to this; ODE Native clients create it directly. Do not instantiate directly — use one of the three directional profiles."
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains referralId 1..1 MS
* identifier[referralId].system = $referralId (exactly)
* identifier[referralId].value 1..1 MS
* status MS
* intent = #order
* code 1..1 MS
* subject 1..1 MS
* subject only Reference($ucPatient)
* requester MS
* requester only Reference($ucPractitioner or $ucPractitionerRole or $ucOrganization)
* performerType MS
* reasonCode MS
* reasonReference MS
* supportingInfo MS
* supportingInfo only Reference(ODEReferralDocumentReference or $ucCondition or $ucDocRef)


Profile: ODEMedicalToDentalReferral
Parent: ODEReferralServiceRequest
Id: ode-medical-to-dental-referral
Title: "ODE Medical-to-Dental Referral"
Description: "A referral originating in a medical system. Medical billing codes are must-support so the dentist need not look them up or run a CDT crosswalk: reasonCode is ICD-10-CM, and any requested service is CPT/HCPCS. CDT is NOT must-support in this direction. Imaging follows as a separate $submit-attachment push (no inbound pull on the medical side)."
* reasonCode 1..* MS
* reasonCode ^slicing.discriminator.type = #value
* reasonCode ^slicing.discriminator.path = "coding.system"
* reasonCode ^slicing.rules = #open
* reasonCode contains icd10 1..* MS
* reasonCode[icd10].coding.system = $icd10cm (exactly)
* code MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cpt 0..* MS and hcpcs 0..* MS
* code.coding[cpt].system = $cpt (exactly)
* code.coding[hcpcs].system = $hcpcs (exactly)
* bodySite ^short = "SHOULD support — the medical sender often will not know the tooth"
* supportingInfo MS
* supportingInfo ^short = "MS: referral/clinical note (DocumentReference, LOINC 57133-1). Imaging is NOT embedded — it follows as a separate $submit-attachment push after this referral. Radiation dosimetry for clearance is required-when-applicable but UNMODELED (gap)."


Profile: ODEDentalToDentalReferral
Parent: ODEReferralServiceRequest
Id: ode-dental-to-dental-referral
Title: "ODE Dental-to-Dental Referral"
Description: "A dentist-to-dentist referral. CDT is the working vocabulary and is must-support on the requested service. SNODENT is should-support for diagnostic/clinical granularity — modeled as an optional (non-MS) slice documented as SHOULD, because FHIR has no native should-support flag. No medical codes are required. Supporting imaging uses support-a-pull (receiver retrieves via CDex)."
* code 1..1 MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cdt 1..* MS and snodent 0..*
* code.coding[cdt].system = $cdt (exactly)
* code.coding[snodent].system = $snodent (exactly)
* code.coding[snodent] ^short = "SHOULD support — SNODENT diagnostic/clinical detail (optional slice, not MS)"
* code.coding[snodent] ^comment = "Senders SHOULD populate SNODENT when available; receivers MUST NOT reject a referral that omits it. Represented as a non-must-support slice because FHIR's only conformance flag is Must Support."
* bodySite 1..* MS
* bodySite.extension contains ODETooth named tooth 1..1 MS
* bodySite ^short = "MS: the tooth (ode-tooth) is REQUIRED — you cannot extract 'a tooth'. Add arch/quadrant/surface per procedure class."
* reasonCode MS
* supportingInfo MS
* supportingInfo ^short = "MS: clinical note; periodontal charting when perio-relevant. Supporting imaging is referenced here and the RECEIVER supports a CDex pull to retrieve it (not required in the initial bundle)."
* supportingInfo ^comment = "Pre-procedure risk Observations (anticoagulation/INR, HbA1c, BP, pregnancy status, antiresorptive/bisphosphonate exposure) are SHOULD-populate: senders SHOULD include when available, receivers MUST support if present, not a hard reject. Prior authorization (PAS ClaimResponse) is MS where the payer requires PA."


Profile: ODEDentalToMedicalReferral
Parent: ODEReferralServiceRequest
Id: ode-dental-to-medical-referral
Title: "ODE Dental-to-Medical Referral"
Description: "A dentist refers to a physician (e.g. AI sleep-apnea screening to sleep medicine). The physician acts and bills medically, so medical codes are must-support and CDT is not; SNODENT is should-support to preserve the dental finding. The screening/finding result that motivated the referral travels in the referral. Imaging follows as a separate $submit-attachment push."
* reasonCode 1..* MS
* reasonCode ^slicing.discriminator.type = #value
* reasonCode ^slicing.discriminator.path = "coding.system"
* reasonCode ^slicing.rules = #open
* reasonCode contains icd10 1..* MS
* reasonCode[icd10].coding.system = $icd10cm (exactly)
* code MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cpt 0..* MS and hcpcs 0..* MS and snodent 0..*
* code.coding[cpt].system = $cpt (exactly)
* code.coding[hcpcs].system = $hcpcs (exactly)
* code.coding[snodent].system = $snodent (exactly)
* code.coding[snodent] ^short = "SHOULD support — SNODENT preserves the dental finding/origin (optional slice, not MS)"
* supportingInfo MS
* supportingInfo ^short = "MS: the screening/finding result — Observation (e.g. Epworth) + RiskAssessment (AI OSA risk) — plus the clinical note. AI-result shape is a gap. Supporting scan is delivered as a separate $submit-attachment push after the referral."
