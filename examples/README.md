# Examples

Mock **R4** payload instances that exercise the ODE profiles. Patient data is synthetic;
provider NPIs and payer IDs may be real where public.

| Example | Exercises |
|---------|-----------|
| [`ode-medication-list-example.json`](./ode-medication-list-example.json) | `ODEMedicationList` (List) + US Core `MedicationRequest` — a collection Bundle with three meds, one patient-reported |

Add more as views reach consensus (e.g. a medical→dental referral with ICD-10 + CPT/HCPCS,
a dental→dental referral with CDT + tooth). Keep them aligned to the profiles in
`../interfaces/fsh/`.
