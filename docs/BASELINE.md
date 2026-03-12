# Baseline — Phase 0

## Why this repo exists

`odoo19-clean` is a clean-room control specimen for Odoo 19. It exists to answer one question with certainty: _does a vanilla Odoo 19 stack start, initialise a database, and serve the web UI correctly?_

All future addon layering (OCA modules, IPAI integrations, custom apps) must be benchmarked against this baseline.

---

## Canonical database model

| Database | Role | Demo data | Addon scope |
|---|---|---|---|
| `odoo_dev` | Clean control development DB | ❌ disabled | `base` only |
| `odoo_dev_demo` | Auxiliary showroom/demo DB | ✅ enabled | Broad available core apps |
| `odoo_staging` | Staging rehearsal DB | ❌ | Mirrors production |
| `odoo` | Production DB | ❌ | Production-only |

`odoo_dev_demo` is an auxiliary database under **development**, not a fourth canonical environment. It exists for product exploration and UX/Copilot testing only.

---

## Phase 0 rules

| Rule | Detail |
|---|---|
| No OCA addons | Phase 0 uses only the Odoo 19 official image |
| No IPAI addons | No integration, AI, or analytics modules |
| No extra addons | `addons_path` points only to core Odoo |
| No devcontainer mixing | No `.devcontainer/`, no Codespaces config |
| No runtime mixing | One Dockerfile, one compose file, no overrides |
| `odoo_dev` stays clean | Only `base`, no demo data — the control specimen |
| `odoo_dev_demo` is allowed | Demo data + broad core apps — showroom only |

---

## Acceptance criteria

| Check | How to verify |
|---|---|
| Stack starts | `docker compose ps` shows both `db` and `odoo` running |
| Health endpoint responds | `curl -sf http://localhost:8069/web/health` returns `{"status":"pass"}` |
| Login page loads | `http://localhost:8069/web/login` returns HTTP 200 |
| `odoo_dev` initialises cleanly | `bash scripts/init_db.sh` exits 0 — `base` only, no demo data |
| `odoo_dev_demo` initialises | `bash scripts/init_demo_db.sh` exits 0 — demo data, broad core apps |
| DBs remain separate | `odoo_dev` and `odoo_dev_demo` are independent databases |
| CRM (future) | After installing `crm` + dependencies, CRM menu loads (phase 1+) |

---

## What comes next

**Only after local validation of both databases passes** should Phase 1 begin.

- **Phase 1 (first additions):** `queue_job` + `auditlog` — and nothing else until those are stable.
- **Phase 2:** IPAI addon layer on top of the Phase 1 baseline.
- Each phase gets its own branch and its own set of acceptance criteria.

> The baseline merge is successful only when:
> 1. `odoo_dev` is base-only and clean
> 2. `odoo_dev_demo` is separate and demo-rich
> 3. runtime stays core-only
> 4. repo remains minimal
> 5. no MCP / OCA / IPAI creep remains

