// ============================================================================
// $append-interim — attach interim clinical content to an open referral.
// The ODE-native equivalent of a 360X PCC-59 (Interim Consultation Note),
// usable directly with no bridge and no HL7 v2 message.
// ============================================================================

Instance: ode-append-interim
InstanceOf: OperationDefinition
Usage: #definition
* url = "https://oralhealthalliance.net/fhir/OperationDefinition/ode-append-interim"
* name = "ODEAppendInterim"
* title = "Append interim clinical content to a referral"
* status = #draft
* kind = #operation
* description = "Creates the supplied clinical resources (Encounter, DiagnosticReport, Observation, ...), attaches them to the referral Task's `output`, and advances `businessStatus` (typically to `interim-results`). This is the ODE-native equivalent of what a 360X bridge does for PCC-59 (Interim Consultation Note) — but usable directly, with no bridge or HL7 v2 message required. Use this when new clinical findings arise mid-referral; use the transaction Bundle POST for the INITIAL referral submission only."
* code = #append-interim
* resource = #Task
* system = false
* type = false
* instance = true

* parameter[+].name = #content
* parameter[=].use = #in
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "A collection Bundle of the interim clinical resources to attach (ODEEncounter, ODEDiagnosticReport, ODEObservation)."
* parameter[=].type = #Bundle

* parameter[+].name = #return
* parameter[=].use = #out
* parameter[=].min = 1
* parameter[=].max = "1"
* parameter[=].documentation = "The updated referral Task, with `output` populated and `businessStatus` advanced."
* parameter[=].type = #Task
