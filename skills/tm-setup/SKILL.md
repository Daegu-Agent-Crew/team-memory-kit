---
name: tm-setup
description: Check and install a team memory repo for Codex or Claude.
---

# tm-setup

Run:

```bash
bin/memory-setup
```

For local skill installation:

```bash
./setup --host codex   # Codex only
./setup --host claude  # Claude Code only
./setup --host auto    # both
```

For Claude Code:

```bash
./setup --host claude
```

If setup reports an existing non-link path from an older or broken install, use
repair mode after confirming the path is team-memory-managed:

```bash
./setup --host codex --repair
```

On Windows, run setup from Git Bash. If symlink creation fails, enable Windows
Developer Mode or use an elevated Git Bash, then rerun setup.

If setup reports missing members, ask the user for the responsible GitHub
username and add it to `.github/team-memory-members.yml` only after confirmation.

For an existing private team memory repo that needs newer installed helpers or
skills, use `tm-upgrade` instead of rerunning `memory-init`.

Success criteria:

- `~/.team-memory` points to this repo's `context/`.
- `~/.codex/skills/tm-*` links to the repo skills.
- Claude installs each `SKILL.md` under `~/.claude/skills/tm-*`.
- `bin/memory-setup`, `bin/memory-status`, and `bin/memory-verify` pass.
