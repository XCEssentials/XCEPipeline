import PathKit

import XCERepoConfigurator

// MARK: - PRE-script invocation output

print("\n")
print("--- BEGIN of '\(Executable.name)' script ---")

// MARK: -

// MARK: Parameters

Spec.BuildSettings.swiftVersion.value = "4.2"

let localRepo = try Spec.LocalRepo.current()

let remoteRepo = try Spec.RemoteRepo()

let company = try Spec.Company(
    prefix: "XCE"
)

let project = try Spec.Project(
    summary: "Custom pipeline operators for easy chaining in Swift",
    copyrightYear: 2018,
    deploymentTargets: [
        .iOS : "9.0",
        .watchOS : "3.0",
        .tvOS : "9.0",
        .macOS : "10.11"
    ]
)

let product = (
    name: company.prefix + project.name,
    none: ()
)

let authors = [
    ("Maxim Khatskevich", "maxim@khatskevi.ch")
    ]

typealias PerSubSpec<T> = (
    core: T,
    tests: T
)

let subSpecs: PerSubSpec = (
    "Core",
    "AllTests"
)

let targetNames: PerSubSpec = (
    product.name,
    product.name + subSpecs.tests
)

let sourcesLocations: PerSubSpec = (
    Spec.Locations.sources + subSpecs.core,
    Spec.Locations.tests + subSpecs.tests
)

let dummyFiles = [
    sourcesLocations.core + "\(subSpecs.core).swift",
    sourcesLocations.tests + "\(subSpecs.tests).swift"
]

// MARK: Parameters - Summary

localRepo.report()
remoteRepo.report()
company.report()
project.report()

// MARK: -

// MARK: Write - Dummy files

try dummyFiles
    .forEach{
    
        try CustomTextFile
            .init(
                "//"
            )
            .prepare(
                at: $0
            )
            .writeToFileSystem(
                ifFileExists: .skip
            )
    }

// MARK: Write - ReadMe

try ReadMe()
    .addGitHubLicenseBadge(
        account: company.name,
        repo: project.name
    )
    .addGitHubTagBadge(
        account: company.name,
        repo: project.name
    )
    .addSwiftPMCompatibleBadge()
    .addCarthageCompatibleBadge()
    .addWrittenInSwiftBadge(
        version: Spec.BuildSettings.swiftVersion.value
    )
    .add("""

        # \(project.name)

        \(project.summary)
        
        ```swift
        22 ./ Utils.funcThatConvertsIntIntoString ./ { print($0) }
        ```
        
        See more examples of usage in unit tests.
        
        """
    )
    .prepare(
        removeRepeatingEmptyLines: false
    )
    .writeToFileSystem()

// MARK: Write - License

try License
    .MIT(
        copyrightYear: project.copyrightYear,
        copyrightEntity: authors.map{ $0.0 }.joined(separator: ", ")
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - GitHub - PagesConfig

try GitHub
    .PagesConfig()
    .prepare()
    .writeToFileSystem()

// MARK: Write - Git - .gitignore

try Git
    .RepoIgnore()
    .addMacOSSection()
    .addCocoaSection()
    .addSwiftPackageManagerSection(ignoreSources: true)
    .add(
        """
        # we don't need to store project file,
        # as we generate it on-demand
        *.\(Xcode.Project.extension)
        """
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - Package.swift

try CustomTextFile("""
    // swift-tools-version:\(Spec.BuildSettings.swiftVersion.value)

    import PackageDescription

    let package = Package(
        name: "\(product.name)",
        products: [
            .library(
                name: "\(product.name)",
                targets: [
                    "\(targetNames.core)"
                ]
            )
        ],
        targets: [
            .target(
                name: "\(targetNames.core)",
                path: "\(sourcesLocations.core)"
            ),
            .testTarget(
                name: "\(targetNames.tests)",
                dependencies: [
                    "\(targetNames.core)"
                ],
                path: "\(sourcesLocations.tests)"
            ),
        ],
        swiftLanguageVersions: [.version("\(Spec.BuildSettings.swiftVersion.value)")]
    )
    """
    )
    .prepare(
        at: ["Package.swift"]
    )
    .writeToFileSystem()

// MARK: - POST-script invocation output

print("--- END of '\(Executable.name)' script ---")
