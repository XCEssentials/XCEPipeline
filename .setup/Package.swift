// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "PipelineSetup",
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "2.7.3")
    ],
    targets: [
        .target(
            name: "PipelineSetup",
            dependencies: ["XCERepoConfigurator", "PathKit"],
            path: ".",
            sources: ["main.swift"]
        )
    ]
)
