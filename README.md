## Sensorberg

<!--[![CI Status](http://img.shields.io/travis/tagyro/Sensorberg.svg?style=flat)](https://travis-ci.org/tagyro/Sensorberg)
[![Version](https://img.shields.io/cocoapods/v/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![License](https://img.shields.io/cocoapods/l/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![Platform](https://img.shields.io/cocoapods/p/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)-->

### Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use the SDK:

```
// Initialise the SBManager with a resolver url and API key
[[SBManager sharedManager] setupResolver:resolverURL apiKey:apiKey]  
// When ready, tell the SBManager to ask for location authorization 
[[SBManager sharedManager] requestLocationAuthorization];  
// Once the SBManager has access to location, request the layout from the resolver
[[SBManager sharedManager] requestLayout];  
```

## Requirements



## Installation

Sensorberg is available through [CocoaPods](http://cocoapods.org).  
To install it, simply add the following line to your Podfile:

```  
pod "Sensorberg", :git => 'git@github.com:sensorberg-dev/ios-sdk.git', :branch => 'v2'  
```

## Author

[Sensorberg](https://sensorberg.com)


## License

Sensorberg SDK is available under the MIT license. See the LICENSE file for more info.
