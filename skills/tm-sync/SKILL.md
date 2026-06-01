---
name: tm-sync
description: Verify team memory changes and prepare Git sharing.
---

# tm-sync

Run:

```bash
bin/memory-sync
```

`memory-sync` runs `bin/memory-verify` first and prints Git status plus suggested
Git commands. It does not push. Ask for explicit approval before any write to an
external destination.

After sync, use `tm-share` when the update should be announced to humans.
