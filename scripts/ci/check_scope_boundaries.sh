#!/usr/bin/env bash
# check_scope_boundaries.sh — Fail if banned paths or files exist in the repo tree.
# Designed to run locally or in CI. No external dependencies.
set -euo pipefail

REPO_ROOT="${1:-.}"
FAILED=0

fail() { echo "FAIL: $1"; FAILED=1; }

echo "Checking scope boundaries in ${REPO_ROOT}"
echo "---"

# Banned directories (anywhere in tree, case-insensitive)
BANNED_DIRS=(
  "addons"
  "supabase"
  "apps"
  "packages"
  "runtime"
  "n8n"
  "mcp"
  "databricks"
  "genie"
  "powerbi"
  "power_bi"
  "terraform"
  "bicep"
)

for dir in "${BANNED_DIRS[@]}"; do
  if find "${REPO_ROOT}" -not -path '*/.git/*' -type d -iname "${dir}" 2>/dev/null | grep -q .; then
    fail "Forbidden directory: '${dir}'"
    find "${REPO_ROOT}" -not -path '*/.git/*' -type d -iname "${dir}"
  fi
done

# Banned files
BANNED_FILES=(
  ".mcp.json"
)

for fname in "${BANNED_FILES[@]}"; do
  if find "${REPO_ROOT}" -not -path '*/.git/*' -name "${fname}" 2>/dev/null | grep -q .; then
    fail "Forbidden file: '${fname}'"
    find "${REPO_ROOT}" -not -path '*/.git/*' -name "${fname}"
  fi
done

# Banned file patterns (ipai_* anywhere)
if find "${REPO_ROOT}" -not -path '*/.git/*' -name "ipai_*" 2>/dev/null | grep -q .; then
  fail "Forbidden ipai_* files detected"
  find "${REPO_ROOT}" -not -path '*/.git/*' -name "ipai_*"
fi

# Odoo addon manifests (__manifest__.py) — no custom addons allowed
if find "${REPO_ROOT}" -not -path '*/.git/*' -name "__manifest__.py" 2>/dev/null | grep -q .; then
  fail "__manifest__.py detected — custom Odoo addons are forbidden in this repo"
  find "${REPO_ROOT}" -not -path '*/.git/*' -name "__manifest__.py"
fi

# Top-level directory allowlist — reject anything outside the approved set
ALLOWED_TOP_LEVEL_DIRS=("config" "docker" "docs" "scripts" "spec" "ssot" ".github")
while IFS= read -r d; do
  basename_d=$(basename "${d}")
  allowed=0
  for allowed_dir in "${ALLOWED_TOP_LEVEL_DIRS[@]}"; do
    if [ "${basename_d}" = "${allowed_dir}" ]; then
      allowed=1
      break
    fi
  done
  if [ "${allowed}" -eq 0 ]; then
    fail "Non-approved top-level directory: '${basename_d}' — not in allowlist"
  fi
done < <(find "${REPO_ROOT}" -mindepth 1 -maxdepth 1 -not -path '*/.git' -type d 2>/dev/null)

echo "---"
if [ "${FAILED}" -ne 0 ]; then
  echo ""
  echo "This repo is a frozen clean-room baseline (odoo19-clean)."
  echo "No OCA, IPAI, Databricks, Genie/BI, platform IaC, or custom addons are allowed here."
  echo "See docs/SCOPE_BOUNDARY.md for the full boundary rules."
  exit 1
fi

echo "Result: No forbidden scope detected — boundaries intact"
