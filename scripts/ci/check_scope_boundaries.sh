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

# Banned addon paths
BANNED_ADDON_PATHS=(
  "addons/oca"
  "addons/ipai"
  "addons/local"
)

for addon_path in "${BANNED_ADDON_PATHS[@]}"; do
  if find "${REPO_ROOT}" -not -path '*/.git/*' -type d -iwholename "*/${addon_path}" 2>/dev/null | grep -q .; then
    fail "Forbidden addon path: '${addon_path}'"
    find "${REPO_ROOT}" -not -path '*/.git/*' -type d -iwholename "*/${addon_path}"
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

echo "---"
if [ "${FAILED}" -ne 0 ]; then
  echo ""
  echo "This repo is a frozen clean-room baseline (odoo19-clean)."
  echo "No OCA, IPAI, Databricks, Genie/BI, or platform IaC is allowed here."
  echo "See docs/BASELINE.md for the boundary rules."
  exit 1
fi

echo "Result: No forbidden scope detected — boundaries intact"
