# Constitution — clean-odoo

## Governing principles

1. **This repository is a control specimen.** It must remain free of custom addons, integrations, and infrastructure tooling at all times during Phase 0.

2. **No addon layering in Phase 0.** The only code running is the official `odoo:19` image. Nothing is mounted, copied, or installed beyond what that image provides plus the minimal `odoo.conf`.

3. **Changes must be intentional and documented.** Every deviation from a clean baseline must be recorded in `docs/BASELINE.md` and tracked through a dedicated phase.

4. **Idempotency is required.** Running `scripts/up.sh` and `scripts/init_db.sh` multiple times must produce the same result without manual intervention.

5. **Minimal surface area.** The repo must never contain secrets, local-machine paths, editor configs, or cloud-provider credentials.
