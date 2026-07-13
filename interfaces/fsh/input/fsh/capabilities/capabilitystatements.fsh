// ============================================================================
// The API contract — two actors.
//   ODEReferralRecipientServer : the dental ODE Native FHIR server (and what the
//                                360X bridge drives).
//   ODEReferralInitiatorClient : a medical/dental system (or the bridge on behalf
//                                of a 360X-only EHR) that creates referrals.
// ============================================================================

Instance: ODEReferralRecipientServer
InstanceOf: CapabilityStatement
Usage: #definition
* url = "https://oralhealthalliance.net/fhir/CapabilityStatement/ode-referral-recipient-server"
* name = "ODEReferralRecipientServer"
* title = "ODE Referral Recipient / Fulfiller — Server"
* status = #draft
* date = "2026-06-29"
* kind = #requirements
* fhirVersion = #4.0.1
* format[+] = #json
* format[+] = #xml
* rest.mode = #server
* rest.documentation = "Accepts referral transaction Bundles, exposes the ODE workflow Task and ServiceRequest for read/search/update, and serves supporting documents/images."
* rest.security.service = $smart#SMART-on-FHIR

// system-level: accept the referral as a transaction Bundle
* rest.interaction[+].code = #transaction
* rest.interaction[+].code = #batch

// Task — the ODE workflow object
* rest.resource[+].type = #Task
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-referral-task"
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #update
* rest.resource[=].interaction[+].code = #patch
* rest.resource[=].searchParam[+].name = "referral-id"
* rest.resource[=].searchParam[=].definition = "https://oralhealthalliance.net/fhir/SearchParameter/ode-referral-id"
* rest.resource[=].searchParam[=].type = #token
* rest.resource[=].searchParam[+].name = "status"
* rest.resource[=].searchParam[=].type = #token
* rest.resource[=].operation[+].name = "append-interim"
* rest.resource[=].operation[=].definition = "https://oralhealthalliance.net/fhir/OperationDefinition/ode-append-interim"
* rest.resource[=].operation[=].documentation = "Attach interim clinical content (Encounter, DiagnosticReport, Observation) to an open referral: creates the resources, attaches them to Task.output, and advances businessStatus (typically to interim-results). The ODE-native equivalent of a 360X PCC-59 Interim Consultation Note — usable with no bridge."

// ServiceRequest — the referral order (three directional profiles)
* rest.resource[+].type = #ServiceRequest
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-referral-servicerequest"
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-medical-to-dental-referral"
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-dental-to-dental-referral"
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-dental-to-medical-referral"
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].searchParam[+].name = "referral-id"
* rest.resource[=].searchParam[=].type = #token

// DocumentReference — supporting data / imaging (CDex-aligned)
* rest.resource[+].type = #DocumentReference
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-referral-documentreference"
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].operation[+].name = "submit-attachment"
* rest.resource[=].operation[=].definition = "http://hl7.org/fhir/us/davinci-cdex/OperationDefinition/submit-attachment"

// Patient + clinical context (US Core)
* rest.resource[+].type = #Patient
* rest.resource[=].supportedProfile = $ucPatient
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Medication list — US Core MedicationRequest entries, aggregated by an ODE List
* rest.resource[+].type = #MedicationRequest
* rest.resource[=].supportedProfile = $ucMedReq
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].searchParam[+].name = "patient"
* rest.resource[=].searchParam[=].type = #reference
* rest.resource[+].type = #List
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-medication-list"
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Clinical content — findings arising DURING a referral episode
* rest.resource[+].type = #Observation
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-observation"
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-periodontal-observation"
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[+].type = #DiagnosticReport
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-diagnosticreport"
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[+].type = #Encounter
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-encounter"
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Claims sharing — the non-financial, claims-ready package
* rest.resource[+].type = #ExplanationOfBenefit
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-dental-claim"
* rest.resource[=].documentation = "Non-financial claims-sharing package. NOT a claim submission: status=draft, outcome=queued, no pricing or adjudication. A receiving system constructs its own 837D / 837P / priced FHIR Claim from it."
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].searchParam[+].name = "patient"
* rest.resource[=].searchParam[=].type = #reference

// Notifications
* rest.resource[+].type = #Subscription
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read


Instance: ODEReferralInitiatorClient
InstanceOf: CapabilityStatement
Usage: #definition
* url = "https://oralhealthalliance.net/fhir/CapabilityStatement/ode-referral-initiator-client"
* name = "ODEReferralInitiatorClient"
* title = "ODE Referral Initiator — Client"
* status = #draft
* date = "2026-06-29"
* kind = #requirements
* fhirVersion = #4.0.1
* format[+] = #json
* format[+] = #xml
* rest.mode = #client
* rest.documentation = "Creates referrals (transaction Bundle), follows Task status by referral-id, subscribes to status changes, and sends/requests supporting data via CDex. The 360X bridge implements this client role for a 360X-only medical EHR."
* rest.security.service = $smart#SMART-on-FHIR
* rest.interaction[+].code = #transaction

* rest.resource[+].type = #ServiceRequest
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-medical-to-dental-referral"
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-dental-to-dental-referral"
* rest.resource[=].supportedProfile[+] = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-dental-to-medical-referral"
* rest.resource[=].interaction[+].code = #create

* rest.resource[+].type = #Task
* rest.resource[=].supportedProfile = "https://oralhealthalliance.net/fhir/StructureDefinition/ode-referral-task"
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].searchParam[+].name = "referral-id"
* rest.resource[=].searchParam[=].type = #token

* rest.resource[+].type = #DocumentReference
* rest.resource[=].operation[+].name = "submit-attachment"
* rest.resource[=].operation[=].definition = "http://hl7.org/fhir/us/davinci-cdex/OperationDefinition/submit-attachment"

* rest.resource[+].type = #Subscription
* rest.resource[=].interaction[+].code = #create
