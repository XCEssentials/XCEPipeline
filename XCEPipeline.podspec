Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift'
    s.version       = '1.2.2'
    s.homepage      = 'https://XCEssentials.github.io/Pipeline'

    s.source        = { :git => 'https://github.com/XCEssentials/Pipeline.git', :tag => s.version }

    s.requires_arc  = true

    s.license       = { :type => 'MIT', :file => 'LICENSE' }

    s.authors = {
        'Maxim Khatskevich' => 'maxim@khatskevi.ch'
    } # authors

    s.swift_version = '4.2'

    s.cocoapods_version = '>= 1.7.0'

    # === ios

    s.ios.deployment_target = '9.0'

    # === tvos

    s.tvos.deployment_target = '9.0'

    # === osx

    s.osx.deployment_target = '10.11'

    # === SUBSPECS ===

    s.subspec 'Core' do |ss|

        ss.source_files = 'Sources/Core/**/*'

    end # subspec 'Core'

    s.subspec 'Operators' do |ss|

        ss.dependency 'XCEPipeline/Core'
        ss.source_files = 'Sources/Operators/**/*'

    end # subspec 'Operators'

    s.test_spec 'AllTests' do |ss|

        ss.requires_app_host = false
        ss.dependency 'SwiftLint'
        ss.source_files = 'Tests/AllTests/**/*'

    end # test_spec 'AllTests'

end # spec s
