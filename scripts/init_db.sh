#!/usr/bin/env bash
set -euo pipefail

# Verify the odoo container is running before attempting init.
if ! docker compose ps --services --filter "status=running" | grep -q "^odoo$"; then
  echo "ERROR: 'odoo' container is not running. Run 'bash scripts/up.sh' first." >&2
  exit 1
fi

echo "Initialising database 'odoo_dev_clean' with module 'base' (demo data disabled)..."

docker compose exec odoo odoo \
  --db_host db \
  --db_port 5432 \
  --db_user odoo \
  --db_password odoo \
  --database odoo_dev_clean \
  --init base \
  --without-demo=all \
  --stop-after-init

echo "Database 'odoo_dev_clean' initialised successfully."
echo "Open http://localhost:8069/web/login to continue."
