## Sensorberg

<!--[![CI Status](http://img.shields.io/travis/tagyro/Sensorberg.svg?style=flat)](https://travis-ci.org/tagyro/Sensorberg)
[![Version](https://img.shields.io/cocoapods/v/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![License](https://img.shields.io/cocoapods/l/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)
[![Platform](https://img.shields.io/cocoapods/p/Sensorberg.svg?style=flat)](http://cocoapods.org/pods/Sensorberg)-->

This is the v2 of the Sensorberg SDK as a package.
Please check the [master branch](https://github.com/sensorberg-dev/ios-sdk) for instalation information.

**Only use this package if you have dependencies collisions.**

To install this version, add the following lines in your Podfile:  

````  
  pod "SensorbergSDK", :git => 'git@github.com:sensorberg-dev/ios-sdk.git', :tag => '2.1.1m'  
  pod 'tolo', '~> 1.0'  
````  

In any class where you use the `Sensorberg SDK` you will also need to import the `tolo` header:  

`#import <tolo/Tolo.h>`  
(or `import tolo`)

## Author

[Sensorberg](https://sensorberg.com)


## License

Sensorberg SDK is available under the MIT license. See the LICENSE file for more info.
