# Repo Hardening Runbook — odoo19-clean

This document is the exact step-by-step runbook to lock down `main` after
the baseline CI (PR #4) is merged.  
Execute in order. Each step maps to a GitHub Settings screen or API call.

---

## 1. Merge PR #4

PR #4 adds `.github/workflows/ci.yml` with four enforcement jobs:

| Job | Enforces |
|---|---|
| `shell-lint` | `shellcheck` on all `scripts/*.sh` |
| `scope-guard` | Blocks forbidden dirs/files (`ipai_*`, OCA paths, Databricks, Genie/BI, Terraform, Bicep, `.mcp.json`) |
| `db-name-check` | Only canonical DB names in scripts/config |
| `required-files` | Baseline skeleton files must all be present |

**Before merging:** ensure the four jobs ran and passed on the PR head commit.

---

## 2. Actions approval policy

**Where:** `Settings → Actions → General → Fork pull request workflows`

**Set:**

> **Require approval for all outside collaborators**

This prevents untrusted workflow runs from executing before a maintainer
approves them. It is the correct setting for a personal public repo.

---

## 3. Branch protection ruleset for `main`

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

After PR #4 has run at least once on `main`, add these four checks:

```
shell-lint
scope-guard
db-name-check
required-files
```

**Note:** GitHub only allows selecting a check as "required" after it has
completed successfully at least once in the repository. Run PR #4 first,
then add the checks.

---

## 4. CODEOWNERS enforcement

`.github/CODEOWNERS` (added in this PR) maps all files to `@jgtolentino`.

For CODEOWNERS review to be enforced, the branch protection rule
**"Require review from Code Owners"** must be enabled (step 3 above).

Once enabled, any PR touching any file will require `@jgtolentino` approval
before merge, regardless of who opened the PR.

---

## 5. Verify the protection is active

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

## 6. Desired end state

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

## Assumptions and deferred items

| Item | Status |
|---|---|
| Docker runtime local validation | Deferred — requires Docker on a dev machine |
| `/web/health` smoke test in CI | Deferred — would need a running stack (integration CI, not unit) |
| Dependabot for `actions/checkout` pin | Can be added; deferred pending org policy |
| Signed commits requirement | Optional; deferred |
