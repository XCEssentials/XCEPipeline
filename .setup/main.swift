import PathKit

import XCERepoConfigurator

// MARK: - PRE-script invocation output

print("\n")
print("--- BEGIN of '\(Executable.name)' script ---")

// MARK: -

// MARK: Parameters

Spec.BuildSettings.swiftVersion.value = "4.2"
let swiftLanguageVersionsForSPM = "[.v4, .v4_2]"

let localRepo = try Spec.LocalRepo.current()

let remoteRepo = try Spec.RemoteRepo()

let company = try Spec.Company(
    prefix: "XCE",
    identifier: "com.\(remoteRepo.accountName)"
)

let project = try Spec.Project(
    summary: "Custom pipeline operators for easy chaining in Swift",
    copyrightYear: 2018,
    deploymentTargets: [
        .iOS : "9.0",
        //.watchOS : "3.0", // be prepared to fail 'pod lib lint' if uncomment!
        .tvOS : "9.0",
        .macOS : "10.11"
    ]
)

var cocoaPod = try Spec.CocoaPod(
    companyInfo: .from(company),
    productInfo: .from(project),
    authors: [
        ("Maxim Khatskevich", "maxim@khatskevi.ch")
    ]
)

let subSpecs = (
    core: Spec.CocoaPod.SubSpec("Core"),
    operators: Spec.CocoaPod.SubSpec("Operators"),
    tests: Spec.CocoaPod.SubSpec.tests()
)

let allSubspecs = try Spec
    .CocoaPod
    .SubSpec
    .extractAll(from: subSpecs)

let targetsSPM = (
    core: (
        productName: cocoaPod.product.name,
        name: cocoaPod.product.name + subSpecs.core.name
    ),
    operators: (
        productName: cocoaPod.product.name + "WithOperators",
        name: cocoaPod.product.name + subSpecs.operators.name
    ),
    allTests: (
        name: cocoaPod.product.name + subSpecs.tests.name,
        none: ()
    )
)

// MARK: Parameters - Summary

localRepo.report()
remoteRepo.report()
company.report()
project.report()

// MARK: -

// MARK: Write - Dummy files

try allSubspecs
    .forEach{
    
        try CustomTextFile
            .init(
                "//"
            )
            .prepare(
                at: $0.sourcesLocation + ["\($0.name).swift"]
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
        copyrightEntity: cocoaPod.authors[0].name
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
        name: "\(cocoaPod.product.name)",
        products: [
            .library(
                name: "\(targetsSPM.core.productName)",
                targets: [
                    "\(targetsSPM.core.name)"
                ]
            ),
            .library(
                name: "\(targetsSPM.operators.productName)",
                targets: [
                    "\(targetsSPM.operators.name)"
                ]
            ),
        ],
        targets: [
            .target(
                name: "\(targetsSPM.core.name)",
                path: "\(subSpecs.core.sourcesLocation)"
            ),
            .target(
                name: "\(targetsSPM.operators.name)",
                dependencies: [
                    "\(targetsSPM.core.name)"
                ],
                path: "\(subSpecs.operators.sourcesLocation)"
            ),
            .testTarget(
                name: "\(targetsSPM.allTests.name)",
                dependencies: [
                    "\(targetsSPM.core.name)",
                    "\(targetsSPM.operators.name)"
                ],
                path: "\(subSpecs.tests.sourcesLocation)"
            ),
        ],
        swiftLanguageVersions: \(swiftLanguageVersionsForSPM)
    )
    """
    )
    .prepare(
        at: ["Package.swift"]
    )
    .writeToFileSystem()

// MARK: - POST-script invocation output

print("--- END of '\(Executable.name)' script ---")
