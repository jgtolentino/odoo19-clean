# Plan — clean-odoo

## Phase 0 — Core-only runtime (this repo, `main`)

- Use the official `odoo:19` Docker image unmodified.
- Supply only a minimal `odoo.conf` (no custom addon paths).
- Two services: `db` (postgres:16) and `odoo`.
- Provide helper scripts for start, stop, and DB init.
- Document acceptance criteria in `docs/BASELINE.md`.

**Exit criteria:** `/web/health` responds and DB init exits 0.

---

## Phase 1 — Minimal safe OCA baseline (future branch)

- Add a curated, pinned set of OCA `server-tools` modules.
- Extend `addons_path` to include OCA paths.
- Re-validate all Phase 0 acceptance criteria still pass.

**Exit criteria:** OCA modules install without error; baseline tests still green.

---

## Phase 2 — IPAI addon layer (future branch)

- Layer IPAI-specific addons on top of the Phase 1 baseline.
- Maintain backwards compatibility with Phase 0 DB schema where possible.

**Exit criteria:** IPAI features functional; no regressions in Phase 0/1 checks.
