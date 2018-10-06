// swift-tools-version:4.2
// https://github.com/apple/swift-package-manager/blob/master/Documentation
// Managed by ice

import PackageDescription

let package = Package(
    name: "Setup",
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "2.2.1"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.1.0"),
        .package(url: "https://github.com/nvzqz/FileKit", from: "5.2.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "1.8.6"),
    ],
    targets: [
        .target(name: "Setup", dependencies: ["ShellOut", "XCERepoConfigurator", "FileKit", "Files"], path: "Sources"),
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)
