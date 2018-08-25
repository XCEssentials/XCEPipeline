[![GitHub License](https://img.shields.io/github/license/XCEssentials/Pipeline.svg?longCache=true)](https://github.com/XCEssentials/Pipeline/blob/master/LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/Pipeline.svg?longCache=true)](https://github.com/XCEssentials/Pipeline/tags)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/XCEPipeline.svg?longCache=true)](https://cocoapods.org/pods/XCEPipeline)
[![CocoaPods Platforms](https://img.shields.io/cocoapods/p/XCEPipeline.svg?longCache=true)](https://cocoapods.org/pods/XCEPipeline)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?longCache=true)](https://github.com/Carthage/Carthage)
[![Written in Swift](https://img.shields.io/badge/Swift-4.2-orange.svg?longCache=true)](https://developer.apple.com/swift/)


# Pipeline

Custom pipeline operators for easy chaining in Swift.

```swift
22 ./ { "\($0)" } ./ { print($0) }
```

See more examples of usage in unit tests.
