import FileKit

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

let license: CocoaPods.Podspec.License = (
    License.MIT.licenseType,
    License.MIT.relativeLocation
)

var cocoaPod = try Spec.CocoaPod(
    companyInfo: .from(company),
    productInfo: .from(project),
    authors: [
        ("Maxim Khatskevich", "maxim@khatskevi.ch")
    ]
)

try? cocoaPod.readCurrentVersion(
    callFastlane: .viaBundler
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

// MARK: Write - Bundler - Gemfile

// https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile
try Bundler
    .Gemfile(
        basicFastlane: true,
        """
        gem '\(CocoaPods.gemName)'
        gem '\(CocoaPods.Generate.gemName)'
        """
    )
    .prepare()
    .writeToFileSystem()

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
    .addCocoaPodsVersionBadge(
        podName: cocoaPod.product.name
    )
    .addCocoaPodsPlatformsBadge(
        podName: cocoaPod.product.name
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

// MARK: Write - SwiftLint

try allSubspecs
    .filter{ !$0.tests }
    .map{ $0.linterCfgLocation }
    .forEach{
        
        try SwiftLint
            .standard()
            .prepare(
                at: $0
            )
            .writeToFileSystem()
    }

// MARK: Write - License

try License
    .MIT(
        copyrightYear: project.copyrightYear,
        copyrightEntity: cocoaPod.authors[0].name
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - CocoaPods - Podspec

try CocoaPods
    .Podspec
    .withSubSpecs(
        project: project,
        company: cocoaPod.company,
        version: cocoaPod.currentVersion,
        license: license,
        authors: cocoaPod.authors,
        swiftVersion: Spec.BuildSettings.swiftVersion.value,
        globalSettings: {
            
            globalContext in
            
            //declare support for all defined deployment targets
            
            project
                .deploymentTargets
                .forEach{ globalContext.settings(for: $0) }
        },
        subSpecs: {

            let core = subSpecs.core
            
            $0.subSpec(core.name){

                $0.settings(
                    .sourceFiles(core.sourcesPattern)
                )
            }
            
            let operators = subSpecs.operators

            $0.subSpec(operators.name){
                
                $0.settings(
                    .dependency("\(cocoaPod.product.name)/\(core.name)"),
                    .sourceFiles(operators.sourcesPattern)
                )
            }
        },
        testSubSpecs: {
            
            let tests = subSpecs.tests

            $0.testSubSpec(tests.name){

                $0.settings(
                    .noPrefix("requires_app_host = false"),
                    .dependency("SwiftLint"), // we will be running linting from unit tests!
                    .sourceFiles(tests.sourcesPattern)
                )
            }
        }
    )
    .prepare(
        for: cocoaPod
    )
    .writeToFileSystem()

// MARK: Write - Fastlane - Fastfile

try Fastlane
    .Fastfile
    .ForLibrary()
    .defaultHeader()
    .beforeRelease(
        podspecLocation: .from(cocoaPod)
    )
    .lane("lintThoroughly"){

        "pod_lib_lint"
    }
    .generateProjectViaCP(
        callCocoaPods: .viaBundler,
        prefixLocation: cocoaPod.xcodeArtifactsLocation,
        scriptBuildPhases: {

            // NOTE: we inject build phase script into 'Pods' project
            // auto-generated by 'cocoapods-generate' for our library
            
            // NOTE: following script will ensure that
            // any of the platform-specific targets will trigger
            // linting of all sources
            
            try $0.swiftLint(
                project: cocoaPod.generatedXcodeProjectLocation,
                // NOTE: regardless of subspecs, targets are generated per platform
                targetNames: project
                    .deploymentTargets
                    .keys
                    .map{ "\(cocoaPod.product.name)-\($0.rawValue)-Unit-\(subSpecs.tests.name)" },
                executableAt: .currentFolder, // this is how 'cocoapods-generate' works
                params: [

                    // NOTE: the '${SRCROOT}' of 'Pods' points inside "./Xcode/XCEMyFwk/"
                    
                    """
                    --path "${SRCROOT}/../../\(Spec.Locations.sources.rawValue)"
                    """
                ]
            )
        }
    )
    .generateProjectViaSwiftPM(
        for: cocoaPod
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
    .RepoIgnore
    .framework(
        otherEntries: [
            """
            # we don't need to store any project files,
            # as we generate them on-demand from specs
            *.\(Xcode.Project.extension)
            
            # folder for temporary development Xcode-related artifacts
            # generated by 'cocopods-generate'
            \(cocoaPod.xcodeArtifactsLocation.rawValue)
            
            # derived files generated by '.setup' script
            \(DummyFile.relativeLocation.rawValue)
            """
        ]
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
