#!/usr/bin/env bash
set -euo pipefail

# Start the clean Odoo 19 stack (build if needed).
docker compose up -d --build
echo "Stack started. Odoo will be available at http://localhost:8069 once healthy."
