Pod::Spec.new do |s|
    s.name         = "CoreMind"
    s.version      = "1.2.1"
    s.summary      = "topmindKit framework"
    s.homepage     = "https://www.topmind.eu"
    s.license      = "All rights reserved topmind GmbH"
    s.authors      = ["Martin Gratzer"]
  
    s.ios.deployment_target = "10.0"
    s.osx.deployment_target = "10.12"
    s.watchos.deployment_target = "4.0"
    s.tvos.deployment_target = "10.0"
  
    s.swift_version = "5.0"
    s.source = {
        :git => "https://github.com/topminds/topmindKit.git",
        :tag => "#{s.version}"
    }
    s.source_files  = [ "Sources/#{s.name}/**/*.{h,m,swift}" ]
    s.frameworks    = [ 'Foundation' ]  
end
  