import FileKit
import Files
import ShellOut

import XCERepoConfigurator

// MARK: - Helper typealiases

/**
 Declares kinds of platforms supported by this library.
 */
typealias PerPlatform<T> = (
    iOS: T,
    watchOS: T,
    tvOS: T,
    macOS: T
)

/**
 Declares kinds of targets presetned in this library.
 */
typealias PerTarget<M, T> = (
    main: M,
    tst: T
)

// MARK: - PRE-script invocation output

print("\n")
print("--- BEGIN of '\(Executable.name!)' script ---")

// MARK: - Parameters

guard
    let repoFolder = Folder.currentRepoRoot
else
{
    preconditionFailure("❌ Expected to be inside a git repo folder!")
}

print("✅ Repo folder: \(repoFolder.path)")

//---

guard
    let companyName = repoFolder.parent?.name
else
{
    preconditionFailure("❌ Expected to be one level deep from a company-named folder!")
}

print("✅ Company name: \(companyName)")

//---

let productName = repoFolder.name

print("✅ Product name (without company prefix): \(productName)")

//---

let projectName = productName

let swiftVersion: VersionString = "4.2"

let copyrightYear: UInt = 2018

let product: CocoaPods.Podspec.Product = (
    name: productName,
    summary: "Custom pipeline operators for easy chaining in Swift."
)

let company: CocoaPods.Podspec.Company = (
    name: companyName,
    identifier: "com.\(companyName)",
    prefix: "XCE"
)

let cocoaPodsModuleName = company.prefix + product.name

let author: CocoaPods.Podspec.Author = (
    name: "Maxim Khatskevich",
    email: "maxim@khatskevi.ch"
)

let tstSuffix = Defaults.tstSuffix

let depTargets: PerPlatform<DeploymentTarget> = (
    (.iOS, "9.0"),
    (.watchOS, "3.0"),
    (.tvOS, "9.0"),
    (.macOS, "10.11")
)

let sourcesPath: PerTarget<Path, Path> = (
    [Defaults.pathToSourcesFolder],
    [tstSuffix]
)

let sourcesFolder: PerTarget<Folder, Folder> = try (
    repoFolder
        .createSubfolderIfNeeded(
            withName: sourcesPath.main.rawValue
        ),
    repoFolder
        .createSubfolderIfNeeded(
            withName: sourcesPath.tst.rawValue
        )
)

enum PodSubSpecs: String
{
    case core
    case operators
    
    var name: String
    {
        return self.rawValue.capitalized
    }
    
    var path: Path
    {
        return .init(arrayLiteral:
            sourcesPath.main.rawValue, self.rawValue.capitalized, "**", "*.swift"
        )
    }
}

let podspecFileName = cocoaPodsModuleName + ".podspec"

let currentPodVersion: VersionString // will be defined later

let genXcodeArtifactsPath = Path("Xcode")

let symLinkCmd: (String, String) -> String = {
    
    """
    ln -sf "\($0)" "\($1)"
    """
}

// NOTE: Origin path MUST be absolute in oreder symlink to work properly
let linterCfgOriginPath = """
    \(SwiftLint.fileName)
    """

let linterCfgSymLinkPath: PerTarget<String, String> = (
    "\(sourcesPath.main.rawValue)/\(SwiftLint.fileName)",
    "\(sourcesPath.tst.rawValue)/\(SwiftLint.fileName)"
)

// NOTE: 'Pods' project!!!
let genXcodeProjectBeforeExt = """
    \(genXcodeArtifactsPath.rawValue)/\(cocoaPodsModuleName)/Pods
    """

let fastlaneFolderPath = Defaults.pathToFastlaneFolder

let fastlaneFolder = try repoFolder
    .createSubfolderIfNeeded(
        withName: fastlaneFolderPath
    )

let dummyFileName = "RemoveMe.swift"

// MARK: -

// MARK: Write - Dummy files

//try CustomTextFile()
//    .prepare(
//        name: dummyFileName,
//        targetFolder: sourcesFolder.main.path
//    )
//    .writeToFileSystem(ifFileExists: .skip)
//
//try CustomTextFile()
//    .prepare(
//        name: dummyFileName,
//        targetFolder: sourcesFolder.tst.path
//    )
//    .writeToFileSystem(ifFileExists: .skip)

// MARK: Write - Bundler - Gemfile

// https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile
try Bundler
    .Gemfile(
        basicFastlane: true,
        """
        gem 'cocoapods'
        gem 'cocoapods-generate'
        """
    )
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Read - currentPodVersion

do
{
    // NOTE: depends on https://github.com/sindresorhus/find-versions-cli
    // run before first time usage:
    // try shellOut(to: "npm install --global find-versions-cli")

    currentPodVersion = try Read.CocoaPods.currentPodVersion(
        fromFolder: repoFolder,
        callFastlane: .viaBundler
    )

    print("✅ Detected current pod version: \(currentPodVersion).")
}
catch
{
    currentPodVersion = Defaults.initialVersionString

    print("""
        ⓘ NOTE: failed to auto-detect current Pod version: \(error).
        """
    )
}

// MARK: Write - ReadMe

try ReadMe()
    .addGitHubLicenseBadge(
        account: company.name,
        repo: product.name
    )
    .addGitHubTagBadge(
        account: company.name,
        repo: product.name
    )
    .addCocoaPodsVersionBadge(
        podName: cocoaPodsModuleName
    )
    .addCocoaPodsPlatformsBadge(
        podName: cocoaPodsModuleName
    )
    .addSwiftPMCompatibleBadge()
    .addCarthageCompatibleBadge()
    .addWrittenInSwiftBadge(
        version: swiftVersion
    )
    .add("""

        # Pipeline

        Custom pipeline operators for easy chaining in Swift.

        ```swift
        22 ./ { "\\($0)" } ./ { print($0) }
        ```

        See more examples of usage in unit tests.

        """
    )
    .prepare(
        targetFolder: repoFolder.path,
        removeRepeatingEmptyLines: false
    )
    .writeToFileSystem()

// MARK: Write - SwiftLint

try SwiftLint
    .standard()
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - License

try License
    .MIT(
        copyrightYear: copyrightYear,
        copyrightEntity: author.name
    )
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - CocoaPods - Podspec

try CocoaPods
    .Podspec
    .withSubSpecs(
        product: product,
        company: company,
        version: currentPodVersion,
        license: (License.MIT.licenseType, License.MIT.fileName),
        authors: [author],
        swiftVersion: swiftVersion,
        perPlatformSettings: {
            
            $0.settings(
                for: depTargets.iOS
            )

            $0.settings(
                for: depTargets.tvOS
            )
            
            $0.settings(
                for: depTargets.macOS
            )
        },
        subSpecs: {
            
            $0.subSpec(PodSubSpecs.core.name){
                
                $0.settings(
                    """
                    source_files = '\(PodSubSpecs.core.path)'
                    """
                )
            }
            
            $0.subSpec(PodSubSpecs.operators.name){
                
                $0.settings(
                    """
                    dependency '\(cocoaPodsModuleName)/\(PodSubSpecs.core.name)'
                    """,
                    
                    """
                    source_files = '\(PodSubSpecs.operators.path)'
                    """
                )
            }
        },
        testSubSpecs: {
            
            $0.testSubSpec(tstSuffix){

                $0.settings(

                    "requires_app_host = false",
                    "source_files = '\(sourcesPath.tst)/**/*.swift'",
                    "framework = 'XCTest'",
                    "dependency 'SwiftLint'" // we will be running linting from unit tests!
                )
                
                $0.settings(
                    
                    // https://github.com/CocoaPods/CocoaPods/issues/7708#issuecomment-424392893
                    """
                    pod_target_xcconfig = {
                        'EXPANDED_CODE_SIGN_IDENTITY' => '-',
                        'EXPANDED_CODE_SIGN_IDENTITY_NAME' => '-'
                    }
                    """
                )
            }
        }
    )
    .prepare(
        name: podspecFileName,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - Fastlane - Fastfile

try Fastlane
    .Fastfile
    .ForLibrary()
    .defaultHeader()
    .beforeRelease(
        cocoaPodsModuleName: cocoaPodsModuleName
    )
    .lane("lintThoroughly"){
        
        "pod_lib_lint"
    }
    .generateProjectViaCP(
        callCocoaPods: .viaBundler,
        targetPath: genXcodeArtifactsPath,
        extraScriptBuildPhases: [
            
            .swiftLint(
                projectName: genXcodeProjectBeforeExt,
                targetNames: [
                    
                    "\(cocoaPodsModuleName)-\(OSIdentifier.iOS.rawValue)",
                    "\(cocoaPodsModuleName)-\(OSIdentifier.watchOS.rawValue)",
                    "\(cocoaPodsModuleName)-\(OSIdentifier.tvOS.rawValue)",
                    "\(cocoaPodsModuleName)-\(OSIdentifier.macOS.rawValue)"
                ],
                params: [
                    
                    """
                    --path "${SRCROOT}/../../\(sourcesPath.main.rawValue)"
                    """
                ]
            ),
            
            .swiftLint(
                projectName: genXcodeProjectBeforeExt,
                targetNames: [
                    
                    "\(cocoaPodsModuleName)-\(OSIdentifier.iOS.rawValue)-Unit-\(tstSuffix)",
                    // NOTE: skip watchOS!
                    "\(cocoaPodsModuleName)-\(OSIdentifier.tvOS.rawValue)-Unit-\(tstSuffix)",
                    "\(cocoaPodsModuleName)-\(OSIdentifier.macOS.rawValue)-Unit-\(tstSuffix)"
                ],
                params: [
                
                    """
                    --path "${SRCROOT}/../../\(sourcesPath.tst.rawValue)"
                    """
                ]
            )
        ],
        endingEntries: [
            
            """
            # NOTE: Origin path MUST be absolute in order the symlink to work properly!
            sh 'cd ./.. && \(symLinkCmd("$PWD/" + linterCfgOriginPath, linterCfgSymLinkPath.main))'
            sh 'cd ./.. && \(symLinkCmd("$PWD/" + linterCfgOriginPath, linterCfgSymLinkPath.tst))'
            """
        ]
    )
    .generateProjectViaIce()
    .prepare(
        targetFolder: fastlaneFolder.path
    )
    .writeToFileSystem()

// MARK: Write - GitHub - PagesConfig

try GitHub
    .PagesConfig()
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - Git - .gitignore

try Git
    .RepoIgnore
    .framework(
        otherEntries: [
            """
            # we don't need to store any project files,
            # as we generate them on-demand from specs
            *.xcodeproj

            # folder for temporary development Xcode-related artifacts
            # generated by 'cocopods-generate'
            Xcode

            # derived files generated by '.automation/Setup' script
            \(sourcesPath.main)/\(dummyFileName)
            \(sourcesPath.tst)/\(dummyFileName)
            \(Bundler.Gemfile.fileName)
            \(Bundler.Gemfile.fileName).lock
            \(fastlaneFolderPath)/\(Fastlane.Fastfile.fileName)
            # \(ReadMe.fileName)
            # \(SwiftLint.fileName)
            \(linterCfgSymLinkPath.main)
            \(linterCfgSymLinkPath.tst)
            # \(License.MIT.fileName)
            # \(podspecFileName)
            # \(GitHub.PagesConfig.fileName)
            """
            ]
    )
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: - POST-script invocation output

print("--- END of '\(Executable.name!)' script ---")
