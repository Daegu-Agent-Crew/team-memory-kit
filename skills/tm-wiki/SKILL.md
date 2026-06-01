---
name: tm-wiki
description: Regenerate citation-backed project wiki files from source records.
---

# tm-wiki

Run:

```bash
bin/memory-wiki --project <project>
bin/memory-verify
```

Wiki is not raw transcript storage. Keep it short enough for future agent
sessions to load, and cite source records with:

```markdown
[source: context/records/projects/<project>/<file>.md]
```

If records disagree, preserve the conflict instead of smoothing it away.
