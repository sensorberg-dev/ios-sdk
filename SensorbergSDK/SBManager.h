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

#import "SBEnums.h"
#import "SBEvent.h"
#import "SBModel.h"

/**
 *  **SBManager**
 *
 *  The `SBManager` provides a centralized way of easily using the Sensorberg SDK.
 *  Every app must have exactly one instance, created by the :sharedManager, usually on app launch.
 */
@interface SBManager : NSObject

/**
 *  @brief  sharedManager
 *
 *  @return The SBManager singleton instance
 *
 *  @since 2.0
 */
+ (instancetype)sharedManager;

- (instancetype)init __attribute__((unavailable("use [SBManager sharedManager]")));

- (instancetype)new __attribute__((unavailable("use [SBManager sharedManager]")));
/**
 *  @brief  availabilityStatus
 *
 *  @return General availability of the system
 *
 *  @since 2.0
 */
- (SBManagerAvailabilityStatus)availabilityStatus;

/**
 *  @brief  Setup method for the SBManager
 *
 *  @param resolver The URL string for the resolver - can be **nil** if using the default resolver
 *  @param apiKey   The API key string - register on the [management platform](https://manage.sensorberg.com/) to obtain an API key
 *  @param delegate The class instance that will receive the SBManager events
 *
 *  @since 2.0
 */
- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate __attribute__((nonnull (3)));

/**
 *  @brief  Force a reset of the SBManager (clears cache, Resolver URL, API Key). To use the SBManager again, call [SBManager sharedManager] and setup the environment with :setupResolver:apiKey:delegate
 *
 *  @since 2.0
 */
- (void)resetSharedClient;

/**
 *  @brief  resolverLatency
 *
 *  @return Latency in seconds of the resolver; a negative value means no connection to the resolver
 *
 *  @since 2.0
 */
- (double)resolverLatency;

/**
 *  requestResolverStatus
 *
 *  Ping the resolver to check latency (and connectivity); Subscribe to SBEventPing or call resolverLatency: to check status
 */
- (void)requestResolverStatus;

/**
 *  @brief  Request user access to location information
 *  
 *  Ideally, you would show a message to the user
 *  explaining why access to Location services is required.
 *  <br>**Warning** Be sure to include the `NSLocationAlwaysUsageDescription` key in the *Info.plist* with a descriptive string
 *
 *  @since 2.0
 */
- (void)requestLocationAuthorization;

/**
 *  locationAuthorization
 *
 *  @return SBLocationAuthorizationStatus
 */
- (SBLocationAuthorizationStatus)locationAuthorization;

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
 *  bluetoothAuthorization
 *
 *  @return SBBluetoothStatus
 */
- (SBBluetoothStatus)bluetoothAuthorization;

/**
 *  backgroundAppRefreshStatus
 *
 *  @return SBManagerBackgroundAppRefreshStatus
 */
- (SBManagerBackgroundAppRefreshStatus)backgroundAppRefreshStatus;

/**
 *  @brief Request authorization to show notifications
 *
 *  @since 2.0
 */
- (void)requestNotificationsAuthorization;

/**
 *  @brief Checks and returns a boolean value depending on the types of notifications that can be shown
 *
 *  @return true if at least one type of notification can be shown, false if no type of notifications are allowed
 *
 *  @since <#2.0#>
 */
- (BOOL)canReceiveNotifications;

/**
 *  This will return a cached version if available,
 *  otherwise a network call will be made to the ```Resolver```
 *
 *  Load the layout configuration
 *
 */
- (void)requestLayout;

/**
 *
 *  startMonitoring
 *
 *  Start monitoring for the UUID's
 *  <br>**Warning** You need to :requestLayout first!
 *
 *  @since 2.0
 */
- (void)startMonitoring:(NSArray*)uuids __attribute__((nonnull));


/**
 *  stopMonitoring
 *  
 *  Stops monitoring for all UUID's
 */
- (void)stopMonitoring;


/**
 *  startBackgroundMonitoring
 */
- (void)startBackgroundMonitoring;

/**
 *  @brief Scan for bluetooth devices with services
 *
 *  @param services An array containing service id's
 *
 *  @since 2.0
 */
- (void)startServiceScan:(NSArray*)services;

@end

#pragma mark - Protocol methods
/**
 *  The SBManager uses *events* for message
 *  In every class you want to receive events from the SBManager you have to call (once) `REGISTER`
 *  and add listeners for the events you want to receive.
 *  Bellow is the list of events the `SBManager` sends
 *  to receive an event simply SUBSCRIBE to receive the fired
 *
 */

/**
 *  SBEventReachabilityEvent
 *  
 *  Event fired when there's a change rechability (connection to the resolver). The resulting event contains the `reachable` boolean value
 */
@protocol SBEventReachabilityEvent
@end

/**
 *  SBEventGetLayout
 *
 *  Event fired when the layout has been retrieved from the resolver (either from the network call or from cache). The resulting event contains the `SBMGetLayout` layout object or the `NSError` error
 */
@protocol SBEventLayout
@end

/**
 *  SBEventLocationAuthorization
 *
 *  Event fired when there's a change in the authorization status of the Location Manager
 */
@protocol SBEventLocationAuthorization
@end

/**
 *  SBEventPerformAction
 *
 *  Event fired when a detected UUID has been resolved to a campaign action.
 */
@protocol SBEventPerformAction
@end

/**
 *  SBEventRangedBeacons
 *
 *  Event fired when a beacon has been ranged. The resulting event contains the beacon (`SBMBeacon`), proximity, accuracy and rssi values
 */
@protocol SBEventRangedBeacons
@end

/**
 *  SBEventRegionEnter
 *
 *  Event fired upon entering a beacon region. The resulting event contains the SBMBeacon object
 */
@protocol SBEventRegionEnter
@end

/**
 *  SBEventRegionExit
 *
 *  Event fired upon exiting a beacon region. The resulting event contains the SBMBeacon object
 */
@protocol SBEventRegionExit
@end
