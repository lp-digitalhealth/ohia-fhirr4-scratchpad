// ============================================================================
// Tooth designation extension. Applied on <resource>.bodySite (a CodeableConcept),
// so the context is Element (broad) to keep it usable across ServiceRequest,
// Procedure, and Observation bodySite.
// ============================================================================

Extension: ODETooth
Id: ode-tooth
Title: "Tooth designation"
Description: "Identifies a tooth using the ADA Universal Tooth Designation System as published in HL7 Terminology (THO). ODE does not define its own tooth code system. Confirmed with the ADA that FDI (ISO 3950) notation is not used for US dental data."
* ^context[+].type = #element
* ^context[=].expression = "Element"
* value[x] only CodeableConcept
* valueCodeableConcept from ODEToothVS (required)
