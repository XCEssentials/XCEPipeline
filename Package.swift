// swift-tools-version:6.0

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
    dependencies: [
        .package(
            url: "https://github.com/SimplyDanny/SwiftLintPlugins",
            from: "0.65.0"
        )
    ],
    targets: [
        .target(
            name: "XCEPipeline",
            path: "Sources/Core",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLintPlugins"
                )
            ]
        ),
        .testTarget(
            name: "XCEPipelineAllTests",
            dependencies: [
                "XCEPipeline"
            ],
            path: "Tests/AllTests",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLintPlugins"
                )
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
