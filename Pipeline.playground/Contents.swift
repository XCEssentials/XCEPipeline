import XCERepoConfigurator

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

let gitignore = Git
    .RepoIgnore
    .framework()
    .prepare(
        targetFolder: repoFolder
    )

let swiftLint = SwiftLint
    .init()
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
        OSIdentifier.watchOS.rawValue + "-" + product.name + tstSuffix,
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

let swiftVersion: VersionString = "4.2"

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

let dummyFile: CommonAndPerTarget = (
    (
        CustomTextFile
            .init()
            .prepare(
                name: targetName.main.common + ".swift",
                targetFolder: sourcesFolder.main.common
            ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.main.iOS + ".swift",
                targetFolder: sourcesFolder.main.iOS
            ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.main.watchOS + ".swift",
                targetFolder: sourcesFolder.main.watchOS
            ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.main.tvOS + ".swift",
                targetFolder: sourcesFolder.main.tvOS
            ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.main.macOS + ".swift",
                targetFolder: sourcesFolder.main.macOS
            )
    ),
    (
        CustomTextFile
            .init()
            .prepare(
                name: targetName.tst.common + ".swift",
                targetFolder: sourcesFolder.tst.common
        ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.tst.iOS + ".swift",
                targetFolder: sourcesFolder.tst.iOS
        ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.tst.watchOS + ".swift",
                targetFolder: sourcesFolder.tst.watchOS
        ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.tst.tvOS + ".swift",
                targetFolder: sourcesFolder.tst.tvOS
        ),
        CustomTextFile
            .init()
            .prepare(
                name: targetName.tst.macOS + ".swift",
                targetFolder: sourcesFolder.tst.macOS
        )
    )
)

let project = Struct
    .Spec(product.name){

        project in

        //---

        project.buildSettings.base.override(

            "SWIFT_VERSION" <<< swiftVersion,
            "VERSIONING_SYSTEM" <<< "apple-generic",

            "CURRENT_PROJECT_VERSION" <<< "0", // just a default non-empty value

            "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING" <<< YES,
            "CLANG_WARN_COMMA" <<< YES,
            "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS" <<< YES,
            "CLANG_WARN_NON_LITERAL_NULL_CONVERSION" <<< YES,
            "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF" <<< YES,
            "CLANG_WARN_OBJC_LITERAL_CONVERSION" <<< YES,
            "CLANG_WARN_RANGE_LOOP_ANALYSIS" <<< YES,
            "CLANG_WARN_STRICT_PROTOTYPES" <<< YES,

            "PRODUCT_NAME" <<< "\(company.prefix)\(product.name)",
            
            "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion,
            "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,
            "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion,
            "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
        )

        project.buildSettings[.debug].override(

            "SWIFT_OPTIMIZATION_LEVEL" <<< "-Onone"
        )

        //---

        project.target(targetName.main.iOS, .iOS, .framework) {

            fwk in

            //---

            fwk.include(sourcesPath.main.common)
            fwk.include(sourcesPath.main.iOS)

            //---

            fwk.buildSettings.base.override(

                "SWIFT_VERSION" <<< "$(inherited)",

                "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.iOS,
                "INFOPLIST_FILE" <<< infoPlistsPath.main.iOS,

                //--- platform specific:

                "SDKROOT" <<< "iphoneos",
                "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion,
                "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal,

                //--- Framework related:

                "CODE_SIGN_IDENTITY" <<< "iPhone Developer",
                "CODE_SIGN_STYLE" <<< "Automatic",

                "PRODUCT_NAME" <<< "$(inherited)",
                "DEFINES_MODULE" <<< YES,
                "SKIP_INSTALL" <<< YES,
                "MTL_ENABLE_DEBUG_INFO" <<< YES
            )

            fwk.buildSettings[.debug].override(

                "MTL_ENABLE_DEBUG_INFO" <<< "INCLUDE_SOURCE"
            )

            //---

            fwk.unitTests(targetName.tst.iOS) {

                fwkTests in

                //---

                fwkTests.include(sourcesPath.tst.common)
                fwkTests.include(sourcesPath.tst.iOS)

                //---

                fwkTests.buildSettings.base.override(

                    "SWIFT_VERSION" <<< "$(inherited)",

                    // very important for unit tests,
                    // prevents the error when unit test do not start at all
                    "LD_RUNPATH_SEARCH_PATHS" <<<
                    "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",

                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.iOS,
                    "INFOPLIST_FILE" <<< infoPlistsPath.tst.iOS,
                    "FRAMEWORK_SEARCH_PATHS" <<< "$(inherited) $(BUILT_PRODUCTS_DIR)",

                    //--- platform specific:

                    "IPHONEOS_DEPLOYMENT_TARGET" <<< depTargets.iOS.minimumVersion
                )

                fwkTests.buildSettings[.debug].override(

                    "MTL_ENABLE_DEBUG_INFO" <<< YES
                )
            }
        }

        //---

        project.target(targetName.main.watchOS, .watchOS, .framework) {

            fwk in

            //---

            fwk.include(sourcesPath.main.common)
            fwk.include(sourcesPath.main.watchOS)

            //---

            fwk.buildSettings.base.override(

                "SWIFT_VERSION" <<< "$(inherited)",

                "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.watchOS,
                "INFOPLIST_FILE" <<< infoPlistsPath.main.watchOS,

                //--- platform specific:

//                "SDKROOT" <<< "iphoneos",
                "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,
//                "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal,

                //--- Framework related:

                "CODE_SIGN_IDENTITY" <<< "iPhone Developer",
                "CODE_SIGN_STYLE" <<< "Automatic",

                "PRODUCT_NAME" <<< "$(inherited)",
                "DEFINES_MODULE" <<< YES,
                "SKIP_INSTALL" <<< YES,
                "MTL_ENABLE_DEBUG_INFO" <<< YES
            )

            fwk.buildSettings[.debug].override(

                "MTL_ENABLE_DEBUG_INFO" <<< "INCLUDE_SOURCE"
            )

            //---

//            fwk.unitTests(targetName.tst.watchOS) {
//
//                fwkTests in
//
//                //---
//
//                fwkTests.include(sourcesPath.tst.common)
//                fwkTests.include(sourcesPath.tst.watchOS)
//
//                //---
//
//                fwkTests.buildSettings.base.override(
//
//                    "SWIFT_VERSION" <<< "$(inherited)",
//
//                    // very important for unit tests,
//                    // prevents the error when unit test do not start at all
//                    "LD_RUNPATH_SEARCH_PATHS" <<<
//                    "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",
//
//                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.watchOS,
//                    "INFOPLIST_FILE" <<< infoPlistsPath.tst.watchOS,
//                    "FRAMEWORK_SEARCH_PATHS" <<< "$(inherited) $(BUILT_PRODUCTS_DIR)",
//
//                    //--- platform specific:
//
//                    "WATCHOS_DEPLOYMENT_TARGET" <<< depTargets.watchOS.minimumVersion,
//
//                )
//
//                fwkTests.buildSettings[.debug].override(
//
//                    "MTL_ENABLE_DEBUG_INFO" <<< YES
//                )
//            }
        }

        //---

        project.target(targetName.main.tvOS, .tvOS, .framework) {

            fwk in

            //---

            fwk.include(sourcesPath.main.common)
            fwk.include(sourcesPath.main.tvOS)

            //---

            fwk.buildSettings.base.override(

                "SWIFT_VERSION" <<< "$(inherited)",


                "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.tvOS,
                "INFOPLIST_FILE" <<< infoPlistsPath.main.tvOS,

                //--- platform specific:

//                "SDKROOT" <<< "iphoneos",
                "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion,
//                "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal,

                //--- Framework related:

                "CODE_SIGN_IDENTITY" <<< "iPhone Developer",
                "CODE_SIGN_STYLE" <<< "Automatic",

                "PRODUCT_NAME" <<< "$(inherited)",
                "DEFINES_MODULE" <<< YES,
                "SKIP_INSTALL" <<< YES,
                "MTL_ENABLE_DEBUG_INFO" <<< YES
            )

            fwk.buildSettings[.debug].override(

                "MTL_ENABLE_DEBUG_INFO" <<< "INCLUDE_SOURCE"
            )

            //---

            fwk.unitTests(targetName.tst.tvOS) {

                fwkTests in

                //---

                fwkTests.include(sourcesPath.tst.common)
                fwkTests.include(sourcesPath.tst.tvOS)

                //---

                fwkTests.buildSettings.base.override(

                    "SWIFT_VERSION" <<< "$(inherited)",

                    // very important for unit tests,
                    // prevents the error when unit test do not start at all
                    "LD_RUNPATH_SEARCH_PATHS" <<<
                    "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",

                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.tvOS,
                    "INFOPLIST_FILE" <<< infoPlistsPath.tst.tvOS,
                    "FRAMEWORK_SEARCH_PATHS" <<< "$(inherited) $(BUILT_PRODUCTS_DIR)",

                    //--- platform specific:

                    "TVOS_DEPLOYMENT_TARGET" <<< depTargets.tvOS.minimumVersion
                )

                fwkTests.buildSettings[.debug].override(

                    "MTL_ENABLE_DEBUG_INFO" <<< YES
                )
            }
        }

        //---

        project.target(targetName.main.macOS, .macOS, .framework) {

            fwk in

            //---

            fwk.include(sourcesPath.main.common)
            fwk.include(sourcesPath.main.macOS)

            //---

            fwk.buildSettings.base.override(

                "SWIFT_VERSION" <<< "$(inherited)",

                "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.main.macOS,
                "INFOPLIST_FILE" <<< infoPlistsPath.main.macOS,

                //--- platform specific:

                "SDKROOT" <<< "macosx",
                "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion,

                //--- Framework related:

                "CODE_SIGN_IDENTITY" <<< "Mac Developer",
                "CODE_SIGN_STYLE" <<< "Automatic",

                "PRODUCT_NAME" <<< "$(inherited)",
                "DEFINES_MODULE" <<< YES,
                "SKIP_INSTALL" <<< YES,
                "MTL_ENABLE_DEBUG_INFO" <<< YES
            )

            fwk.buildSettings[.debug].override(

                "MTL_ENABLE_DEBUG_INFO" <<< "INCLUDE_SOURCE"
            )

            //---

            fwk.unitTests(targetName.tst.macOS) {

                fwkTests in

                //---

                fwkTests.include(sourcesPath.tst.common)
                fwkTests.include(sourcesPath.tst.macOS)


                //---

                fwkTests.buildSettings.base.override(

                    "SWIFT_VERSION" <<< "$(inherited)",

                    // very important for unit tests,
                    // prevents the error when unit test do not start at all
                    "LD_RUNPATH_SEARCH_PATHS" <<<
                    "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",

                    "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst.macOS,
                    "INFOPLIST_FILE" <<< infoPlistsPath.tst.macOS,
                    "FRAMEWORK_SEARCH_PATHS" <<< "$(inherited) $(BUILT_PRODUCTS_DIR)",

                    //--- platform specific:

                    "MACOSX_DEPLOYMENT_TARGET" <<< depTargets.macOS.minimumVersion
                )

                fwkTests.buildSettings[.debug].override(

                    "MTL_ENABLE_DEBUG_INFO" <<< YES
                )
            }
        }
    }
    .prepare(
        targetFolder: repoFolder
    )

//---

let cocoaPodsModuleName = company.prefix + product.name

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

let podspec = CocoaPods
    .Podspec
    .standard(
        product: product,
        company: company,
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
        name: cocoaPodsModuleName + ".podspec",
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
        cocoaPodsModuleName: cocoaPodsModuleName
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

try? info
    .tst
    .watchOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .tst
    .tvOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? info
    .tst
    .macOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .main
    .common
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .main
    .iOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .main
    .watchOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .main
    .tvOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .main
    .macOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .tst
    .common
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .tst
    .iOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .tst
    .watchOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .tst
    .tvOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? dummyFile
    .tst
    .macOS
    .writeToFileSystem(ifFileExists: .doNotWrite) // write ONCE!

try? project
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
