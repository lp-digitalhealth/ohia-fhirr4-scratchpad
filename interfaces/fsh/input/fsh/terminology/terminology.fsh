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


// ---------------------------------------------------------------------------
// TOOTH DESIGNATION — uses the REAL HL7 THO code system, not an ODE invention.
// http://terminology.hl7.org/CodeSystem/ADAUniversalToothDesignationSystem
// (ADA Universal/National numbering 1-32, deciduous A-T, supernumerary codes;
// backed by an ADA-HL7 Statement of Understanding.)
// The former interim `ohia-codes.org/CodeSystem/ode-tooth-universal` is RETIRED —
// ODE reuses published terminology rather than reinventing it. Confirmed with the
// ADA that FDI (ISO 3950) notation is not used for US dental data, so the FDI
// alternate is no longer a gap.
// ---------------------------------------------------------------------------

ValueSet: ODEToothVS
Id: ode-tooth-vs
Title: "ODE Tooth Designation (ADA Universal, via HL7 THO)"
Description: "Tooth designation using the ADA Universal/National Tooth Designation System as published in HL7 Terminology (THO). ODE does not define its own tooth code system."
* ^url = "http://ohia-codes.org/ValueSet/ode-tooth-vs"
* include codes from system $tooth


// Document type codes used on the 360X boundary are reused from LOINC:
//   57133-1  Referral Note      -> inbound  PCC-55
//   11488-4  Consultation Note  -> outbound PCC-57 / PCC-59


// ---------------------------------------------------------------------------
// CLAIMS SHARING terminology (reused from CARIN Blue Button / THO — not invented)
// ---------------------------------------------------------------------------

ValueSet: ODEClaimCareTeamRoleVS
Id: ode-claim-careteam-role-vs
Title: "ODE Claim Care Team Role"
Description: "Care-team roles on the claims-sharing EOB, from CARIN Blue Button. BOTH `referring` and `rendering`/`performing` are expected — their joint presence is the evidence of medical-dental care coordination that CMS and Humana each require."
* ^url = "http://ohia-codes.org/ValueSet/ode-claim-careteam-role-vs"
* include codes from system $c4bbRole

// Modifiers (e.g. KX) come from HCPCS Level II: $hcpcs
// Claim type comes from THO claim-type: $claimType
