# team-memory-kit

Open-source, Git-native team memory for small AI-native development teams.

`team-memory-kit` turns agent-assisted work into durable, approved,
agent-reloadable context. Git stores the memory. Slack, Discord, email, or
another messenger announces the memory. Agents load the memory on the next task.

The core loop:

```text
memory-load -> memory-ingest -> memory-wiki -> memory-verify -> memory-sync -> memory-share-plan
```

## Quickstart

Create a private, self-contained team memory repo:

```bash
git clone <this-repo-url> team-memory-kit
cd team-memory-kit
bin/memory-init ../my-team-memory
cd ../my-team-memory
./setup --host codex
bin/memory-setup
```

Then edit:

- `.github/team-memory-members.yml`
- `context/registry/projects/team-memory.yml`
- `context/registry/repositories/team-memory.yml`
- `context/registry/messengers/channels/general.yml`

Ingest the first note:

```bash
bin/memory-ingest \
  --project team-memory \
  --member your-github-username \
  --source-type codex-session \
  --title "First memory note" \
  /path/to/note.md

bin/memory-wiki --project team-memory
bin/memory-verify
bin/memory-sync
bin/memory-share-plan --project team-memory --title "First memory update"
```

## What Ships

```text
bin/                         generic CLI helpers
skills/                      Codex/Claude skill docs, all prefixed tm-
templates/team-memory-repo/  private memory repo skeleton
tests/                       shell integration tests
docs/design/                 product design history
```

CLI commands use the explicit `memory-*` prefix. Agent skills use the shorter
`tm-*` prefix, for example `/tm-load`, `/tm-ingest`, `/tm-wiki`, `/tm-sync`, and
`/tm-share`.

## Commands

- `memory-init`: creates a private team memory repo from the template.
- `memory-setup`: checks dependencies, member allowlist, and registry shape.
- `memory-project`: resolves the current Git repo to a memory project.
- `memory-project-register`: maps the current repo to an existing or new project.
- `memory-load`: prints registry, wiki, and recent record pointers for agents.
- `memory-ingest`: creates append-only source records.
- `memory-wiki`: regenerates cited project wiki context from records.
- `memory-secret-scan`: scans for obvious credentials and team denylist markers.
- `memory-verify`: validates records, members, registry, citations, and safety.
- `memory-sync`: runs verification and prints Git sharing next steps.
- `memory-share-plan`: drafts an approval-gated Slack/Discord/email/chat update.

## Model

Records are source of truth:

```text
context/records/projects/<project>/YYYY-MM-DD-<slug>.md
```

Wiki files are reloadable summaries:

```text
context/wiki/projects/<project>/current-context.md
```

Wiki citations must point at existing records:

```markdown
[source: context/records/projects/<project>/<file>.md]
```

Messenger posts are notifications only. They should link back to Git source
records, wiki files, commits, or pull requests.

## Pre-Implementation Patterns

Before writing code, run one of three agent-assisted patterns to reduce
rework: blind-spot sweep, brainstorm, or interview. See
[Pre-Implementation Patterns](docs/guides/pre-implementation-patterns.md).

The `tm-preimpl` skill automates the workflow and connects outputs to team
memory via `memory-ingest`.

## Safety

- Capture is explicit. No silent chat surveillance.
- Records are append-only by default.
- `misc` is blocked by verification unless explicitly handled outside the
  default path.
- Secret scanning runs before records are written and before sync.
- Team-specific private markers belong in `context/policies/denylist.txt`.
- External sharing is draft-first and requires human approval.

## Development

Run tests:

```bash
tests/run.sh
```

The product design that led to this implementation lives at:

- [Small Team Memory Kit Design](docs/design/2026-05-29-small-team-memory-kit.md)
