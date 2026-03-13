# odoo19-clean

**Clean-room Odoo 19 baseline repository.**

> This repository is intentionally not the canonical delivery/runtime repo and must remain baseline-only.

## What this repo is

A **frozen clean-room control specimen** for Odoo 19.  
Its sole purpose: verify that a vanilla Odoo 19 stack starts, initialises a
database, and serves the web UI correctly — with no custom addons, no
integrations, and no scope creep.

All future addon layering (OCA modules, IPAI integrations, custom apps) must
be benchmarked against this baseline.

## What this repo is not

- ❌ The real Odoo runtime repo
- ❌ An OCA or IPAI addon host
- ❌ A wiki — all docs live in-repo, versioned alongside CI
- ❌ A Slack integration hub — belongs on active delivery repos
- ❌ A template repository

For the full desired end state, see [`docs/architecture/TARGET_ARCHITECTURE.md`](docs/architecture/TARGET_ARCHITECTURE.md).

## Canonical database model

| Database | Purpose |
|---|---|
| `odoo_dev` | Clean control development DB — `base` only, no demo data |
| `odoo_dev_demo` | Auxiliary development showroom/demo DB — broad core apps, demo data enabled |
| `odoo_staging` | Staging rehearsal DB — mirrors production topology |
| `odoo` | Production DB |

`odoo_dev_demo` is an auxiliary database under the **development** environment, not a fourth canonical environment.

## Repository layout

```
docker/Dockerfile.clean              # Odoo 19 image, clean config only
config/clean/odoo.conf               # Minimal Odoo configuration
docker-compose.yml                   # db + odoo services, no custom mounts
requirements.txt                     # Python deps (Odoo.sh-style; empty in phase 0)
scripts/up.sh                        # Start the stack
scripts/down.sh                      # Stop the stack
scripts/init_db.sh                   # Initialise odoo_dev (clean control DB)
scripts/init_demo_db.sh              # Initialise odoo_dev_demo (showroom DB)
docs/BASELINE.md                     # Phase 0 rules and acceptance criteria
docs/HARDENING.md                    # Branch-protection and GitHub Settings runbook
docs/architecture/TARGET_ARCHITECTURE.md  # Desired end state (this repo only)
spec/clean-odoo/                     # Constitution, PRD, plan, tasks
.github/CODEOWNERS                   # Ownership file for review routing and change visibility
.github/workflows/ci.yml             # CI: shell-lint, scope-guard, db-name-check, required-files
```

## Quickstart — clean control DB (`odoo_dev`)

```bash
# 1. Start the stack (credentials are pre-configured — no .env needed)
bash scripts/up.sh

# 2. Initialise the canonical clean control database
bash scripts/init_db.sh

# 3. Open the browser
open http://localhost:8069/web/login
```

> **Credentials (first run):** Odoo will prompt you to create the first admin user after DB init.

## Quickstart — demo/showroom DB (`odoo_dev_demo`)

```bash
# Stack must be running first (bash scripts/up.sh)

# Initialise the showroom database with demo data and broad core apps
bash scripts/init_demo_db.sh

# Open the browser and select odoo_dev_demo from the DB manager
open http://localhost:8069/web/login
```

> The demo DB script detects which modules are available in the runtime and skips any that are absent.
> If the DB already exists and is non-empty, the script prints a drop instruction and exits cleanly.

## Stopping

```bash
bash scripts/down.sh
```

## Requirements

- Docker ≥ 24
- Docker Compose plugin (bundled with Docker Desktop / modern Docker Engine)

## What comes next

Potential future benchmark phases (not active in this repo by default):

1. **Phase 1** — benchmark `queue_job` and `auditlog` on an explicit branch
2. **Phase 2** — benchmark IPAI addon layer only after Phase 1 is proven stable

This repo remains a control specimen. No addon drift until Phase 1 is explicitly started on its own branch.

