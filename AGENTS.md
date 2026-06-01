# team-memory-kit Agent Notes

This public repo contains generic product code and examples only. Do not commit
private team records, real people data, private company registry entries, or
copied internal context.

## Product Boundary

- `bin/` contains generic `memory-*` helpers.
- `skills/` contains generic Codex/Claude skills.
- `templates/team-memory-repo/` is the private repo skeleton users copy with
  `bin/memory-init`.
- Actual team memory belongs in a generated private repo, not in this public
  product repo.

## Implementation Rules

- Keep runtime dependency-light: Bash + Git + ripgrep.
- Keep all helper commands prefixed with `memory-`.
- Keep all skill directories and skill names prefixed with `tm-`.
- Verification is part of the happy path, not an optional cleanup.
- Messenger sharing is draft-first and approval-gated.
