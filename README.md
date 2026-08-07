[![GitHub License](https://img.shields.io/github/license/XCEssentials/XCEPipeline.svg?longCache=true)](LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/XCEPipeline.svg?longCache=true)](https://github.com/XCEssentials/XCEPipeline/tags)
[![CI](https://github.com/XCEssentials/XCEPipeline/actions/workflows/ci.yml/badge.svg)](https://github.com/XCEssentials/XCEPipeline/actions/workflows/ci.yml)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-6-orange.svg?longCache=true)](https://swift.org)
[![Apple platforms](https://img.shields.io/badge/Apple-macOS%2012%2B%20%7C%20iOS%20%26%20Mac%20Catalyst%2015%2B%20%7C%20tvOS%2015%2B%20%7C%20watchOS%208%2B%20%7C%20visionOS%201%2B-blue.svg?longCache=true)](Package.swift)
[![Linux](https://img.shields.io/badge/Linux-Swift%206-orange.svg?longCache=true)](https://www.swift.org/install/linux/)

# XCEPipeline

XCEPipeline adds small, typed-throws-aware building blocks for readable value
chains in Swift 6. Use operators for compact pipelines, `take(_:)` and
`SimpleWrapper` for method-style chains, or the Optional helpers when a value
may be absent.

See the [changelog](CHANGELOG.md) for breaking changes and migration guidance.

```swift
import XCEPipeline

let message = 22
    ./ String.init
    ./ { "Value: \($0)" }

message .* { print($0) }
```

## Custom Operators

| Operator | Description |
|----------|-------------|
| `./` | Pass through — transform value and continue the chain |
| `.?` | Pass through unwrapped — unwrap optional, then transform |
| `.+` | Mutate — modify value in place via `inout` |
| `.-` | Inspect — observe value without modifying it |
| `.*` | End chain — transform and return final result |
| `.?*` | End chain unwrapped — unwrap optional, transform, and return |
| `.!` | Ensure condition — assert a condition or throw |
| `?!` | Unwrap or throw — unwrap optional or throw an error |

Operators associate from left to right, so each result becomes the next
operation's input. Throwing closures preserve their concrete error type.

```swift
enum ValidationError: Error { case missingName }

let name: String? = "Taylor"
let normalized = try name
    ?! ValidationError.missingName
    ./ { $0.trimmingCharacters(in: .whitespaces) }
    .! { !$0.isEmpty }
```

## Async/Await Support

Transformation, mutation, inspection, condition, and terminal operators have
async variants, making them compatible with actors and structured concurrency.

## SimpleWrapper & `take()`

Use `take(_:)` as the public entry point to wrap a nonoptional value in a
`SimpleWrapper`. Its initializer is intentionally not public. Read `.value` to
finish the chain.

- `map` — transform the wrapped value (sync + async)
- `inspect` — observe the value without changing it (sync + async)
- `mutate` — modify the value in place (sync + async)

```swift
let result = try take([1, 2])
    .mutate { $0.append(3) }
    .inspect { print($0) }
    .map { $0.reduce(0, +) }
    .value
```

For optionals, `take(optionalValue)` returns the optional unchanged so you can
continue with standard `map` plus `inspect(_:)`, `mutate(_:)`, and
`filter(_:)`.

## Error Types

The `.!` operator throws `ConditionCheckError<PredicateError>`:

- `.conditionCheckFailed` means the predicate returned `false`.
- `.predicateBodyError(error)` preserves an error thrown by the predicate.

The `?!` operator throws the caller-supplied error directly. Errors from
transformation, inspection, mutation, and terminal closures also retain their
concrete type through Swift 6 typed throws.

## How to install

XCEPipeline 4 requires Swift 6 or newer. It supports macOS 12, iOS 15,
Mac Catalyst 15, tvOS 15, watchOS 8, and visionOS 1 or newer. The
platform-independent API is also supported on Linux with Swift 6.

Install using [SwiftPM](https://swift.org/package-manager/).

```swift
.package(url: "https://github.com/XCEssentials/XCEPipeline.git", from: "4.0.0")
```

## Migrating from 3.x

Version 4 compiles in Swift 6 language mode and therefore requires a Swift 6
toolchain. The pipeline operators and their behavior are unchanged.
