[![GitHub License](https://img.shields.io/github/license/XCEssentials/XCEPipeline.svg?longCache=true)](LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/XCEPipeline.svg?longCache=true)](https://github.com/XCEssentials/XCEPipeline/tags)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-6-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/platforms-macOS%2012%2B%20%7C%20iOS%2015%2B%20%7C%20Linux-blue.svg?longCache=true)](Package.swift)

# Pipeline

Custom pipeline operators for easy chaining in Swift

```swift
22 ./ Utils.funcThatConvertsIntIntoString ./ { print($0) }
```

See more examples of usage in unit tests.

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

## Async/Await Support

All operators have `async` and `async throws` variants, making them compatible with actors and structured concurrency.

## SimpleWrapper & `take()`

Use `take()` as an entry point to wrap any value in a `SimpleWrapper`, which provides:

- `map` — transform the wrapped value (sync + async)
- `inspect` — observe the value without changing it (sync + async)
- `mutate` — modify the value in place (sync + async)

## Combine Helpers

Convenience extensions for working with Combine publishers:

- `waitForFirstResult()` — await the first published `Sendable` value
- `observe()` — subscribe with simplified callbacks
- `executeNow()` — immediately execute and observe
- `ensureMainThread()` — receive values on the main thread
- `mutate()` — apply mutations via publisher output

## Error Types

- `Pipeline.FailedConditionCheck` — thrown when a `.!` condition fails
- `Pipeline.CompletedWithoutValue` — thrown when a publisher completes without emitting a value

## How to install

XCEPipeline 4 requires Swift 6 or newer. The supported deployment targets remain
macOS 12 and iOS 15; platform-independent functionality is also available on
Linux.

Install using [SwiftPM](https://swift.org/package-manager/).

```swift
.package(url: "https://github.com/XCEssentials/XCEPipeline.git", from: "4.0.0")
```

## Migrating from 3.x

Version 4 compiles in Swift 6 language mode and therefore requires a Swift 6
toolchain. `Publisher.waitForFirstResult()` now requires `Publisher.Output` to
conform to `Sendable` so values can safely cross the async task boundary. The
pipeline operators and their behavior are unchanged.
