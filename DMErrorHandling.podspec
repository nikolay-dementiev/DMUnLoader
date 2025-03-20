
Pod::Spec.new do |s|
  s.name             = 'DMErrorHandling'
  s.version          = '0.1.27'
  s.summary          = 'Error handling SDK'
  s.description      = <<-DESC
  
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/nikolay-dementiev/DMErrorHandling'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nikolay Dementiev' => 'nikolas.dementiev@gmail.com' }
  s.ios.deployment_target = "17.0"
  #s.osx.deployment_target = "10.13"
  #s.tvos.deployment_target = "12.0"
  s.watchos.deployment_target = "7.0"
  #s.visionos.deployment_target = "1.0"
  
  s.source           = { :git => 'https://github.com/nikolay-dementiev/DMErrorHandling.git', :tag => "v#{s.version}" }
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
  #s.dependency 'DMAction'
  
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.resource_bundles = {
  #   'DMErrorHandling' => ['DMErrorHandling/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Sources/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
