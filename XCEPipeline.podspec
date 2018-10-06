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

    # === All platforms

    s.source_files = 'Sources/Pipeline/**/*.swift'

    # === iOS

    s.ios.deployment_target = '9.0'

    # === watchOS

    s.watchos.deployment_target = '3.0'

    # === tvOS

    s.tvos.deployment_target = '9.0'

    # === macOS

    s.osx.deployment_target = '10.11'

end # spec s
