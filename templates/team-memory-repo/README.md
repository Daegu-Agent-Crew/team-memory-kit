# Team Memory Repo

Private Git-native memory for an AI-native team.

The daily loop:

```text
memory-load -> memory-ingest -> memory-wiki -> memory-verify -> memory-sync -> memory-share-plan
```

## First Setup

```bash
./setup --host codex   # or --host claude for Claude Code, --host auto for both
bin/memory-setup
```

Then edit:

- `.github/team-memory-members.yml`
- `context/registry/projects/team-memory.yml`
- `context/registry/repositories/team-memory.yml`
- `context/registry/messengers/channels/general.yml`

## Ingest A Note

```bash
bin/memory-ingest \
  --project team-memory \
  --member your-github-username \
  --source-type codex-session \
  --title "First team memory note" \
  /path/to/note.md
# use --source-type claude-session for Claude Code sessions

bin/memory-wiki --project team-memory
bin/memory-verify
bin/memory-sync
bin/memory-share-plan --project team-memory --title "First memory update"
```

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
- Messenger posts are drafts until a human approves the exact destination and body.
- Do not store secrets, private credentials, customer data, or unrelated private context.
- Add team-specific blocked words to `context/policies/denylist.txt`.
