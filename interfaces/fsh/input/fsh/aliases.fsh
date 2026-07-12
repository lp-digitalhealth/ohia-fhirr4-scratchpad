// aliases.fsh — global aliases (SUSHI aliases are project-wide)
// Mirrors the alias block in fhir-interfaces.md exactly.

Alias: $sct          = http://snomed.info/sct
Alias: $loinc        = http://loinc.org
Alias: $cdt          = http://www.ada.org/cdt
Alias: $snodent      = http://www.ada.org/snodent
Alias: $icd10cm      = http://hl7.org/fhir/sid/icd-10-cm
Alias: $cpt          = http://www.ama-assn.org/go/cpt
Alias: $hcpcs        = https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets
Alias: $npi          = http://hl7.org/fhir/sid/us-npi
Alias: $taskcode     = http://hl7.org/fhir/CodeSystem/task-code
Alias: $smart        = http://terminology.hl7.org/CodeSystem/restful-security-service

// US Core 6.1.0 profiles (reused, not redefined)
Alias: $ucPatient          = http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient
Alias: $ucPractitioner     = http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitioner
Alias: $ucPractitionerRole = http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitionerrole
Alias: $ucOrganization     = http://hl7.org/fhir/us/core/StructureDefinition/us-core-organization
Alias: $ucProcedure        = http://hl7.org/fhir/us/core/StructureDefinition/us-core-procedure
Alias: $ucServiceRequest   = http://hl7.org/fhir/us/core/StructureDefinition/us-core-servicerequest
Alias: $ucCondition        = http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition-problems-health-concerns
Alias: $ucDocRef           = http://hl7.org/fhir/us/core/StructureDefinition/us-core-documentreference
Alias: $ucMedReq           = http://hl7.org/fhir/us/core/StructureDefinition/us-core-medicationrequest
Alias: $ucAllergy          = http://hl7.org/fhir/us/core/StructureDefinition/us-core-allergyintolerance
Alias: $ucCoverage         = http://hl7.org/fhir/us/core/StructureDefinition/us-core-coverage
Alias: $ucEncounter        = http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter
Alias: $ucProvenance       = http://hl7.org/fhir/us/core/StructureDefinition/us-core-provenance
Alias: $ucObs              = http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-clinical-result
Alias: $ucDiagReportNote   = http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-note

// ODE referral-id (matches the reference adapter)
Alias: $referralId   = urn:ohia:referral-id
