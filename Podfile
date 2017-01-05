# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'SensorbergSDK' do
    pod  'JSONModel', '~> 1.1'
    pod  'tolo'
    pod  'UICKeyChainStore', '~> 2.0'
    pod  'GeoHashObjC', :git => "https://github.com/dominikweifieg/GeoHashObjC.git"
end

target 'SBDemoApp' do
    pod 'SensorbergSDK', :path => './'
end

target 'SBDemoAppSwift' do
    pod 'SensorbergSDK', :path => './'
end

target 'SensorbergSDKTests' do
    pod 'SensorbergSDK', :path => './'
end


