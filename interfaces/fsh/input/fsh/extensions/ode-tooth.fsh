// ============================================================================
// Tooth designation extension. Applied on <resource>.bodySite (a CodeableConcept),
// so the context is Element (broad) to keep it usable across ServiceRequest,
// Procedure, and Observation bodySite.
// ============================================================================

Extension: ODETooth
Id: ode-tooth
Title: "Tooth designation"
Description: "Identifies a tooth by a recognized numbering system. Universal/National numbering is the ODE default; FDI Two-Digit (ISO 3950) is an alternate pending permission."
* ^context[+].type = #element
* ^context[=].expression = "Element"
* value[x] only CodeableConcept
* valueCodeableConcept from ODEToothVS (extensible)
