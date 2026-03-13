#!/usr/bin/env bash
# check_repo_settings.sh — Assert GitHub repo settings match frozen-baseline policy.
# Read-only: queries the GitHub API, never modifies anything.
# Requires: gh CLI authenticated with repo read access.
set -euo pipefail

REPO="${REPO:-jgtolentino/odoo19-clean}"
FAILED=0

fail() { echo "FAIL: $1"; FAILED=1; }
pass() { echo "  OK: $1"; }

echo "Auditing GitHub settings for ${REPO}"
echo "---"

# Fetch repo settings once
SETTINGS=$(gh api "repos/${REPO}" 2>/dev/null) || {
  echo "ERROR: Cannot reach GitHub API for ${REPO}"
  exit 2
}

check_bool() {
  local field="$1" expected="$2" label="$3"
  actual=$(echo "${SETTINGS}" | jq -r ".${field}")
  if [ "${actual}" = "${expected}" ]; then
    pass "${label} = ${expected}"
  else
    fail "${label}: expected ${expected}, got ${actual}"
  fi
}

check_bool "has_wiki"                    "false" "Wiki disabled"
check_bool "has_projects"                "false" "Projects disabled"
check_bool "delete_branch_on_merge"      "true"  "Delete head branches on merge"
check_bool "allow_merge_commit"          "false" "Merge commits disabled"
check_bool "allow_squash_merge"          "true"  "Squash merge enabled"
check_bool "allow_rebase_merge"          "false" "Rebase merge disabled"
check_bool "allow_auto_merge"            "false" "Auto-merge disabled"
check_bool "web_commit_signoff_required" "true"  "Web commit signoff required"

echo "---"

# Branch protection checks
echo "Auditing branch protection for main"
PROTECTION=$(gh api "repos/${REPO}/branches/main/protection" 2>/dev/null) || {
  fail "No branch protection on main"
  echo ""
  echo "Result: ${FAILED} failure(s)"
  exit 1
}

# Required status checks
STRICT=$(echo "${PROTECTION}" | jq -r '.required_status_checks.strict')
if [ "${STRICT}" = "true" ]; then
  pass "Strict status checks enabled"
else
  fail "Strict status checks: expected true, got ${STRICT}"
fi

REQUIRED_CHECKS=("shell-lint" "scope-guard" "db-name-check" "required-files")
for check in "${REQUIRED_CHECKS[@]}"; do
  if echo "${PROTECTION}" | jq -r '.required_status_checks.contexts[]' | grep -qx "${check}"; then
    pass "Required check: ${check}"
  else
    fail "Missing required check: ${check}"
  fi
done

# PR review requirements
APPROVALS=$(echo "${PROTECTION}" | jq -r '.required_pull_request_reviews.required_approving_review_count')
if [ "${APPROVALS}" -ge 1 ] 2>/dev/null; then
  pass "PR approvals required: ${APPROVALS}"
else
  fail "PR approvals: expected >= 1, got ${APPROVALS}"
fi

CODEOWNERS=$(echo "${PROTECTION}" | jq -r '.required_pull_request_reviews.require_code_owner_reviews')
if [ "${CODEOWNERS}" = "true" ]; then
  pass "CODEOWNERS review required"
else
  fail "CODEOWNERS review: expected true, got ${CODEOWNERS}"
fi

# History and force-push
LINEAR=$(echo "${PROTECTION}" | jq -r '.required_linear_history.enabled')
if [ "${LINEAR}" = "true" ]; then
  pass "Linear history enforced"
else
  fail "Linear history: expected true, got ${LINEAR}"
fi

FORCE_PUSH=$(echo "${PROTECTION}" | jq -r '.allow_force_pushes.enabled')
if [ "${FORCE_PUSH}" = "false" ]; then
  pass "Force push blocked"
else
  fail "Force push: expected blocked, got allowed"
fi

DELETIONS=$(echo "${PROTECTION}" | jq -r '.allow_deletions.enabled')
if [ "${DELETIONS}" = "false" ]; then
  pass "Branch deletion blocked"
else
  fail "Branch deletion: expected blocked, got allowed"
fi

echo "---"
if [ "${FAILED}" -ne 0 ]; then
  echo "Result: ${FAILED} failure(s) — repo settings have drifted from frozen-baseline policy"
  exit 1
fi

echo "Result: All checks passed — repo settings match frozen-baseline policy"
