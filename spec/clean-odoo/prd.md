# PRD — clean-odoo (Phase 0)

## Goal

Validate that Odoo 19 can:

1. Start from the official Docker image with no customisation.
2. Initialise a PostgreSQL 16 database with the `base` module only.
3. Serve the web UI at `/web/login` and respond to `/web/health`.

## Auxiliary development database

In addition to the canonical clean control database, this repo supports a second
auxiliary development database:

| Database | Purpose |
|---|---|
| `odoo_dev` | Canonical clean control DB — `base` only, no demo data |
| `odoo_dev_demo` | Auxiliary showroom/demo DB — broad core apps, demo data enabled |

`odoo_dev_demo` exists for:
- product exploration and app walkthroughs
- richer sample data for UX/Copilot validation
- demonstrating core Odoo features without touching the clean control specimen

`odoo_dev_demo` is auxiliary to the development environment. It is not a staging or
production candidate. It does not change the clean-room identity of this repo.

## Non-goals (Phase 0)

- Installing OCA or third-party modules.
- Configuring email, cron, or external services.
- Performance benchmarking.
- Multi-worker or production-grade deployment.

## Success metrics

| Metric | Target |
|---|---|
| `docker compose up` exit code | 0 |
| `/web/health` HTTP status | 200, body `{"status":"pass"}` |
| `/web/login` HTTP status | 200 |
| `init_db.sh` exit code | 0, targets `odoo_dev` |
| `init_demo_db.sh` exit code | 0, targets `odoo_dev_demo` |
| Time to healthy (cold start) | < 120 s on a developer laptop |

