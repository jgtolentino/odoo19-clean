# Baseline — Phase 0

## Why this repo exists

`odoo19-clean` is a clean-room control specimen for Odoo 19. It exists to answer one question with certainty: _does a vanilla Odoo 19 stack start, initialise a database, and serve the web UI correctly?_

All future addon layering (OCA modules, IPAI integrations, custom apps) must be benchmarked against this baseline.

---

## Phase 0 rules

| Rule | Detail |
|---|---|
| No OCA addons | Phase 0 uses only the Odoo 19 official image |
| No IPAI addons | No integration, AI, or analytics modules |
| No extra addons | `addons_path` points only to core Odoo |
| No devcontainer mixing | No `.devcontainer/`, no Codespaces config |
| No runtime mixing | One Dockerfile, one compose file, no overrides |

---

## Acceptance criteria

| Check | How to verify |
|---|---|
| Stack starts | `docker compose ps` shows both `db` and `odoo` running |
| Health endpoint responds | `curl -sf http://localhost:8069/web/health` returns `{"status":"pass"}` |
| Login page loads | `http://localhost:8069/web/login` returns HTTP 200 |
| DB initialises cleanly | `bash scripts/init_db.sh` exits 0 without errors |
| CRM (future) | After installing `crm` + dependencies, CRM menu loads (phase 1+) |

---

## What comes next

- **Phase 1:** Minimal safe OCA baseline (e.g. `server-tools`)  
- **Phase 2:** IPAI addon layer  
- Each phase gets its own branch and its own set of acceptance criteria.
