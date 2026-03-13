# Repo Hardening Runbook — odoo19-clean

This document is the exact step-by-step runbook to lock down `main` after
the baseline CI is merged.  
Execute in order. Each step maps to a GitHub Settings screen or API call.

---

## 1. Baseline CI (already merged)

The baseline CI workflow (`.github/workflows/ci.yml`) adds four enforcement jobs:

| Job | Enforces |
|---|---|
| `shell-lint` | `shellcheck` on all `scripts/*.sh` |
| `scope-guard` | Blocks forbidden dirs/files (`ipai_*`, OCA paths, Databricks, Genie/BI, Terraform, Bicep, `.mcp.json`) |
| `db-name-check` | Only canonical DB names in scripts/config |
| `required-files` | Baseline skeleton files must all be present |

**Verify:** ensure the four jobs ran and passed on the `main` HEAD commit before
proceeding to the remaining hardening steps below.

---

## 2. GitHub repository General settings

**Where:** `Settings → General`

Apply these settings after the baseline CI is on `main`.

| Setting | Value |
|---|---|
| Template repository | Off |
| Wikis | **Off** — all docs are versioned in-repo; a wiki creates a second undisciplined documentation surface that will drift |
| Issues | On |
| Discussions | Off |
| Projects | Off |
| Sponsorships | Off |
| Allow merge commits | **Off** — squash-only history |
| Allow squash merging | **On** |
| Allow rebase merging | **Off** |
| Always suggest updating branches | On |
| Allow auto-merge | Off |
| Automatically delete head branches | **On** — keeps branch list clean |
| Require contributors to sign off on web-based commits | On |

> **Why wikis off?** This repo is a frozen clean-room baseline. All authoritative
> documentation must live in `README.md`, `docs/`, and `spec/` — versioned
> alongside code and CI. A GitHub wiki is a separate surface not tracked by
> `git`, not validated by CI, and not subject to CODEOWNERS review. It will
> drift. Disable it.

---

## 3. Actions approval policy

**Where:** `Settings → Actions → General → Fork pull request workflows`

**Set:**

> **Require approval for all outside collaborators**

This prevents untrusted workflow runs from executing before a maintainer
approves them. It is the correct setting for a personal public repo.

---

## 4. Branch protection ruleset for `main`

**Where:** `Settings → Branches → Add branch ruleset` (or classic rule on `main`)

### Required settings

| Setting | Value |
|---|---|
| Branch name pattern | `main` |
| Require a pull request before merging | ✅ enabled |
| Required approvals | `1` |
| Dismiss stale approvals when new commits are pushed | ✅ enabled |
| Require review from Code Owners | ✅ enabled (enforces `.github/CODEOWNERS`) |
| Require status checks to pass before merging | ✅ enabled |
| Require branches to be up to date before merging | ✅ enabled |
| Allow force pushes | ❌ disabled |
| Allow deletions | ❌ disabled |

### Required status checks

After the CI workflow has run at least once on `main`, add these four checks:

```
shell-lint
scope-guard
db-name-check
required-files
```

**CodeQL / code scanning:** If GitHub code scanning is consistently present on
`main` (i.e. a CodeQL workflow has run at least once), add it as a required
check too. If it is not yet stable on this repo, leave it non-required for now.

**Note:** GitHub only allows selecting a check as "required" after it has
completed successfully at least once in the repository. Ensure the CI workflow
has run on `main` before adding the required checks.

---

## 5. CODEOWNERS enforcement

`.github/CODEOWNERS` maps all files to `@jgtolentino`.

For CODEOWNERS review to be enforced, the branch protection rule
**"Require review from Code Owners"** must be enabled (step 3 above).

Once enabled, any PR touching any file will require `@jgtolentino` approval
before merge, regardless of who opened the PR.

---

## 6. Verify the protection is active

After applying the settings above:

1. Open `Settings → Branches` — confirm `main` shows a ✅ lock icon.
2. Attempt a direct push to `main`:
   ```bash
   git push origin main
   ```
   It must be rejected with:
   ```
   remote: error: GH006: Protected branch update failed for refs/heads/main.
   ```
3. Open a test PR — confirm the four status checks appear as required.

---

## 7. Desired end state

After completing this runbook, `odoo19-clean` has:

- ✅ Frozen clean-room baseline docs, Dockerfile, compose, config
- ✅ Smoke/init scripts for `odoo_dev` and `odoo_dev_demo`
- ✅ Canonical DB naming enforced by CI
- ✅ Scope-creep guard blocking all forbidden dirs/files
- ✅ Required-files guard keeping baseline skeleton intact
- ✅ Shell-lint keeping scripts syntactically correct
- ✅ `CODEOWNERS` requiring owner review on all PRs
- ✅ `main` protected: PR required, status checks required, force-push blocked, deletion blocked

**This repo must not grow beyond baseline maintenance.**  
The next allowed scope additions are `queue_job` and `auditlog` only, on a
separate Phase 1 branch, after all Phase 0 acceptance criteria pass locally.

---

## 8. Branch cleanup

Once baseline branches have been merged to `main`:

1. **Delete merged PR branches** — they will be auto-deleted if "Automatically delete head branches" is on.
2. **Confirm only `main` remains** in `Settings → Branches`.

---

## Locked end state

After these steps, `odoo19-clean` is treated as:

- **Frozen clean-room baseline** — Phase 0 only on `main`
- **Protected reference repo** — no direct pushes, no force pushes
- **No feature growth beyond baseline maintenance**
- **No Databricks / Genie / platform / custom business scope**

### Next repos

Do **not** extend `odoo19-clean` further. The next real build-out belongs in:

| Repo | Purpose |
|---|---|
| `Insightpulseai/odoo` | Canonical Odoo runtime repo |
| `Insightpulseai/lakehouse` | Databricks / ETL / metric-view |
| `Insightpulseai/genie-bi` | Semantic layer / Genie / BI |
| `Insightpulseai/infra` | Infrastructure / platform IaC |
| `Insightpulseai/ops-platform` | Ops and platform tooling |

`odoo19-clean` is the reference baseline only. Use it for clean Odoo 19 runtime
sanity, DB init sanity, smoke-path validation, and future comparison against
canonical repos.

---

## Assumptions and deferred items

| Item | Status |
|---|---|
| Docker runtime local validation | Deferred — requires Docker on a dev machine |
| `/web/health` smoke test in CI | Deferred — would need a running stack (integration CI, not unit) |
| Dependabot for `actions/checkout` pin | Can be added; deferred pending org policy |
| Signed commits (web-based) | Apply in `Settings → General` → Require contributors to sign off on web-based commits |
| CodeQL as required check | Add after code scanning workflow runs successfully once on `main` |
