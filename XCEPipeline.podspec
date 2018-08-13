Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift.'
    s.version       = '1.0.1'
    s.homepage      = 'https://XCEssentials.github.io/Pipeline'

    s.source        = { :git => 'https://github.com/XCEssentials/Pipeline.git', :tag => s.version }

    s.requires_arc  = true

    s.license       = { :type => 'MIT', :file => 'LICENSE' }

    s.authors = {
        'Maxim Khatskevich' => 'maxim@khatskevi.ch'
    }

    s.swift_version = '4.2'

    s.cocoapods_version = '>= 0.36'

    # === iOS

    s.ios.deployment_target = '9.0'

    s.ios.source_files = 'Sources/Pipeline/**/*.swift'

end