Pod::Spec.new do |s|

    s.name          = 'XCEPipeline'
    s.summary       = 'Custom pipeline operators for easy chaining in Swift.'
    s.version       = '0.1.0'
    s.homepage      = 'https://XCEssentials.github.io/Pipeline'

    s.source        = { :git => 'https://github.com/XCEssentials/Pipeline.git', :tag => s.version }

    s.requires_arc  = true

    s.license       = { :type => 'MIT', :file => 'LICENSE' }
    s.author        = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }

    s.swift_version = '4.2'

    s.ios.deployment_target = '9.0'

    s.source_files = 'Sources/**/*.swift'

end