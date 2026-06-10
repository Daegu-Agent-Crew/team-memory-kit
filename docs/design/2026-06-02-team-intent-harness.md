# Design: Team Intent Harness

Date: 2026-06-02
Status: DRAFT
Mode: Internal prototype product design

## Problem Statement

AI has made individual context generation much faster than team intent
alignment. Each teammate can now explore product ideas, technical approaches,
and implementation paths with an AI session before the team has agreed on the
shared "why", "what", "not", and decision criteria.

Meetings are still constrained by physical time and turn-taking. One person
speaks while the others listen. Context differs by person. Discussion can only
move through one thread at a time. As a result, teams spend more time in
planning meetings while still leaving with unresolved or misaligned intent.

`team-memory-kit` already addresses one layer of this problem: it helps teams
explicitly promote AI-assisted work into durable, Git-backed team memory. The
remaining gap is pre-meeting alignment. Before a planning meeting, the team
needs a harness that turns multiple personal intents into a shared agenda:
common ground, conflicts, missing context, and decisions needed.

This is not a meeting transcript tool. It is a pre-meeting team intent compiler.

## Core Thesis

Code, tests, and docs are increasingly easy for AI to regenerate. What remains
hard is intent: why this exists, what should happen, what should not happen, and
what the team learned while exploring. Individual intent engineering captures
that for one person. This product extends the idea to a team.

The working loop:

```text
Git stores intent.
Harness compiles intent.
Messenger announces intent.
Meeting resolves intent.
Team memory preserves decisions.
```

## Reference

The external intent-engineering reference motivating this design is:

- https://intent.roboco.io/

The useful transferable pattern is the small intent artifact: why, what, not,
and learnings. For a team, that structure should not merely be merged. It should
be compared across people to expose alignment and disagreement before the
meeting starts.

## Target User

The first target user is a small AI-native product or engineering team already
using coding agents and team-memory workflows.

They likely already have:

- Individual AI sessions where real product thinking happens.
- A messenger such as Slack, Discord, or another team chat for human updates.
- A private Git-backed memory repo generated from `team-memory-kit`.
- Planning meetings that are getting longer because every teammate has more AI
  generated context than the team can naturally reconcile in conversation.

## Product Boundary

The public `team-memory-kit` repo remains generic product code and examples
only. Actual team intent files, AI session originals, private people data, and
company context belong in the generated private team memory repo.

The harness should follow existing project rules:

- Helpers use the `memory-*` prefix.
- Skills use the `tm-*` prefix.
- Runtime stays dependency-light: Bash, Git, and ripgrep first.
- Verification is part of the happy path.
- Messenger sharing is draft-first and approval-gated.

## Recommended V0

Build a CLI-first, folder-first intent harness with messenger share drafts.

The core v0 is not automatic AI session surveillance. It is a shared intent
folder plus a compiler:

```text
team members submit intent files
-> harness compares the files
-> harness writes common ground, conflicts, agenda, and decisions needed
-> messenger draft announces the meeting prep report
-> meeting resolves the agenda
-> final decisions are ingested into team memory
```

Session discovery is useful, but it should be treated as a v0.5 accelerator, not
the v0 core. The first product must prove that multiple intent files can reduce
meeting time and sharpen decisions.

## User Scenario

A planning meeting is scheduled for 4pm.

Before the meeting, the organizer creates an intent run:

```bash
bin/memory-intent-new \
  --project team-memory-kit \
  --topic "team intent harness"
```

This creates a run folder in the private team memory repo:

```text
context/intents/projects/team-memory-kit/2026-06-02-team-intent-harness/
  run.yml
  inputs/
  outputs/
  share-drafts/
```

Each teammate adds one intent file to `inputs/`. They may write it manually, ask
their AI agent to draft it from their recent work, or later use Session Scout to
find candidate AI sessions.

Example:

```text
inputs/
  member-a.intent.md
  member-b.intent.md
  member-c.intent.md
```

The organizer runs:

```bash
bin/memory-intent-prepare \
  --project team-memory-kit \
  --run 2026-06-02-team-intent-harness
```

The harness writes:

```text
outputs/team-intent-report.md
outputs/meeting-agenda.md
outputs/conflict-report.md
outputs/source-map.md
```

Then the organizer prepares a messenger draft:

```bash
bin/memory-intent-share-plan \
  --project team-memory-kit \
  --run 2026-06-02-team-intent-harness \
  --messenger manual
```

The meeting only discusses the compressed agenda. After the meeting, resolved
decisions are ingested with the existing memory workflow:

```bash
bin/memory-ingest --source-type decision ...
bin/memory-wiki --project team-memory-kit
bin/memory-verify
bin/memory-sync
bin/memory-share-plan ...
```

## Intent Input Format

Each teammate submits a concise intent file:

```markdown
# Intent: <topic>

## Why
Why this matters.

## What
What direction this teammate thinks the team should take.

## Not
What should not be built, discussed, optimized, or assumed yet.

## Evidence
Links to AI sessions, notes, experiments, prototypes, or observations.

## Decision Criteria
How this teammate would judge whether the final decision is good.

## Open Questions
Questions the meeting must resolve.
```

The file is intentionally small. Full AI session originals may be linked or
attached as evidence, but the intent file is the comparable unit.

## Output Format

The main output is a team intent report:

```markdown
# Team Intent Report: <topic>

## Common Ground
Already-aligned points that do not need meeting time.

## Conflicts
Places where teammates differ in intent, scope, risk tolerance, or success
criteria.

## Missing Context
Context present in one person's input but absent from others.

## Meeting Agenda
Only the points that require synchronous discussion.

## Decisions Needed
The decisions that must be true at the end of the meeting.

## Source Map
Every claim mapped back to the input file or evidence that caused it.
```

The source map is critical. The report should never feel like an AI black box.
If the harness says two teammates disagree, it must point to the source lines or
evidence that produced that conclusion.

## Session Scout V0.5

Session Scout helps teammates find what to submit. It is not the source of truth.

The problem it solves:

```text
I know I explored this with AI, but I do not remember which session has the
useful context.
```

Potential flow:

```bash
bin/memory-intent-scout \
  --project team-memory-kit \
  --topic "team intent harness" \
  --since today
```

The harness finds likely candidate sessions using repo, working directory,
branch, timestamps, titles, summaries, and topic keywords. It presents candidates
for include/exclude approval. Approved candidates can draft an intent file or be
attached as evidence.

This preserves the product principle:

```text
Discovery can be automatic.
Sharing is explicit.
Compilation is transparent.
```

## Messenger Model

Messenger support must stay generic. Slack is one possible adapter, but the
product should say "messenger" by default and support Slack, Discord, email, or
manual copy.

The messenger draft should include:

- Link to the team intent report.
- Count of common-ground items.
- Count of conflicts.
- The meeting agenda.
- The decisions needed.
- Links to source files or evidence.

Sending remains approval-gated. The harness drafts; the human approves.

## Approaches Considered

### Approach A: Folder-First CLI Harness

Team members submit small intent files to a shared run folder. The CLI compiles
those files into a team report, agenda, conflict report, and messenger draft.

Effort: M

Risk: Low

Pros:

- Closest to the current `team-memory-kit` model.
- Keeps v0 simple and Git-native.
- Proves the core value without building a new UI.
- Makes explicit sharing the default.

Cons:

- Requires teammates to write or generate intent files.
- The first version may feel manual without Session Scout.
- Report quality depends on input quality.

### Approach B: Scout-First Harness

The organizer starts from a topic and time window. The harness discovers
candidate AI sessions, asks teammates to include or exclude them, then generates
intent files and the team report.

Effort: L

Risk: Medium

Pros:

- Lower friction for teammates.
- Better captures raw AI session context.
- Feels more magical when it works.

Cons:

- Harder to implement across different AI tools.
- Product may drift into session surveillance if the consent boundary is weak.
- More moving parts before the core compiler is proven.

### Approach C: Messenger-First Workflow

The team runs the workflow from a messenger command. The bot requests teammate
inputs, collects responses, generates the report, and posts the agenda back to
the channel.

Effort: L

Risk: Medium

Pros:

- Fits where teams already coordinate.
- Stronger team-facing demo.
- Makes reminders and participation easier.

Cons:

- Requires adapter and permission design early.
- Risks making messenger the product rather than the announcement surface.
- Less aligned with the current CLI-first repo.

## Recommendation

Choose Approach A: Folder-First CLI Harness.

Add Session Scout as v0.5 and messenger share drafts as the team-facing output.
This keeps the first prototype focused on the hard thing: turning multiple
teammate intents into common ground, conflicts, and a compressed meeting agenda.

## Success Criteria

- A team can create an intent run in under 1 minute.
- Each teammate can submit or generate an intent file in under 5 minutes.
- The generated agenda removes at least half of the possible discussion topics
  by marking them as common ground or not-yet-needed.
- Every conflict in the report has a source map back to input files or evidence.
- The meeting ends with decisions that can be ingested into the existing
  `team-memory-kit` record flow.
- The workflow works without Slack-specific assumptions.

## Open Questions

- Should intent runs live under `context/intents/` or `context/records/` with a
  dedicated `source_type`?
- Should input intent files require frontmatter with member, project, run, and
  status?
- Should `memory-verify` validate intent runs, or should there be a separate
  `memory-intent-verify`?
- What AI session sources can Session Scout support first without introducing
  tool-specific complexity?
- Should the final team intent report become a record automatically after the
  meeting, or only the resolved decisions?

## The Assignment

Run one real planning meeting with the manual folder-first version before
building Session Scout.

Have each participant write one intent file using the proposed format. Compile
the files manually or with an agent into common ground, conflicts, agenda, and
decisions needed. Then measure whether the meeting spends less time on context
sharing and more time on actual decisions.

If that works once, build the CLI harness.
