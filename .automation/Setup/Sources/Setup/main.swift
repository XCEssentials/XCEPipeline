import FileKit
import Files
import ShellOut

import XCERepoConfigurator

//---

public
extension Path
{
    var isGitRepoRoot: Bool
    {
        return children().contains{
            
            $0.isDirectory && ($0.components.last == ".git")
        }
    }
    
    static
    var currentRepoRoot: Path?
    {
        var maybeResult: Path? = .current
        
        //---
        
        repeat
        {
            switch maybeResult
            {
            case let .some(path) where path.isGitRepoRoot:
                return path
                
            case let .some(path) where !path.isGitRepoRoot:
                let nextMaybeResult = path.parent
                
                if
                    nextMaybeResult ~= path
                {
                    return nil // already at the root and nothing found
                }
                else
                {
                    maybeResult = nextMaybeResult
                }
                
            default:
                return nil
            }
        }
            while true
    }
}

extension Path: ExpressibleByArrayLiteral
{
    public
    init(arrayLiteral elements: String...)
    {
        self.init(elements.joined(separator: Path.separator))
    }
}

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

let baseSourcesPathStr = Defaults
    .pathToSourcesFolder

let crossPlatfromSourcesPathStr = "Common"

let sourcesPath: CommonAndPerTarget<Path> = (
    (
        [baseSourcesPathStr, baseTargetName, crossPlatfromSourcesPathStr],
        [baseSourcesPathStr, baseTargetName, OSIdentifier.iOS.rawValue],
        [baseSourcesPathStr, baseTargetName, OSIdentifier.watchOS.rawValue],
        [baseSourcesPathStr, baseTargetName, OSIdentifier.tvOS.rawValue],
        [baseSourcesPathStr, baseTargetName, OSIdentifier.macOS.rawValue]
    ),
    (
        [baseSourcesPathStr, baseTstTargetName, crossPlatfromSourcesPathStr],
        [baseSourcesPathStr, baseTstTargetName, OSIdentifier.iOS.rawValue],
        // NO tests for .watchOS
        [baseSourcesPathStr, baseTstTargetName, OSIdentifier.tvOS.rawValue],
        [baseSourcesPathStr, baseTstTargetName, OSIdentifier.macOS.rawValue]
    )
)

let sourcesFolder: CommonAndPerTarget<Folder> = try (
    (
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.main.common.rawValue
        ),
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.main.iOS.rawValue
        ),
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.main.watchOS.rawValue
        ),
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.main.tvOS.rawValue
        ),
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.main.macOS.rawValue
        )
    ),
    (
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.tst.common.rawValue
        ),
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.tst.iOS.rawValue
        ),
        // NO tests for .watchOS
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.tst.tvOS.rawValue
        ),
        repoFolder
            .createSubfolderIfNeeded(
                withName: sourcesPath.tst.macOS.rawValue
        )
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
        gem 'xcodeproj'
        gem 'cocoapods'
        gem 'struct'
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

    currentPodVersion = try shellOut(
        to: """
        bundle exec fastlane run version_get_podspec \
            path:"\(repoFolder.path + "/" + podspecFileName)" \
        | grep "Result:" \
        | find-versions
        """
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
    .framework()
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

// MARK: Write - Info plists - Main

try Xcode
    .Target
    .InfoPlist(
        for: .framework,
        preset: .iOS
    )
    .prepare(
        name: infoPlistPaths.main.iOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

try Xcode
    .Target
    .InfoPlist(
        for: .framework,
        preset: nil
    )
    .prepare(
        name: infoPlistPaths.main.watchOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

try Xcode
    .Target
    .InfoPlist(
        for: .framework,
        preset: nil
    )
    .prepare(
        name: infoPlistPaths.main.tvOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

try Xcode
    .Target
    .InfoPlist(
        for: .framework,
        preset: .macOS(
            copyrightYear: copyrightYear,
            copyrightEntity: author.name
        )
    )
    .prepare(
        name: infoPlistPaths.main.macOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

// MARK: Write - Info plists - Tst

try Xcode
    .Target
    .InfoPlist(
        for: .tests,
        preset: .iOS
    )
    .prepare(
        name: infoPlistPaths.tst.iOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

// NO tests for .watchOS

try Xcode
    .Target
    .InfoPlist(
        for: .tests,
        preset: nil
    )
    .prepare(
        name: infoPlistPaths.tst.tvOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

try Xcode
    .Target
    .InfoPlist(
        for: .tests,
        preset: .macOS(
            copyrightYear: copyrightYear,
            copyrightEntity: author.name
        )
    )
    .prepare(
        name: infoPlistPaths.tst.macOS.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem(ifFileExists: .skip) // write ONCE!

// MARK: Write - Dummy files - Main

try CustomTextFile()
    .prepare(
        name: targetName.main.common + swiftExt,
        targetFolder: sourcesFolder.main.common.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.main.iOS + swiftExt,
        targetFolder: sourcesFolder.main.iOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.main.watchOS + swiftExt,
        targetFolder: sourcesFolder.main.watchOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.main.tvOS + swiftExt,
        targetFolder: sourcesFolder.main.tvOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.main.macOS + swiftExt,
        targetFolder: sourcesFolder.main.macOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

// MARK: Write - Dummy files - Tst

try CustomTextFile()
    .prepare(
        name: targetName.tst.common + swiftExt,
        targetFolder: sourcesFolder.tst.common.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.tst.iOS + swiftExt,
        targetFolder: sourcesFolder.tst.iOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

// NO tests for .watchOS

try CustomTextFile()
    .prepare(
        name: targetName.tst.tvOS + swiftExt,
        targetFolder: sourcesFolder.tst.tvOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

try CustomTextFile()
    .prepare(
        name: targetName.tst.macOS + swiftExt,
        targetFolder: sourcesFolder.tst.macOS.path
    )
    .writeToFileSystem(ifFileExists: .skip)

// MARK: Write - Struct - PostGenScript

try Struct
    .Spec
    .PostGenerateScript{

        $0.inheritedModuleName(
            productTypes: [.framework]
        )
    }
    .prepare(
        name: scriptName.structPostGen.rawValue,
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

// MARK: Write - Struct - Spec

try Struct
    .Spec(product.name){

        project in

        // MARK: Write - Struct - Spec - Project Build Settings

        project.buildSettings.base.override(

            "SWIFT_VERSION" <<< swiftVersion,

            "PRODUCT_NAME" <<< "\(company.prefix)\(product.name)",

            "DEVELOPMENT_TEAM" <<< developmentTeamId, // needed for macOS tests

            "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion,
            "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,
            "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion,
            "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
        )

        // MARK: Write - Struct - Spec - Targets

        project.targets(

            // MARK: Write - Struct - Spec - Targets - iOS

            Mobile.Framework(targetName.main.iOS) {

                fwk in

                //---

                fwk.include(sourcesPath.main.common.rawValue)
                fwk.include(sourcesPath.main.iOS.rawValue)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistPaths.main.iOS.rawValue,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.iOS,

                    //--- platform specific:

                    "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion,
                    "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal
                )

                //---

                fwk.addUnitTests(targetName.tst.iOS) {

                    fwkTests in

                    //---

                    fwkTests.include(sourcesPath.tst.common.rawValue)
                    fwkTests.include(sourcesPath.tst.iOS.rawValue)

                    //---

                    fwkTests.buildSettings.base.override(

                        "INFOPLIST_FILE" <<< infoPlistPaths.tst.iOS.rawValue,
                        "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.iOS,

                        //--- platform specific:

                        "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion
                    )
                }
            },

            // MARK: Write - Struct - Spec - Targets - watchOS

            Watch.Framework(targetName.main.watchOS){

                fwk in

                //---

                fwk.include(sourcesPath.main.common.rawValue)
                fwk.include(sourcesPath.main.watchOS.rawValue)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistPaths.main.watchOS.rawValue,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.watchOS,

                    //--- platform specific:

                    "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,

                    //--- Framework related:

                    "CODE_SIGN_IDENTITY" <<< "iPhone Developer",
                    "CODE_SIGN_STYLE" <<< "Automatic"
                )
            },

            // MARK: Write - Struct - Spec - Targets - tvOS

            TV.Framework(targetName.main.tvOS){

                fwk in

                //---

                fwk.include(sourcesPath.main.common.rawValue)
                fwk.include(sourcesPath.main.tvOS.rawValue)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistPaths.main.tvOS.rawValue,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.tvOS,

                    //--- platform specific:

                    "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion
                )

                //---

                fwk.addUnitTests(targetName.tst.tvOS){

                    fwkTests in

                    //---

                    fwkTests.include(sourcesPath.tst.common.rawValue)
                    fwkTests.include(sourcesPath.tst.tvOS.rawValue)

                    //---

                    fwkTests.buildSettings.base.override(

                        "INFOPLIST_FILE" <<< infoPlistPaths.tst.tvOS.rawValue,
                        "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.tvOS,

                        //--- platform specific:

                        "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion
                    )
                }
            },

            // MARK: Write - Struct - Spec - Targets - macOS

            Desktop.Framework(targetName.main.macOS){

                fwk in

                //---

                fwk.include(sourcesPath.main.common.rawValue)
                fwk.include(sourcesPath.main.macOS.rawValue)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistPaths.main.macOS.rawValue,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.macOS,

                    //--- platform specific:

                    "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
                )

                //---

                fwk.addUnitTests(targetName.tst.macOS) {

                    fwkTests in

                    //---

                    fwkTests.include(sourcesPath.tst.common.rawValue)
                    fwkTests.include(sourcesPath.tst.macOS.rawValue)

                    //---

                    fwkTests.buildSettings.base.override(

                        "INFOPLIST_FILE" <<< infoPlistPaths.tst.macOS.rawValue,
                        "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.macOS,

                        //--- platform specific:

                        "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
                    )
                }
            }
        )

        // MARK: Write - Struct - Spec - Schemes - iOS

        project.scheme(named: targetName.main.iOS){

            $0.build(
                targets: [
                    targetName.main.iOS: (
                        true,
                        true,
                        true,
                        true,
                        true
                    )
                ]
            )

            $0.test(
                targets: [
                    targetName.tst.iOS
                ]
            )
        }

        // MARK: Write - Struct - Spec - Schemes - watchOS

        project.scheme(named: targetName.main.watchOS){

            $0.build(
                targets: [
                    targetName.main.watchOS: (
                        true,
                        true,
                        true,
                        testing: false, // no unit testing for watchOS yet!
                        true
                    )
                ]
            )
        }

        // MARK: Write - Struct - Spec - Schemes - tvOS

        project.scheme(named: targetName.main.tvOS){

            $0.build(
                targets: [
                    targetName.main.tvOS: (
                        true,
                        true,
                        true,
                        true,
                        true
                    )
                ]
            )

            $0.test(
                targets: [
                    targetName.tst.tvOS
                ]
            )
        }

        // MARK: Write - Struct - Spec - Schemes - macOS

        project.scheme(named: targetName.main.macOS){

            $0.build(
                targets: [
                    targetName.main.macOS: (
                        true,
                        true,
                        true,
                        true,
                        true
                    )
                ]
            )

            $0.test(
                targets: [
                    targetName.tst.macOS
                ]
            )
        }

        // MARK: Write - Struct - Spec - Life Cycle Hooks

        project.lifecycleHooks.post = scriptName.structPostGen.rawValue
    }
    .prepare(
        targetFolder: repoFolder.path
    )
    .writeToFileSystem()

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
                "source_files = '\(sourcesPath.main.common)/**/*.swift'"
            )

            $0.settings(
                for: depTargets.iOS,
                "source_files = '\(sourcesPath.main.iOS)/**/*.swift'"
            )

            $0.settings(
                for: depTargets.watchOS,
                "source_files = '\(sourcesPath.main.watchOS)/**/*.swift'"
            )

            $0.settings(
                for: depTargets.tvOS,
                "source_files = '\(sourcesPath.main.tvOS)/**/*.swift'"
            )

            $0.settings(
                for: depTargets.macOS,
                "source_files = '\(sourcesPath.main.macOS)/**/*.swift'"
            )
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
    .framework(
        productName: product.name,
        getCurrentVersionFromTarget: defaultTargetName,
        cocoaPodsModuleName: cocoaPodsModuleName,
        swiftLintTargets: [

            targetName.main.iOS,
            targetName.main.watchOS,
            targetName.main.tvOS,
            targetName.main.macOS,

            targetName.tst.iOS,
            // NO tests for .watchOS,
            targetName.tst.tvOS,
            targetName.tst.macOS
        ]
    )
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

//---

print("--- END of '\(Executable.name!)' script ---")
