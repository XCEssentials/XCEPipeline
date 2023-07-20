// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "XCEPipeline",
    platforms: [
        .macOS(.v10_15), // depends on Combine
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "XCEPipeline",
            targets: [
                "XCEPipeline"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/XCEssentials/XCERequirement",
            .upToNextMinor(from: "2.6.0")
        )
    ],
    targets: [
        .target(
            name: "XCEPipeline",
            dependencies: [
                "XCERequirement"
            ],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCEPipelineAllTests",
            dependencies: [
                "XCEPipeline",
                "XCERequirement"
            ],
            path: "Tests/AllTests"
        ),
    ]
)
