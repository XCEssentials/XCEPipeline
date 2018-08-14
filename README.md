[![GitHub license](https://img.shields.io/github/license/XCEssentials/Pipeline.svg)](https://github.com/XCEssentials/Pipeline/blob/master/LICENSE)
[![GitHub tag](https://img.shields.io/github/tag/XCEssentials/Pipeline.svg)](https://github.com/XCEssentials/Pipeline/tags)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/XCEPipeline.svg)](https://cocoapods.org/pods/XCEPipeline)
[![CocoaPods Platform](https://img.shields.io/cocoapods/p/XCEPipeline.svg)](https://github.com/XCEssentials/Pipeline/blob/master/XCEPipeline.podspec)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![Written in Swift](https://img.shields.io/badge/Swift-4-orange.svg)](https://developer.apple.com/swift/)

# Pipeline

Custom pipeline operators for easy chaining in Swift.

```swift
22 ./ { "\($0)" } ./ { print($0) }
```

See more examples of usage in unit tests.