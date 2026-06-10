---
name: tm-sync
description: Sync team memory with Git. Use when the user asks to pull, push, publish, sync, or make newly ingested team memory available to the team.
---

# tm-sync

Synchronize the private team memory repo with Git.

## Workflow

1. Run a dry-run when scope is unclear:

   ```bash
   bin/memory-sync --project <project> --dry-run
   ```

2. Sync the intended scope:

   ```bash
   bin/memory-sync --project <project> --member <github>
   ```

   Use exact paths when the current session touched specific files:

   ```bash
   bin/memory-sync --paths context/records/projects/<project>/<record>.md context/wiki/projects/<project>/current-context.md --member <github>
   ```

   Use broad sync only for intentional repository-wide memory updates:

   ```bash
   bin/memory-sync --all --member <github>
   ```

3. Push only after explicit approval, because this writes to an external Git
   remote:

   ```bash
   bin/memory-sync --project <project> --member <github> --push
   ```

After sync, use `tm-share` when the update should be announced to humans.

## Guardrails

- `memory-sync` stages only the selected plan and writes `MEMORY_VERSION`.
- It refuses unrelated staged files and dirty team-memory files outside the plan.
- It refuses missing or unlisted members; use a GitHub username from `.github/team-memory-members.yml`.
- Do not push without explicit approval.
- If verification, secret scan, registry validation, or citation checks fail, do not commit.
