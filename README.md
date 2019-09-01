[![GitHub License](https://img.shields.io/github/license/XCEssentials/Pipeline.svg?longCache=true)](LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/Pipeline.svg?longCache=true)](https://github.com/XCEssentials/Pipeline/tags)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?longCache=true)](https://github.com/Carthage/Carthage)
[![Written in Swift](https://img.shields.io/badge/Swift-5.0-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blue.svg?longCache=true)](Package.swift)
[![Build Status](https://travis-ci.com/XCEssentials/Pipeline.svg?branch=master)](https://travis-ci.com/XCEssentials/Pipeline)

# Pipeline

Custom pipeline operators for easy chaining in Swift

```swift
22 ./ Utils.funcThatConvertsIntIntoString ./ { print($0) }
```

See more examples of usage in unit tests.

## How to install

The recommended way is to install using [SwiftPM](https://swift.org/package-manager/), but [Carthage](https://github.com/Carthage/Carthage) is also supported out of the box.
