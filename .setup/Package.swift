// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "PipelineSetup",
    dependencies: [
        .package(url: "https://github.com/nvzqz/FileKit", from: "5.2.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "PipelineSetup",
            dependencies: ["XCERepoConfigurator", "FileKit"],
            path: ".",
            sources: ["main.swift"]
        )
    ]
)
