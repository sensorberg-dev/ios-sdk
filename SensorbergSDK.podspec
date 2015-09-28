Pod::Spec.new do |s|
  s.name                    = "SensorbergSDK"
  s.version                 = "1.0.6"
  s.platform                = :ios, "7.0"
  s.summary                 = "iOS SDK for handling iBeacon technology via the Sensorberg Beacon Management Platform."
  s.homepage                = "https://github.com/sensorberg-dev/ios-sdk"
  s.documentation_url       = "https://developer.sensorberg.com/ios"
  s.social_media_url        = "https://twitter.com/sensorberg"
  s.authors                 = { "Sensorberg" => "info@sensorberg.com" }
  s.license                 = { :type => "Copyright",
                                :text => "Copyright 2013-2015 Sensorberg GmbH. All rights reserved." }

  s.source                  = { :git => "https://github.com/sensorberg-dev/ios-sdk.git",
                                :tag => s.version.to_s }

  s.public_header_files     = 'SensorbergSDK/*.h'
  s.source_files            = 'SensorbergSDK/SensorbergSDK.h'

  s.source_files            = 'SensorbergSDK/**/*.{h,m}'

  s.dependency                'AFNetworking/NSURLSession', '~> 2.5.4'
  s.dependency                'MSWeakTimer', '~> 1.1.0'

  s.frameworks              = "CoreBluetooth", "CoreGraphics", "CoreLocation", "Foundation", "MobileCoreServices", "Security", "SystemConfiguration"

  s.requires_arc            = true

  s.xcconfig                = { "OTHER_LDFLAGS" => "$(inherited) -ObjC -read_only_relocs suppress",
                                "GCC_PREPROCESSOR_DEFINITIONS" => %{$(inherited) SENSORBERGSDK_VERSION="@\\"#{s.version}\\""},
                                "CLANG_ENABLE_MODULES" => "YES",
                                "CLANG_MODULES_AUTOLINK" => "YES",
                                "ENABLE_BITCODE" => "NO"
                                }
end
