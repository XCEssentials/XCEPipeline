// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "XCEPipeline",
    products: [
        .library(name: "XCEPipeline", targets: ["XCEPipeline"]),
    ],
    targets: [
        .target(name: "XCEPipeline", path: "Sources"),
        .testTarget(name: "XCEPipelineTests", dependencies: ["XCEPipeline"], path: "Tests"),
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)
