// ============================================================================
// Clinical profiles that accompany the referral. All inherit US Core except
// ODEMedicationList (base FHIR List — US Core has no List profile).
// ============================================================================

Profile: ODEReferralDocumentReference
Parent: $ucDocRef
Id: ode-referral-documentreference
Title: "ODE Referral DocumentReference (supporting data / imaging)"
Description: "Supporting documents and images for a referral, modeled on CDex provider-to-provider exchange. attachment.data carries small inline bytes; attachment.url is a retrievable pointer (FHIR Binary, an ImagingStudy/WADO-RS endpoint for DICOM, or a bridge capability link). Large DICOM uses ImagingStudy + WADO-RS, never inline."
* category MS
* type MS
* content 1..* MS
* content.attachment MS
* content.attachment.contentType 1..1 MS
* content.attachment.data MS
* content.attachment.url MS
* context MS


Profile: ODEDentalProcedure
Parent: $ucProcedure
Id: ode-dental-procedure
Title: "ODE Dental Procedure (CDT)"
Description: "A completed/planned dental procedure coded in CDT, optionally tooth-specific. CDT is must-support for dental-to-dental exchange; for medical-context procedures (medical->dental), use US Core Procedure with CPT/HCPCS. Carried as structured data on ODE Native; degraded to C-CDA narrative across the 360X bridge (loss profile)."
* code from ODEDentalProcedureVS (extensible)
* code.coding 1..* MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cdt 0..* MS
* code.coding[cdt].system = $cdt (exactly)
* bodySite MS
* bodySite.extension contains ODETooth named tooth 0..1 MS


Profile: ODEPeriodontalObservation
Parent: $ucObs
Id: ode-periodontal-observation
Title: "ODE Periodontal Observation"
Description: "A tooth- or site-specific periodontal measurement (e.g., probing depth, attachment loss), inheriting US Core Observation Clinical Result. Structured on ODE Native; narrative-only across the bridge."
* status MS
* category MS
* code 1..1 MS
* subject 1..1 MS
* subject only Reference($ucPatient)
* bodySite MS
* bodySite.extension contains ODETooth named tooth 0..1 MS
* value[x] MS
* value[x] only Quantity or CodeableConcept


Profile: ODEMedicationList
Parent: List
Id: ode-medication-list
Title: "ODE Medication List"
Description: "A point-in-time medication list conveyed with a referral so the receiving dentist/physician has the patient's current medications before the encounter (e.g. surgical-risk review). Inherits base FHIR List — the second of the two ODE classes that do not inherit US Core, since US Core has no List profile. Entries reference the patient's active medications as US Core MedicationRequest — ordered, or patient-reported via reportedBoolean. MedicationStatement is accepted where a source system conveys patient-reported history that way."
* status = #current
* mode = #snapshot
* code 1..1 MS
* code = $loinc#10160-0
* subject 1..1 MS
* subject only Reference($ucPatient)
* date MS
* source MS
* entry MS
* entry.item 1..1 MS
* entry.item only Reference($ucMedReq or MedicationStatement)
