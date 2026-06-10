# Changelog

All notable changes to team-memory-kit are documented in this file.

## [2026.06.10.2] - 2026-06-10

### Added

- Generated team memory repos can now be refreshed from the same `PRODUCT_MANIFEST`
  used by `memory-init`, keeping install and upgrade surfaces aligned.
- `memory-upgrade` now reports and prunes stale product-owned `memory-*` helpers
  and `tm-*` skills that are no longer shipped by the kit.

### Changed

- `memory-init` and `memory-upgrade` now copy product-owned files through shared
  manifest helpers instead of maintaining separate file lists.
- Upgrade documentation now directs people to run the `/tm-upgrade` skill while
  preserving private context, registries, and memory snapshots.
