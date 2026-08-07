# Improvement Suggestions

The generic typed-error conversion is sound. The following follow-up work would improve documentation, API clarity, and concurrency safety.

## 1. Improve documentation coverage

Review all sources and see if any documentation comments or README need to be improved in order to make the discoverability of the functionality of this library better optimized for AI agents.

## 2. Add useful error conformances

Consider conditional conformances that make errors easier to compare, test, and move through concurrent code:

```swift
extension ConditionCheckError: Equatable where E: Equatable {}
extension ConditionCheckError: Sendable where E: Sendable {}
```

Confirm which `Sendable` conformances are already inferred by the supported Swift toolchain before adding redundant declarations. `Equatable` remains useful for concise tests and client-side matching.

Affected file: `Sources/Core/ConditionCheckError.swift`

## 3. Clarify `SimpleWrapper` construction

`SimpleWrapper` is public, but its initializer is internal. Clients must create it through `take(_:)`.

Choose and document one intended design:

- Keep the initializer internal and state clearly that `take(_:)` is the public entry point; or
- Make `init(_:)` public if direct construction is part of the supported API.

Affected files:

- `Sources/Core/SimpleWrapper.swift`
- `Sources/Core/Take.swift`

## 4. Review API naming for precision and consistency

Potential improvements:

- Align Optional's `inspect(via:)` and `mutate(via:)` labels with `SimpleWrapper.inspect(_:)` and `mutate(_:)`, if source compatibility permits.

Renaming public APIs is source-breaking. Prefer introducing clearer alternatives and deprecating old names during a migration period.

Affected files:

- `Sources/Core/Extensions/Optional+Helpers.swift`

## 5. Document the typed-throws API change for releases

Replacing `rethrows` with generic `throws(E)` changes exported generic signatures and symbol mangling, even though typical Swift 6 source call sites remain compatible.

If the affected declarations have already been released as public API:

- Mention the change prominently in release notes.
- Validate source compatibility against representative downstream clients.
- Treat binary compatibility as changed.
- Consider whether the package's semantic-versioning policy requires a major-version release.

## Suggested order of work

1. Add a DocC catalog and complete public symbol documentation.
2. Add useful error conformances.
3. Clarify wrapper construction and naming policy.
4. Plan any source-breaking renames or release-version changes.
