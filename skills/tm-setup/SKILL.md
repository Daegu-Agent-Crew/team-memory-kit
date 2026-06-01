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
./setup --host codex
```

If setup reports missing members, ask the user for the responsible GitHub
username and add it to `.github/team-memory-members.yml` only after confirmation.
