#
# Be sure to run `pod lib lint Sensorberg.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Sensorberg"
  s.version          = "2.0"
  s.summary          = "iOS SDK for handling iBeacon technology via the Sensorberg Beacon Management Platform."
  s.homepage         = "https://sensorberg.com"
  s.license          = 'MIT'
  s.author           = { "sensorberg" => "info@sensorberg.com" }
  s.source           = { :git => "https://github.com/sensorberg-dev/ios-sdk", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files     = 'Pod/Classes/**/*.h'
  s.resource_bundles = {
    'Sensorberg' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit', 'CoreBluetooth', 'Security', 'CoreTelephony', 'CoreLocation'
  s.dependency 'JSONModel', '~> 1.1'
  s.dependency 'tolo','~> 1.0'
  s.dependency 'AFNetworking', '~> 2.0'

end
