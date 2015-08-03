#
# Be sure to run `pod lib lint SensorbergSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = "SensorbergSDK"
  s.version                 = "0.1.0"
  s.summary                 = "iOS SDK for handling iBeacon technology via the Sensorberg Beacon Management Platform."
  s.homepage                = "https://github.com/sensorberg-dev/ios-sdk"
  s.documentation_url       = "http://sensorberg-dev.github.io/ios-sdk/#{s.version}/"
  s.social_media_url        = "https://twitter.com/sensorberg"
  s.authors                 = { "Devs at sensorberg" => "info@sensorberg.com" }

  s.license                 = 'MIT'

  s.license                 = { :type => "Copyright", :text => "Copyright 2013-2014 Sensorberg GmbH. All rights reserved." }
  s.source                  = { :git => "https://github.com/sensorberg-dev/ios-sdk.git", :tag => s.version.to_s }

  s.platform                = :ios, '7.0'
  s.requires_arc            = true
  s.frameworks              = "CoreBluetooth", "CoreGraphics", "CoreLocation", "Foundation", "MobileCoreServices", "Security", "SystemConfiguration"


  s.source_files            = 'Classes/**/*'

  s.dependency 'AFNetworking/NSURLSession', '~> 2.5.3'
  s.dependency 'MSWeakTimer', '~> 1.1.0'
  s.dependency 'GBDeviceInfo', '~> 2.2.10'
  s.dependency 'GBStorage', '~> 2.2'
  s.dependency 'tolo', '~> 1.0'
end
