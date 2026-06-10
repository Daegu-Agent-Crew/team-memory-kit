---
name: tm-upgrade
description: Upgrade a private team memory repo to a newer team-memory-kit release. Use when the user asks to update, upgrade, or refresh installed memory helpers or skills.
---

# tm-upgrade

Use this as the human-facing upgrade workflow. People should invoke `/tm-upgrade`;
`bin/memory-upgrade` is the deterministic engine the skill runs.

## Workflow

1. Locate the source `team-memory-kit` checkout. Prefer an explicit user-provided
   path, then `TEAM_MEMORY_KIT_ROOT`, then the current repo if it contains
   `PRODUCT_MANIFEST`, `VERSION`, `bin/`, `skills/`, and
   `templates/team-memory-repo/`.
2. Locate the target private team memory repo. Usually this is the current repo
   if it contains `MEMORY_VERSION` and `context/`.
3. Run a dry-run first:

   ```bash
   <kit-repo>/bin/memory-upgrade --source <kit-repo> --dry-run <team-memory-repo>
   ```

4. If the plan only updates product-owned files, apply it:

   ```bash
   <kit-repo>/bin/memory-upgrade --source <kit-repo> <team-memory-repo>
   ```

5. Inspect status:

   ```bash
   bin/memory-status
   ```

6. Use `tm-sync` only after review if the upgraded private repo changes should
   be committed or pushed.

## Guardrails

- Upgrade only paths listed in `PRODUCT_MANIFEST`.
- Stale `bin/memory-*` helpers and `skills/tm-*` skills are product-owned and
  may be pruned when they are no longer listed in `PRODUCT_MANIFEST`.
- Do not edit `context/`, `MEMORY_VERSION`, registries, member allowlists, or
  share drafts as part of an upgrade.
- Do not push. Use `tm-sync` after the user reviews the local changes.
- If `memory-verify` fails after upgrade, stop and report the verification
  failure before syncing.
