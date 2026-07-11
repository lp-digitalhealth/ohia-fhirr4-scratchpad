`1`# FHIR R4 Interface Scratchpad

Welcome to the ODE interface design repository. This repository is our **design-first API
directory** (similar to Swagger) to establish consensus on our payloads and the interface
**before** we build the formal Implementation Guide (IG).

**Target Version:** FHIR **R4** (4.0.1) · inherits US Core 6.1.0
**License:** CC0 1.0 (per HL7/FHIR IG convention — see [`LICENSE`](./LICENSE))

---

## The interface as four synchronized views

The same interface is maintained in four formats so each stakeholder can work in the one
they know. They are **not merged** — they are kept in sync via the crosswalk. Conversations
and edits happen here; nothing is normative until it's promoted.

| View | Location | For |
|------|----------|-----|
| 1 — IG-development narrative (+ illustrative FSH) | [`interfaces/fhir-interfaces.md`](./interfaces/fhir-interfaces.md) | IG authors / standards |
| 2 — OpenAPI 3.0 REST contract | [`interfaces/openapi.yaml`](./interfaces/openapi.yaml) | REST dev teams |
| 3 — Swagger UI (open in a browser) | [`interfaces/ode-api-swagger.html`](./interfaces/ode-api-swagger.html) | anyone |
| 4 — Compilable FSH IG source | [`interfaces/fsh/`](./interfaces/fsh) | the FSH developer |
| — Parity crosswalk (sync backbone) | [`interfaces/INTERFACE-VIEWS.md`](./interfaces/INTERFACE-VIEWS.md) | proves the views agree |

---

## Collaboration Workflow

1. **Propose / Edit:** open a Pull Request that adds or modifies the view you own
   (`interfaces/`, `terminology/`, `examples/`, or `use-cases/`). All FHIR content targets
   **R4** — resources state `"fhirVersion": "4.0.1"` where applicable.
2. **Sync:** update the affected row(s) of `interfaces/INTERFACE-VIEWS.md` and flag which
   other views need the matching change (the PR template asks this). If you changed the
   OpenAPI (view 2), regenerate the Swagger HTML (view 3).
3. **Consensus:** once all four views + the crosswalk agree, a maintainer **manually copies
   the FSH** (`interfaces/fsh/`) into `staging-transition/`. **Files in transition are
   frozen.** Only the FSH is promoted.

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the full protocol and view ownership.

---

## API Interface Directory

### Dental–medical referral (three directional profiles)
* **FHIR Resource:** `ServiceRequest` + `Task` (COW workflow), on US Core R4
* **Interface (all views):** [`interfaces/`](./interfaces) — see `fhir-interfaces.md`,
  `openapi.yaml`, `ode-api-swagger.html`, `fsh/`
* **Profiles:** `ODEMedicalToDentalReferral`, `ODEDentalToDentalReferral`,
  `ODEDentalToMedicalReferral` (directional coding — see the crosswalk)
* **Status:** Under Active Review

### Medication list
* **FHIR Resource:** `List` + US Core `MedicationRequest`
* **Profile:** `ODEMedicationList` · **Mock payload:**
  [`examples/ode-medication-list-example.json`](./examples/ode-medication-list-example.json)
* **Status:** Under Active Review

---

## Repository Structure Reference

* **`/interfaces`** — the interface, as four synchronized views (the consensus surface):
  the IG-dev narrative, OpenAPI, Swagger, and the buildable FSH IG source (`interfaces/fsh/`).
  Also holds definitional starters like `Patient-Template.json`.
* **`/terminology`** — code systems / value sets for the service (human reference; the
  authoritative, buildable terminology FSH lives in `interfaces/fsh/`).
* **`/examples`** — mock R4 payload instances.
* **`/use-cases`** — the five use cases the IG is built from (UC01–UC05).
* **`/staging-transition`** — landing zone for the finalized **FSH** that has reached full
  consensus. Frozen.
* **`CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `CHANGELOG.md`** — the sync
  protocol that keeps the four views honest.

## Building the FSH

```bash
cd interfaces/fsh
sushi .
```

Needs US Core 6.1.0 (declared in `interfaces/fsh/sushi-config.yaml`). See
[`interfaces/fsh/README.md`](./interfaces/fsh/README.md) for dependencies and known
finalization points.