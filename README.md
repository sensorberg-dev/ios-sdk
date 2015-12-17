## Sensorberg

<!--[![CI Status](http://img.shields.io/travis/tagyro/Sensorberg.svg?style=flat)](https://travis-ci.org/tagyro/Sensorberg)
[![Version](https://img.shields.io/cocoapods/v/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![License](https://img.shields.io/cocoapods/l/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![Platform](https://img.shields.io/cocoapods/p/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)-->

## Installation

Sensorberg is available through [CocoaPods](http://cocoapods.org).  
To install it, simply add the following line to your Podfile:

`pod "Sensorberg", :git => 'git@github.com:sensorberg-dev/ios-sdk.git', :branch => 'v2m'`  

### Usage and setup

Initialize the **`SBManager`** with the **Resolver url**, an **API key** and a **delegate**  
1. `[[SBManager sharedManager] setupResolver:resolverURL apiKey:apiKey delegate:self];`  
When ready, tell the SBManager to ask for location authorization  
2. `[[SBManager sharedManager] requestLocationAuthorization];`   

* Be sure to add the `NSLocationAlwaysUsageDescription` key to your plist file and the corresponding string to explain the user why the app requires access to location.

### Notes

If you want to use the default **Resolver**, you can pass in ```nil``` during setup and the SDK will use the default url.  
The SensorbergSDK uses an [EventBus](https://github.com/google/guava/wiki/EventBusExplained) for events dispatch. During setup, you pass the class instance that will receive the events as the delegate.  
If you want to receive events in other class insances also, simply call ```REGISTER();``` and subscribe to the events. 

## Dependencies

Sensorberg SDK uses:  
- [AFNetworking](https://github.com/AFNetworking/AFNetworking) for network communication   
- [JSONModel](https://github.com/icanzilb/JSONModel) for JSON parsing  
- [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore) for keychain access  
- [tolo](https://github.com/genzeb/tolo) for event communication  


## Author

[Sensorberg](https://sensorberg.com)


## License

Sensorberg SDK is available under the MIT license. See the LICENSE file for more info.