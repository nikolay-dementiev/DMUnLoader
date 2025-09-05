
Pod::Spec.new do |s|
  s.name             = 'DMUnLoader'
  s.version          = '0.1.29'
  s.summary          = 'Universal Loader & Result handling SDK'
  s.description      = <<-DESC
  
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/nikolay-dementiev/DMUnLoader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nikolay Dementiev' => 'nikolas.dementiev@gmail.com' }
  s.ios.deployment_target = "17.0"
  #s.osx.deployment_target = "10.13"
  #s.tvos.deployment_target = "12.0"
  s.watchos.deployment_target = "7.0"
  #s.visionos.deployment_target = "1.0"
  
  s.source           = { :git => 'https://github.com/nikolay-dementiev/DMUnLoader.git', :tag => "v#{s.version}" }
  s.source_files = 'Sources/**/*.{swift,h,m,c}'
  s.exclude_files = 'Examples/**', 'Sources/Deprecated/'
  s.weak_framework = "XCTest"
  s.requires_arc = true
  
  s.cocoapods_version = '>= 1.4.0'
  if s.respond_to?(:swift_versions) then
    s.swift_versions = ['5.0']
  else
    s.swift_version = '5.0'
  end
  s.frameworks = 'UIKit', 'SwiftUI'
  s.dependency 'DMAction'
end
