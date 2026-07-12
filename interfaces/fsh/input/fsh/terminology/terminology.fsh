// ============================================================================
// Terminology. Published under the OHIA codes namespace (http://ohia-codes.org)
// via explicit ^url. CDT (http://www.ada.org/cdt) and SNODENT
// (http://www.ada.org/snodent) are external ADA systems, referenced not defined.
// ============================================================================

CodeSystem: ODEReferralSubStatus
Id: ode-referral-sub-status
Title: "ODE Referral Sub-Status"
* ^url = "http://ohia-codes.org/CodeSystem/ode-referral-sub-status"
* ^status = #draft
* ^content = #complete
* #received    "Received"     "Referral received, not yet triaged"
* #triaged     "Triaged"      "Clinically triaged"
* #scheduled   "Scheduled"    "Appointment scheduled"
* #interim     "Interim"      "Interim update issued"
* #interim-results "Interim results" "Interim clinical content attached to the open referral (via $append-interim)"
* #no-show     "No-show"      "Patient did not attend"

ValueSet: ODEReferralSubStatusVS
Id: ode-referral-sub-status-vs
Title: "ODE Referral Sub-Status Value Set"
* ^url = "http://ohia-codes.org/ValueSet/ode-referral-sub-status-vs"
* include codes from system ODEReferralSubStatus


ValueSet: ODEReferralTaskStatusVS
Id: ode-referral-task-status-vs
Title: "ODE Referral Task Status (loop subset)"
* ^url = "http://ohia-codes.org/ValueSet/ode-referral-task-status-vs"
* http://hl7.org/fhir/task-status#requested
* http://hl7.org/fhir/task-status#accepted
* http://hl7.org/fhir/task-status#in-progress
* http://hl7.org/fhir/task-status#completed
* http://hl7.org/fhir/task-status#rejected
* http://hl7.org/fhir/task-status#cancelled
* http://hl7.org/fhir/task-status#failed


ValueSet: ODEDentalProcedureVS
Id: ode-dental-procedure-vs
Title: "ODE Dental Procedure Codes (CDT)"
Description: "All CDT procedure codes. CDT is licensed by the ADA; the IG references the code system rather than enumerating codes. http://www.ada.org/cdt is the endorsed de facto system URI."
* ^url = "http://ohia-codes.org/ValueSet/ode-dental-procedure-vs"
* include codes from system $cdt


CodeSystem: ODEToothUniversal
Id: ode-tooth-universal
Title: "ODE Tooth — Universal/National Numbering"
Description: "Permanent teeth 1-32 and primary teeth A-T. Interim OHIA-published system; FDI ISO 3950 to be added pending permission. Fragment shown here — the published artifact enumerates the full 1-32 and A-T set."
* ^url = "http://ohia-codes.org/CodeSystem/ode-tooth-universal"
* ^status = #draft
* ^content = #fragment
* #1  "Tooth 1"  "Maxillary right third molar"
* #19 "Tooth 19" "Mandibular left first molar"
* #30 "Tooth 30" "Mandibular right first molar"

ValueSet: ODEToothVS
Id: ode-tooth-vs
Title: "ODE Tooth Value Set"
* ^url = "http://ohia-codes.org/ValueSet/ode-tooth-vs"
* include codes from system ODEToothUniversal

// Document type codes used on the 360X boundary are reused from LOINC:
//   57133-1  Referral Note      -> inbound  PCC-55
//   11488-4  Consultation Note  -> outbound PCC-57 / PCC-59
