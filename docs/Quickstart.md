#Sensorberg SDK

##Quickstart

###1. Create an account

The first thing you need to do to get started with Firebase is [sign up for a free account](https://manage.sensorberg.com/#/signup).[^1]  

[^1]: Read more about our Beacon Management Platform @ [link here](https://link)

###2. CocoaPods setup

The easiest way to integrate the iOS SDK is via [CocoaPods](https://cocoapods.org/) [^2]. If you're new to CocoaPods, visit their [getting started documentation](https://guides.cocoapods.org/using/getting-started.html). 

````
cd your-project-directory    
pod init
````

Once you've initialized CocoaPods, just add the [Sensorberg Pod](https://cocoapods.org/pods/SensorbergSDK) to your Podfile:

````
pod 'SensorbergSDK', '~> 2.0'
pod 'tolo', '~> 1.0'
````
[^2]: For instructions on including the Sensorberg framework and its dependencies manually see the guide on [alternative setup](http://link)

###3. Gettings started in Xcode

Objective-C

Include the Sensorberg SDK header in your app to get all the needed classes:
`#import <SensorbergSDK/SensorbergSDK.h>`

Swift

You can use the Sensorberg SDK in your Swift class by simply importing the module:

`import SensorbergSDK`


###4. Setup the Sensorberg SDK

Before using the SDK you need to do some basic configuration.  
You can find your API key on the [Beacon Managerment Platform](https://manage.sensorberg.com) in the Apps section.

The SensorbergSDK uses an the [Observer pattern](http://codentrick.com/observer-pattern-in-mobile-eventbus-and-notificationcenter/) for events dispatching.  
During setup, you pass the class instance that will receive the events as the delegate.  
If you want to receive events in other class insances also, simply call `REGISTER()` and subscribe to the relative events.  

`[[SBManager sharedManager] setApiKey:<api> delegate:self];`


###5. Using the Sensorberg SDK

- `#import <SensorbergSDK/SensorbergSDK.h>` (or, with modules, `@import SensorbergSDK`)  
- `#import <tolo/Tolo.h>` to use `tolo` (the event publish/subscribe framework) (or, with modules, `@import tolo`)  
- `REGISTER()` to receive events in your class instance  
- `SUBSCRIBE(<SBEventName>)` to receive that event (e.g. `SBEventRegionEnter`, `SBEventRegionExit`, `SBEventPerformAction` etc.)  