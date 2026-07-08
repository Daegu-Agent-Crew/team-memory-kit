# Pre-Implementation Patterns

Date: 2026-07-09
Status: ACTIVE

Three patterns to run **before** writing code. Each pattern produces an
artifact worth capturing as a team memory record.

---

## 1. Blind-Spot Sweep

**Goal:** surface "unknown unknowns" before they become production incidents.

**When to use:** starting work on an unfamiliar codebase, module, dependency,
or integration surface.

**How:**

Tell the agent honestly what you do not know:

> "I don't know this codebase's auth at all. Find pitfalls I might miss."

Ask the agent to check:

- Authentication / authorization assumptions
- Hidden coupling between modules
- Error-handling gaps
- Dependency version risks
- Configuration and environment drift
- Security implications (input validation, secrets, CORS, etc.)
- Performance characteristics under load

**Output:** a prioritized list of risk areas with references to specific files,
line ranges, or external docs.

**Memory hook:** ingest the output with `--source-type pre-impl-analysis`.

---

## 2. Brainstorm

**Goal:** generate multiple divergent options fast, then converge by selection.

**When to use:** open-ended design decisions — architecture, API shape, UI
layout, data model, tech stack choice.

**How:**

Ask for several distinct alternatives:

> "I have no design sense. Generate 4 completely different approaches. I'll pick."

Specify:

- How many alternatives (3–5 is productive)
- What dimensions should differ (architecture, complexity, speed, etc.)
- Any hard constraints (budget, deadline, existing stack)

Do **not** ask for "the best approach." Ask for breadth first, then evaluate.

**Output:** a comparison table or short design doc covering each alternative
with trade-offs.

**Memory hook:** ingest the selected approach with rationale as a
`--source-type pre-impl-analysis` record.

---

## 3. Interview

**Goal:** resolve ambiguity through structured one-question-at-a-time
clarification.

**When to use:** vague requirements, half-formed ideas, "we need something
like X" requests.

**How:**

> "Interview me one question at a time to pin down what this should do."

Rules for the agent:

- Ask **one** question at a time. Wait for the answer.
- Prioritize questions that eliminate the largest branch of possibility space.
- Avoid yes/no traps — prefer questions that reveal constraints, priorities,
  and acceptable trade-offs.
- Summarize what is known so far before each new question.
- Stop when the requirement is clear enough to act on, and produce a brief
  spec.

**Output:** a short requirement spec distilled from the conversation.

**Memory hook:** ingest the final spec as a `--source-type pre-impl-analysis`
record so future sessions reload the agreed requirements.

---

## Connecting to Team Memory

All three patterns produce durable artifacts. The recommended flow:

```text
run pattern → review output → memory-ingest (source-type: pre-impl-analysis) → memory-wiki
```

This keeps pre-implementation thinking inside the team memory loop, so the
next person — or the next agent session — loads the context without
re-deriving it.
