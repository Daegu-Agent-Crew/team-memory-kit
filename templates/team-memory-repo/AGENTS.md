# Team Memory Agent Notes

This repo stores shared team memory for future agent sessions. Treat
`context/records/` as source material and `context/wiki/` as synthesized,
reloadable summaries.

## Rules

- Load context with `bin/memory-load` before related work.
- Write durable source material with `bin/memory-ingest`.
- Regenerate wiki with `bin/memory-wiki`.
- Run `bin/memory-verify` before sync or share.
- Use `bin/memory-share-plan` for approved Slack, Discord, email, or chat drafts.
- Never write to external messengers before explicit human approval.
- Do not store secrets. Redact tokens, passwords, `.env` values, private keys,
  customer data, private contact details, and unrelated private context.
- If project resolution fails, ask which project applies. Do not silently use
  `misc`.
