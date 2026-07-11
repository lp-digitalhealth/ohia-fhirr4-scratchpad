# ODE IG source (FSH) — for `ohia-fhirr4-scratchpad`

The **fourth view** of the ODE interface: compilable FHIR Shorthand that your FSH developer
drops into the IG. It is functionally identical to the three stakeholder views
(`fhir-interfaces.md`, `openapi.yaml`, `ode-api-swagger.html`) — see
[`INTERFACE-VIEWS.md`](../INTERFACE-VIEWS.md) for the element-by-element parity crosswalk.

## What to copy where

Merge into your existing scaffolding. SUSHI finds `.fsh` files recursively under
`input/fsh/`, so the subfolders are for humans — keep or reorganize to match your template.

```
sushi-config.yaml                    # merge dependencies + canonical into your existing config
input/fsh/
  aliases.fsh                        # global aliases (systems + US Core profile URLs)
  profiles/
    referrals.fsh                    # base + medical→dental, dental→dental, dental→medical
    workflow.fsh                     # ODEReferralTask (COW)
    clinical.fsh                     # DocumentReference, DentalProcedure, PerioObservation, MedicationList
  extensions/
    ode-tooth.fsh                    # tooth designation extension
  terminology/
    terminology.fsh                  # CodeSystems + ValueSets (published under ohia-codes.org)
  capabilities/
    capabilitystatements.fsh         # Recipient server + Initiator client
  instances/
    search-and-subscription.fsh      # referral-id SearchParameter + status SubscriptionTopic
```

## Build

```bash
sushi .
```

Dependencies (in `sushi-config.yaml`):
- **`hl7.fhir.us.core: 6.1.0`** — required; the profiles inherit US Core.
- **Topic-based Subscriptions Backport** — needed only for the `SubscriptionTopic` in
  `instances/search-and-subscription.fsh`. Add the package for your R4 build, or comment
  the `SubscriptionTopic` out. (Left commented in the config so the tank builds with just
  US Core.)
- **Da Vinci CDex** — optional; only referenced as a canonical string
  (`$submit-attachment`) in the CapabilityStatements. Not required to build.

## Notes for the FSH developer (known finalization points)

These are faithful to the stakeholder views but are the spots most likely to need your
hand during a real build:

1. **"Should-support" slices.** SNODENT (`code.coding[snodent]`) and the pre-procedure risk
   observations are optional slices documented via `^short`/`^comment` as SHOULD-populate,
   because FHIR has only Must Support. If your IG adopts an obligation extension, swap it in.
2. **Terminology canonicals.** CodeSystems/ValueSets set an explicit `^url` under
   `http://ohia-codes.org` while the IG `canonical` is `oralhealthalliance.net/fhir`. SUSHI
   will warn about the mismatch — it's intentional (terminology namespace).
3. **`code.coding` / `reasonCode` slicing by system.** Confirm the discriminators behave as
   intended against US Core's existing bindings on `ServiceRequest.code`.
4. **Deferred gaps** (unmodeled on purpose): radiation dosimetry, the AI screening-result
   profile (Observation + RiskAssessment) that is must-support on `ODEDentalToMedicalReferral`,
   and FDI ISO 3950 tooth numbering.
5. **CapabilityStatements** are `Usage: #definition` requirements statements (not a live
   server's `#instance`).

Not yet included (add if your IG wants them): IG `pagecontent` narrative, example
`Instance`s (a medication-list example exists in the interfaces repo), and an
`ImplementationGuide` menu — your scaffolding likely already provides these.
