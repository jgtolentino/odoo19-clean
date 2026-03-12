# PRD — clean-odoo (Phase 0)

## Goal

Validate that Odoo 19 can:

1. Start from the official Docker image with no customisation.
2. Initialise a PostgreSQL 16 database with the `base` module only.
3. Serve the web UI at `/web/login` and respond to `/web/health`.

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
| `init_db.sh` exit code | 0 |
| Time to healthy (cold start) | < 120 s on a developer laptop |
