// ============================================================================
// Search & notifications.
// NOTE: the SubscriptionTopic below is an R4B/R5 resource. To build it on R4,
// add the Topic-based Subscriptions Backport package to sushi-config.yaml
// dependencies. If you are not using it yet, comment the SubscriptionTopic out.
// ============================================================================

Instance: ode-referral-id
InstanceOf: SearchParameter
Usage: #definition
* url = "https://oralhealthalliance.net/fhir/SearchParameter/ode-referral-id"
* name = "ODEReferralId"
* status = #draft
* experimental = false
* description = "Search ServiceRequest and Task by the ODE referral identifier (system urn:ohia:referral-id)."
* code = #referral-id
* base[+] = #ServiceRequest
* base[+] = #Task
* type = #token
* expression = "ServiceRequest.identifier.where(system='urn:ohia:referral-id') | Task.identifier.where(system='urn:ohia:referral-id')"


Instance: ode-referral-status
InstanceOf: SubscriptionTopic
Usage: #definition
* url = "https://oralhealthalliance.net/fhir/SubscriptionTopic/ode-referral-status"
* status = #draft
* title = "ODE Referral Status Change"
* description = "Fires when an ODE Referral Task changes status or businessStatus — the trigger the bridge uses to emit the matching outbound 360X transaction (PCC-56/57/58/59)."
* resourceTrigger[+].resource = "http://hl7.org/fhir/StructureDefinition/Task"
* resourceTrigger[=].supportedInteraction[+] = #update
* resourceTrigger[=].queryCriteria.previous = "status"
* resourceTrigger[=].queryCriteria.current = "status"
