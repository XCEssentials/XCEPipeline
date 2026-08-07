# Improvement Suggestions

The generic typed-error conversion is sound. The following follow-up work would improve API clarity and release readiness.

## 1. Document the typed-throws API change for releases

Replacing `rethrows` with generic `throws(E)` changes exported generic signatures and symbol mangling, even though typical Swift 6 source call sites remain compatible.

If the affected declarations have already been released as public API:

- Mention the change prominently in release notes.
- Validate source compatibility against representative downstream clients.
- Treat binary compatibility as changed.
- Consider whether the package's semantic-versioning policy requires a major-version release.
