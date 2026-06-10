# Product Philosophy: Human Context Is The Scarce Resource

Date: 2026-06-04
Status: NOTE
Mode: Product philosophy

## Source

This note is based on:

- [LLM 시대의 엔지니어링 | GeekNews](https://news.hada.io/topic?id=30060)
- [Yair Weinberger on X](https://x.com/yairwein), linked by GeekNews as the
  original source

## Why This Matters

`team-memory-kit` should treat human context as the resource to protect.

LLMs have made text and code cheap to produce, but they have not made human
attention cheaper. The new bottleneck is the ratio between machine output speed
and human review speed. A team memory system should not maximize the amount of
stored context. It should maximize the amount of useful, compressed, trusted
context that humans and agents can reload without drowning in noise.

The product philosophy:

```text
Human context is scarce.
Team memory preserves the useful part.
Verification keeps slop from becoming institutional memory.
```

## Principles For team-memory-kit

### 1. Capture Is A Human Promotion Step

The system should not silently ingest every conversation, tool output, or agent
session. That would make the write path faster while making the read path worse.

Good team memory starts when a human or agent explicitly promotes something that
deserves to become durable:

```text
session output -> selected note -> source record -> cited wiki -> shared update
```

This keeps the default posture high-trust and low-noise.

### 2. Compression Beats Coverage

Organizational text should contain only what is not already clear from code,
tests, behavior, or existing records.

For `team-memory-kit`, this means:

- Source records should explain the decision, evidence, and implication.
- Wiki synthesis should be compact and cited.
- Share drafts should announce what changed, not replay the entire history.
- Agent-facing context should fit the next task, not the whole organization.

The product should reward concise records more than exhaustive logs.

### 3. Modeling Is The Human Load-Bearing Work

LLMs can regenerate implementation quickly, but they cannot be trusted to own the
team's model of the system: project boundaries, source-of-truth rules, registry
shape, verification policy, and sharing contracts.

`team-memory-kit` should make those modeling decisions explicit and durable:

- Which repo maps to which project.
- Which records are authoritative.
- Which wiki files are synthesized views.
- Which messenger posts are notifications only.
- Which changes require human approval before they spread.

The memory repo should be where the team's operating model stays accessible.

### 4. APIs And Schemas Are Public Contracts

Generated code often adds fields, formats, and options that are convenient for a
single task but expensive for the product forever.

For this project, record schemas, registry files, CLI flags, verifier rules, and
share draft formats should be treated as contracts. New fields should pay their
way by improving durable clarity, not by making one generation easier.

The default answer to schema drift should be "no" until the product reason is
clear.

### 5. Verification Is A Defense Layer, Not Cleanup

Human review alone does not scale against high-volume agent output. The product
needs automatic guardrails that block bad memory before it becomes reusable
context.

Verification should remain part of the happy path:

- Secret scanning before records are written or synced.
- Citation checks before wiki context is trusted.
- Registry validation before project memory is loaded.
- Share draft checks before messenger updates are sent.
- Policy checks before private or ambiguous context leaves the repo.

This is the product equivalent of linters and LLM judges: small, repeated
defense layers that protect the team's shared context window.

### 6. Small Units Protect Attention

A pull request, record, share draft, or wiki update is an attention unit. If it
exceeds a human's context window, it may be approved but it has not really been
read.

`team-memory-kit` should favor small, inspectable units:

- One record per decision, session, meeting, or research note.
- Cited wiki updates generated from bounded records.
- Share drafts that summarize one meaningful change.
- Sync flows that make reviewable diffs the default.

The product should make the cheapest workflow also the most reviewable workflow.

### 7. Give LLMs Padded Rooms

LLMs should have room to move quickly where mistakes are easy to replace and do
not leak into load-bearing product structure.

Good padded rooms for this repo:

- Drafting source records from user-approved notes.
- Regenerating cited wiki summaries.
- Preparing messenger share drafts.
- Suggesting project registry entries for human review.
- Compiling team intent inputs into agenda drafts.

Load-bearing areas still require strict human and verifier control:

- Record schema.
- Registry semantics.
- Verification rules.
- Public CLI behavior.
- Approval boundaries for sharing.

The product should separate fast draft surfaces from durable contracts.

### 8. Rewrite Cheaply, Fix Modeling Early

When implementation is easy to regenerate, postponing a modeling mistake becomes
more expensive than rewriting. Bad structure now spreads faster because future
agents will read it, imitate it, and build on it.

For `team-memory-kit`, this argues for early correction of:

- Ambiguous project mapping.
- Over-broad source types.
- Unclear ownership rules.
- Messenger-specific assumptions in generic workflows.
- Wiki text that loses its citation trail.

The rule is simple: if the model is wrong, fix the model before generating more
surface area.

## Product Takeaway

`team-memory-kit` is not a larger memory bucket. It is a context-quality system.

Its job is to help small AI-native teams decide what deserves to become shared
memory, keep that memory compressed and cited, verify it before it spreads, and
reload it into future agent work without wasting human attention.

The core loop should continue to reflect that philosophy:

```text
load -> ingest -> wiki -> verify -> sync -> share
```

Each step protects human context:

- `load` bounds what the agent sees.
- `ingest` makes capture explicit.
- `wiki` compresses with citations.
- `verify` blocks unsafe or noisy memory.
- `sync` makes durable context reviewable.
- `share` notifies humans without making messenger the source of truth.
