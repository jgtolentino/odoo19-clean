# odoo19-clean

**Clean-room Odoo 19 baseline repository.**

## Purpose

This repo exists as a clean-slate control specimen for Odoo 19:

- **Phase 0 — no custom addons.** Only the Odoo 19 core image is used.
- Validates that a clean Docker runtime can start and respond.
- Validates that a fresh database can be initialised with the `base` module.
- Provides a stable, reproducible starting point for future controlled layering (OCA baseline, IPAI addons, etc.) without noise from prior environments.

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
docker/Dockerfile.clean      # Odoo 19 image, clean config only
config/clean/odoo.conf       # Minimal Odoo configuration
docker-compose.yml           # db + odoo services, no custom mounts
requirements.txt             # Python deps (Odoo.sh-style; empty in phase 0)
scripts/up.sh                # Start the stack
scripts/down.sh              # Stop the stack
scripts/init_db.sh           # Initialise odoo_dev (clean control DB)
scripts/init_demo_db.sh      # Initialise odoo_dev_demo (showroom DB)
docs/BASELINE.md             # Phase 0 rules and acceptance criteria
spec/clean-odoo/             # Constitution, PRD, plan, tasks
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

