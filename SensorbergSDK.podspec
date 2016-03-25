Pod::Spec.new do |s|
  s.name = 'SensorbergSDK'
  s.version = '2.1.0'
  s.summary = 'iOS SDK for handling iBeacon technology via the Sensorberg Beacon Management Platform'
  s.license = 'MIT'
  s.authors = {"Sensorberg GmbH"=>"info@sensorberg.com"}
  s.homepage = 'https://www.sensorberg.com'
  s.description = 'iOS SDK for handling iBeacon technology via the [Sensorberg Beacon Management Platform](https://www.sensorberg.com).'
  s.social_media_url = 'https://twitter.com/sensorberg'
  s.frameworks = ["UIKit", "CoreBluetooth", "Security", "CoreTelephony", "CoreLocation", "SystemConfiguration", "MobileCoreServices"]
  s.requires_arc = true
  s.source = {}

  s.platform = :ios, '8.0'
  s.ios.platform             = :ios, '8.0'
  s.ios.preserve_paths       = 'ios/SensorbergSDK.framework'
  s.ios.public_header_files  = 'ios/SensorbergSDK.framework/Versions/A/Headers/*.h'
  s.ios.resource             = 'ios/SensorbergSDK.framework/Versions/A/Resources/**/*'
  s.ios.vendored_frameworks  = 'ios/SensorbergSDK.framework'
end
