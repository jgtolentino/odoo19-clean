#!/usr/bin/env bash
# init_demo_db.sh — Initialise odoo_dev_demo with demo data and a broad core app set.
#
# Purpose:
#   Creates the auxiliary development showroom/demo database used for product exploration,
#   app walkthroughs, and UX/Copilot testing. Demo data is intentionally enabled here.
#   This database is separate from the canonical clean control database (odoo_dev).
#
# Usage:
#   bash scripts/init_demo_db.sh
#
# Rerun behaviour:
#   If the database already exists and is non-empty, Odoo will exit with a non-zero code.
#   The script detects this and prints a clear message instead of crashing silently.
#
# Canonical DB model:
#   odoo_dev        — clean control development DB (init_db.sh)
#   odoo_dev_demo   — showroom/demo DB (this script)
#   odoo_staging    — staging rehearsal DB
#   odoo            — production DB

set -euo pipefail

DEMO_DB_NAME=odoo_dev_demo

# ---------------------------------------------------------------------------
# 1. Guard: odoo container must be running
# ---------------------------------------------------------------------------
if ! docker compose ps --services --filter "status=running" | grep -q "^odoo$"; then
  echo "ERROR: 'odoo' container is not running. Run 'bash scripts/up.sh' first." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Detect available modules
#    We query the installed addons path for directory names rather than trying
#    to install unknown modules and failing. Any module whose directory is
#    present in the core addons path is treated as "available".
# ---------------------------------------------------------------------------
echo "Detecting available modules in the runtime image..."

ADDONS_PATH="/usr/lib/python3/dist-packages/odoo/addons"

if ! docker compose exec -T odoo test -d "${ADDONS_PATH}" 2>/dev/null; then
  echo "ERROR: addons path '${ADDONS_PATH}' not found in the container." >&2
  echo "       Is the container fully started? Try 'bash scripts/up.sh' and wait." >&2
  exit 1
fi

AVAILABLE_MODULES=$(docker compose exec -T odoo bash -c "ls '${ADDONS_PATH}'")

is_available() {
  echo "${AVAILABLE_MODULES}" | grep -qx "$1"
}

# ---------------------------------------------------------------------------
# 3. Build install list
#    Preferred modules for a broad showroom footprint.
#    Each optional module is checked for availability; missing ones are skipped.
# ---------------------------------------------------------------------------
REQUIRED_MODULES="base"

OPTIONAL_MODULES=(
  web
  mail
  contacts
  crm
  sale_management
  purchase
  stock
  project
  calendar
  discuss
  account
  documents
  website
  website_sale
  helpdesk
)

INSTALL_LIST="${REQUIRED_MODULES}"
SKIPPED_MODULES=()

echo ""
echo "Module availability check:"
for mod in "${OPTIONAL_MODULES[@]}"; do
  if is_available "${mod}"; then
    echo "  [available]  ${mod}"
    INSTALL_LIST="${INSTALL_LIST},${mod}"
  else
    echo "  [skipped]    ${mod}  (not found in addons path)"
    SKIPPED_MODULES+=("${mod}")
  fi
done

echo ""
echo "Install list: ${INSTALL_LIST}"
if [ ${#SKIPPED_MODULES[@]} -gt 0 ]; then
  echo "Skipped (unavailable in this runtime): ${SKIPPED_MODULES[*]}"
fi

# ---------------------------------------------------------------------------
# 4. Initialise the demo database
# ---------------------------------------------------------------------------
echo ""
echo "Initialising database '${DEMO_DB_NAME}' with demo data enabled..."

set +e
docker compose exec odoo odoo \
  --db_host db \
  --db_port 5432 \
  --db_user odoo \
  --db_password odoo \
  --database "${DEMO_DB_NAME}" \
  --init "${INSTALL_LIST}" \
  --stop-after-init
EXIT_CODE=$?
set -e

if [ ${EXIT_CODE} -ne 0 ]; then
  echo ""
  echo "ERROR: Odoo exited with code ${EXIT_CODE} while initialising '${DEMO_DB_NAME}'." >&2
  echo "Possible causes:" >&2
  echo "  - The database already exists and is non-empty. Drop it first:" >&2
  echo "      docker compose exec db psql -U odoo -c \"DROP DATABASE ${DEMO_DB_NAME};\"" >&2
  echo "  - A module in the install list has unresolved dependencies or conflicts." >&2
  echo "  - A network or permission error prevented the init from completing." >&2
  echo "Check the Odoo container logs for details:" >&2
  echo "      docker compose logs odoo" >&2
  exit "${EXIT_CODE}"
fi

# ---------------------------------------------------------------------------
# 5. Done
# ---------------------------------------------------------------------------
echo ""
echo "Database '${DEMO_DB_NAME}' initialised successfully with demo data."
echo "Open http://localhost:8069/web/login and select '${DEMO_DB_NAME}' to explore."
