#!/usr/bin/env bash
set -euo pipefail

DB_NAME="odoo_dev_clean"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${POSTGRES_USER:-odoo}"
DB_PASSWORD="${ODOO_DB_PASSWORD:-odoo}"

# Verify the odoo container is running before attempting init.
if ! docker compose ps --services --filter "status=running" | grep -q "^odoo$"; then
  echo "ERROR: 'odoo' container is not running. Run 'bash scripts/up.sh' first." >&2
  exit 1
fi

echo "Initialising database '${DB_NAME}' with module 'base' (demo data disabled)..."

docker compose exec odoo odoo \
  --db_host "${DB_HOST}" \
  --db_port "${DB_PORT}" \
  --db_user "${DB_USER}" \
  --db_password "${DB_PASSWORD}" \
  --database "${DB_NAME}" \
  --init base \
  --without-demo=all \
  --stop-after-init

echo "Database '${DB_NAME}' initialised successfully."
echo "Open http://localhost:8069/web/login to continue."
