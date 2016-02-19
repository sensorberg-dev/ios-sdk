## Sensorberg

<!--[![CI Status](http://img.shields.io/travis/tagyro/Sensorberg.svg?style=flat)](https://travis-ci.org/tagyro/Sensorberg)
[![Version](https://img.shields.io/cocoapods/v/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![License](https://img.shields.io/cocoapods/l/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![Platform](https://img.shields.io/cocoapods/p/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)-->

## Installation

The easiest way to integrate the SensorbergSDK is via [CocoaPods](http://cocoapods.org).  
To install it, simply add the following lines to your Podfile:  

`pod "SensorbergSDK", :git => 'git@github.com:sensorberg-dev/ios-sdk.git', :branch => 'master'`  
`pod 'tolo', '~> 1.0'`   

### Usage and setup

Initialize the **`SBManager`** with an **API key** and a **delegate**  
1. `[[SBManager sharedManager] setApiKey:apiKey delegate:self];`  
When ready, tell the SBManager to ask for location authorization  
2. `[[SBManager sharedManager] requestLocationAuthorization];`   

* Be sure to add the `NSLocationAlwaysUsageDescription` key to your plist file and the corresponding string to explain the user why the app requires access to location.

The `SBManager` will automaticall start scanning for beacon regions you added on the [Sensorberg Management Platform](https://manage.sensorberg.com).  
You can also scan for custom beacon regions by calling `[[SBManager sharedManager] startMonitoring:]` and passing a list of custom UUID strings. 

### Notes

The SensorbergSDK uses an [EventBus](https://github.com/google/guava/wiki/EventBusExplained) for events dispatch. During setup, you pass the class instance that will receive the events as the delegate.  
If you want to receive events in other class insances also, simply call ```REGISTER();``` and subscribe to the events. 

## Dependencies
The Sensorberg SDK requires iOS 8.0
Sensorberg SDK uses:  
- [AFNetworking](https://github.com/AFNetworking/AFNetworking) for network communication   
- [JSONModel](https://github.com/icanzilb/JSONModel) for JSON parsing  
- [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore) for keychain access  
- [tolo](https://github.com/genzeb/tolo) for event communication  


## Author

[Sensorberg GmbH](https://sensorberg.com)


## License

Sensorberg SDK is available under the MIT license. See the LICENSE file for more info.
