// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "XCEPipeline",
    platforms: [
        .macOS(.v12),
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
    ]
)
