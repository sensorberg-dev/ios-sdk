//
//  SBManager.h
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
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
 *
 *  @since 2.0
 */
@interface SBManager : NSObject

#pragma mark -

/**
 *  @brief  sharedManager
 *
 *  @return The SBManager singleton instance
 *
 *  @since 2.0
 */
+ (instancetype)sharedManager;

/**
 *  @brief  Setup method for the SBManager
 *
 *  @param apiKey   The API key string - register on the [management platform](https://manage.sensorberg.com/) to obtain an API key
 *  @param delegate The class instance that will receive the SBManager events
 *
 *  @since 2.0
 */
- (void)setApiKey:(NSString*)apiKey delegate:(id)delegate;

#pragma mark -

/**
 *  Start monitoring for all campaign UUID's
 *
 *  @since 2.0
 */
- (void)startMonitoring;

/**
 *  Start monitoring for iBeacons with the specified UUID strings
 *
 *  @param uuids Array of UUID's (as NSString, with or without the hyphen) to monitor
 *
 *  @since 2.0
 */
- (void)startMonitoring:(NSArray <NSString*>*)uuids __attribute__((nonnull));

/**
 *  stopMonitoring
 *
 *  Stops monitoring for all UUID's
 *
 *  @since 2.0
 */
- (void)stopMonitoring;

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
 *
 *  @since 2.0
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
 *
 *  @since 2.0
 */
- (SBBluetoothStatus)bluetoothAuthorization;

/**
 *  backgroundAppRefreshStatus
 *
 *  @return SBManagerBackgroundAppRefreshStatus
 *
 *  @since 2.0
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
 *  @since 2.0
 */
- (BOOL)canReceiveNotifications;

/**
 *  @brief  Force a reset of the SBManager (clears cache, Resolver URL, API Key). To use the SBManager again, call [SBManager sharedManager] and setup the environment with :setApiKey:delegate
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
 *
 *  @since 2.0
 */
- (void)requestResolverStatus;

/**
 *  @brief  availabilityStatus
 *
 *  @return General availability of the system
 *
 *  @since 2.0
 */
- (SBManagerAvailabilityStatus)availabilityStatus;

- (void)enableAIDHeader:(BOOL)status;

- (instancetype)init __attribute__((unavailable("use [SBManager sharedManager]")));

- (instancetype)new __attribute__((unavailable("use [SBManager sharedManager]")));

@end

#pragma mark - Protocol methods
/**
 *  The SBManager uses *events* for message
 *  In every class you want to receive events from the SBManager you have to call (once) `REGISTER`
 *  and add listeners for the events you want to receive.
 *  Bellow is the list of events the `SBManager` sends
 *  to receive an event simply SUBSCRIBE(<event>) to receive the fired
 *
 *  @since 2.0
 */

/**
 *  Event fired when the authorization status for location services changes.
 *
 *  @brief  This event is fired after calling requestLocationAuthorization and at this point you should start monitoring for beacons 
 *
 *  @since 2.0
 */
@protocol SBEventLocationAuthorization
@end

/**
 *  SBEventRangedBeacons
 *
 *  Event fired when a beacon has been ranged. The resulting event contains the beacon (`SBMBeacon`), proximity, accuracy and RSSI values
 *
 *  @since 2.0
 */
@protocol SBEventRangedBeacons
@end

/**
 *  SBEventRegionEnter
 *
 *  Event fired upon entering a beacon region. The resulting event contains the SBMBeacon object
 *
 *  @since 2.0
 */
@protocol SBEventRegionEnter
@end

/**
 *  SBEventRegionExit
 *
 *  Event fired upon exiting a beacon region. The resulting event contains the SBMBeacon object
 *
 *  @since 2.0
 */
@protocol SBEventRegionExit
@end

/**
 *  Event fired when a detected iBeacon resolves to a campaign
 *
 *  @since 2.0
 */
@protocol SBEventPerformAction
@end


