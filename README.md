# team-memory-kit

Open-source, Git-native team memory for small AI-native development teams.

`team-memory-kit` helps teams turn agent-assisted work into durable, approved,
agent-reloadable context. GitHub stores the memory. Slack, Discord, or another
messenger announces the memory. Agents use the memory on the next task.

The core loop:

```text
load -> ingest -> wiki -> verify -> sync -> share
```

## Target User

Small AI-native development teams, roughly 10 people, already using coding
agents such as Codex, Claude Code, Cursor, or similar tools.

These teams generate lots of planning docs, research notes, implementation
notes, and decisions through agent workflows. The hard part is no longer writing
more documents. The hard part is preserving the right context, making it safe to
share, and making it easy for the next agent session to reload.

## Product Thesis

Notion is for humans to browse. This is memory for AI agents to reload.

The kit is intentionally explicit. A teammate invokes a command or skill when a
session, note, or decision deserves to become team memory. The system drafts a
source record, regenerates cited wiki context, verifies safety, syncs through
GitHub, and optionally shares an approved notification to Slack or Discord.

## Current Status

Design stage. See the initial product design doc:

- [Small Team Memory Kit Design](docs/design/2026-05-29-small-team-memory-kit.md)
