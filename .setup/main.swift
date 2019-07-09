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

//var cocoaPod = try Spec.CocoaPod(
//    companyInfo: .from(company),
//    productInfo: .from(project),
//    authors: [
//        ("Maxim Khatskevich", "maxim@khatskevi.ch")
//    ]
//)

struct SubSpec
{
    let name: String
    let isTests: Bool
    
    var target: String
    {
        return product.name + name
    }
    
    var sourcesPath: Path
    {
        return (isTests ? Spec.Locations.tests : Spec.Locations.sources) + name
    }
    
    init(
        _ name: String,
        isTests: Bool = false
        )
    {
        self.name = name
        self.isTests = isTests
    }
    
    static
    func tests(
        _ name: String = "AllTests"
        ) -> SubSpec
    {
        return .init(
            name,
            isTests: true
        )
    }
    
}

let subSpecs = (
    core: SubSpec("Core"),
    tests: SubSpec.tests()
)

//let subSpecs = (
//    core: Spec.CocoaPod.SubSpec("Core"),
//    operators: Spec.CocoaPod.SubSpec("Operators"),
//    tests: Spec.CocoaPod.SubSpec.tests()
//)

//let allSubspecs = try Spec
//    .CocoaPod
//    .SubSpec
//    .extractAll(from: subSpecs)

//let targetsSPM = (
//    core: (
//        productName: cocoaPod.product.name,
//        name: cocoaPod.product.name + subSpecs.core.name
//    ),
//    allTests: (
//        name: cocoaPod.product.name + subSpecs.tests.name,
//        none: ()
//    )
//)

// MARK: Parameters - Summary

localRepo.report()
remoteRepo.report()
company.report()
project.report()

// MARK: -

// MARK: Write - Dummy files

try [
    subSpecs.core,
    subSpecs.tests
    ]
    .forEach{
    
        try CustomTextFile
            .init(
                "//"
            )
            .prepare(
                at: $0.sourcesPath + ["\($0.name).swift"]
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
                    "\(subSpecs.core.target)"
                ]
            )
        ],
        targets: [
            .target(
                name: "\(subSpecs.core.target)",
                path: "\(subSpecs.core.sourcesPath)"
            ),
            .testTarget(
                name: "\(subSpecs.tests.target)",
                dependencies: [
                    "\(subSpecs.core.target)"
                ],
                path: "\(subSpecs.tests.sourcesPath)"
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
