# FHIR R6 Interface Scratchpad

Welcome to the interface design repository. This repository acts as our design-first API directory (similar to Swagger) to establish consensus on our payloads before we build a formal Implementation Guide (IG).

**Target Version:** FHIR R6 (`6.0.0`) 

---

## Collaboration Workflow

1. **Propose / Edit:** Submit a Pull Request (PR) adding or modifying JSON files in the `interfaces/` or `examples/` folders.
2. **Validate:** Ensure all JSON files use R6 structures and explicitly state `"fhirVersion": "6.0.0"` where applicable.
3. **Consensus:** Once approved, the JSON file will be moved to the `staging-transition/` folder. **Files in transition are frozen.**

---

## API Interface Directory
## Example: 
### Patient Identity & Demographics
* **FHIR Resource:** `Patient` (R6 Core)
* **Interface Schema:** [interfaces/patient-interface.json](./interfaces/patient-interface.json)
* **Mock Payload:** [examples/patient-payload-mock.json](./examples/patient-payload-mock.json)
* **Status:**  Under Active Review

### Clinical Observations & Vitals
* **FHIR Resource:** `Observation` (R6 Core - Note R6 Vital Signs Profile changes)
* **Interface Schema:** [staging-transition/observation-interface.json](./staging-transition/observation-interface.json)
* **Mock Payload:** [examples/observation-payload-mock.json](./examples/observation-payload-mock.json)
* **Status:**  Consensus Reached

---

##  Repository Structure Reference

* **`/interfaces`**: The drop zone for proposed FHIR R6 definitional resources (e.g., CapabilityStatements, custom Profiles).
* **`/examples`**: The drop zone for mock R6 payload instances.
* **`/staging-transition`**: The landing zone for finalized files that have achieved full team consensus.
* **`/terminology`**: The terminology used for the service
