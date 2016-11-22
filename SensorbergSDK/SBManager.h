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

/**
 *  @brief  resolverURL
 *
 *  @return The Resolver URL string.
 *
 *  @since 2.0
 *
 *  @deprecated 2.3
 */
- (NSString *)resolverURL __attribute__((deprecated("not available")));

#pragma mark -

/**
 *  Start monitoring for all campaign UUID's
 *
 *  @since 2.0
 */
- (void)startMonitoring;


/**
 *  Start monitoring for specific UUID's
 *
 *  @param UUIDS An array of UUID's as NSString's
 */
- (void)startMonitoring:(NSArray*)UUIDS;

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
 *
 *  @deprecated 2.1 Use requestLocationAuthorization: instead
 */
- (void)requestLocationAuthorization __attribute__((deprecated("use requestLocationAuthorization:")));

/**
 *  @brief  Request user access to location information (optionally always)
 *
 *  Ideally, you would show a message to the user
 *  explaining why access to Location services is required.
 *  <br>**Warning** Be sure to include the `NSLocationAlwaysUsageDescription` and/or `NSLocationWhenInUseUsageDescription` key in the *Info.plist* with a descriptive text
 *
 *  @since 2.1
 */
- (void)requestLocationAuthorization:(BOOL)always;

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

/**
 *  Attach the Apple Advertising Identifier to this instance of the SDK.
 *
 *  @param IDFA A NSString containing the UUID of the Apple Advertising Identifier
 *
 *  @since 2.1
 */
- (void)setIDFAValue:(NSString*)IDFA;

/**
 *  Set target informaions which can be used to specify right campaigns for target.
 *
 *  @discussion The app should set attributes when app is launched and after calling [[SBManager sharedManager] resetSharedClient];
 *  @param attributes A Dictionary containing key-value pair of tartget informations
 *
 *  @since 2.4
 */
- (void)setTargetAttributes:(NSDictionary*)attributes;

/**
 *  Track campaign conversion
 *
 *  @param type An SBConversionType value (one of kSBConversionSuccessful, kSBConversionIgnored or kSBConversionUnavailable
 *  @param eid  The campaign identifier
 */
- (void)reportConversion:(SBConversionType)type forCampaignAction:(NSString*)action;

- (instancetype)init __attribute__((unavailable("use [SBManager sharedManager]")));

- (instancetype)new __attribute__((unavailable("use [SBManager sharedManager]")));

@end

#pragma mark - Protocol methods
/**
 *  Event fired when a user enters/exits a beacon region and the campaign has been triggered
 *
 *  @discussion A SBMCampaignAction object containing the subject, body etc of the campaign.
 *  Be sure to check the fireDate (NSDate object) to check if the campaign should fire at a specific date/time
 *
 *  @since 2.0
 */
@protocol SBEventPerformAction
@end

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
    Event fired when the authorization status for the Bluetooth radio changes. The resulting event contains the new `SBBluetoothStatus`
    
    @since 2.0
 */
@protocol SBEventBluetoothAuthorization
@end


/**
    * **DEPRECATED** Call [[SBManager sharedManager] canReceiveNotifications] to retrieve the current status
 */
@protocol SBEventNotificationsAuthorization
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


