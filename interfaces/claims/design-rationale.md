# ODE Claims-Sharing Profile — Draft OpenAPI Addition

**Status:** Draft, for HL7 PSS project team review (oral health data exchange claims-sharing extension).
**Scope:** This is a proposed ADDITION to the existing `interfaces/openapi.yaml` — a new profile family and its paths/schemas, alongside the existing referral profiles. Nothing below modifies or removes any existing content. Per `INTERFACE-VIEWS.md`'s own sync discipline, this same addition needs mirroring into views 1 (narrative/FSH-illustrative), 3 (Swagger), and 4 (compiled FSH) once approved here — that work is assumed to sit with the project team already assigned to view-sync.

**Uses the IG's existing shared anchors** (per `INTERFACE-VIEWS.md`): canonical `https://oralhealthalliance.net/fhir`, terminology namespace `http://ohia-codes.org`, CDT `http://www.ada.org/cdt`, SNODENT `http://www.ada.org/snodent`, ICD-10-CM/CPT/HCPCS systems as already declared. No new anchors introduced.

---

## Design summary (for reviewers before reading the YAML)

- **Base:** derived from CARIN Blue Button's `C4BB-ExplanationOfBenefit-Professional-NonClinician-Basis` (the non-financial variant) — chosen because it's the profile family structurally proven to map to CMS-1500/837P (confirmed field-by-field: `careTeam.role = referring` ↔ Box 17, `diagnosis` ↔ Box 21, `item.productOrService` ↔ Box 24D, `supportingInfo[servicefacility]` ↔ Box 32).
- **Extended with oral-specific must-support elements**, borrowed from CARIN BB's sibling `Oral` profile pattern (not inherited from it — Oral and Professional are siblings, not parent/child): `item.bodySite` required, dual CDT+CPT/HCPCS coding in `item.productOrService`.
- **Non-financial this iteration**: no `unitPrice`, `net`, `total`, or `adjudication` — `status: draft`, `outcome: queued`. Structured so a future iteration can populate pricing/adjudication into the identical shape without restructuring, matching CARIN BB's own "Basis" convention for exactly this purpose.
- **Tooth numbering: Universal Tooth Designation System only** (`http://terminology.hl7.org/CodeSystem/ADAUniversalToothDesignationSystem`) — confirmed directly with the ADA that FDI is not used for US dental data. This resolves `INTERFACE-VIEWS.md`'s own listed open item, *"FDI ISO 3950 tooth numbering (permission pending)"* — recommend closing that item as resolved, not just deferred, when this is merged.
- **Diagnosis is conditionally required**: always present in the data (cost-free to include), but documented as mandatory-if-medical-payer, payer's-discretion-if-dental-payer — per confirmed CMS/ADA guidance that CDT is universally required on dental claims while ICD-10 is not.

---

## YAML addition

### New tag

```yaml
tags:
  # ... existing tags (Capability, Referral, Workflow, Medications, Clinical Content, Attachments, Notifications) ...
  - name: Claims Sharing
    description: >
      Non-financial, oral-optimized ExplanationOfBenefit — a dental-first "claims-ready"
      package derived from CARIN Blue Button's Professional/NonClinician Basis profile,
      extended with oral must-support elements (tooth bodySite, dual CDT+CPT coding).
      Designed so a receiving system (medical or dental payer, or a clearinghouse) can
      construct its own final claim (837D, 837P/CMS-1500, or a fully-priced FHIR Claim)
      without OHIA making pricing, adjudication, or code-system-choice decisions on their
      behalf. Financial fields (unitPrice, net, total, adjudication) are intentionally
      absent in this iteration; the shape is designed to accept them in a future
      Connectathon without restructuring.
```

### New paths

```yaml
  /ExplanationOfBenefit:
    post:
      tags: [Claims Sharing]
      operationId: createClaimsSharingEOB
      summary: Create a non-financial, oral-optimized ExplanationOfBenefit
      description: >
        Creates the claims-ready data package described in `ODEDentalClaim`. This
        is NOT a claim submission and carries no pricing/adjudication — see the schema
        description for what is and isn't included, and why.
      requestBody:
        required: true
        content:
          application/fhir+json:
            schema: { $ref: '#/components/schemas/ODEDentalClaim' }
            examples:
              johnSmithClaimsSharing: { $ref: '#/components/examples/oralProfessionalEobExample' }
      responses:
        '201':
          description: Created
          content:
            application/fhir+json:
              schema: { $ref: '#/components/schemas/ODEDentalClaim' }
        '400': { $ref: '#/components/responses/OperationOutcome' }
        '401': { $ref: '#/components/responses/Unauthorized' }
    get:
      tags: [Claims Sharing]
      operationId: searchClaimsSharingEOB
      summary: Search claims-sharing ExplanationOfBenefit resources
      parameters:
        - $ref: '#/components/parameters/patient'
        - name: encounter
          in: query
          schema: { type: string, example: 'Encounter/example' }
          description: Reference search by the Encounter this claims-sharing package relates to
      responses:
        '200':
          description: searchset Bundle of ExplanationOfBenefit
          content:
            application/fhir+json:
              schema: { $ref: '#/components/schemas/Bundle' }

  /ExplanationOfBenefit/{id}:
    get:
      tags: [Claims Sharing]
      operationId: readClaimsSharingEOB
      summary: Read a claims-sharing ExplanationOfBenefit by id
      parameters: [{ $ref: '#/components/parameters/id' }]
      responses:
        '200':
          description: ODEDentalClaim
          content:
            application/fhir+json:
              schema: { $ref: '#/components/schemas/ODEDentalClaim' }
        '404': { $ref: '#/components/responses/NotFound' }
```

### New schema

```yaml
    ODEDentalClaim:
      type: object
      description: >
        Non-financial, oral-optimized ExplanationOfBenefit. Derived from CARIN Blue
        Button's C4BB-ExplanationOfBenefit-Professional-NonClinician-Basis profile
        (chosen because it is structurally proven to map to CMS-1500/837P — see design
        notes), extended with oral must-support elements. This is a candidate new ODE
        profile, not a direct reuse of an existing CARIN BB profile as-is, since CARIN BB
        does not currently define a profile that is simultaneously CMS-1500-compatible
        and oral-optimized.

        NOT a claim submission: status is always `draft`, outcome is always `queued`.
        No unitPrice/net/total/adjudication. Diagnosis is always present in the data
        (cost-free to include) but is only REQUIRED when the receiving payer is medical;
        for a dental-only payer it is available at the payer's discretion, per confirmed
        CMS/ADA guidance. CDT coding in `item.productOrService` is always required
        regardless of payer type (a HIPAA requirement for any dental claim); CPT/HCPCS
        is included alongside it wherever a crosswalk is knowable, for medical-payer use.
      x-fhir-profile: https://oralhealthalliance.net/fhir/StructureDefinition/ode-eob-oral-professional
      x-derived-from: http://hl7.org/fhir/us/carin-bb/StructureDefinition/C4BB-ExplanationOfBenefit-Professional-NonClinician-Basis
      required: [resourceType, status, type, use, patient, insurer, provider, item]
      properties:
        resourceType: { type: string, enum: [ExplanationOfBenefit] }
        identifier:
          type: array
          items: { $ref: '#/components/schemas/Identifier' }
        status: { type: string, enum: [draft], description: "Always 'draft' — this is not a submission." }
        type:
          $ref: '#/components/schemas/CodeableConcept'
          description: Fixed to professional-oriented claim type per the base profile.
        use: { type: string, enum: [claim] }
        patient: { $ref: '#/components/schemas/Reference' }
        billablePeriod:
          type: object
          properties:
            start: { type: string, format: date }
            end: { type: string, format: date }
        created: { type: string, format: date }
        insurer: { $ref: '#/components/schemas/Reference' }
        provider: { $ref: '#/components/schemas/Reference' }
        outcome: { type: string, enum: [queued], description: "Always 'queued' — adjudication has not occurred." }
        careTeam:
          type: array
          description: >
            Includes both referring and rendering/performing roles — the referring role
            is confirmed to map directly to CMS-1500 Box 17.
          items:
            type: object
            properties:
              sequence: { type: integer }
              provider: { $ref: '#/components/schemas/Reference' }
              responsible: { type: boolean }
              role:
                type: object
                description: "CARIN BB C4BBClaimCareTeamRole — e.g. 'referring', 'rendering', 'performing'."
                properties:
                  coding: { type: array, items: { $ref: '#/components/schemas/Coding' } }
        supportingInfo:
          type: array
          description: >
            Includes servicefacility (maps to CMS-1500 Box 32) and other CARIN BB
            C4BBSupportingInfoType categories as applicable.
          items: { type: object }
        diagnosis:
          type: array
          description: >
            Always present when known (cost-free to include). REQUIRED when the
            receiving payer is medical; payer's-discretion for dental-only payers.
          items:
            type: object
            properties:
              sequence: { type: integer }
              diagnosisCodeableConcept: { $ref: '#/components/schemas/CodeableConcept' }
        insurance:
          type: array
          items:
            type: object
            properties:
              focal: { type: boolean }
              coverage: { $ref: '#/components/schemas/Reference' }
        item:
          type: array
          items:
            type: object
            required: [sequence, productOrService, bodySite]
            properties:
              sequence: { type: integer }
              productOrService:
                type: object
                description: >
                  MUST include a CDT coding (always required, per HIPAA, regardless of
                  payer type). SHOULD include a CPT/HCPCS coding alongside it wherever a
                  crosswalk is knowable, for medical-payer use.
                properties:
                  coding: { type: array, items: { $ref: '#/components/schemas/Coding' } }
              bodySite:
                type: object
                description: >
                  REQUIRED (must-support). Uses ONLY the ADA Universal Tooth Designation
                  System (http://terminology.hl7.org/CodeSystem/ADAUniversalToothDesignationSystem)
                  — confirmed directly with the ADA that FDI notation is not used for US
                  dental data. Resolves the "FDI ISO 3950 tooth numbering (permission
                  pending)" item in INTERFACE-VIEWS.md's Deferred Gaps section.
                properties:
                  coding: { type: array, items: { $ref: '#/components/schemas/Coding' } }
              servicedDate: { type: string, format: date }
              locationCodeableConcept: { $ref: '#/components/schemas/CodeableConcept' }
              modifier:
                type: array
                items: { $ref: '#/components/schemas/CodeableConcept' }
                description: >
                  Service/product billing modifiers — the real, pre-existing base FHIR
                  element (Claim.item.modifier / ExplanationOfBenefit.item.modifier,
                  0..* CodeableConcept), not an ODE-invented field. Added specifically to
                  carry the KX modifier: confirmed directly against CMS's own guidance
                  that KX is required (as of 2025-07-01) on whichever claim form is used
                  — 837D, 837P, or 837I — to certify a dental service is inextricably
                  linked to a covered medical service, and confirmed against Humana's
                  own MA policy that it specifically requires KX appended to a CDT code.
                  Example: { "coding": [{ "system": "http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets",
                  "code": "KX", "display": "Requirements specified in the medical policy have been met" }] }
              quantity:
                type: object
                properties:
                  value: { type: number }
                description: Count only — NOT pricing. No unitPrice/net alongside this in this iteration.
        additionalProperties: true
```

### New example

```yaml
  examples:
    oralProfessionalEobExample:
      summary: Non-financial claims-sharing package (UC01 pattern)
      value:
        resourceType: ExplanationOfBenefit
        meta:
          profile: ['https://oralhealthalliance.net/fhir/StructureDefinition/ode-eob-oral-professional']
        status: draft
        type:
          coding:
            - { system: 'http://terminology.hl7.org/CodeSystem/claim-type', code: 'professional', display: 'Professional' }
        use: claim
        patient: { reference: 'Patient/example', display: 'John Smith' }
        created: '2026-07-29'
        insurer: { reference: 'Organization/payer-example' }
        provider: { reference: 'Organization/dental-practice-example' }
        outcome: queued
        careTeam:
          - sequence: 1
            provider: { reference: 'PractitionerRole/referring-example' }
            role:
              coding:
                - { system: 'http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBClaimCareTeamRole', code: 'referring', display: 'Referring' }
          - sequence: 2
            provider: { reference: 'PractitionerRole/rendering-example' }
            responsible: true
            role:
              coding:
                - { system: 'http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBClaimCareTeamRole', code: 'rendering', display: 'Rendering provider' }
        diagnosis:
          - sequence: 1
            diagnosisCodeableConcept:
              coding:
                - { system: 'http://hl7.org/fhir/sid/icd-10-cm', code: 'C02.1', display: 'Malignant neoplasm of border of tongue' }
        insurance:
          - focal: true
            coverage: { reference: 'Coverage/example' }
        item:
          - sequence: 1
            productOrService:
              coding:
                - { system: 'http://www.ada.org/cdt', code: 'D7210', display: 'Extraction, erupted tooth requiring removal of bone and/or sectioning of tooth' }
                - { system: 'http://www.ama-assn.org/go/cpt', code: '41899', display: 'Unlisted procedure, dentoalveolar structures' }
            bodySite:
              coding:
                - { system: 'http://terminology.hl7.org/CodeSystem/ADAUniversalToothDesignationSystem', code: '30', display: '30' }
            servicedDate: '2026-07-29'
            quantity: { value: 1 }
```

---

## Handoff notes for the project team

1. This addition assumes the base `openapi.yaml`'s existing `components.schemas.Reference`, `.CodeableConcept`, `.Coding`, `.Bundle`, `.responses.*`, and `.parameters.*` — all already defined in the current file; nothing new needed there.
2. `x-derived-from` is not a standard OpenAPI keyword — it's a documentation convenience flagging the CARIN BB lineage for FSH authors building view 4; the actual `StructureDefinition.baseDefinition` in FSH should point at the real CARIN BB Professional/NonClinician Basis canonical URL.
3. The CPT code in the example (`41899`, "Unlisted procedure, dentoalveolar structures") is a placeholder crosswalk value for illustration — confirm the correct crosswalk code before this ships as a real example, same discipline as everything else in this project.
4. Recommend closing `INTERFACE-VIEWS.md`'s Deferred Gaps item on FDI tooth numbering as **resolved** (not deferred) once this merges, citing the direct ADA confirmation.
