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
        ),
        .library(
            name: "XCEPipelineWithOperators",
            targets: [
                "XCEPipelineOperators"
            ]
        ),
    ],
    targets: [
        .target(
            name: "XCEPipelineCore",
            path: "Sources/Core"
        ),
        .target(
            name: "XCEPipelineOperators",
            dependencies: [
                "XCEPipelineCore"
            ],
            path: "Sources/Operators"
        ),
        .testTarget(
            name: "XCEPipelineAllTests",
            dependencies: [
                "XCEPipelineCore",
                "XCEPipelineOperators"
            ],
            path: "Tests/AllTests"
        ),
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)