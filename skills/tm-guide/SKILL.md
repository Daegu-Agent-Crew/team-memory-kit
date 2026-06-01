---
name: tm-guide
description: Route team-memory-kit workflows and explain which memory-* command to use.
---

# tm-guide

Use this when the user is unsure which team memory workflow applies.

Core loop:

```bash
bin/memory-load
bin/memory-ingest --project <project> --member <github> --source-type codex-session --title "<title>" <file>
bin/memory-wiki --project <project>
bin/memory-verify
bin/memory-sync
bin/memory-share-plan --project <project> --title "<summary>"
```

Route:

- Load context before work: `tm-load`
- Save durable context: `tm-ingest`
- Refresh cited summaries: `tm-wiki`
- Check safety and citations: `memory-verify`
- Prepare Git sharing: `tm-sync`
- Draft messenger announcement: `tm-share`

Never write to external messengers before showing the exact destination and body
and receiving explicit approval.
