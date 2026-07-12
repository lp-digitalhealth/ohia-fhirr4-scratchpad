<!-- Pull request template — keeps the four views in sync. -->

## What changed

<!-- One or two sentences on the interface change. -->

## Which view(s) did you edit?

- [ ] View 1 — `interfaces/fhir-interfaces.md` (IG-dev)
- [ ] View 2 — `interfaces/openapi.yaml` (OpenAPI)
- [ ] View 3 — `interfaces/ode-api-swagger.html` (regenerated from view 2, not hand-edited)
- [ ] View 4 — `interfaces/fsh/**` (FSH IG source)

## Sync checklist

- [ ] Updated the affected row(s) of `interfaces/INTERFACE-VIEWS.md` (the crosswalk)
- [ ] Flagged which **other** views need the same change (list below)
- [ ] If view 2 changed, **regenerated view 3** (Swagger HTML) in this PR
- [ ] Confirmed the **shared anchors** are unchanged, or updated them everywhere:
      canonical `https://oralhealthalliance.net/fhir`, terminology `http://ohia-codes.org`,
      referral-id `urn:ohia:referral-id`, CDT / SNODENT / ICD-10-CM / CPT / HCPCS systems
- [ ] If view 4 (FSH) changed, it still builds: `cd interfaces/fsh && sushi .`

## Other views that still need this change

<!-- e.g. "openapi.yaml and fsh/ still need the new must-support element on dental-to-dental" -->

## Notes / open questions
