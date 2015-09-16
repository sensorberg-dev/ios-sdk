//
//  SBManager.h
//  SensorbergSDK
//
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#import <tolo/Tolo.h>

#import "SBResolverModels.h"

#import "SBProtocolModels.h"

#import "SBProtocolEvents.h"

/**
 SBManagerAvailabilityStatus
 Represents the app’s overall iBeacon readiness, like Bluetooth being turned on,
 Background App Refresh enabled and authorization to use location services.
 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBManagerAvailabilityStatus) {
    /**
     Background App Refresh is enabled, the app is authorized to use location services and
     Bluetooth is turned on.
     */
    SBManagerAvailabilityStatusFullyFunctional,
    
    /**
     Bluetooth is turned off. The specific status can be found in bluetoothStatus.
     */
    SBManagerAvailabilityStatusBluetoothRestricted,
    
    /**
     This application is not enabled to use Background App Refresh. The specific status can be
     found in backgroundAppRefreshStatus.
     */
    SBManagerAvailabilityStatusBackgroundAppRefreshRestricted,
    
    /**
     This application is not authorized to use location services. The specific status can be
     found in authorizationStatus.
     */
    SBManagerAvailabilityStatusAuthorizationRestricted,
    
    /**
     This application is not connected to the Sensorberg Beacon Management Platform. The
     specific status can be found in connectionState.
     */
    SBManagerAvailabilityStatusConnectionRestricted,
    
    /**
     This application cannot reach the Sensorberg Beacon Management Platform. The specific
     status can be found in reachabilityState.
     */
    SBManagerAvailabilityStatusReachabilityRestricted,
    
    /**
     This application runs on a device that does not support iBeacon.
     @since 0.7.9
     */
    SBManagerAvailabilityStatusIBeaconUnavailable
};

/**
 *  SBManager
 *
 *  The default class of the SDK
 *  Instantiate with :sharedManager
 *  and setup with :setupResolver:apiKey
 */
@interface SBManager : NSObject {
    SBMGetLayout *layout;
}

/**
 *  kSBResolver
 *
 *  The url of the ```Resolver``` - default https://resolver.sensorberg.com
 *  call :setupResolver:apiKey: to setup this value
 *
 *  @since 2.0
 */
extern NSString *kSBResolver;

/**
 *  kSBAPIKey
 *
 *  The API Key used to connect to the ```Resolver```
 *
 *  @discussion You can generate an API Key via the 
 *  [Sensorberg Management Platform](https://manage.sensorberg.com)
 *  call :setupResolver:apiKey: to setup this value
 *
 *  @since 2.0
 */
extern NSString *kSBAPIKey;

/**
 *  sharedManager
 *
 *  Singleton instance of the Sensorberg manager
 *  Call setupResolver:apiKey: to setup the back-end and api key
 *
 *  @return SBManager singleton instance
 * 
 *  @since 2.0
 */
+ (instancetype)sharedManager;

/**
 *  Do not use **init** or **new** to instantiate the SBManager
 *  instead use [SBManager sharedManager] to get the singleton instance
 *  and make a call to :setupResolver:apiKey
 *
 *  @since 2.0
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  availabilityStatus
 *
 *  Indicates the general availability.
 *
 *  see SBManagerAvailabilityStatus
 *
 *  @since 0.7.0
 */

- (SBManagerAvailabilityStatus)availabilityStatus;

/**
 *  setupResolver: apiKey:
 *
 *  Setup initial values for the Sensorberg manager. 
 *
 *  @param resolver URL of the ```Resolver``` (default is *https://resolver.sensorberg.com*)
 *  @param apiKey   API Key - Register on [Sensorberg Management Platform](https://manage.sensorberg.com) to generate one
 *
 *  @since 2.0
 */
- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey;

/**
 *  requestLocationAuthorization
 *
 *  Ask the user access to Location services
 *
 *  Ideally, you would show a message to the user
 *  explaining why access to Location services is required.
 *  <br>**Warning** Be sure to include the ```NSLocationAlwaysUsageDescription``` key-value in the *Info.plist*
 *
 *  @since 2.0
 */
- (void)requestLocationAuthorization;

/**
 *  requestBluetoothAuthorization
 *
 *  Request authorization to use Bluetooth services
 *  <br>**Warning** Required if you're using the advanced functionalities of the SDK
 *
 *  @since 2.0
 */
- (void)requestBluetoothAuthorization;


/**
 *  requestNotificationAuthorization
 *
 *  Register to receive local/remote notifications
 *
 *  @since 2.0
 */
- (void)requestNotificationAuthorization;

/**
 *  This will return a cached version if available,
 *  otherwise a network call will be made to the ```Resolver```
 *
 *  Load the layout configuration
 *
 */
- (void)requestLayout;

/**
 *  This does not make a network request - if there is not a local copy of the layout
 *  **nil** will be returned
 *
 *  @return The local (cached) version of the layout
 *
 *
 *  @since 2.0
 */
- (SBMGetLayout*)currentLayout;

/**
 *
 *  startMonitoring
 *
 *  Start monitoring for the beacon UUID's in the :currentLayout
 *  <br>**Warning** You need to :requestLayout first!
 *
 *  @since 2.0
 */
- (void)startMonitoring;

/**
 *  startBackgroundMonitoring
 */
- (void)startBackgroundMonitoring;

@end

