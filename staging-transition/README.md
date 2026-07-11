# staging-transition

**Promotion target.** When a change set to the ODE interface reaches **concurrence** in
[`../interfaces/`](../interfaces), a maintainer **manually copies the FSH here** — the
contents of `interfaces/fsh/` (`sushi-config.yaml` + `input/fsh/**`).

Only the FSH is promoted. The other three views (`fhir-interfaces.md`, `openapi.yaml`,
`ode-api-swagger.html`) stay in `interfaces/` as the collaboration surface; they do not come
here.

This folder is **empty until the first concurrence**. What lands here is the agreed,
build-checked interface on its way into the IG.

## Promote (manual)

From the repo root, once `cd interfaces/fsh && sushi .` builds clean:

```bash
rm -rf staging-transition/sushi-config.yaml staging-transition/input
cp interfaces/fsh/sushi-config.yaml staging-transition/
cp -r interfaces/fsh/input staging-transition/
git add staging-transition
git commit -m "Promote ODE FSH to staging-transition (concurrence: <describe change set>)"
```

Record what was promoted (and the concurrence it represents) in the repo `CHANGELOG.md`.
