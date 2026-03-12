# odoo19-clean

**Clean-room Odoo 19 baseline repository.**

## Purpose

This repo exists as a clean-slate control specimen for Odoo 19:

- **Phase 0 — no custom addons.** Only the Odoo 19 core image is used.
- Validates that a clean Docker runtime can start and respond.
- Validates that a fresh database can be initialised with the `base` module.
- Provides a stable, reproducible starting point for future controlled layering (OCA baseline, IPAI addons, etc.) without noise from prior environments.

## Repository layout

```
docker/Dockerfile.clean   # Odoo 19 image, clean config only
config/clean/odoo.conf    # Minimal Odoo configuration
docker-compose.yml        # db + odoo services, no custom mounts
scripts/up.sh             # Start the stack
scripts/down.sh           # Stop the stack
scripts/init_db.sh        # Initialise odoo_dev_clean database
docs/BASELINE.md          # Phase 0 rules and acceptance criteria
spec/clean-odoo/          # Constitution, PRD, plan, tasks
```

## Quickstart

```bash
# 0. Copy the example env file (adjust passwords if needed)
cp .env.example .env

# 1. Start the stack
bash scripts/up.sh

# 2. Wait ~30 s for the database to be ready, then initialise the DB
bash scripts/init_db.sh

# 3. Open the browser
open http://localhost:8069/web/login
```

> **Credentials (first run):** Odoo will prompt you to create the first admin user after DB init.

## Stopping

```bash
bash scripts/down.sh
```

## Requirements

- Docker ≥ 24
- Docker Compose plugin (bundled with Docker Desktop / modern Docker Engine)
