//
//  SBSDKManager.h
//  SensorbergSDK
//
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

#import <Availability.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SBSDKNetworkManager.h"

@protocol SBSDKManagerDelegate;
@class SBSDKBeaconAction;

#pragma mark -

/**
 SBSDKManagerAvailabilityStatus

 Represents the app’s overall iBeacon readiness, like Bluetooth being turned on,
 Background App Refresh enabled and authorization to use location services.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerAvailabilityStatus) {
    /**
     Background App Refresh is enabled, the app is authorized to use location services and
     Bluetooth is turned on.
     */
    SBSDKManagerAvailabilityStatusFullyFunctional,

    /**
     Bluetooth is turned off. The specific status can be found in bluetoothStatus.
     */
    SBSDKManagerAvailabilityStatusBluetoothRestricted,

    /**
     This application is not enabled to use Background App Refresh. The specific status can be
     found in backgroundAppRefreshStatus.
     */
    SBSDKManagerAvailabilityStatusBackgroundAppRefreshRestricted,

    /**
     This application is not authorized to use location services. The specific status can be
     found in authorizationStatus.
     */
    SBSDKManagerAvailabilityStatusAuthorizationRestricted,

    /**
     This application is not connected to the Sensorberg Beacon Management Platform. The
     specific status can be found in connectionState.
     */
    SBSDKManagerAvailabilityStatusConnectionRestricted,

    /**
     This application cannot reach the Sensorberg Beacon Management Platform. The specific
     status can be found in reachabilityState.
     */
    SBSDKManagerAvailabilityStatusReachabilityRestricted,

    /**
     This application runs on a device that does not support iBeacon.

     @since 0.7.9
     */
    SBSDKManagerAvailabilityStatusIBeaconUnavailable
};

/**
 SBSDKManagerBluetoothStatus

 Represents the device’s Bluetooth status.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerBluetoothStatus) {
    /**
     Bluetooth is not known yet. As soon as the state is known,
     beaconManager:didChangeBluetoothStatus: will be called.
     */
    SBSDKManagerBluetoothStatusUnknown,

    /**
     Bluetooth is turned on.
     */
    SBSDKManagerBluetoothStatusPoweredOn,

    /**
     Bluetooth is turned off.
     */
    SBSDKManagerBluetoothStatusPoweredOff,

    /**
     This application runs on a device that does not support iBeacon.
     */
    SBSDKManagerBluetoothStatusUnavailable
};

/**
 SBSDKManagerBackgroundAppRefreshStatus

 Represents the app’s Background App Refresh status.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerBackgroundAppRefreshStatus) {
    /**
     Background App Refresh is enabled, the app is authorized to use location services and
     Bluetooth is turned on.
     */
    SBSDKManagerBackgroundAppRefreshStatusAvailable,

    /**
     This application is not enabled to use Background App Refresh. Due
     to active restrictions on Background App Refresh, the user cannot change
     this status, and may not have personally denied availability.
     
     Do not warn the user if the value of this property is set to 
     SBSDKManagerBackgroundAppRefreshStatusRestricted; a restricted user does not have
     the ability to enable multitasking for the app.
     */
    SBSDKManagerBackgroundAppRefreshStatusRestricted,

    /**
     User has explicitly disabled Background App Refresh for this application, or
     Background App Refresh is disabled in Settings.
     */
    SBSDKManagerBackgroundAppRefreshStatusDenied,

    /**
     This application runs on a device that does not support Background App Refresh.
     */
    SBSDKManagerBackgroundAppRefreshStatusUnavailable
};

/**
 SBSDKManagerAuthorizationStatus

 Represents the app’s authorization status for using location services.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerAuthorizationStatus) {
    /**
     User has not yet made a choice with regards to this application
     */
    SBSDKManagerAuthorizationStatusNotDetermined,

    /**
     Authorization procedure has not been fully implemeneted in app.
     NSLocationAlwaysUsageDescription is missing from Info.plist.
     */
    SBSDKManagerAuthorizationStatusUnimplemented,

    /**
     This application is not authorized to use location services. Due
     to active restrictions on location services, the user cannot change
     this status, and may not have personally denied authorization.

     Do not warn the user if the value of this property is set to
     SBSDKManagerAuthorizationStatusRestricted; a restricted user does not have
     the ability to enable multitasking for the app.
     */
    SBSDKManagerAuthorizationStatusRestricted,

    /**
     User has explicitly denied authorization for this application, or
     location services are disabled in Settings.
     */
    SBSDKManagerAuthorizationStatusDenied,

    /**
     User has granted authorization to use their location at any time,
     including monitoring for regions, visits, or significant location changes.
     */
    SBSDKManagerAuthorizationStatusAuthorized,

    /**
     This application runs on a device that does not support iBeacon.
     */
    SBSDKManagerAuthorizationStatusUnavailable
};

/**
 SBSDKManagerConnectionState
 
 Represents the current connection state of the SBSDKManager object to the 
 Sensorberg Beacon Management Platform.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerConnectionState) {
    /**
     The SBSDKManager object is not connected to the Sensorberg Beacon Management Platform.
     */
    SBSDKManagerConnectionStateDisconnected,

    /**
     The SBSDKManager object is trying to connect to the Sensorberg Beacon Management Platform.
     */
    SBSDKManagerConnectionStateConnecting,

    /**
     The SBSDKManager object is connected to the Sensorberg Beacon Management Platform.
     */
    SBSDKManagerConnectionStateConnected
};

/**
 SBSDKManagerReachabilityState

 Represents the current reachability state of the SBSDKManager object to the
 Sensorberg Beacon Management Platform.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerReachabilityState) {
    /**
     The Sensorberg Beacon Management Platform is reachable.
     */
    SBSDKManagerReachabilityStateReachable,

    /**
     The Sensorberg Beacon Management Platform is not reachable.
     */
    SBSDKManagerReachabilityStateNotReachable
};

#pragma mark -

/**
 The SBSDKManager object is your entry point for handling the interaction with beacons
 that are managed via the Sensorberg Beacon Management Platform.

 @since 0.7.0
 */
@interface SBSDKManager : NSObject <CLLocationManagerDelegate, CBCentralManagerDelegate, SBSDKNetworkManagerDelegate>

///-----------------
/// @name Properties
///-----------------

/**
 Delegate for SBSDKManager.
 
 Defines the class that implements the protocol `SBSDKManagerDelegate`.

 @since 0.7.0
 */
@property (nonatomic, assign) id <SBSDKManagerDelegate> delegate;

///------------------
/// @name Collections
///------------------

/**
 Holds the default list of regions to listen for iBeacon advertisements.
 */
@property (nonatomic, strong) NSArray *defaultRegions;

/**
 Holds a list of regions to listen for iBeacon advertisements.

 Each regions object holds a string of the proximityUUID of a beacon id.

 @since 0.7.0
 */
@property (nonatomic, readonly) NSArray *regions;

/**
 Holds a list of all detected Beacons.

 @since 0.7.0
 */
@property (nonatomic, readonly) NSArray *detectedBeacons;

///----------------------
/// @name Manager objects
///----------------------

/**
 The `SBSDKNetworkManager` object used by the SBSDKManager object.
 
 @see SBSDKNetworkManager

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKNetworkManager *networkManager;

/**
 The CLLocationManager object used by the SBSDKManager object.

 @since 0.7.0
 */
@property (nonatomic, readonly) CLLocationManager *locationManager;

/**
 The CBCentralManager object used by the SBSDKManager object.

 @since 0.7.0
 */
@property (nonatomic, readonly) CBCentralManager *bluetoothManager;

///----------------------------------
/// @name Feature support indications
///----------------------------------

/**
 Indicator if the device supports iBeacon.

 Returns YES if iOS >= 7.0 and device has BLE capabilities.

 @since 0.7.9
 */
@property (nonatomic, readonly) BOOL iBeaconSupported;

/**
 Indicates the app’s overall iBeacon readiness.
 
 @see SBSDKManagerAvailabilityStatus

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKManagerAvailabilityStatus availabilityStatus;

/**
 Indicates the device’s Bluetooth status.
 
 @see SBSDKManagerBluetoothStatus

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKManagerBluetoothStatus bluetoothStatus;

/**
 Indicates the app’s Background App Refresh status.
 
 @see SBSDKManagerBackgroundAppRefreshStatus

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKManagerBackgroundAppRefreshStatus backgroundAppRefreshStatus;

/**
 Indicates the app’s authorization status for using location services.
 
 @see SBSDKManagerAuthorizationStatus

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKManagerAuthorizationStatus authorizationStatus;

/**
 Indicates if the SBSDKManager object is connected to the Sensorberg Beacon Management Platform.
 
 @see SBSDKManagerConnectionState

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKManagerConnectionState connectionState;

/**
 Indicates if the Sensorberg Beacon Management Platform is reachable via the current
 network connection.
 
 @see SBSDKManagerReachabilityState

 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKManagerReachabilityState reachabilityState;

///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the SBSDKManager object.

 @param delegate Delegate for SBSDKManager.

 @return `SBSDKManager` object.
 
 @see SBSDKManagerDelegate

 @since 0.7.0
 */
- (instancetype)initWithDelegate:(id<SBSDKManagerDelegate>)delegate;

/**
 Initializer of the SBSDKManager object, if you want to re-use a CLLocationManager object.

 @param delegate        Delegate for SBSDKManager.
 @param locationManager CLLocationManager object to be used.

 @return `SBSDKManager` object.
 
 @see SBSDKManagerDelegate

 @since 0.7.0
 */
- (instancetype)initWithDelegate:(id<SBSDKManagerDelegate>)delegate locationManager:(CLLocationManager *)locationManager;

///----------------------------------
/// @name Accessing location services
///----------------------------------

/**
 When `authorizationStatus` == `SBSDKManagerAuthorizationStatusNotDetermined`, calling this method will
 trigger a prompt to request "always" authorization from the user.
 
 If possible, perform this call in response to direct user request for a location-based service
 so that the reason for the prompt will be clear.
 
 Any authorization change as a result of the prompt will be reflected via the
 delegate callback beaconManager:didChangeAuthorizationStatus:.

 When authorizationStatus != SBSDKManagerAuthorizationStatusNotDetermined, (i.e. generally
 after the first call) this method will do nothing.

 If the NSLocationAlwaysUsageDescription key is not specified in your Info.plist, this method
 will do nothing, as your app will be assumed not to support Always authorization.
 
 When running on iOS 7, this method will do nothing.

 @since 0.7.0
 */
- (void)requestAuthorization;

///--------------------------------------------------------------
/// @name Connecting to the Sensorberg Beacon Management Platform
///--------------------------------------------------------------

/**
 Actively connects the SBSDKManager object to the Sensorberg Beacon Management Platform
 in order to resolve detected beacon advertisments.

 This is done asynchronously.

 @param apiKey  API key to use.
 @param error   If an error occurs, upon return contains an `NSError` object
                that describes the problem.

 @return `YES` if the connection request was initiated, otherwise `NO`.

 @since 0.7.0
 */
- (BOOL)connectToBeaconManagementPlatformUsingApiKey:(NSString *)apiKey
                                               error:(NSError * __autoreleasing *)error;

/**
 Disconnects the SBSDKManager object from the Sensorberg Beacon Management Platform.

 Can savely be called even if SBSDKManager object wasn't connected to the Sensorberg
 Beacon Management Platform, yet.

 @since 0.7.0
 */
- (void)disconnectFromBeaconManagementPlatform;

/**
 Disconnects the SBSDKManager object from the Sensorberg Beacon Management Platform
 and resets the device identifier that is used when communicating with the Sensorberg
 Beacon Management Platform.
 
 Next time the connection to the Sensorberg Beacon Management Platform is being
 executed, the device will act like a new device to the Sensorberg Beacon Management
 Platform.

 The method can savely be called even if SBSDKManager object wasn't connected to the
 Sensorberg Beacon Management Platform, yet.

 @since 0.7.0
 */
- (void)disconnectFromBeaconManagementPlatformAndResetDeviceIdentifier;

///----------------------
/// @name Beacon handling
///----------------------

/**
 Monitors all beacons that are managed via the Sensorberg Beacon Management Platform.

 If Sensorberg Beacon Management Platform is not reachable, the default set of
 Sensorberg Proximity UUIDs will be used.

 This is done asynchronously.

 @since 0.7.0
 */
- (void)startMonitoringBeacons;

/**
 Stops monitoring all beacons that are managed via the Sensorberg Beacon Management Platform.

 This is done asynchronously.

 @since 0.7.0
 */
- (void)stopMonitoringBeacons;

///----------------
/// @name Constants
///----------------

/**
 Domain used for beacon region identifiers.

 @since 0.7.0
 */
extern NSString *const SBSDKManagerBeaconRegionIdentifier;

/**
 Error domain used in Sensorberg SDK.

 @since 0.7.0
 */
extern NSString *const SBSDKManagerErrorDomain;

/**
 Error codes used in Sensorberg SDK

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKManagerErrorCode) {
    /**
     iOS 7 or later is required to support iBeacon functionality.
     */
    SBSDKManagerErrorIOSUnsupported = -100,
    /**
     Cannot connect to Beacon Management Platform without an API key.
     */
    SBSDKManagerErrorApiKeyMissing = -99,
    /**
     Already connected to Beacon Management Platform, disconnect first.
     */
    SBSDKManagerErrorAlreadyConnected = -98,
};

@end

#pragma mark - 

/**
 The delegate of a `SBSDKManager` object must adopt the `SBSDKManagerDelegate` protocol.

 The optional methods allow for the discovery and interaction with beacons
 that are managed via the Sensorberg Beacon Management Platform.

 @since 0.7.0
 */
@protocol SBSDKManagerDelegate <NSObject>

@optional

///-------------------------------------------------
/// @name Methods indicating feature support changes
///-------------------------------------------------

/**
 Tells the delegate that the overall iBeacon readiness status for the application changed.

 This method is called whenever any option that influences iBeacon readiness changes.

 @param manager            Beacon manager.
 @param availabilityStatus New availabilityStatus.
 
 @see SBSDKManager
 @see SBSDKManagerAvailabilityStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didChangeAvailabilityStatus:(SBSDKManagerAvailabilityStatus)availabilityStatus;

/**
 Tells the delegate that the Bluetooth status for the device changed.

 This method is called whenever the device's ability to use Bluetooth changes.
 Changes can occur because the user enabled or disabled the Bluetooth radio
 for the system as a whole.

 @param manager         Beacon manager.
 @param bluetoothStatus New bluetoothStatus.

 @see SBSDKManager
 @see SBSDKManagerBluetoothStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didChangeBluetoothStatus:(SBSDKManagerBluetoothStatus)bluetoothStatus;

/**
 Tells the delegate that the Background App Refresh status for the application changed.

 This method is called whenever the application’s ability to use Background App Refresh changes.
 Changes can occur because the user allowed or denied the use of Background App Refresh for your
 application or for the system as a whole.

 @param manager                    Beacon manager.
 @param backgroundAppRefreshStatus New backgroundAppRefreshStatus.

 @see SBSDKManager
 @see SBSDKManagerBackgroundAppRefreshStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didChangeBackgroundAppRefreshStatus:(SBSDKManagerBackgroundAppRefreshStatus)backgroundAppRefreshStatus;

/**
 Tells the delegate that the authorization status for the application changed.

 This method is called whenever the application’s ability to use location services changes.
 Changes can occur because the user allowed or denied the use of location services for your
 application or for the system as a whole.

 @param manager             Beacon manager.
 @param authorizationStatus New authorizationStatus.

 @see SBSDKManager
 @see SBSDKManagerAuthorizationStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didChangeAuthorizationStatus:(SBSDKManagerAuthorizationStatus)authorizationStatus;

/**
 Delegate method invoked when the connection status to the Sensorberg Beacon Management
 Platform changes.

 @param manager         Beacon manager
 @param connectionState Indicates if the application is connected to the Sensorberg
                        Beacon Management Platform.

 @see SBSDKManager
 @see SBSDKManagerConnectionState

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didChangeSensorbergPlatformConnectionState:(SBSDKManagerConnectionState)connectionState;

/**
 Delegate method invoked when the reachability status to the Sensorberg Beacon Management
 Platform changes.

 @param manager           Beacon manager
 @param reachabilityState Indicates if the Sensorberg Beacon Management Platform is reachable.

 @see SBSDKManager
 @see SBSDKManagerReachabilityState

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didChangeSensorbergPlatformReachabilityState:(SBSDKManagerReachabilityState)reachabilityState;

/**
 Delegate method invoked when beacon monitoring started.

 This delegate method is being called for each single region to be monitored.

 @param manager Beacon manager.
 @param region  Beacon region to be monitored.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didStartMonitoringForRegion:(CLRegion *)region;

/**
 Delegate method invoked when a region monitoring error has occurred.
 
 Error types are defined in "CLError.h".

 @param manager Beacon manager.
 @param region  Beacon region that failed.
 @param error   An error object containing the error code that indicates why region monitoring failed.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

/**
 Delegate method invoked when beacon ranging started.

 This delegate method is being called for each single region to be ranged.

 @param manager Beacon manager.
 @param region  Beacon region to be ranged.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didStartRangingForRegion:(CLRegion *)region;

/**
 Delegate method invoked when beacon ranging stopped.

 This delegate method is being called for each single region where ranged did stop.

 @param manager Beacon manager.
 @param region  Beacon region where ranging stopped.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didStopRangingForRegion:(CLRegion *)region;

/**
 Delegate method invoked when a region ranging error has occurred.

 Error types are defined in "CLError.h".

 @param manager Beacon manager.
 @param region  Beacon region that failed.
 @param error   An error object containing the error code that indicates why region ranging failed.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager rangingDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

/**
 Delegate method invoked when Bluetooth is turned off.

 @param manager         Beacon manager.
 @param bluetoothStatus Bluetooth status that caused the failure.

 @see SBSDKManager
 @see SBSDKManagerBluetoothStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager bluetoothDidFailWithBluetoothStatus:(SBSDKManagerBluetoothStatus)bluetoothStatus;

/**
 Delegate method invoked when using Background App Refresh is unavailable.

 @param manager                    Beacon manager.
 @param backgroundAppRefreshStatus Background App Refresh status that caused the failure.

 @see SBSDKManager
 @see SBSDKManagerBackgroundAppRefreshStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager backgroundAppRefreshDidFailWithBackgroundAppRefreshStatus:(SBSDKManagerBackgroundAppRefreshStatus)backgroundAppRefreshStatus;

/**
 Delegate method invoked when accessing the location services is unavailable.

 @param manager             Beacon manager.
 @param authorizationStatus Authorization status that caused the failure.

 @see SBSDKManager
 @see SBSDKManagerAuthorizationStatus

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager authorizationDidFailWithAuthorizationStatus:(SBSDKManagerAuthorizationStatus)authorizationStatus;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
/**
 Delegate method invoked when a beacon region has been entered and is about to be resolved.

 This delegate method is being called for each single detected beacon that is part of the
 beacons regions.
 
 It will only resolve into a beacon action if the specific beacon has an active campaign
 at the Sensorberg Beacon Management Platform.

 @param manager Beacon manager.
 @param beacon  Detected beacon.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didDetectBeaconEnterEventForBeacon:(CLBeacon *)beacon;
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
/**
 Delegate method invoked when a beacon region has been left and is about to be resolved.

 This delegate method is being called for each single detected beacon that is part of the
 beacons regions.

 It will only resolve into a beacon action if the specific beacon has an active campaign
 at the Sensorberg Beacon Management Platform.

 @param manager Beacon manager.
 @param beacon  Detected beacon.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didDetectBeaconExitEventForBeacon:(CLBeacon *)beacon;
#endif

/**
 Delegate method invoked when the array holding detected beacon objects has been updated.

 @param manager         Beacon manager.
 @param detectedBeacons Array holding detected beacons.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didUpdateDetectedBeacons:(NSArray *)detectedBeacons;

/**
* Delegeate mthod invoked when a beacon was resolved to an action
* @param manager        Beacon manager.
* @param action         The action, use your own logic to switch on the type as defined in the mangement platform. Respect the Application state (in background
*/
- (void)beaconManager:(SBSDKManager *)manager didResolveAction:(SBSDKBeaconAction *)action;

/**
 Delegate method invoked when a beacon action could not be resolved.

 @param manager Beacon manager.
 @param error   If an error occurs it contains an `NSError` object
                that describes the problem.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager resolveBeaconActionsDidFailWithError:(NSError *)error;

@end
