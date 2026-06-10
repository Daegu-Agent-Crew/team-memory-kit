# team-memory-kit

Open-source, Git-native team memory for small AI-native development teams.

`team-memory-kit` turns agent-assisted work into durable, approved,
agent-reloadable context. Git stores the memory. Slack, Discord, email, or
another messenger announces the memory. Agents load the memory on the next task.

The core loop:

```text
memory-load -> memory-ingest -> memory-wiki -> memory-verify -> memory-sync -> memory-share-plan
```

## Versioning

`team-memory-kit` uses two version files:

- `VERSION`: tool and schema release version for this kit. It uses date-based
  CalVer in `YYYY.MM.DD.N` format. Increment `N` when shipping multiple releases
  on the same day. `memory-init` copies this file into generated team memory
  repos so operators can see which kit version produced the installed helpers,
  skills, and template.
- `PRODUCT_MANIFEST`: product-owned files that `memory-init` and
  `memory-upgrade` copy into generated team memory repos. This keeps install and
  upgrade surfaces identical and lets upgrades prune stale `memory-*` helpers or
  `tm-*` skills safely.
- `MEMORY_VERSION`: generated private repo snapshot metadata. `memory-sync`
  writes it when committing team memory updates, including the snapshot time,
  responsible member, sync mode, and sync scope. It is memory state, not product
  release state.

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

Commit the generated baseline after editing the template values:

```bash
git add .
git commit -m "chore: initialize team memory"
```

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
bin/memory-sync --project team-memory --member your-github-username
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
- `memory-upgrade`: refreshes generated repo product files from `PRODUCT_MANIFEST` in a newer kit checkout.
- `memory-setup`: checks dependencies, member allowlist, and registry shape.
- `memory-status`: prints runtime paths, resolved project, verification, Git status, and recent context.
- `memory-project`: resolves the current Git repo to a memory project.
- `memory-project-register`: maps the current repo to an existing or new project.
- `memory-link-context`: creates a local `team-memory-context/<project>/` symlink mirror.
- `memory-load`: prints registry, wiki, and recent record pointers for agents.
- `memory-ingest`: creates append-only source records.
- `memory-wiki`: regenerates cited project wiki context from records.
- `memory-secret-scan`: scans for obvious credentials and team denylist markers.
- `memory-verify`: validates records, members, registry, citations, and safety.
- `memory-lib-registry`: reads and validates project, repository, and messenger registry files.
- `memory-sync`: verifies, stages only the selected scope, commits, and pushes only with `--push`.
- `memory-commit-policy-check`: validates team memory commit trailers and `MEMORY_VERSION`.
- `memory-share-plan`: drafts an approval-gated Slack/Discord/email/chat update.

Useful sync modes:

```bash
bin/memory-sync --project team-memory --member your-github-username
bin/memory-sync --paths context/wiki/projects/team-memory/current-context.md --member your-github-username
bin/memory-sync --all --member your-github-username
bin/memory-sync --project team-memory --member your-github-username --push
```

`memory-sync` writes `MEMORY_VERSION` and commit trailers. It refuses unrelated
staged files and dirty team-memory files outside the selected sync plan.

`memory-status` prints both `TEAM_MEMORY_KIT_VERSION` and `MEMORY_VERSION_*`
metadata so a team can distinguish installed tool/schema version from latest
memory snapshot metadata during support or release checks.

Use `/tm-upgrade` to apply a newer kit release to an existing private team
memory repo. The skill runs `memory-upgrade` so people do not need to call the
helper directly.

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

## Safety

- Capture is explicit. No silent chat surveillance.
- Records are append-only by default.
- `misc` is blocked by verification unless explicitly handled outside the
  default path.
- Secret scanning runs before records are written and before sync.
- Sync commits identify the responsible human member from `.github/team-memory-members.yml`.
- Team-specific private markers belong in `context/policies/denylist.txt`.
- External sharing is draft-first and requires human approval.

## Development

Run tests:

```bash
tests/run.sh
```

The product design that led to this implementation lives at:

- [Small Team Memory Kit Design](docs/design/2026-05-29-small-team-memory-kit.md)
