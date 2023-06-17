// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "XCEPipeline",
    platforms: [
        .macOS(.v10_15), // depends on Combine
        .iOS(.v13)
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
            name: "XCERequirement",
            url: "https://github.com/XCEssentials/Requirement",
            from: "2.2.0"
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
