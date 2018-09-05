import RepoConfigurator // marathon:https://github.com/XCEssentials/RepoConfigurator.git

//---

typealias PerPlatform<T> = (
    iOS: T,
    watchOS: T,
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

// one item for main target, and one - for unit tests
typealias PerTarget<T> = (
    main: PerPlatform<T>,
    tst: PerPlatform<T>
)

typealias CommonAndPerTarget<T> = (
    main: CommonAndPerPlatform<T>,
    tst: CommonAndPerPlatform<T>
)

//---

let swiftVersion: VersionString = "4.2"

let product: CocoaPods.Podspec.Product = (
    name: "Pipeline",
    summary: "Custom pipeline operators for easy chaining in Swift."
)

let projectName = product.name

let company: CocoaPods.Podspec.Company = (
    name: "XCEssentials",
    identifier: "com.XCEssentials",
    prefix: "XCE"
)

// necessary for signing FWK on macOS:
let developmentTeamId = "UJA88X59XP" // "Maxim Khatskevich"

let cocoaPodsModuleName = company.prefix + product.name

let author: CocoaPods.Podspec.Author = (
    name: "Maxim Khatskevich",
    email: "maxim@khatskevi.ch"
)

let repoFolder = PathPrefix
    .iCloudDrive
    .appendingPathComponent(
        "Dev"
    )
    .appendingPathComponent(
        company.name
    )
    .appendingPathComponent(
        product.name
)

//---

let readme = try ReadMe
    .openSourceProduct(
        header: [
            .gitHubLicenseBadge(
                account: company.name,
                repo: product.name
            ),
            .gitHubTagBadge(
                account: company.name,
                repo: product.name
            ),
            .cocoaPodsVersionBadge(
                podName: cocoaPodsModuleName
            ),
            .cocoaPodsPlatformsBadge(
                podName: cocoaPodsModuleName
            ),
            .carthageCompatibleBadge(),
            .writtenInSwiftBadge(
                version: swiftVersion
            )
        ],

        """


        # Pipeline

        Custom pipeline operators for easy chaining in Swift.

        ```swift
        22 ./ { "\\($0)" } ./ { print($0) }
        ```

        See more examples of usage in unit tests.

        """
    )
    .prepare(
        targetFolder: repoFolder,
        removeRepeatingEmptyLines: false
)

let gitignore = Git
    .RepoIgnore
    .framework()
    .prepare(
        targetFolder: repoFolder
)

let swiftLint = SwiftLint
    .standard()
    .prepare(
        targetFolder: repoFolder
)

let license = License
    .MIT(
        copyrightYear: 2018,
        copyrightEntity: author.name
    )
    .prepare(
        targetFolder: repoFolder
)

//---

let tstSuffix = Defaults.tstSuffix

let targetName: CommonAndPerTarget = (
    (
        product.name,
        OSIdentifier.iOS.rawValue + "-" + product.name,
        OSIdentifier.watchOS.rawValue + "-" + product.name,
        OSIdentifier.tvOS.rawValue + "-" + product.name,
        OSIdentifier.macOS.rawValue + "-" + product.name
    ),
    (
        product.name + tstSuffix,
        OSIdentifier.iOS.rawValue + "-" + product.name + tstSuffix,
        "", // no unit testing for watchOS yet!
        OSIdentifier.tvOS.rawValue + "-" + product.name + tstSuffix,
        OSIdentifier.macOS.rawValue + "-" + product.name + tstSuffix
    )
)

let defaultTargetName = targetName.main.macOS

let commonInfoPlistsPath = Defaults
    .pathToInfoPlistsFolder

let infoPlistsFolder = repoFolder
    .appendingPathComponent(
        commonInfoPlistsPath
)

//---

let info: PerTarget = (
    (
        Xcode
            .Target
            .InfoPlist(
                for: .framework,
                preset: .iOS
            )
            .prepare(
                name: targetName.main.iOS + ".plist",
                targetFolder: infoPlistsFolder
        ),
        Xcode
            .Target
            .InfoPlist(
                for: .framework,
                preset: nil
            )
            .prepare(
                name: targetName.main.watchOS + ".plist",
                targetFolder: infoPlistsFolder
        ),
        Xcode
            .Target
            .InfoPlist(
                for: .framework,
                preset: nil
            )
            .prepare(
                name: targetName.main.tvOS + ".plist",
                targetFolder: infoPlistsFolder
        ),
        Xcode
            .Target
            .InfoPlist(
                for: .framework,
                preset: .macOS(
                    copyrightYear: 2018,
                    copyrightEntity: author.name
                )
            )
            .prepare(
                name: targetName.main.macOS + ".plist",
                targetFolder: infoPlistsFolder
        )
    ),
    (
        Xcode
            .Target
            .InfoPlist(
                for: .tests,
                preset: .iOS
            )
            .prepare(
                name: targetName.tst.iOS + ".plist",
                targetFolder: infoPlistsFolder
        ),
        Xcode
            .Target
            .InfoPlist(
                for: .tests,
                preset: nil
            )
            .prepare(
                name: targetName.tst.watchOS + ".plist",
                targetFolder: infoPlistsFolder
        ),
        Xcode
            .Target
            .InfoPlist(
                for: .tests,
                preset: nil
            )
            .prepare(
                name: targetName.tst.tvOS + ".plist",
                targetFolder: infoPlistsFolder
        ),
        Xcode
            .Target
            .InfoPlist(
                for: .tests,
                preset: .macOS(
                    copyrightYear: 2018,
                    copyrightEntity: author.name
                )
            )
            .prepare(
                name: targetName.tst.macOS + ".plist",
                targetFolder: infoPlistsFolder
        )
    )
)

//---

let depTargets: PerPlatform<DeploymentTarget> = (
    (.iOS, "9.0"),
    (.watchOS, "3.0"),
    (.tvOS, "9.0"),
    (.macOS, "10.11")
)

let baseSourcesPath = Defaults
    .pathToSourcesFolder

let sourcesPath: CommonAndPerTarget = (
    (
        baseSourcesPath + "/" + product.name + "/Common",
        baseSourcesPath + "/" + product.name + "/" + OSIdentifier.iOS.rawValue,
        baseSourcesPath + "/" + product.name + "/" + OSIdentifier.watchOS.rawValue,
        baseSourcesPath + "/" + product.name + "/" + OSIdentifier.tvOS.rawValue,
        baseSourcesPath + "/" + product.name + "/" + OSIdentifier.macOS.rawValue
    ),
    (
        baseSourcesPath + "/" + product.name + tstSuffix + "/Common",
        baseSourcesPath + "/" + product.name + tstSuffix + "/" + OSIdentifier.iOS.rawValue,
        baseSourcesPath + "/" + product.name + tstSuffix + "/" + OSIdentifier.watchOS.rawValue,
        baseSourcesPath + "/" + product.name + tstSuffix + "/" + OSIdentifier.tvOS.rawValue,
        baseSourcesPath + "/" + product.name + tstSuffix + "/" + OSIdentifier.macOS.rawValue
    )
)

let sourcesFolder: CommonAndPerTarget = (
    (
        repoFolder
            .appendingPathComponent(
                sourcesPath.main.common
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.main.iOS
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.main.watchOS
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.main.tvOS
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.main.macOS
        )
    ),
    (
        repoFolder
            .appendingPathComponent(
                sourcesPath.tst.common
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.tst.iOS
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.tst.watchOS
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.tst.tvOS
        ),
        repoFolder
            .appendingPathComponent(
                sourcesPath.tst.macOS
        )
    )
)

let bundleId: PerTarget = (
    (
        company.identifier + "." + targetName.main.iOS,
        company.identifier + "." + targetName.main.watchOS,
        company.identifier + "." + targetName.main.tvOS,
        company.identifier + "." + targetName.main.macOS
    ),
    (
        company.identifier + "." + targetName.tst.iOS,
        company.identifier + "." + targetName.tst.watchOS,
        company.identifier + "." + targetName.tst.tvOS,
        company.identifier + "." + targetName.tst.macOS
    )
)

let infoPlistsPath: PerTarget = (
    (
        commonInfoPlistsPath + "/" + info.main.iOS.name,
        commonInfoPlistsPath + "/" + info.main.watchOS.name,
        commonInfoPlistsPath + "/" + info.main.tvOS.name,
        commonInfoPlistsPath + "/" + info.main.macOS.name
    ),
    (
        commonInfoPlistsPath + "/" + info.tst.iOS.name,
        commonInfoPlistsPath + "/" + info.tst.watchOS.name,
        commonInfoPlistsPath + "/" + info.tst.tvOS.name,
        commonInfoPlistsPath + "/" + info.tst.macOS.name
    )
)

//---

//let dummyFile: CommonAndPerTarget = (
//    (
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.main.common + ".swift",
//                targetFolder: sourcesFolder.main.common
//            ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.main.iOS + ".swift",
//                targetFolder: sourcesFolder.main.iOS
//            ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.main.watchOS + ".swift",
//                targetFolder: sourcesFolder.main.watchOS
//            ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.main.tvOS + ".swift",
//                targetFolder: sourcesFolder.main.tvOS
//            ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.main.macOS + ".swift",
//                targetFolder: sourcesFolder.main.macOS
//            )
//    ),
//    (
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.tst.common + ".swift",
//                targetFolder: sourcesFolder.tst.common
//        ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.tst.iOS + ".swift",
//                targetFolder: sourcesFolder.tst.iOS
//        ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.tst.watchOS + ".swift",
//                targetFolder: sourcesFolder.tst.watchOS
//        ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.tst.tvOS + ".swift",
//                targetFolder: sourcesFolder.tst.tvOS
//        ),
//        CustomTextFile
//            .init()
//            .prepare(
//                name: targetName.tst.macOS + ".swift",
//                targetFolder: sourcesFolder.tst.macOS
//        )
//    )
//)

//---

let scriptsPath = "Scripts"

let scriptsFolder = repoFolder
    .appendingPathComponent(
        scriptsPath
)

//---

let structPostGenScript = Struct
    .Spec
    .PostGenerateScript(
        .inheritedModuleName(
            productTypes: [.framework]
        )
    )
    .prepareWithDefaultName(
        targetFolder: scriptsFolder
)

let structSpec = Struct
    .Spec(product.name){

        project in

        //---

        project.buildSettings.base.override(

            "SWIFT_VERSION" <<< swiftVersion,

            "PRODUCT_NAME" <<< "\(company.prefix)\(product.name)",

            "DEVELOPMENT_TEAM" <<< developmentTeamId, // needed for macOS tests

            "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion,
            "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,
            "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion,
            "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
        )

        //---

        project.targets(

            Mobile.Framework(targetName.main.iOS) {

                fwk in

                //---

                fwk.include(sourcesPath.main.common)
                fwk.include(sourcesPath.main.iOS)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistsPath.main.iOS,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.iOS,

                    //--- platform specific:

                    "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion,
                    "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal
                )

                //---

                fwk.addUnitTests(targetName.tst.iOS) {

                    fwkTests in

                    //---

                    fwkTests.include(sourcesPath.tst.common)
                    fwkTests.include(sourcesPath.tst.iOS)

                    //---

                    fwkTests.buildSettings.base.override(

                        "INFOPLIST_FILE" <<< infoPlistsPath.tst.iOS,
                        "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.iOS,

                        //--- platform specific:

                        "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion
                    )
                }
            },

            //---

            Watch.Framework(targetName.main.watchOS){

                fwk in

                //---

                fwk.include(sourcesPath.main.common)
                fwk.include(sourcesPath.main.watchOS)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistsPath.main.watchOS,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.watchOS,

                    //--- platform specific:

                    "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,

                    //--- Framework related:

                    "CODE_SIGN_IDENTITY" <<< "iPhone Developer",
                    "CODE_SIGN_STYLE" <<< "Automatic"
                )
            },

            //---

            TV.Framework(targetName.main.tvOS){

                fwk in

                //---

                fwk.include(sourcesPath.main.common)
                fwk.include(sourcesPath.main.tvOS)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistsPath.main.tvOS,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.tvOS,

                    //--- platform specific:

                    "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion
                )

                //---

                fwk.addUnitTests(targetName.tst.tvOS){

                    fwkTests in

                    //---

                    fwkTests.include(sourcesPath.tst.common)
                    fwkTests.include(sourcesPath.tst.tvOS)

                    //---

                    fwkTests.buildSettings.base.override(

                        "INFOPLIST_FILE" <<< infoPlistsPath.tst.tvOS,
                        "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.tvOS,

                        //--- platform specific:

                        "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion
                    )
                }
            },

            //---

            Desktop.Framework(targetName.main.macOS){

                fwk in

                //---

                fwk.include(sourcesPath.main.common)
                fwk.include(sourcesPath.main.macOS)

                //---

                fwk.buildSettings.base.override(

                    "INFOPLIST_FILE" <<< infoPlistsPath.main.macOS,
                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.macOS,

                    //--- platform specific:

                    "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
                )

                //---

                fwk.addUnitTests(targetName.tst.macOS) {

                    fwkTests in

                    //---

                    fwkTests.include(sourcesPath.tst.common)
                    fwkTests.include(sourcesPath.tst.macOS)

                    //---

                    fwkTests.buildSettings.base.override(

                        "INFOPLIST_FILE" <<< infoPlistsPath.tst.macOS,
                        "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.macOS,

                        //--- platform specific:

                        "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
                    )
                }
            }
        )

        //---

        project.schemes(
            .scheme(
                named: targetName.main.iOS,
                .build(
                    targets: [
                        targetName.main.iOS: (
                            true,
                            true,
                            true,
                            true,
                            true
                        )
                    ]
                ),
                .test(
                    targets: [
                        targetName.tst.iOS
                    ]
                )
            ),
            .scheme(
                named: targetName.main.watchOS,
                .build(
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
            ),
            .scheme(
                named: targetName.main.tvOS,
                .build(
                    targets: [
                        targetName.main.tvOS: (
                            true,
                            true,
                            true,
                            true,
                            true
                        )
                    ]
                ),
                .test(
                    targets: [
                        targetName.tst.tvOS
                    ]
                )
            ),
            .scheme(
                named: targetName.main.macOS,
                .build(
                    targets: [
                        targetName.main.macOS: (
                            true,
                            true,
                            true,
                            true,
                            true
                        )
                    ]
                ),
                .test(
                    targets: [
                        targetName.tst.macOS
                    ]
                )
            )
        )

        //---

        project.lifecycleHooks.post = scriptsPath + "/" + structPostGenScript.name
    }
    .prepare(
        targetFolder: repoFolder
)

//---

let podfile = CocoaPods
    .Podfile(
        workspaceName: product.name,
        targets: [
            .target(
                targetName.main.iOS,
                projectName: projectName,
                deploymentTarget: depTargets.iOS,
                includePodsFromPodspec: true,
                pods: [

                    // add pods here...
                ]
            ),
            .target(
                targetName.main.watchOS,
                projectName: projectName,
                deploymentTarget: depTargets.watchOS,
                includePodsFromPodspec: true,
                pods: [

                    // add pods here...
                ]
            ),
            .target(
                targetName.main.tvOS,
                projectName: projectName,
                deploymentTarget: depTargets.tvOS,
                includePodsFromPodspec: true,
                pods: [

                    // add pods here...
                ]
            ),
            .target(
                targetName.main.macOS,
                projectName: projectName,
                deploymentTarget: depTargets.macOS,
                includePodsFromPodspec: true,
                pods: [

                    // add pods here...
                ]
            )
        ]
    )
    .prepare(
        targetFolder: repoFolder
)

//---

let podspecFileName = cocoaPodsModuleName + ".podspec"

var currentPodVersion: String? = nil

//let output = run(bash: """
//    fastlane run version_get_podspec path:"\(repoFolder.appendingPathComponent(podspecFileName).path)"
//    """
//)
//
//if
//    output.succeeded
//{
//    currentPodVersion = output.stdout
//    print(currentPodVersion)
//}
//else
//{
//    print(output.stderror)
//}


//\
//| grep "Result:" \
//| awk -F'Result: ' '{print $2}'

//---

let podspec = CocoaPods
    .Podspec
    .standard(
        product: product,
        company: company,
        version: currentPodVersion ?? Defaults.initialVersionString,
        license: license.model.cocoaPodsLicenseSummary,
        authors: [author],
        swiftVersion: swiftVersion,
        otherSettings: [
            (
                deploymentTarget: nil,
                settigns: [

                    "source_files = '\(sourcesPath.main.common)/**/*.swift'"
                ]
            ),
            (
                deploymentTarget: depTargets.iOS,
                settigns: [

                    "source_files = '\(sourcesPath.main.iOS)/**/*.swift'"
                ]
            ),
            (
                deploymentTarget: depTargets.watchOS,
                settigns: [

                    "source_files = '\(sourcesPath.main.watchOS)/**/*.swift'"
                ]
            ),
            (
                deploymentTarget: depTargets.tvOS,
                settigns: [

                    "source_files = '\(sourcesPath.main.tvOS)/**/*.swift'"
                ]
            ),
            (
                deploymentTarget: depTargets.macOS,
                settigns: [

                    "source_files = '\(sourcesPath.main.macOS)/**/*.swift'"
                ]
            )
        ]
    )
    .prepare(
        name: podspecFileName,
        targetFolder: repoFolder
)

// https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile
//let gemfile = Fastlane
//    .Gemfile
//    .fastlaneSupportOnly()
//    .prepare(
//        targetFolder: repoFolder
//    )

//---

let fastlaneFolder = repoFolder
    .appendingPathComponent(
        Defaults.pathToFastlaneFolder
)

//---

let fastfile = Fastlane
    .Fastfile
    .framework(
        productName: product.name,
        getCurrentVersionFromTarget: defaultTargetName,
        cocoaPodsModuleName: cocoaPodsModuleName,
        swiftLintGlobalTargets: [

            targetName.main.iOS,
            targetName.main.watchOS,
            targetName.main.tvOS,
            targetName.main.macOS,

            targetName.tst.iOS,
            targetName.tst.watchOS,
            targetName.tst.tvOS,
            targetName.tst.macOS
        ]
    )
    .prepare(
        targetFolder: fastlaneFolder
)

let gitHubPagesConfig = GitHub
    .PagesConfig()
    .prepare(
        targetFolder: repoFolder
)

// MARK: - Actually write repo configuration files

try? readme
    .writeToFileSystem()

try? gitignore
    .writeToFileSystem()

try? swiftLint
    .writeToFileSystem()

try? license
    .writeToFileSystem()

try? info
    .main
    .iOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .main
    .watchOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .main
    .tvOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .main
    .macOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .tst
    .iOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

// NO unit testing for wtachOS yet!

try? info
    .tst
    .tvOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .tst
    .macOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

//try? dummyFile
//    .main
//    .common
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .main
//    .iOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .main
//    .watchOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .main
//    .tvOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .main
//    .macOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .tst
//    .common
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .tst
//    .iOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//// NO unit testing for wtachOS yet!
//
//try? dummyFile
//    .tst
//    .tvOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!
//
//try? dummyFile
//    .tst
//    .macOS
//    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? structPostGenScript
    .writeToFileSystem()

try? structSpec
    .writeToFileSystem()

try? podfile
    .writeToFileSystem()

try? podspec
    .writeToFileSystem()

//try? gemfile
//    .writeToFileSystem()

try? fastfile
    .writeToFileSystem()

try? gitHubPagesConfig
    .writeToFileSystem()
