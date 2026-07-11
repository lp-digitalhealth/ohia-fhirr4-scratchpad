// ============================================================================
// The ODE workflow object — the COW Task. One of only two ODE classes that
// inherit base FHIR (US Core has no Task profile); the other is List.
// ============================================================================

Profile: ODEReferralTask
Parent: Task
Id: ode-referral-task
Title: "ODE Referral Task (workflow)"
Description: "The ODE workflow object and single source of truth for referral state, inheriting base FHIR Task — one of only two ODE classes that do not inherit US Core, since US Core has no Task profile. ODE is a full extension of HL7 Clinical Order Workflows (COW). The bridge mirrors this Task to/from 360X transactions; it never invents state."
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains referralId 1..1 MS
* identifier[referralId].system = $referralId (exactly)
* identifier[referralId].value 1..1 MS
* status MS
* status from ODEReferralTaskStatusVS (required)
* businessStatus MS
* businessStatus from ODEReferralSubStatusVS (extensible)
* intent = #order
* code 1..1 MS
* code = $taskcode#fulfill
* focus 1..1 MS
* focus only Reference(ODEReferralServiceRequest)
* for 1..1 MS
* for only Reference($ucPatient)
* requester MS
* owner MS
* owner only Reference($ucPractitionerRole or $ucOrganization or $ucPractitioner)
* statusReason MS
* output MS
