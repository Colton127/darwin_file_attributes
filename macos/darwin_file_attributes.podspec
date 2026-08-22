#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint darwin_file_attributes.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'darwin_file_attributes'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'darwin_file_attributes/Sources/darwin_file_attributes/**/*.swift'

  # The privacy manifest is shared with the Swift Package Manager build, which
  # picks it up from the package's Resources directory. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'darwin_file_attributes_privacy' => ['darwin_file_attributes/Sources/darwin_file_attributes/Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
