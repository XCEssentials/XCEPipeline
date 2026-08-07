# Changelog

## 4.0.0 (2026-08-07)

This is a source- and binary-breaking major release. Applications and libraries
must rebuild against XCEPipeline 4.0.0.

### Breaking changes

- XCEPipeline now requires the Swift 6 toolchain and Swift 6 language mode.
- Public operators and fluent wrapper methods now use generic typed throws,
  such as `throws(E)`, instead of `rethrows`. Ordinary call sites generally do
  not require changes, and thrown closure errors retain their concrete type.
  Code that stores these functions using explicit function types or otherwise
  depends on their exported generic signatures may need to be updated.
- Optional helper closure parameters are now unlabeled. Replace
  `inspect(via:)`, `mutate(via:)`, and `filter(via:)` with `inspect(_:)`,
  `mutate(_:)`, and `filter(_:)` respectively.
- Combine `Publisher` convenience extensions have been removed.

### Migration

Perform a clean rebuild of every downstream target to avoid linking against
symbols from XCEPipeline 3.x. Update explicitly labeled Optional helper calls;
trailing-closure calls keep the same spelling.
