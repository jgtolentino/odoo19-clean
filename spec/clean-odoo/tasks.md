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

## CI / boundary enforcement

- [x] Create `.github/workflows/ci.yml` with four jobs:
  - `shell-lint` — shellcheck on all `scripts/*.sh`
  - `scope-guard` — reject forbidden paths/patterns (ipai_*, OCA, Databricks, Genie/BI, platform IaC, MCP)
  - `db-name-check` — verify only canonical DB names appear in config/scripts/compose
  - `required-files` — assert baseline skeleton is intact on every PR

## Runtime validation

- [ ] Run `bash scripts/up.sh` — both containers reach healthy state
- [ ] Run `bash scripts/init_db.sh` — exits 0, DB `odoo_dev` created with `base` only
- [ ] Run `bash scripts/init_demo_db.sh` — exits 0, DB `odoo_dev_demo` created with demo data
- [ ] Confirm `GET /web/health` returns HTTP 200 `{"status":"pass"}`
- [ ] Confirm `GET /web/login` returns HTTP 200
- [ ] Confirm `odoo_dev` and `odoo_dev_demo` are separate, independent databases

## Repo hardening (post-merge)

Steps to complete after the baseline CI is merged into `main`. See `docs/HARDENING.md` for the full runbook.

- [ ] **GitHub General settings** (`Settings → General`):
  - [ ] Wikis: **Off**
  - [ ] Issues: On
  - [ ] Discussions: Off
  - [ ] Projects: Off
  - [ ] Template repository: Off
  - [ ] Allow merge commits: **Off**
  - [ ] Allow squash merging: **On**
  - [ ] Allow rebase merging: **Off**
  - [ ] Always suggest updating branches: On
  - [ ] Allow auto-merge: Off
  - [ ] Automatically delete head branches: **On**
  - [ ] Require contributors to sign off on web-based commits: On
- [ ] Set Actions approval policy: **Require approval for all outside collaborators** (`Settings → Actions → General`)
- [ ] Add branch protection ruleset for `main`:
  - [ ] Require pull request before merging
  - [ ] Required approvals: 1
  - [ ] Dismiss stale approvals on new commits
  - [ ] Require review from Code Owners (enforces `.github/CODEOWNERS`)
  - [ ] Require status checks to pass before merging
  - [ ] Require branches to be up to date before merging
  - [ ] Block force pushes
  - [ ] Block branch deletion
- [ ] Add required status checks on `main` (after first successful run):
  - [ ] `shell-lint`
  - [ ] `scope-guard`
  - [ ] `db-name-check`
  - [ ] `required-files`
  - [ ] `CodeQL` (add only if code scanning is consistently present on `main`)
- [ ] Verify `main` shows lock icon in `Settings → Branches`
- [ ] Verify direct push to `main` is rejected

## Branch cleanup

- [ ] Delete any merged PR branches (auto-deleted if "Automatically delete head branches" is on)
- [ ] Confirm only `main` remains in `Settings → Branches`

## Sign-off

- [ ] All acceptance criteria in `docs/BASELINE.md` met
- [ ] No custom addons, OCA paths, or IPAI references present
- [ ] No MCP config (`.mcp.json`) or MCP docs present
- [ ] Repo is PR-ready and reviewable

## Locked end state

After all hardening and cleanup steps above are complete, this repo is:

- **Frozen clean-room baseline** — Phase 0 only on `main`
- **Protected reference repo** — no direct pushes, no force pushes
- **No feature growth beyond baseline maintenance**
- **No Databricks / Genie / platform / custom business scope**

**Next repos:** Do not extend `odoo19-clean` further. The next build-out belongs in:

| Repo | Purpose |
|---|---|
| `Insightpulseai/odoo` | Canonical Odoo runtime repo |
| `Insightpulseai/lakehouse` | Databricks / ETL / metric-view |
| `Insightpulseai/genie-bi` | Semantic layer / Genie / BI |
| `Insightpulseai/infra` | Infrastructure / platform IaC |
| `Insightpulseai/ops-platform` | Ops and platform tooling |

`odoo19-clean` is the reference baseline only.

