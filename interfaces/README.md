# ODE referral interface — four synchronized views

The **Oral Health Data Exchange (ODE) referral interface** as **four views** of one
contract. They are intentionally *not* merged — different stakeholders develop from
different views. [`INTERFACE-VIEWS.md`](./INTERFACE-VIEWS.md) is the crosswalk that proves
they describe the same interface and is the checklist for keeping them in sync.

| View | File | For |
|------|------|-----|
| 1 — IG-development narrative + illustrative FSH | [`fhir-interfaces.md`](./fhir-interfaces.md) | IG authors, standards reviewers |
| 2 — OpenAPI 3.0 REST contract | [`openapi.yaml`](./openapi.yaml) | REST dev teams (import to Swagger/Postman/Stoplight) |
| 3 — Swagger UI rendering of view 2 | [`ode-api-swagger.html`](./ode-api-swagger.html) | anyone — open in a browser |
| 4 — Compilable IG source (FSH) | [`fsh/`](./fsh) | the FSH developer building the IG |
| — Parity crosswalk | [`INTERFACE-VIEWS.md`](./INTERFACE-VIEWS.md) | proves the four views agree |

## Build the FSH (view 4)

```bash
cd fsh
sushi .
```

Needs US Core 6.1.0 (declared in `fsh/sushi-config.yaml`). See [`fsh/README.md`](./fsh/README.md)
for dependencies and known finalization points.

## Promotion

`fsh/` is the only view promoted to `../staging-transition/` once a change set reaches
concurrence — see the repo root `CONTRIBUTING.md`.
