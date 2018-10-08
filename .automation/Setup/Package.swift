// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "Setup",
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "2.2.1"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.1.0"),
        .package(url: "https://github.com/nvzqz/FileKit", from: "5.2.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "1.10.1"),
    ],
    targets: [
        .target(name: "Setup", dependencies: ["ShellOut", "XCERepoConfigurator", "FileKit", "Files"], path: "Sources"),
    ],
    swiftLanguageVersions: [.v4_2]
)
