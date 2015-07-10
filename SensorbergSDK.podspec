Pod::Spec.new do |s|
  s.name                    = "SensorbergSDK"
  s.version                 = "1.0.1"
  s.platform                = :ios, "7.0"
  s.summary                 = "iOS SDK for handling iBeacon technology via the Sensorberg Beacon Management Platform."
  s.homepage                = "https://github.com/sensorberg-dev/ios-sdk"
  s.documentation_url       = "http://sensorberg-dev.github.io/ios-sdk/#{s.version}/"
  s.social_media_url        = "https://twitter.com/sensorberg"
  s.authors                 = { "Max Horvath" => "max@sensorberg.com" }
  s.license                 = { :type => "Copyright",
                                :text => "Copyright 2013-2014 Sensorberg GmbH. All rights reserved." }
  s.source                  = { :git => "https://github.com/sensorberg-dev/ios-sdk.git",
                                :tag => s.version.to_s }

  s.ios.vendored_frameworks = "SensorbergSDK.framework"

  s.frameworks              = "CoreBluetooth", "CoreGraphics", "CoreLocation", "Foundation", "MobileCoreServices", "Security", "SystemConfiguration"

  s.requires_arc            = true

  s.xcconfig                = { "OTHER_LDFLAGS" => "$(inherited) -ObjC -read_only_relocs suppress",
                                "GCC_PREPROCESSOR_DEFINITIONS" => %{$(inherited) SENSORBERGSDK_VERSION="@\\"#{s.version}\\""},
                                "CLANG_ENABLE_MODULES" => "YES",
                                "CLANG_MODULES_AUTOLINK" => "YES" }
end
