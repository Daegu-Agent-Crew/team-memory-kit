---
name: tm-preimpl
description: Run a pre-implementation pattern (blind-spot sweep, brainstorm, or interview) before coding, then ingest the result as team memory.
---

# tm-preimpl

Use this skill **before** implementation work begins. Pick one of three modes
based on the situation:

## Modes

### `blindspot` — Blind-Spot Sweep

Goal: find "unknown unknowns."

When: working on an unfamiliar codebase, module, dependency, or integration.

Prompt pattern:

> "I don't know \<area\> at all. Find pitfalls I might miss."

Check: auth assumptions, hidden coupling, error-handling gaps, dependency
risks, config drift, security implications, performance under load.

Output: prioritized risk list with file/line references.

### `brainstorm` — Divergent Options

Goal: generate multiple distinct approaches fast.

When: open-ended design decisions — architecture, API shape, data model, UI.

Prompt pattern:

> "Generate N completely different approaches. I'll pick."

Ask for breadth, not "the best." Specify how many and what dimensions differ.

Output: comparison of alternatives with trade-offs.

### `interview` — One Question at a Time

Goal: resolve ambiguity through structured clarification.

When: vague requirements, half-formed ideas.

Prompt pattern:

> "Interview me one question at a time to pin down what this should do."

Rules: one question only, wait for answer, eliminate largest possibility
branch first, summarize knowns before each new question, stop when clear
enough to act.

Output: short requirement spec.

## After the Pattern

Every pattern produces a durable artifact. Capture it:

```bash
bin/memory-ingest \
  --project <project> \
  --member <github> \
  --source-type pre-impl-analysis \
  --title "<pattern> for <topic>" \
  /path/to/output.md

bin/memory-wiki --project <project>
bin/memory-verify
```

This keeps pre-implementation thinking inside the team memory loop.

## Reference

See [Pre-Implementation Patterns](../../docs/guides/pre-implementation-patterns.md)
for the full guide.
