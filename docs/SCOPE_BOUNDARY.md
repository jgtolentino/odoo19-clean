# Scope Boundary — odoo19-clean

This document defines what is **permanently forbidden** in this repository.  
It is the authoritative human-readable companion to `ssot/baseline/scope-policy.yaml`.

---

## What this repo is

`odoo19-clean` is a **frozen clean-room control specimen** for Odoo 19.

Its role is:

- **Regression comparator** — compare against `Insightpulseai/odoo` to isolate platform/core drift from custom-layer drift
- **Clean-start validator** — prove vanilla Odoo 19 boots and initialises correctly
- **Odoo.sh-alignment specimen** — stay close to Odoo.sh defaults
- **Not** a delivery repo, runtime repo, or addon host

---

## Permanently forbidden changes

The following **may never be merged** into this repository under any circumstances:

| Category | Examples | Why |
|---|---|---|
| OCA addons | `addons/oca/`, `queue_job`, `auditlog` | Addon layering belongs in `Insightpulseai/odoo` |
| IPAI addons | `ipai_*`, any IPAI integration | Custom business logic is not baseline |
| Custom Odoo modules | Any `__manifest__.py` | No addon drift in the clean control specimen |
| External integrations | Supabase, n8n, MCP, Slack, Azure, GCP | Integration concerns belong in the runtime repo |
| Platform IaC | Terraform, Bicep, ARM templates | Infrastructure-as-code is not a baseline concern |
| Analytics / BI | Databricks, Genie, Power BI | Analytics belongs in the delivery layer |
| App / package scaffolding | `apps/`, `packages/`, `runtime/` dirs | Not a monorepo — baseline only |
| Additional databases | Any DB name outside `odoo_dev`, `odoo_dev_demo`, `odoo_staging`, `odoo` | Canonical DB set is fixed |
| Devcontainer / Codespaces | `.devcontainer/`, Codespaces config | Delivery-environment concerns |

---

## Allowed top-level structure

The following top-level entries are the **complete** allowlist:

```
config/          # Minimal Odoo config only
docker/          # Single Dockerfile.clean only
docs/            # Baseline documentation
scripts/         # Start/stop/init scripts and CI helpers
spec/            # Constitution, PRD, plan, tasks
ssot/            # Machine-readable baseline metadata
.github/         # CI workflows and CODEOWNERS only
README.md
docker-compose.yml
requirements.txt
.env.example
.gitignore
```

Any top-level directory or significant file outside this list **will cause CI to fail**.

---

## CI enforcement

The following CI checks enforce this boundary automatically:

| Check | What it blocks |
|---|---|
| `scope-guard` | `__manifest__.py`, any `addons/` dir, forbidden top-level dirs, integration dirs, `ipai_*`, `.mcp.json` |
| `db-name-check` | Non-canonical DB names in scripts/config |
| `required-files` | Missing baseline skeleton files |
| `shell-lint` | Syntactically broken shell scripts |

See `.github/workflows/ci.yml` for the exact implementation.

---

## Drift interpretation doctrine

| Baseline CI | Runtime CI (`Insightpulseai/odoo`) | Root cause |
|---|---|---|
| 🔴 Failing | 🔴 Failing | Platform or core Odoo 19 issue |
| ✅ Passing | 🔴 Failing | Custom-layer drift in runtime repo |
| 🔴 Failing | ✅ Passing | Regression in clean baseline — investigate Docker/config |

---

## Cross-repo references

- **Canonical runtime repo:** `Insightpulseai/odoo`
- **Baseline manifest:** `ssot/baseline/baseline.manifest.json`
- **Acceptance criteria:** `ssot/baseline/acceptance-criteria.yaml`
- **Scope policy:** `ssot/baseline/scope-policy.yaml`

This repo must not grow. All feature work, addon layering, and integrations belong in `Insightpulseai/odoo`.
