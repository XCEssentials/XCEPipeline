// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "Setup",
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "2.2.1"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.1.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "1.8.4"),
    ],
    targets: [
        .target(name: "Setup", dependencies: ["Files", "ShellOut", "XCERepoConfigurator"]),
    ]
)
