Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift.'
    s.version       = '1.0.8'
    s.homepage      = 'https://XCEssentials.github.io/Pipeline'

    s.source        = { :git => 'https://github.com/XCEssentials/Pipeline.git', :tag => s.version }

    s.requires_arc  = true

    s.license       = { :type => 'MIT', :file => 'LICENSE' }

    s.authors = {
        'Maxim Khatskevich' => 'maxim@khatskevi.ch'
    } # authors

    s.swift_version = '4.2'

    s.cocoapods_version = '>= 1.5.3'

    # === ios

    s.ios.deployment_target = '9.0'

    # === watchos

    s.watchos.deployment_target = '3.0'

    # === tvos

    s.tvos.deployment_target = '9.0'

    # === osx

    s.osx.deployment_target = '10.11'

    # === SUBSPECS ===

    s.subspec 'Core' do |ss|

        # === All platforms

        ss.source_files = 'Sources/**/*.swift'

    end # subspec 'Core'

    s.test_spec 'Tests-iOS' do |ss|

        # === All platforms

        ss.platform = :ios
        ss.requires_app_host = false
        ss.source_files = 'Tests/**/*.swift'
        ss.framework = 'XCTest'
        ss.dependency 'SwiftLint'
        ss.script_phase = {
            :name => 'SwiftLint',
            :script => '"${PODS_ROOT}/SwiftLint/swiftlint" --path ./../../',
            :execution_position => :before_compile
        }
        ss.pod_target_xcconfig = {
            'EXPANDED_CODE_SIGN_IDENTITY' => '-',
            'EXPANDED_CODE_SIGN_IDENTITY_NAME' => '-'
        }

    end # test_spec 'Tests-iOS'

    s.test_spec 'Tests-tvOS' do |ss|

        # === All platforms

        ss.platform = :tvos
        ss.requires_app_host = false
        ss.source_files = 'Tests/**/*.swift'
        ss.framework = 'XCTest'
        ss.dependency 'SwiftLint'
        ss.script_phase = {
            :name => 'SwiftLint',
            :script => '"${PODS_ROOT}/SwiftLint/swiftlint" --path ./../../',
            :execution_position => :before_compile
        }
        ss.pod_target_xcconfig = {
            'EXPANDED_CODE_SIGN_IDENTITY' => '-',
            'EXPANDED_CODE_SIGN_IDENTITY_NAME' => '-'
        }

    end # test_spec 'Tests-tvOS'

    s.test_spec 'Tests-macOS' do |ss|

        # === All platforms

        ss.platform = :osx
        ss.requires_app_host = false
        ss.source_files = 'Tests/**/*.swift'
        ss.framework = 'XCTest'
        ss.dependency 'SwiftLint'
        ss.script_phase = {
            :name => 'SwiftLint',
            :script => '"${PODS_ROOT}/SwiftLint/swiftlint" --path ./../../',
            :execution_position => :before_compile
        }
        ss.pod_target_xcconfig = {
            'EXPANDED_CODE_SIGN_IDENTITY' => '-',
            'EXPANDED_CODE_SIGN_IDENTITY_NAME' => '-'
        }

    end # test_spec 'Tests-macOS'

end # spec s
