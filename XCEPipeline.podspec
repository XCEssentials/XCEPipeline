Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift.'
    s.version       = '1.0.5'
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

    s.test_spec 'Tests' do |ss|

        # === All platforms

        ss.requires_app_host = false
        ss.source_files = 'Tests/**/*.swift'
        ss.dependency 'SwiftLint'
        ss.script_phase = {
            :name => 'SwiftLint',
            :script => '"${PODS_ROOT}/SwiftLint/swiftlint" --path ./../../',
            :execution_position => :before_compile
        }

        # === osx

        ss.osx.pod_target_xcconfig = {
            'EXPANDED_CODE_SIGN_IDENTITY' => '-',
            'EXPANDED_CODE_SIGN_IDENTITY_NAME' => '-'
        }

    end # test_spec 'Tests'

end # spec s
