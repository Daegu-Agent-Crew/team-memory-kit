---
name: tm-load
description: Load project memory for the current repository.
---

# tm-load

Load the smallest useful project memory before related work.

Run:

```bash
bin/memory-load
```

Then read the listed project registry, current wiki, and recent source records.
If project resolution fails, ask which project applies instead of silently using
`misc`.

For a fuller preflight view, run:

```bash
bin/memory-status
```

When browsing context in the Codex app would help, create or refresh the local
mirror:

```bash
bin/memory-link-context --project <project>
```

Read in this order:

- `context/registry/projects/<project>.yml`
- repository and messenger registry entries for the project
- `context/wiki/projects/<project>/current-context.md`
- recent or keyword-matched records under `context/records/projects/<project>/`

Files under `team-memory-context/<project>/` are live symlinks to the original
team memory context. Treat them as editable source paths, not detached copies.
