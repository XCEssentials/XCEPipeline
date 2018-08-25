Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift.'
    s.version       = '0.1.0+dirty'
    s.homepage      = 'https://XCEssentials.github.io/Pipeline'

    s.source        = { :git => 'https://github.com/XCEssentials/Pipeline.git', :tag => s.version }

    s.requires_arc  = true

    s.license       = { :type => 'MIT', :file => 'LICENSE' }

    s.authors = {
        'Maxim Khatskevich' => 'maxim@khatskevi.ch'
    } # authors

    s.swift_version = '4.2'

    s.cocoapods_version = '>= 1.5.3'

    # === All platforms

    s.source_files = 'Sources/Pipeline/Common/**/*.swift'

    # === iOS

    s.ios.deployment_target = '9.0'

    s.ios.source_files = 'Sources/Pipeline/iOS/**/*.swift'

    # === watchOS

    s.watchos.deployment_target = '3.0'

    s.watchos.source_files = 'Sources/Pipeline/watchOS/**/*.swift'

    # === tvOS

    s.tvos.deployment_target = '9.0'

    s.tvos.source_files = 'Sources/Pipeline/tvOS/**/*.swift'

    # === macOS

    s.osx.deployment_target = '10.11'

    s.osx.source_files = 'Sources/Pipeline/macOS/**/*.swift'

end # spec