#!/usr/bin/env bash
set -euo pipefail

# Verify the odoo container is running before attempting init.
if ! docker compose ps --services --filter "status=running" | grep -q "^odoo$"; then
  echo "ERROR: 'odoo' container is not running. Run 'bash scripts/up.sh' first." >&2
  exit 1
fi

DEV_DB_NAME=odoo_dev

echo "Initialising database '${DEV_DB_NAME}' with module 'base' (demo data disabled)..."

docker compose exec odoo odoo \
  --db_host db \
  --db_port 5432 \
  --db_user odoo \
  --db_password odoo \
  --database "${DEV_DB_NAME}" \
  --init base \
  --without-demo=all \
  --stop-after-init

echo "Database '${DEV_DB_NAME}' initialised successfully."
echo "Open http://localhost:8069/web/login to continue."
