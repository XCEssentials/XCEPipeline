import FileKit
import Files
import ShellOut

import XCERepoConfigurator

//---

print("\n")
print("--- BEGIN of '\(Executable.name!)' script ---")

// MARK: - Type declarations

typealias PerPlatform<T> = (
    iOS: T,
    watchOS: T,
    tvOS: T,
    macOS: T
)

typealias PerPlatformTst<T> = (
    iOS: T,
    // NO tests for .watchOS
    tvOS: T,
    macOS: T
)

typealias CommonAndPerPlatform<T> = (
    common: T,
    iOS: T,
    watchOS: T,
    tvOS: T,
    macOS: T
)

typealias CommonAndPerPlatformTst<T> = (
    common: T,
    iOS: T,
    // NO tests for .watchOS
    tvOS: T,
    macOS: T
)

// one item for main target, and one - for unit tests
typealias PerTarget<T> = (
    main: PerPlatform<T>,
    tst: PerPlatformTst<T>
)

typealias JustPerTarget<T> = (
    main: T,
    tst: T
)

typealias CommonAndPerTarget<T> = (
    main: CommonAndPerPlatform<T>,
    tst: CommonAndPerPlatformTst<T>
)

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

let swiftExt = ".swift"

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

// necessary for signing FWK on macOS:
let developmentTeamId = "UJA88X59XP" // "Maxim Khatskevich"

let cocoaPodsModuleName = company.prefix + product.name

let author: CocoaPods.Podspec.Author = (
    name: "Maxim Khatskevich",
    email: "maxim@khatskevi.ch"
)

typealias LicenseMIT = License.MIT

let tstSuffix = Defaults.tstSuffix

let baseTargetName = product.name
let baseTstTargetName = product.name + tstSuffix

let targetName: CommonAndPerTarget<String> = (
    (
        baseTargetName,
        baseTargetName + "-" + OSIdentifier.iOS.rawValue,
        baseTargetName + "-" + OSIdentifier.watchOS.rawValue,
        baseTargetName + "-" + OSIdentifier.tvOS.rawValue,
        baseTargetName + "-" + OSIdentifier.macOS.rawValue
    ),
    (
        baseTstTargetName,
        baseTstTargetName + "-" + OSIdentifier.iOS.rawValue,
        // NO tests for .watchOS
        baseTstTargetName + "-" + OSIdentifier.tvOS.rawValue,
        baseTstTargetName + "-" + OSIdentifier.macOS.rawValue
    )
)

let defaultTargetName = targetName.main.macOS

let depTargets: PerPlatform<DeploymentTarget> = (
    (.iOS, "9.0"),
    (.watchOS, "3.0"),
    (.tvOS, "9.0"),
    (.macOS, "10.11")
)

let baseInfoPlistsPathStr = Defaults
    .pathToInfoPlistsFolder

let infoPlistPaths: PerTarget<Path> = (
    (
        [baseInfoPlistsPathStr, "\(targetName.main.iOS).plist"],
        [baseInfoPlistsPathStr, "\(targetName.main.watchOS).plist"],
        [baseInfoPlistsPathStr, "\(targetName.main.tvOS).plist"],
        [baseInfoPlistsPathStr, "\(targetName.main.macOS).plist"]
    ),
    (
        [baseInfoPlistsPathStr, "\(targetName.tst.iOS).plist"],
        // NO tests for .watchOS
        [baseInfoPlistsPathStr, "\(targetName.tst.tvOS).plist"],
        [baseInfoPlistsPathStr, "\(targetName.tst.macOS).plist"]
    )
)

let sourcesPath: JustPerTarget<Path> = (
    [Defaults.pathToSourcesFolder],
    [tstSuffix]
)

let sourcesFolder: JustPerTarget<Folder> = try (
    repoFolder
        .createSubfolderIfNeeded(
            withName: sourcesPath.main.rawValue
        ),
    repoFolder
        .createSubfolderIfNeeded(
            withName: sourcesPath.tst.rawValue
        )
)

let bundleId: PerTarget<String> = (
    (
        company.identifier + "." + targetName.main.iOS,
        company.identifier + "." + targetName.main.watchOS,
        company.identifier + "." + targetName.main.tvOS,
        company.identifier + "." + targetName.main.macOS
    ),
    (
        company.identifier + "." + targetName.tst.iOS,
        // NO tests for .watchOS
        company.identifier + "." + targetName.tst.tvOS,
        company.identifier + "." + targetName.tst.macOS
    )
)

let scriptsPath = "Scripts"

let scriptName = (
    structPostGen: Path(arrayLiteral: scriptsPath, Struct.Spec.PostGenerateScript.defaultFileName),
    none: ()
)

let podspecFileName = cocoaPodsModuleName + ".podspec"

let currentPodVersion: VersionString // will be defined later

let commonPodDependencies = [

    "pod 'SwiftLint'"
]

let fastlaneFolder = try repoFolder
    .createSubfolderIfNeeded(
        withName: Defaults.pathToFastlaneFolder
    )

// MARK: -

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

// MARK: Write - Git

try Git
    .RepoIgnore
    .framework(
        otherEntries: [
            "*.xcodeproj"
        ]
    )
    .prepare(
        targetFolder: repoFolder.path
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

try LicenseMIT(
    copyrightYear: copyrightYear,
    copyrightEntity: author.name
    )
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - Dummy files

try CustomTextFile()
    .prepare(
        name: targetName.main.common + swiftExt,
        targetFolder: sourcesFolder.main.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.tst.common + swiftExt,
        targetFolder: sourcesFolder.tst.path
    )
    .writeToFileSystem(ifFileExists: .skip)

// MARK: Write - CocoaPods - Podfile

try CocoaPods
    .Podfile(
        workspaceName: product.name
    )
    .custom("""
        # disable 'deterministic_uuids' to avoid warnings from CocoaPods
        # which arise in case you have files with same names at different locations,
        # see also https://github.com/CocoaPods/CocoaPods/issues/4370#issuecomment-284075060
        install! 'cocoapods', :deterministic_uuids => false
        """
    )
    .target(
        targetName.main.iOS,
        projectName: projectName,
        deploymentTarget: depTargets.iOS,
        includePodsFromPodspec: true,
        pods: commonPodDependencies
    )
    .target(
        targetName.main.watchOS,
        projectName: projectName,
        deploymentTarget: depTargets.watchOS,
        includePodsFromPodspec: true,
        pods: commonPodDependencies
    )
    .target(
        targetName.main.tvOS,
        projectName: projectName,
        deploymentTarget: depTargets.tvOS,
        includePodsFromPodspec: true,
        pods: commonPodDependencies
    )
    .target(
        targetName.main.macOS,
        projectName: projectName,
        deploymentTarget: depTargets.macOS,
        includePodsFromPodspec: true,
        pods: commonPodDependencies
    )
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - CocoaPods - Podspec

try CocoaPods
    .Podspec
    .standard(
        product: product,
        company: company,
        version: currentPodVersion,
        license: (LicenseMIT.licenseType, LicenseMIT.fileName),
        authors: [author],
        swiftVersion: swiftVersion,
        perPlatformSettings: {

            $0.settings(
                for: nil, // common/base settings
                "source_files = '\(sourcesPath.main)/**/*.swift'"
            )

            $0.settings(
                for: depTargets.iOS
            )

            $0.settings(
                for: depTargets.watchOS
            )

            $0.settings(
                for: depTargets.tvOS
            )

            $0.settings(
                for: depTargets.macOS
            )
    }
    )
    .prepare(
        name: podspecFileName,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - Fastlane - Fastfile

//try Fastlane
//    .Fastfile
//    .framework(
//        productName: product.name,
//        getCurrentVersionFromTarget: defaultTargetName,
//        cocoaPodsModuleName: cocoaPodsModuleName,
//        swiftLintTargets: [
//
//            targetName.main.iOS,
//            targetName.main.watchOS,
//            targetName.main.tvOS,
//            targetName.main.macOS,
//
//            targetName.tst.iOS,
//            // NO tests for .watchOS,
//            targetName.tst.tvOS,
//            targetName.tst.macOS
//        ]
//    )
//    .prepare(
//        targetFolder: fastlaneFolder.path
//    )
//    .writeToFileSystem()

// MARK: Write - GitHub - PagesConfig

try GitHub
    .PagesConfig()
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

//---

print("--- END of '\(Executable.name!)' script ---")
