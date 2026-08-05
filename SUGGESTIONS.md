# Improvement Suggestions

The generic typed-error conversion is sound. The following follow-up work would improve documentation, API clarity, concurrency safety, and test coverage.

## 1. Add typed-error-specific tests

The existing tests validate runtime behavior, but they do not explicitly exercise the compile-time guarantees introduced by generic typed throws.

Add coverage for:

- Closures explicitly declared with `throws(SpecificError)`.
- Exhaustive typed `catch` handling without type casts.
- Nonthrowing closures, where the inferred failure type is `Never`.
- Both synchronous and asynchronous `SimpleWrapper` methods.
- Optional `nil` paths, confirming that handlers are not invoked.
- Optional `inspect`, `mutate`, and `filter` behavior when their handlers throw.
- Preservation of the exact error value and type through each operation.

Affected files:

- `Tests/AllTests/SimpleWrapperTests.swift`
- `Tests/AllTests/OperatorsTests.swift`
- `Tests/AllTests/OperatorsAsyncTests.swift`

## 2. Improve DocC coverage

The package has symbol comments in several files but no `.docc` documentation catalog. Some public APIs, particularly the Optional and wrapper helpers, have little or no documentation.

Create a documentation catalog containing:

- A package overview and introductory example.
- A table explaining `./`, `.?`, `.+`, `.-`, `.*`, `.?*`, `.!`, and `?!`.
- Articles covering synchronous and asynchronous pipelines.
- An article explaining generic typed errors and `Pipeline.ConditionCheckError`.
- Links between equivalent operator, `Pipeline`, `SimpleWrapper`, and Optional APIs.

For each public function, document:

- Whether its closure runs for `nil` input.
- Whether it returns the original, transformed, or mutated value.
- The exact error propagation behavior.
- Async execution and cancellation semantics where applicable.
- At least one concise usage example for APIs whose behavior is not obvious.

Most affected files:

- `Sources/Core/SimpleWrapper.swift`
- `Sources/Core/Extensions/Optional+Helpers.swift`
- `Sources/Core/Operators.swift`
- `Sources/Core/Pipeline.swift`

## 3. Add useful error conformances

Consider conditional conformances that make errors easier to compare, test, and move through concurrent code:

```swift
extension Pipeline.ConditionCheckError: Equatable where E: Equatable {}
extension Pipeline.ConditionCheckError: Sendable where E: Sendable {}
```

Confirm which `Sendable` conformances are already inferred by the supported Swift toolchain before adding redundant declarations. `Equatable` remains useful for concise tests and client-side matching.

Affected file: `Sources/Core/Pipeline.swift`

## 4. Clarify `SimpleWrapper` construction

`SimpleWrapper` is public, but its initializer is internal. Clients must create it through `take(_:)`.

Choose and document one intended design:

- Keep the initializer internal and state clearly that `take(_:)` is the public entry point; or
- Make `init(_:)` public if direct construction is part of the supported API.

Affected files:

- `Sources/Core/SimpleWrapper.swift`
- `Sources/Core/Take.swift`

## 5. Review API naming for precision and consistency

Potential improvements:

- Align Optional's `inspect(via:)` and `mutate(via:)` labels with `SimpleWrapper.inspect(_:)` and `mutate(_:)`, if source compatibility permits.

Renaming public APIs is source-breaking. Prefer introducing clearer alternatives and deprecating old names during a migration period.

Affected files:

- `Sources/Core/Extensions/Optional+Helpers.swift`

## 6. Document the typed-throws API change for releases

Replacing `rethrows` with generic `throws(E)` changes exported generic signatures and symbol mangling, even though typical Swift 6 source call sites remain compatible.

If the affected declarations have already been released as public API:

- Mention the change prominently in release notes.
- Validate source compatibility against representative downstream clients.
- Treat binary compatibility as changed.
- Consider whether the package's semantic-versioning policy requires a major-version release.

## Suggested order of work

1. Add typed-error and Optional edge-case tests.
2. Add a DocC catalog and complete public symbol documentation.
3. Add useful error conformances.
4. Clarify wrapper construction and naming policy.
5. Plan any source-breaking renames or release-version changes.
