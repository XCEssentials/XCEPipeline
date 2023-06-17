// swift-tools-version:5.9

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
    dependencies: [
        .package(
            name: "XCERequirement",
            url: "https://github.com/XCEssentials/Requirement",
            from: "2.2.0"
        )
    ],
    targets: [
        .target(
            name: "XCEPipelineCore",
            dependencies: [
                "XCERequirement"
            ],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCEPipelineAllTests",
            dependencies: [
                "XCEPipelineCore",
                "XCERequirement"
            ],
            path: "Tests/AllTests"
        ),
    ]
)
