Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift.'
    s.version       = '1.1.1'
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

    # === tvos

    s.tvos.deployment_target = '9.0'

    # === osx

    s.osx.deployment_target = '10.11'

    # === SUBSPECS ===

    s.subspec 'Core' do |ss|

        ss.source_files = 'Sources/Core/**/*.swift'

    end # subspec 'Core'

    s.subspec 'Operators' do |ss|

        ss.dependency 'XCEPipeline/Core'
        ss.source_files = 'Sources/Operators/**/*.swift'

    end # subspec 'Operators'

    s.test_spec 'Tests' do |ss|

        ss.requires_app_host = false
        ss.source_files = 'Tests/**/*.swift'
        ss.framework = 'XCTest'
        ss.dependency 'SwiftLint'

        ss.pod_target_xcconfig = {
            'EXPANDED_CODE_SIGN_IDENTITY' => '-',
            'EXPANDED_CODE_SIGN_IDENTITY_NAME' => '-'
        }

    end # test_spec 'Tests'

end # spec s
