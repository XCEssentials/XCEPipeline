// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "XCEPipeline",
    products: [
        .library(
            name: "XCEPipeline",
            targets: [
                "XCEPipelineCore"
            ]
        )
    ],
    targets: [
        .target(
            name: "XCEPipelineCore",
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCEPipelineAllTests",
            dependencies: [
                "XCEPipelineCore"
            ],
            path: "Tests/AllTests"
        ),
    ],
    swiftLanguageVersions: [.version("4.2")]
)