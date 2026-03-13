# Target Architecture — odoo19-clean

> **Scope:** This document describes the desired end state of **this repository only** —
> `odoo19-clean` as a frozen clean-room Odoo 19 baseline.  
> It does not describe the full production Odoo platform or any other repo.

---

## What this repo is

`odoo19-clean` is a **frozen clean-room control specimen** for Odoo 19.

Its sole purpose is to answer with certainty:

> _Does a vanilla Odoo 19 stack start, initialise a database, and serve the web UI correctly?_

It provides:

- A reproducible, minimal Docker runtime (official `odoo:19` image, unmodified)
- Helper scripts for stack management and DB initialisation
- Canonical DB naming and boundary enforcement via CI
- A versioned baseline against which all future addon layering is benchmarked

---

## What this repo is not

| This repo is NOT… | Because… |
|---|---|
| The real Odoo runtime | That lives in the canonical delivery repos |
| An OCA addon host | OCA modules land on a Phase 1 branch, never on `main` |
| An IPAI integration repo | IPAI addons are Phase 2+, on their own branch |
| A wiki | All docs are versioned in-repo alongside CI and code |
| A Slack integration hub | Integrations belong on active delivery repos |
| A template repo | It is a control specimen, not a scaffold |

---

## Desired end state (frozen baseline)

When this repo is in its final correct state, `main` must contain exactly:

### Repository structure

```
.github/
  CODEOWNERS                 # Requires @jgtolentino review on all PRs
  workflows/
    ci.yml                   # Four enforcement jobs (see CI section below)
config/
  clean/
    odoo.conf                # Minimal Odoo config — no custom addons_path
docker/
  Dockerfile.clean           # FROM odoo:19 — unmodified official image
docs/
  BASELINE.md                # Frozen baseline rules and acceptance criteria
  HARDENING.md               # Branch protection and GitHub Settings runbook
  architecture/
    TARGET_ARCHITECTURE.md   # This file — desired end state
requirements.txt             # Empty; Odoo.sh-style Python dep declaration
scripts/
  down.sh                    # Stop the stack
  init_db.sh                 # Init odoo_dev (base only, no demo)
  init_demo_db.sh            # Init odoo_dev_demo (demo data, broad core apps)
  up.sh                      # Start the stack
spec/
  clean-odoo/
    constitution.md          # Governance principles
    plan.md                  # Roadmap and phase sequence
    prd.md                   # Product requirements
    tasks.md                 # Implementation checklist
docker-compose.yml           # db (postgres:16) + odoo — no custom mounts
.env.example                 # Example environment variables
.gitignore
README.md
```

**No other directories or files.** Any PR that adds directories outside this
structure must be blocked by the `scope-guard` CI job.

---

## Canonical database model

| Database | Role | Demo data | Addon scope |
|---|---|---|---|
| `odoo_dev` | Clean control development DB | ❌ | `base` only |
| `odoo_dev_demo` | Auxiliary showroom/demo DB | ✅ | Broad available core apps |
| `odoo_staging` | Staging rehearsal DB | ❌ | Mirrors production |
| `odoo` | Production DB | ❌ | Production-only |

Only these four names are canonical. The `db-name-check` CI job enforces
that no other DB name appears in `scripts/` or `config/`.

---

## CI boundary enforcement

Four parallel jobs run on every push and PR. All jobs use `permissions: contents: read`.

| Job | What it enforces |
|---|---|
| `shell-lint` | `shellcheck` on all `scripts/*.sh` — no syntax errors |
| `scope-guard` | Blocks: `ipai_*`, `addons/{oca,ipai,local}`, `databricks`, `genie`, `powerbi`, `terraform`, `bicep`, `.mcp.json` |
| `db-name-check` | Only canonical DB names in `scripts/` and `config/` |
| `required-files` | All baseline skeleton files must be present |

All four jobs must pass before any PR can be merged into `main`.

---

## GitHub repository settings (desired state)

Settings that cannot be expressed in files — must be applied in GitHub UI.

### General

| Setting | Value |
|---|---|
| Template repository | Off |
| Wikis | **Off** — docs live in-repo, not in a separate wiki surface |
| Issues | On |
| Discussions | Off |
| Projects | Off |
| Sponsorships | Off |
| Allow merge commits | **Off** |
| Allow squash merging | **On** |
| Allow rebase merging | **Off** |
| Always suggest updating branches | On |
| Allow auto-merge | Off |
| Automatically delete head branches | **On** |
| Require contributors to sign off on web-based commits | On |

### Branch protection — `main`

| Setting | Value |
|---|---|
| Require pull request before merging | ✅ |
| Required approvals | 1 |
| Dismiss stale approvals when new commits pushed | ✅ |
| Require review from Code Owners | ✅ (enforces `.github/CODEOWNERS`) |
| Require status checks to pass | ✅ |
| Require branches to be up to date | ✅ |
| Block force pushes | ✅ |
| Block branch deletion | ✅ |

### Required status checks

```
shell-lint
scope-guard
db-name-check
required-files
```

### Actions approval policy

`Settings → Actions → General → Fork pull request workflows`:

> **Require approval for all outside collaborators**

---

## Documentation authority

All authoritative documentation lives in-repo, version-controlled alongside
code and CI. There is no wiki.

| Document | Content |
|---|---|
| `README.md` | What this repo is / is not; canonical DB names; quickstart |
| `docs/BASELINE.md` | Frozen baseline rules; acceptance criteria |
| `docs/HARDENING.md` | Branch protection and GitHub Settings runbook |
| `docs/architecture/TARGET_ARCHITECTURE.md` | Desired end state (this file) |
| `spec/clean-odoo/constitution.md` | Governance principles |
| `spec/clean-odoo/plan.md` | Roadmap and phase sequence |
| `spec/clean-odoo/prd.md` | Product requirements |
| `spec/clean-odoo/tasks.md` | Implementation checklist |

**The wiki must remain disabled.** Any documentation added to the GitHub wiki
is authoritative for nothing — it will drift from these files and must be
removed.

---

## Phase sequence

This repo evolves strictly in phases. Each phase is a separate branch.
`main` only advances when the current phase's acceptance criteria pass locally.

| Phase | Branch | Scope |
|---|---|---|
| **Phase 0** | `main` | Vanilla Odoo 19; no addons; two canonical DBs |
| **Phase 0b** | `main` | Demo/showroom DB (`odoo_dev_demo`) alongside clean DB |
| **Phase 1** | `phase-1/oca-baseline` | `queue_job` + `auditlog` only — nothing else |
| **Phase 2** | `phase-2/ipai-addons` | IPAI addon layer on top of Phase 1 |

**Phase 1 does not start until Phase 0 local validation passes.**

---

## Integrations

| Integration | Status | Reason |
|---|---|---|
| GitHub Actions CI | ✅ active | Boundary enforcement |
| Dependabot | Deferred | Add when org policy is set |
| Slack notifications | ❌ not here | Belongs on active delivery repos |
| CodeSpaces | Tooling only | Not for redefining runtime contract |
| Any third-party app | ❌ | This is a frozen baseline repo |
