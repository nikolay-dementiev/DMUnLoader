
Pod::Spec.new do |s|
  s.name             = 'DMUnLoader'
  s.version          = '1.0.3'
  s.summary          = 'A HUD for the loading, success and failure states of an iOS app, for SwiftUI and UIKit.'
  s.description      = <<-DESC
    DMUnLoader shows one HUD at a time over a scene of an app: a spinner while work runs, then
    a success, or a failure with Close and an optional Retry. A loading manager holds the state.
    The HUD is drawn in a window of its own and takes the touches of the scene while it is
    shown. Its views are the library's, with the app's settings, or the app's own.
                       DESC

  s.homepage         = 'https://github.com/nikolay-dementiev/DMUnLoader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mykola Dementiev' => 'nikolas.dementiev@gmail.com' }
  s.ios.deployment_target = "17.0"
  
  s.source           = { :git => 'https://github.com/nikolay-dementiev/DMUnLoader.git', :tag => s.version.to_s }
  s.source_files = 'Sources/DMUnLoader/**/*.swift'
  s.resource_bundles = { 'DMUnLoader' => ['Sources/DMUnLoader/Resources/Localizable.xcstrings'] }
  s.requires_arc = true
  # The package access level needs a package name. The setting belongs to the pod's own
  # target and never reaches the app that installs the pod.
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -package-name DMUnLoader' }
  
  s.cocoapods_version = '>= 1.4.0'
  if s.respond_to?(:swift_versions) then
    s.swift_versions = ['5.0', '6.0']
  else
    s.swift_version = '5.0'
  end
  s.frameworks = 'UIKit', 'SwiftUI'
  s.dependency 'DMAction', '~> 1.1'
  s.dependency 'DMVariableBlurView', '~> 1.1'
end
