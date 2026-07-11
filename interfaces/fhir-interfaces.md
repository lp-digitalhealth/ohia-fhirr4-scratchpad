# ODE FHIR interfaces (IG conformance layer)

The **interfaces** an ODE implementer builds to: the **CapabilityStatements** (the RESTful
API contract), the **profiles** those interactions exchange, the **operations and
interactions** (referral submission, Task workflow, CDex attachments, Subscriptions), and
the **terminology**.

> **This is the IG-development deliverable.** The profiles below are written in **FHIR
> Shorthand (FSH)** so they read the way the authoritative SUSHI source will — they are
> *illustrative guidance for the IG developer*, close to compilable but not required to
> build as-is; the developer owns the final `input/fsh/`. A companion **OpenAPI / Swagger**
> document (`openapi.yaml`, plus `ode-api-swagger.html` to view it) expresses the same
> contract as REST endpoints for the application dev teams.

**What ODE is.** The Oral Health Data Exchange (ODE) IG is a **definitive data model for
oral health — think of it as "USCDI + Dental."** It is the oral-health analog of US Core:
**almost every ODE class inherits from a US Core profile** and adds only what dental
requires. Where US Core has no profile, ODE inherits base FHIR — that is true for exactly
two classes here: **`Task`** (the HL7 Clinical Order Workflows / COW workflow object) and
**`List`** (the medication list). The workflow backbone is COW's Task + ServiceRequest
pattern, and ODE **harmonizes the ecosystem IGs** — US Core, Da Vinci
(CRD/DTR/PAS/CDex/PDex/Plan-Net), CARIN Blue Button, SDC, the Subscriptions Backport, and
SMART — into one coherent contract for dental–medical exchange. OHIA is an implementer
coalition, not an SDO: ODE constrains upstream profiles, it does not re-invent them.

**Must-support, and it's directional.** A conformant ODE exchange has a defined set of
**must-support resources** (§2) — the referral workflow, the patient and providers, the
clinical context (diagnoses, the **medication list**, allergies, observations), procedures,
coverage, and supporting documents. The important subtlety is that **coding requirements
depend on referral direction**: a **medical→dental** referral must carry **medical billing
codes** (ICD-10-CM, CPT/HCPCS) so the dentist need not look them up, and **CDT is not
must-support** there; a **dental→dental** referral makes **CDT must-support** and **SNODENT
should-support**, with no medical codes required. §2 spells this out.

**Canonicals.** Interim ODE artifacts publish under the OHIA namespace; the eventual home
is the HL7 OHDE IG (PIE Work Group, PSS-2714). The referral-id system and CDT URI match the
reference adapter so spec and code agree.

```
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
Alias: $ucPatient         = http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient
Alias: $ucPractitioner    = http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitioner
Alias: $ucPractitionerRole= http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitionerrole
Alias: $ucOrganization    = http://hl7.org/fhir/us/core/StructureDefinition/us-core-organization
Alias: $ucProcedure       = http://hl7.org/fhir/us/core/StructureDefinition/us-core-procedure
Alias: $ucServiceRequest  = http://hl7.org/fhir/us/core/StructureDefinition/us-core-servicerequest
Alias: $ucCondition       = http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition-problems-health-concerns
Alias: $ucDocRef          = http://hl7.org/fhir/us/core/StructureDefinition/us-core-documentreference
Alias: $ucMedReq          = http://hl7.org/fhir/us/core/StructureDefinition/us-core-medicationrequest
Alias: $ucAllergy         = http://hl7.org/fhir/us/core/StructureDefinition/us-core-allergyintolerance
Alias: $ucCoverage        = http://hl7.org/fhir/us/core/StructureDefinition/us-core-coverage
Alias: $ucEncounter       = http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter
Alias: $ucProvenance      = http://hl7.org/fhir/us/core/StructureDefinition/us-core-provenance
Alias: $ucObs             = http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-clinical-result

// ODE referral-id (matches the reference adapter)
Alias: $referralId   = urn:ohia:referral-id
```

---

## 1. Reuse map — borrowed vs ODE-defined

| Need | Interface / profile | Source |
|------|--------------------|--------|
| Patient, Practitioner, Organization, PractitionerRole | US Core profiles | **reuse** US Core 6.1 |
| Problems, meds, allergies | US Core Condition / MedicationRequest / AllergyIntolerance | **reuse** US Core |
| Coverage / eligibility | US Core Coverage | **reuse** US Core |
| Coverage requirements / documentation | CRD (`order-sign` hook) / DTR Questionnaire | **reuse** Da Vinci |
| Prior authorization | PAS `Claim` / `ClaimResponse` | **reuse** Da Vinci |
| Provider directory | Plan-Net | **reuse** Da Vinci |
| Provider-to-provider data + attachments | CDex Task Data Request + `$submit-attachment` | **reuse** Da Vinci |
| Notifications | R4 Topic-based Subscriptions Backport | **reuse** HL7 |
| Authorization | SMART App Launch / Backend Services | **reuse** HL7 |
| **Referral order** | `ODEReferralServiceRequest` | **ODE** |
| **Referral — medical→dental** | `ODEMedicalToDentalReferral` (ICD-10-CM + CPT/HCPCS MS) | **ODE** |
| **Referral — dental→dental** | `ODEDentalToDentalReferral` (CDT MS) | **ODE** |
| **Referral — dental→medical** | `ODEDentalToMedicalReferral` (ICD-10-CM + CPT/HCPCS MS; SNODENT should) | **ODE** |
| **Referral workflow** (extends COW) | `ODEReferralTask` | **ODE** |
| **Supporting data / imaging** | `ODEReferralDocumentReference` | **ODE** (CDex-aligned) |
| **Dental procedure (CDT + tooth)** | `ODEDentalProcedure` | **ODE** |
| **Periodontal finding** | `ODEPeriodontalObservation` | **ODE** |
| **Medication list** | `ODEMedicationList` (List) + US Core MedicationRequest | **ODE** thin + **reuse** |
| **Tooth designation** | `ode-tooth` extension | **ODE** |
| Dosimetry / AI-screening result | *(deferred — see §9)* | **gap** |

---

## 2. Three referral profiles, each with its own must-support

Like **CARIN Blue Button** — which doesn't define one EOB profile but a family
(Inpatient, Outpatient, Pharmacy, Professional, **Oral**), each with must-support tuned to
that claim type — ODE defines **three referral profiles with different must-support sets**,
one per direction that involves dental:

- **`ODEMedicalToDentalReferral`** — a medical system refers *to* a dentist.
- **`ODEDentalToDentalReferral`** — a dentist refers *to* a dentist.
- **`ODEDentalToMedicalReferral`** — a dentist refers *to* a physician (e.g., UC05: an
  AI sleep-apnea screen at the chair → sleep medicine). *(Medical→medical is ordinary
  medical referral and out of ODE scope.)*

**The unifying rule:** each referral is coded for the world the **receiving clinician acts
and bills in**, so they never have to look codes up. Where a **medical** party acts/bills
(medical→dental clearance or DME; dental→medical) the **medical codes** (ICD-10-CM +
CPT/HCPCS) are must-support and CDT is not; where it's **dental→dental**, **CDT** is
must-support (SNODENT should). SNODENT rides along as should-support whenever a dental
finding needs to survive into a medical context.

The clinical resources (Patient, providers, medications, allergies, coverage, …) are a
**shared US-Core-inherited library** all three draw on (§2.1). What differs is the
**referral profile itself and the data that must accompany it** — because, as the table-top
made plain, *what the receiving clinician needs in order to **perform** differs by
direction.* A dental→dental extraction is useless without the **tooth** and a
**radiograph**; a medical→dental clearance is useless without the **diagnosis, medical
codes, and radiation dose**; a dental→medical screening referral is useless without the
**screening result and a medical reason the physician can act on**. Each profile's
must-support is therefore a **performance layer**, not just intake.

### 2.1 Shared foundation (all three profiles inherit these)

Almost every ODE class inherits a US Core profile; only `Task` and `List` inherit base FHIR.

| Resource | ODE profile | Inherits from |
|----------|-------------|---------------|
| `Task` | `ODEReferralTask` | base FHIR Task (COW) — *US Core has none* |
| `Patient` | *(US Core Patient)* | US Core Patient |
| `Practitioner` / `PractitionerRole` / `Organization` | *(US Core)* | US Core |
| `Coverage` | *(US Core Coverage)* | US Core Coverage |
| `Condition` | *(US Core Condition)* | US Core Condition |
| `MedicationRequest` + `List` | `ODEMedicationList` | US Core MedicationRequest; base FHIR List |
| `AllergyIntolerance` | *(US Core AllergyIntolerance)* | US Core AllergyIntolerance |
| `Observation` | `ODEPeriodontalObservation` | US Core Observation Clinical Result |
| `Procedure` | `ODEDentalProcedure` | US Core Procedure |
| `DocumentReference` | `ODEReferralDocumentReference` | US Core DocumentReference |
| `Encounter` / `Provenance` | *(US Core)* | US Core |

### 2.2 `ODEMedicalToDentalReferral` — must-support

Sender is a medical system; the goal is to give the dentist the medical context and the
codes to act and bill medically **without looking anything up**.

| Must-support | Requirement | Why (to perform) |
|--------------|-------------|------------------|
| `ServiceRequest.identifier` | referral-id (`urn:ohia:referral-id`) | correlate the loop |
| `ServiceRequest.reasonCode` | **ICD-10-CM MS** (+ SNOMED) | diagnosis / medical necessity |
| `ServiceRequest.code` | **CPT & HCPCS MS**; **CDT *not* MS** | the dentist bills the medical benefit with codes already supplied |
| `ServiceRequest.bodySite` (`ode-tooth`) | **SHOULD** | medical sender often won't know the tooth |
| `Condition` | **ICD-10-CM MS** | problem list driving the referral |
| clinical note (`DocumentReference`, LOINC 57133-1) | **MS** | the referring clinician's narrative |
| medication list, `AllergyIntolerance` | **MS** | pre-treatment safety |
| `Coverage` | **MS** | medical benefit context |
| imaging (`DocumentReference` / `ImagingStudy`) | **separate push** — a distinct CDex `$submit-attachment` transaction *after* the referral notification (correlated by referral-id) | *no inbound pull* on the medical side, so images can't be embedded-and-pulled; they follow as their own operation |
| **radiation dosimetry (clearance)** | **required-when-applicable — UNMODELED (gap, §9)** | clearance can't be completed without which teeth sit in ≥50 Gy fields |

### 2.3 `ODEDentalToDentalReferral` — must-support

Sender is a dentist; the receiving dentist must be able to **plan and cut**. This set is
deliberately heavier on procedure-critical data.

| Must-support | Requirement | Why (to perform) |
|--------------|-------------|------------------|
| `ServiceRequest.identifier` | referral-id | correlate the loop |
| `ServiceRequest.code` | **CDT MS**; **SNODENT SHOULD**; medical codes *not required* | the requested dental service |
| `ServiceRequest.bodySite` (`ode-tooth` + arch/quadrant/surface) | **MS** | *you cannot extract "a tooth"* — the #1 table-top gap, now required |
| `ServiceRequest.reasonCode` | SNOMED / clinical **MS** | indication |
| supporting imaging (`DocumentReference` / `ImagingStudy`) | **support-a-pull** — sender references it; **receiver MUST support retrieving it via CDex** (Task Data Request / read); not required in the initial bundle | roots, IAN canal, sinus, bone — no safe surgical plan without it, but dental↔dental can pull on demand |
| pre-procedure risk `Observation`s | **SHOULD-populate** (support-if-present, not a hard reject): anticoagulation/INR, HbA1c, BP, pregnancy status, **antiresorptive/bisphosphonate exposure** | bleeding, healing, and MRONJ risk determine whether the procedure is safe |
| periodontal charting (`ODEPeriodontalObservation`) | **MS when perio-relevant** | staging for perio/surgical referrals |
| clinical note (`DocumentReference`) | **MS** | narrative context |
| medication list, `AllergyIntolerance` | **MS** | surgical/anesthesia safety |
| `Coverage` + prior-auth (`ClaimResponse`, PAS) | **MS where the payer requires PA** | e.g. Medicaid — no auth, no procedure |

### 2.4 `ODEDentalToMedicalReferral` — must-support

Sender is a dentist; receiver is a physician (UC05: OSA screening → sleep medicine; also
oral-lesion → ENT, oral signs → PCP). The physician acts and bills **medically**, so the
dentist must hand over medical-usable codes and the **screening result** that motivated the
referral. This is the mirror of §2.2 with the dental origin preserved.

| Must-support | Requirement | Why (to perform) |
|--------------|-------------|------------------|
| `ServiceRequest.identifier` | referral-id | correlate the loop |
| `ServiceRequest.reasonCode` | **ICD-10-CM MS** (+ SNOMED) — e.g. suspected OSA / screening | the physician's medical necessity |
| `ServiceRequest.code` | **CPT/HCPCS MS** for the requested medical service (e.g. sleep study); **SNODENT SHOULD** (dental finding/origin); **CDT *not* MS** | the physician doesn't use CDT |
| **screening / finding result** (`Observation` + `RiskAssessment`) | **MS** — the AI OSA risk score, Epworth, etc. *(AI-result shape is a gap, §9)* | this *is* the substance of the referral |
| `Condition` | **ICD-10-CM MS** | the finding driving the referral |
| clinical note (`DocumentReference`) | **MS** | dentist's narrative |
| medication list, `AllergyIntolerance` | **MS** | clinical context |
| `Coverage` | **MS — cross-benefit** (the medical benefit; the return service, e.g. an oral appliance, bills as DME `E0486`) | the physician bills medical |
| supporting scan/imaging | **separate push** — the dental sender delivers the scan via a distinct `$submit-attachment` transaction after the referral (correlated by referral-id); the screening *result* travels in the referral | the medical receiver never has to implement a pull requester |

> **Imaging is handled per direction (decided).**
> **Dental→dental → support-a-pull:** sender references the image; the **receiver supports a
> CDex pull** (Task Data Request / read) — dental systems can serve a pull.
> **Medical→dental → separate push:** the medical side exposes **no inbound pull**, so
> images follow as a distinct `$submit-attachment` operation *after* the referral.
> **Dental→medical → separate push:** like medical→dental, the medical receiver exposes no
> pull, so the dental sender delivers the scan as a distinct `$submit-attachment` operation
> *after* the referral. (The screening *result* itself always travels **in** the referral.)

> **On "should-support" / "should-populate":** FHIR has one conformance flag — Must Support.
> ODE expresses a *should* obligation (SNODENT, the pre-procedure risk observations) as an
> **optional slice documented as SHOULD-populate**: senders SHOULD populate when available;
> receivers MUST support it if present and MUST NOT reject on absence.

All three profiles derive from the base `ODEReferralServiceRequest` (§4). The receiving
actor's CapabilityStatement declares which it supports.

---


## 3. The API contract — CapabilityStatements

Two actors. The **ODE Referral Recipient (Fulfiller) Server** is what a dental ODE Native
server (HAPI/OnyxOS) exposes and what the bridge drives. The **ODE Referral Initiator
Client** is what a medical/dental system (or the bridge, on behalf of a 360X EHR) uses to
create referrals and follow status.

### 3.1 Recipient / Fulfiller server (the primary interface)

```
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

// ServiceRequest — the referral order (directional profiles)
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

// Notifications
* rest.resource[+].type = #Subscription
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
```

### 3.2 Initiator client (summary)

A conformant initiator **SHALL** be able to: POST the referral transaction Bundle
(`ODEReferralServiceRequest` + `ODEReferralTask` + US Core context); read/search Task by
`referral-id` to follow status; create a Subscription on Task status; and use CDex
(`$submit-attachment` / Task Data Request) to send or request supporting data. The 360X
bridge implements exactly this client role on behalf of a 360X-only medical EHR.

---

## 4. ODE profiles (FSH)

```
Profile: ODEReferralServiceRequest
Parent: $ucServiceRequest
Id: ode-referral-servicerequest
Title: "ODE Referral (ServiceRequest)"
Description: "The dental–medical referral order, inheriting US Core ServiceRequest. The bridge maps 360X PCC-55 to this; ODE Native clients create it directly."
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains referralId 1..1 MS
* identifier[referralId].system = $referralId (exactly)
* identifier[referralId].value 1..1 MS
* status MS
* intent = #order
* code 1..1 MS
* subject 1..1 MS
* subject only Reference($ucPatient)
* requester MS
* requester only Reference($ucPractitioner or $ucPractitionerRole or $ucOrganization)
* performerType MS
* reasonCode MS
* reasonReference MS
* supportingInfo MS
* supportingInfo only Reference(ODEReferralDocumentReference or $ucCondition or $ucDocRef)
```

```
Profile: ODEMedicalToDentalReferral
Parent: ODEReferralServiceRequest
Id: ode-medical-to-dental-referral
Title: "ODE Medical-to-Dental Referral"
Description: "A referral originating in a medical system. Medical billing codes are must-support so the dentist need not look them up or run a CDT crosswalk: reasonCode is ICD-10-CM, and any requested service is CPT/HCPCS. CDT is NOT must-support in this direction."
* reasonCode 1..* MS
* reasonCode ^slicing.discriminator.type = #value
* reasonCode ^slicing.discriminator.path = "coding.system"
* reasonCode ^slicing.rules = #open
* reasonCode contains icd10 1..* MS
* reasonCode[icd10].coding.system = $icd10cm (exactly)
* code MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cpt 0..* MS and hcpcs 0..* MS
* code.coding[cpt].system = $cpt (exactly)
* code.coding[hcpcs].system = $hcpcs (exactly)
* bodySite ^short = "SHOULD support — the medical sender often will not know the tooth"
* supportingInfo MS
* supportingInfo ^short = "MS: referral/clinical note (DocumentReference, LOINC 57133-1). Imaging is NOT embedded here — it follows as a separate $submit-attachment push after this referral (no inbound pull on the medical side). Radiation dosimetry for clearance is required-when-applicable but UNMODELED — see §9."
```

```
Profile: ODEDentalToDentalReferral
Parent: ODEReferralServiceRequest
Id: ode-dental-to-dental-referral
Title: "ODE Dental-to-Dental Referral"
Description: "A dentist-to-dentist referral. CDT is the working vocabulary and is must-support on the requested service. SNODENT is should-support for diagnostic/clinical granularity — modeled as an optional (non-MS) slice documented as SHOULD, because FHIR has no native should-support flag. No medical codes are required in this direction."
* code 1..1 MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cdt 1..* MS and snodent 0..*
* code.coding[cdt].system = $cdt (exactly)
* code.coding[snodent].system = $snodent (exactly)
* code.coding[snodent] ^short = "SHOULD support — SNODENT diagnostic/clinical detail (optional slice, not MS)"
* code.coding[snodent] ^comment = "Senders SHOULD populate SNODENT when available; receivers MUST NOT reject a referral that omits it. Represented as a non-must-support slice because FHIR's only conformance flag is Must Support."
* bodySite 1..* MS
* bodySite.extension contains ODETooth named tooth 1..1 MS
* bodySite ^short = "MS: the tooth (ode-tooth) is REQUIRED — you cannot extract 'a tooth'. Add arch/quadrant/surface per procedure class."
* reasonCode MS
* supportingInfo MS
* supportingInfo ^short = "MS: clinical note; periodontal charting when perio-relevant. Supporting imaging is referenced here and the RECEIVER supports a CDex pull to retrieve it (not required in the initial bundle)."
* supportingInfo ^comment = "Pre-procedure risk Observations (anticoagulation/INR, HbA1c, BP, pregnancy status, antiresorptive/bisphosphonate exposure) are SHOULD-populate: senders SHOULD include when available, receivers MUST support if present, not a hard reject. Prior authorization (PAS ClaimResponse) is MS where the payer requires PA."
```

```
Profile: ODEDentalToMedicalReferral
Parent: ODEReferralServiceRequest
Id: ode-dental-to-medical-referral
Title: "ODE Dental-to-Medical Referral"
Description: "A dentist refers to a physician (e.g. AI sleep-apnea screening to sleep medicine). The physician acts and bills medically, so medical codes are must-support and CDT is not; SNODENT is should-support to preserve the dental finding. The screening/finding result that motivated the referral travels in the referral."
* reasonCode 1..* MS
* reasonCode ^slicing.discriminator.type = #value
* reasonCode ^slicing.discriminator.path = "coding.system"
* reasonCode ^slicing.rules = #open
* reasonCode contains icd10 1..* MS
* reasonCode[icd10].coding.system = $icd10cm (exactly)
* code MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cpt 0..* MS and hcpcs 0..* MS and snodent 0..*
* code.coding[cpt].system = $cpt (exactly)
* code.coding[hcpcs].system = $hcpcs (exactly)
* code.coding[snodent].system = $snodent (exactly)
* code.coding[snodent] ^short = "SHOULD support — SNODENT preserves the dental finding/origin (optional slice, not MS)"
* supportingInfo MS
* supportingInfo ^short = "MS: the screening/finding result — Observation (e.g. Epworth) + RiskAssessment (AI OSA risk) — plus the clinical note. AI-result shape is a gap (§9). Supporting scan is delivered as a separate $submit-attachment push after the referral."
```

```
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
```

```
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
```

```
Profile: ODEDentalProcedure
Parent: $ucProcedure
Id: ode-dental-procedure
Title: "ODE Dental Procedure (CDT)"
Description: "A completed/planned dental procedure coded in CDT, optionally tooth-specific. CDT is must-support for dental-to-dental exchange; for medical-context procedures (medical→dental), use US Core Procedure with CPT/HCPCS. Carried as structured data on ODE Native; degraded to C-CDA narrative across the 360X bridge (loss profile)."
* code from ODEDentalProcedureVS (extensible)
* code.coding 1..* MS
* code.coding ^slicing.discriminator.type = #value
* code.coding ^slicing.discriminator.path = "system"
* code.coding ^slicing.rules = #open
* code.coding contains cdt 0..* MS
* code.coding[cdt].system = $cdt (exactly)
* bodySite MS
* bodySite.extension contains ODETooth named tooth 0..1 MS
```

```
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
```

```
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
```

A concrete instance is in `spec/examples/ode-medication-list-example.json` — a collection
`Bundle` with the `List` plus three US Core `MedicationRequest` entries (one patient-reported).

```
Extension: ODETooth
Id: ode-tooth
Title: "Tooth designation"
Description: "Identifies a tooth by a recognized numbering system. Universal/National numbering is the ODE default; FDI Two-Digit (ISO 3950) is an alternate pending permission."
Context: Element
* value[x] only CodeableConcept
* valueCodeableConcept from ODEToothVS (extensible)
```

---

## 5. Search & notifications

```
Instance: ode-referral-id
InstanceOf: SearchParameter
Usage: #definition
* url = "https://oralhealthalliance.net/fhir/SearchParameter/ode-referral-id"
* name = "ODEReferralId"
* status = #draft
* code = #referral-id
* base[+] = #ServiceRequest
* base[+] = #Task
* type = #token
* expression = "ServiceRequest.identifier.where(system='urn:ohia:referral-id') | Task.identifier.where(system='urn:ohia:referral-id')"
```

```
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
```

---

## 6. Operations & interactions (the verbs)

The interface is exercised with these concrete operations — all standard FHIR or reused
Da Vinci, nothing custom:

1. **Submit a referral** — `POST [base]` a transaction `Bundle` containing one
   `ODEReferralServiceRequest`, one `ODEReferralTask(status=requested)`, and the US Core
   context (`Patient`, `Practitioner`/`Organization`, `Condition`, `MedicationRequest`,
   `AllergyIntolerance`). This is exactly what the bridge produces from a 360X PCC-55.
2. **Follow status** — `GET [base]/Task?referral-id=urn:ohia:referral-id|REF-1001` (or
   subscribe via §5). Status values follow the ODE loop set; `businessStatus` carries
   sub-states (triaged, scheduled, etc.).
3. **Advance the workflow** — `PUT`/`PATCH [base]/Task/{id}` to move
   `requested → accepted/in-progress → completed` (or `rejected`/`cancelled`). Each change
   is what the bridge mirrors outbound (PCC-56/57/58/59).
4. **Supporting imaging — two patterns by direction.**
   - **Dental→dental (pull):** the referral references the image; the **receiver** issues a
     CDex `POST` Task Data Request (or `GET`) to **retrieve it on demand**. The initial
     referral need not carry the bytes.
   - **Medical→dental and dental→medical (separate push):** whenever the **receiver is on
     the medical side** it exposes no inbound pull, so the sender delivers images as a
     distinct `$submit-attachment` transaction *after* the referral notification, correlated
     by referral-id. Images use `attachment.data` (small) or `attachment.url` (large → FHIR
     `Binary`, `ImagingStudy`+WADO-RS for DICOM, or a bridge capability link).
5. **Retrieve the medication list** — the list travels inside the referral `Bundle` as an
   `ODEMedicationList` (`List`) plus its US Core `MedicationRequest` entries, and is
   independently retrievable with `GET [base]/MedicationRequest?patient={id}` or by reading
   the `List`. The bridge populates it from the C-CDA Medications section on a 360X PCC-55.
6. **Coverage & PA (where in scope)** — CRD `order-sign` CDS Hook, DTR `Questionnaire`,
   PAS `Claim`/`ClaimResponse`, Plan-Net directory query — all reused from Da Vinci.

---

## 7. Terminology

```
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
* #no-show     "No-show"      "Patient did not attend"

ValueSet: ODEReferralSubStatusVS
Id: ode-referral-sub-status-vs
* ^url = "http://ohia-codes.org/ValueSet/ode-referral-sub-status-vs"
* include codes from system ODEReferralSubStatus
```

```
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
```

```
ValueSet: ODEDentalProcedureVS
Id: ode-dental-procedure-vs
Title: "ODE Dental Procedure Codes (CDT)"
Description: "All CDT procedure codes. CDT is licensed by the ADA; the IG references the code system rather than enumerating codes. http://www.ada.org/cdt is the endorsed de facto system URI."
* ^url = "http://ohia-codes.org/ValueSet/ode-dental-procedure-vs"
* include codes from system $cdt
```

```
CodeSystem: ODEToothUniversal
Id: ode-tooth-universal
Title: "ODE Tooth — Universal/National Numbering"
Description: "Permanent teeth 1–32 and primary teeth A–T. Interim OHIA-published system; FDI ISO 3950 to be added pending permission. (Codes abbreviated here; the published artifact enumerates 1–32 and A–T.)"
* ^url = "http://ohia-codes.org/CodeSystem/ode-tooth-universal"
* ^status = #draft
* ^content = #fragment
* #1  "Tooth 1"  "Maxillary right third molar"
* #19 "Tooth 19" "Mandibular left first molar"
* #30 "Tooth 30" "Mandibular right first molar"

ValueSet: ODEToothVS
Id: ode-tooth-vs
* ^url = "http://ohia-codes.org/ValueSet/ode-tooth-vs"
* include codes from system ODEToothUniversal
```

```
// Document type codes used on the 360X boundary
CodeSystem: (reuse) $loinc
//   57133-1  Referral Note        -> inbound PCC-55
//   11488-4  Consultation Note    -> outbound PCC-57 / PCC-59
```

---

## 8. Use case → interface map

| UC | Profiles exercised | Key operations |
|----|--------------------|----------------|
| UC01 head/neck cancer | ServiceRequest, Task, DocumentReference, US Core context | submit Bundle, CRD/DTR, CDex (dose/imaging — partial) |
| UC02 surgical extraction | ServiceRequest, Task, DentalProcedure, DocumentReference (radiograph/intraoral) | submit Bundle, PAS, CDex `$submit-attachment` |
| UC03 pediatric perio | ServiceRequest, Task, US Core context (HIE-sourced) | submit Bundle, Subscriptions, multi-recipient return |
| UC04 teledentistry | ServiceRequest, Task, DocumentReference | submit Bundle, Plan-Net, CDex push |
| UC05 OSA screening | `ODEDentalToMedicalReferral`, Task, Observation+RiskAssessment, DocumentReference *(AI result — gap)* | submit Bundle (**dental→medical**), separate-push imaging |

---

## 9. Deferred — gaps the IG must still define

These have no agreed FHIR representation yet and are intentionally left as placeholders
rather than guessed at:

- **Radiation dosimetry (DDC)** for UC01 — currently a `CommunicationRequest` placeholder;
  needs a dose-result profile (likely Observation + an `ode-radiation-dose` extension).
- **AI screening result** for UC05 — the OSA risk score + facial-scan provenance need an
  `ode-screening-result` profile (Observation + `RiskAssessment`) and a method/Provenance
  pattern. This is **must-support on `ODEDentalToMedicalReferral`**, so it's the gap that
  most directly blocks the dental→medical direction.
- **Tooth numbering under FDI ISO 3950** — alternate to the Universal default, pending
  permission; the `ODEToothUniversal` system is the interim home.

---

### Turning this into the IG package
These FSH blocks map 1:1 to files under `input/fsh/` (`profiles/`, `extensions/`,
`terminology/`, `capabilities/`, `instances/`) plus a `sushi-config.yaml`. The canonicals
above (`https://oralhealthalliance.net/fhir`, `http://ohia-codes.org`) are interim OHIA
namespaces; on adoption into the HL7 OHDE IG they re-home to the HL7 canonical, while the
CDT URI (`http://www.ada.org/cdt`) and the `urn:ohia:referral-id` system carry forward
unchanged.
