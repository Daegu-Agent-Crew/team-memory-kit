# Team Memory Repo

Private Git-native memory for an AI-native team.

The daily loop:

```text
memory-load -> memory-ingest -> memory-wiki -> memory-verify -> memory-sync -> memory-share-plan
```

## First Setup

```bash
./setup --host codex
bin/memory-setup
```

Then edit:

- `.github/team-memory-members.yml`
- `context/registry/projects/team-memory.yml`
- `context/registry/repositories/team-memory.yml`
- `context/registry/messengers/channels/general.yml`

Commit the generated baseline after editing the template values:

```bash
git add .
git commit -m "chore: initialize team memory"
```

## Ingest A Note

```bash
bin/memory-ingest \
  --project team-memory \
  --member your-github-username \
  --source-type codex-session \
  --title "First team memory note" \
  /path/to/note.md

bin/memory-wiki --project team-memory
bin/memory-verify
bin/memory-sync --project team-memory --member your-github-username
bin/memory-share-plan --project team-memory --title "First memory update"
```

`memory-sync` commits scoped team-memory changes locally. It pushes only when
you pass `--push` after reviewing the destination:

```bash
bin/memory-sync --project team-memory --member your-github-username --push
```

Use `bin/memory-status` to inspect the resolved project, verification result,
Git status, and recent context. Use `bin/memory-link-context --project
team-memory` to create a local `team-memory-context/team-memory/` symlink
mirror for easier browsing.

## Record Model

Records live at:

```text
context/records/projects/<project>/YYYY-MM-DD-<slug>.md
```

Wiki citations must point at existing records:

```markdown
[source: context/records/projects/<project>/<file>.md]
```

## Safety

- Records are append-only by default.
- Sync commits record the responsible GitHub member in `MEMORY_VERSION` and Git trailers.
- Messenger posts are drafts until a human approves the exact destination and body.
- Do not store secrets, private credentials, customer data, or unrelated private context.
- Add team-specific blocked words to `context/policies/denylist.txt`.
