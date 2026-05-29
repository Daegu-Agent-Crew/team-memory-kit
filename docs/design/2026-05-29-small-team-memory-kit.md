# Design: Small Team Memory Kit for AI Agents

Date: 2026-05-29
Status: DRAFT
Mode: Open-source product design

## Problem Statement

Small AI-native development teams now produce a large amount of useful context
through coding agents: research notes, planning docs, implementation decisions,
failed attempts, review findings, and follow-up work. Much of that context ends
up scattered across chat sessions, pull requests, Slack or Discord threads, and
human-oriented docs.

The product should help teams explicitly promote valuable work into durable team
memory. The memory should be easy for humans to review, safe to share, and easy
for future agent sessions to reload.

This is not an AI Notion clone. Notion and messengers are human-facing surfaces.
This product is an agent-facing team memory workflow.

## Target User

The first target user is a small AI-native development team, roughly 10 people,
already using coding agents in daily work.

The team likely uses GitHub as its source of truth and keeps a paid messenger
such as Slack or Discord because notifications still matter. They want fewer
manual docs, fewer stale knowledge bases, and less copy-paste between agent
sessions and team communication tools.

## Core Insight

Most agent-memory products compete on recall. This product should compete on the
write path: explicit capture, human-approved source records, cited synthesis,
Git review, and messenger sharing.

The key product rule:

```text
GitHub stores memory. Messenger announces memory. Agents reload memory.
```

## Core Loop

```text
load -> ingest -> wiki -> verify -> sync -> share
```

### load

Bring the relevant project memory into the current agent session.

### ingest

Explicitly turn a session summary, planning note, research note, meeting note,
manual messenger excerpt, or implementation decision into a source record.

### wiki

Regenerate cited synthesis from source records. Wiki files are not the source of
truth. They are agent-readable summaries backed by source records.

### verify

Block unsafe or low-quality memory before it spreads. Verification should catch
secrets, broken citations, missing ownership, ambiguous project mapping, unsafe
share drafts, and policy violations.

### sync

Sync durable memory through GitHub, ideally through a pull request or commit that
the team can review.

### share

Draft and send an approved notification to Slack, Discord, or another messenger.
Messenger posts should link back to GitHub source of truth rather than becoming
the canonical record themselves.

## Explicit Capture

Capture should be explicit in v0.

A teammate runs a command or skill when something deserves to become team memory:

```text
/memory-ingest
```

This avoids silent surveillance logs, noisy memory stores, accidental sensitive
context capture, and low-trust automation. The system can still automate the
tedious parts after invocation: drafting records, linking sources, regenerating
wiki files, running verification, opening a PR, and preparing a share message.

## Public Core And Private Team Memory

The open-source repo should contain generic product code and examples only:

```text
spec/
bin/memory-*
skills/memory-*/
adapters/slack/
adapters/discord/
templates/team-memory-repo/
tests/
docs/
```

Each team should keep its actual memory in a private repo generated from a
template:

```text
context/records/
context/wiki/
context/registry/
context/policies/
context/share-drafts/
team config
```

The public repo should never contain private team records, real people data,
company-specific registry entries, or copied internal context.

## Share Model

`memory-share` is a first-class v0 feature, but it must be scoped tightly.

It should:

1. Resolve what changed since the last sync or selected record/wiki update.
2. Draft a concise human-readable messenger update.
3. Include links to source records, wiki files, pull requests, commits, or issues.
4. Show the exact destination and message body before any write.
5. Send only after explicit user approval.
6. Optionally write a local share receipt so the team knows what was announced.

Adapter shape:

```text
adapters/slack
  draft
  send-approved

adapters/discord
  draft
  send-approved
```

Slack is a strong first adapter for work teams. Discord should be in the adapter
contract from the beginning because many builder communities and open-source
teams live there.

## Product Surface

Recommended v0 commands and skills:

```text
memory-load
memory-ingest
memory-wiki
memory-verify
memory-sync
memory-share
```

The demo should show one agent-assisted work session becoming approved team
memory and an approved messenger notification.

```text
Agent session produces a planning decision.
User runs /memory-ingest.
The tool drafts a source record with owner, project, source type, and citations.
User approves.
memory-wiki regenerates project context.
memory-verify catches policy issues.
memory-sync opens a GitHub PR.
memory-share drafts a Slack/Discord post with links to the PR and wiki.
User approves the exact post.
The next agent session runs memory-load and starts with updated team context.
```

## Approaches Considered

### Approach A: Minimal OSS Template

Publish a public template repo with generic `load`, `ingest`, `wiki`, `verify`,
and `sync` commands. Teams generate a private repo from it and store their own
records and wiki there.

Pros:

- Fastest path to public release.
- Easy to explain to teams already using GitHub.
- Keeps v0 technically simple.

Cons:

- Without `share`, the product may feel like a docs repo with helper scripts.
- It misses the notification workflow that keeps small teams aligned.

### Approach B: Small Team Memory Kit

Build a public open-source kit for small AI-native teams. It uses a private
GitHub memory repo for durable records and wiki, explicit skills for capture,
verification before sync, and Slack/Discord adapters for approved team
notifications.

Pros:

- Matches the target team's real operating pattern.
- Makes the demo concrete and useful.
- Feels complete without becoming a large platform.
- Differentiates through governance and provenance.

Cons:

- Messenger adapters add permission and approval design work.
- Adapter abstraction can become too large if not controlled.
- The product must stay clear that messenger share is notification, not source
  of truth.

### Approach C: Memory Protocol First

Publish the file format, record schema, wiki citation rules, share draft
contract, and verifier contract first. CLI and skills come later.

Pros:

- Cleaner long-term standardization path.
- Easier for many agent runtimes to adopt.

Cons:

- Too abstract for the first small-team adopter.
- Slower to create the first demo moment.

## Recommended Approach

Choose Approach B: Small Team Memory Kit.

The v0 should be boring in storage and sharp in workflow. Files and GitHub hold
truth. Agents load bounded context. Humans explicitly promote work into records.
Wiki synthesis is regenerated with citations. Verification blocks unsafe memory.
Slack and Discord share approved updates to the humans who need to notice.

## Success Criteria

- A 10-person AI-native team can set up a private memory repo in under 15 minutes.
- A teammate can run one explicit ingest skill after an agent-assisted work
  session and produce an approved source record without manually writing
  Markdown.
- Generated wiki context cites existing source records.
- Verification blocks secrets, broken citations, missing ownership, ambiguous
  project mapping, and unsafe messenger drafts.
- `memory-share` can notify Slack or Discord with an approved message that links
  back to GitHub source of truth.
- A new agent session can run `memory-load` and recover latest project context
  without asking the user to paste old docs or chat history.
- The public repo contains generic examples only.

## Open Questions

- What should the project be named long term?
- Should the CLI prefix be `memory-*`, `team-memory`, or `agent-memory`?
- Should Slack ship first with a Discord adapter contract, or should both ship in
  v0?
- Should team memory repos be generated from a template instead of forked from
  the public product repo?
- Should `memory-share` post directly, draft only, or support both with draft as
  the default?

## Next Step

Write the public README opening and the first demo script. The demo should show
one agent session becoming source-recorded, wiki-summarized, verified,
GitHub-synced, and messenger-shared team memory.
