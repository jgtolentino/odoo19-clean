# Tasks — clean-odoo (Phase 0)

## Setup

- [x] Create `docker/Dockerfile.clean` (FROM odoo:19, copy conf only)
- [x] Create `config/clean/odoo.conf` (minimal, core addons path only)
- [x] Create `docker-compose.yml` (db + odoo, no custom mounts)
- [x] Create `scripts/up.sh`
- [x] Create `scripts/down.sh`
- [x] Create `scripts/init_db.sh` — targets `odoo_dev`, `base` only, no demo data
- [x] Create `scripts/init_demo_db.sh` — targets `odoo_dev_demo`, demo data, broad core apps
- [x] Create `docs/BASELINE.md`
- [x] Create `spec/clean-odoo/` documents
- [x] Add `requirements.txt` at repo root (Odoo.sh-style Python dep declaration)

## Runtime validation

- [ ] Run `bash scripts/up.sh` — both containers reach healthy state
- [ ] Run `bash scripts/init_db.sh` — exits 0, DB `odoo_dev` created with `base` only
- [ ] Run `bash scripts/init_demo_db.sh` — exits 0, DB `odoo_dev_demo` created with demo data
- [ ] Confirm `GET /web/health` returns HTTP 200 `{"status":"pass"}`
- [ ] Confirm `GET /web/login` returns HTTP 200
- [ ] Confirm `odoo_dev` and `odoo_dev_demo` are separate, independent databases

## Sign-off

- [ ] All acceptance criteria in `docs/BASELINE.md` met
- [ ] No custom addons, OCA paths, or IPAI references present
- [ ] Repo is PR-ready and reviewable

