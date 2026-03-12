#!/usr/bin/env bash
set -euo pipefail

# Stop the clean Odoo 19 stack.
docker compose down
echo "Stack stopped."
