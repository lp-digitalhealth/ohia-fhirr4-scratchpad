# Contributing — how the views stay in sync

The whole point of this repo is that the **four views describe one interface**. The single
rule that keeps that true:

> **No view changes alone.** Every change updates `interfaces/INTERFACE-VIEWS.md` (the
> crosswalk) and flags which other views need the matching change.

## The four views and who tends them

You don't have to be able to edit every view — edit the one you're comfortable with and
flag the rest. Suggested ownership (fill in names):

| View | File | Tended by |
|------|------|-----------|
| 1 — IG-development narrative | `interfaces/fhir-interfaces.md` | IG authors / standards reviewers — _TBD_ |
| 2 — OpenAPI REST contract | `interfaces/openapi.yaml` | application / REST dev teams — _TBD_ |
| 3 — Swagger viewer | `interfaces/ode-api-swagger.html` | regenerated from view 2 (don't hand-edit) — _TBD_ |
| 4 — FSH IG source | `interfaces/fsh/` | FSH developer — _TBD_ |
| — Parity crosswalk | `interfaces/INTERFACE-VIEWS.md` | maintainers (updated by every PR) |

Note on view 3: `ode-api-swagger.html` embeds the spec from view 2. When `openapi.yaml`
changes, regenerate the HTML rather than editing it by hand.

## Making a change

1. Branch and open a **pull request** against `main`.
2. Edit your view.
3. Update the affected row(s) of `interfaces/INTERFACE-VIEWS.md`.
4. Complete the PR checklist (it asks which other views need mirroring, and whether the
   shared anchors — canonical, `urn:ohia:referral-id`, code systems — changed).
5. If your change touches view 2 (OpenAPI), regenerate view 3 (Swagger) in the same PR.
6. A maintainer merges once the crosswalk is consistent. Mirroring in the other views can
   land in the same PR or a tracked follow-up — but it must land before concurrence.

## What "concurrence" means

Concurrence is reached when, for a given change set, **all four views and the crosswalk
agree** on:

- the profile set and their parents,
- the directional-coding table (medical→dental / dental→dental / dental→medical),
- the must-support / required sets,
- the operation ↔ endpoint mapping,
- terminology URIs and the shared anchors.

## Promotion (manual, FSH only)

When a change set reaches concurrence, a maintainer **manually copies the FSH** — the
contents of `interfaces/fsh/` (`sushi-config.yaml` + `input/fsh/**`) — into
[`staging-transition/`](./staging-transition). Only the FSH is promoted; the other three
views stay here as the collaboration surface. See `staging-transition/README.md`.

This step is intentionally manual: promotion is a decision, not an automation.

## Build check before promoting

```bash
cd interfaces/fsh
sushi .
```

The FSH should compile (US Core 6.1.0 dependency) before it's promoted. Known finalization
points are listed in `interfaces/fsh/README.md`.

## Letting an AI agent do the syncing

The protocol above is encoded for AI coding agents so the cross-view propagation can be
delegated:

- **Claude Code** → [`CLAUDE.md`](./CLAUDE.md) (read automatically at the repo root)
- **Cursor** → [`.cursor/rules/`](./.cursor/rules): `ode-interface-sync.mdc` (always on),
  `fsh-authoring.mdc` (on `interfaces/fsh/**`), `openapi-and-swagger.mdc` (on the OpenAPI /
  Swagger files)

They carry the same invariants a human contributor must honor: the shared anchors, the three
directional referral profiles and their must-support sets, the imaging push/pull rule, the
"should-support" convention, and the deferred gaps they must not invent shapes for.

Ask the agent to make a change **and propagate it**; it should edit every affected view,
update `interfaces/INTERFACE-VIEWS.md`, regenerate the Swagger HTML if the OpenAPI changed,
and report what remains unsynced. **Still review the PR** — the agent enforces the protocol,
it doesn't own the decision. Promotion to `staging-transition/` remains human-only.

When the interface changes in a way these files describe (a new profile, a changed
must-support), **update `CLAUDE.md` and the Cursor rules too** — they are part of the
contract, not commentary.
