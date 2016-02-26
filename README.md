# Sensorberg iOS SDK

> iOS SDK for handling iBeacon technology via the Sensorberg Beacon Management Platform. [http://www.sensorberg.com](http://www.sensorberg.com)

<!--[![CI Status](http://img.shields.io/travis/tagyro/Sensorberg.svg?style=flat)](https://travis-ci.org/tagyro/Sensorberg)
[![Version](https://img.shields.io/cocoapods/v/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![License](https://img.shields.io/cocoapods/l/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![Platform](https://img.shields.io/cocoapods/p/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)-->

## Try the Sensorberg SDK

Runing `pod try SensorbergSDK` in a terminal window will open the Sensorberg demo project.  
Select the `SBDemoApp` target and run on device.  


## Install

The easiest way to integrate the Sensorberg SDK is via [CocoaPods](http://cocoapods.org).  
To install it, simply add the following lines to your Podfile:  
`pod 'SensorbergSDK', '~> 2.0'`  

You can find a [full integration tutorial](http://sensorberg-dev.github.io/ios/) on our [developer portal](http://sensorberg-dev.github.io/).

## Notes

The Sensorberg SDK uses an [EventBus](https://github.com/google/guava/wiki/EventBusExplained) for events dispatch. During setup, you pass the class instance that will receive the events as the delegate.

If you want to receive events in other class instances, simply call `REGISTER();` and subscribe to the events.

## Dependencies

The Sensorberg SDK requires iOS 8.0. Sensorberg SDK uses:

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) for network communication   
- [JSONModel](https://github.com/icanzilb/JSONModel) for JSON parsing  
- [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore) for keychain access  
- [tolo](https://github.com/genzeb/tolo) for event communication  


## Documentation

To install the Sensorberg SDK, clone the repo and run the included script:  

```
$ cd your-project-directory  
$ chmod +x createDocs.sh  
$ ./createDocs.sh  
```
This will automatically create and install the docset in Xcode.

## Author

[Sensorberg GmbH](https://sensorberg.com)


## License

Sensorberg SDK is available under the MIT license. See the LICENSE file for more info.
