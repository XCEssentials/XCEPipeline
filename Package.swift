// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "XCEPipeline",
    products: [
        .library(
            name: "XCEPipeline",
            targets: [
                "XCEPipeline"
            ]
        )
    ],
    targets: [
        .target(
            name: "XCEPipeline",
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCEPipelineAllTests",
            dependencies: [
                "XCEPipeline"
            ],
            path: "Tests/AllTests"
        ),
    ],
    swiftLanguageVersions: [.version("4.2")]
)