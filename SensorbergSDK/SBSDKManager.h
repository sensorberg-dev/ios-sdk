//
//  SBSDKManager.h
//  SensorbergSDK
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

#import "Tolo.h"

#import "SBSDKNetworkManager.h"

@protocol SBSDKManagerDelegate;

#pragma mark -

/**
 The SBSDKManager object is your entry point for handling the interaction with beacons
 that are managed via the Sensorberg Beacon Management Platform.

 @since 0.7.0
 */
@interface SBSDKManager : NSObject <CLLocationManagerDelegate, CBCentralManagerDelegate>

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

/**
 Layout holding all beacons and actions.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSDictionary *beaconLayout;

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
 Actively connects the SBSDKManager object to a Sensorberg Resolver at a given base URL
 in order to resolve detected beacon advertisements.

 This is done asynchronously.

 @param baseUrlString Base URL string.
 @param apiKey        API key to use.
 @param error         If an error occurs, upon return contains an `NSError` object
                      that describes the problem.

 @return `YES` if the connection request was initiated, otherwise `NO`.

 @since 1.0.0
 */
- (BOOL)connectToResolver:(NSString *)baseUrlString
                   apiKey:(NSString *)apiKey
                    error:(NSError * __autoreleasing *)error;

/**
 Actively connects the SBSDKManager object to the Sensorberg Beacon Management Platform
 in order to resolve detected beacon advertisements.

 This is done asynchronously.
 
 @deprecated This method has been deprecated. Use -connectToResolver:apiKey:error: instead.

 @param apiKey  API key to use.
 @param error   If an error occurs, upon return contains an `NSError` object
                that describes the problem.

 @return `YES` if the connection request was initiated, otherwise `NO`.

 @since 0.7.0
 @until 0.8.0
 */
- (BOOL)connectToBeaconManagementPlatformUsingApiKey:(NSString *)apiKey
                                               error:(NSError * __autoreleasing *)error DEPRECATED_ATTRIBUTE;

/**
 Disconnects the SBSDKManager object from a Sensorberg Resolver.

 Can savely be called even if SBSDKManager object wasn't connected to a Sensorberg Resolver, yet.

 @since 1.0.0
 */
- (void)disconnectFromResolver;

/**
 Disconnects the SBSDKManager object from the Sensorberg Beacon Management Platform.

 Can savely be called even if SBSDKManager object wasn't connected to the Sensorberg
 Beacon Management Platform, yet.

 @deprecated This method has been deprecated. Use -disconnectFromResolver instead.

 @since 0.7.0
 @until 0.8.0
 */
- (void)disconnectFromBeaconManagementPlatform DEPRECATED_ATTRIBUTE;

/**
 Disconnects the SBSDKManager object from a Sensorberg Resolver and resets the device
 identifier that is used when communicating with a Sensorberg Resolver.

 Next time the connection to a Sensorberg Resolver is being executed, the device will act
 like a new device to the Sensorberg Resolver.

 The method can savely be called even if SBSDKManager object wasn't connected to a
 Sensorberg Resolver, yet.

 @since 1.0.0
 */
- (void)disconnectFromResolverAndResetDeviceIdentifier;

/**
 Disconnects the SBSDKManager object from the Sensorberg Beacon Management Platform
 and resets the device identifier that is used when communicating with the Sensorberg
 Beacon Management Platform.
 
 Next time the connection to the Sensorberg Beacon Management Platform is being
 executed, the device will act like a new device to the Sensorberg Beacon Management
 Platform.

 The method can savely be called even if SBSDKManager object wasn't connected to the
 Sensorberg Beacon Management Platform, yet.

 @deprecated This method has been deprecated. Use -disconnectFromResolverAndResetDeviceIdentifier
             instead.

 @since 0.7.0
 @until 0.8.0
 */
- (void)disconnectFromBeaconManagementPlatformAndResetDeviceIdentifier DEPRECATED_ATTRIBUTE;

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
     Cannot connect to Sensorberg Resolver without an API key.
     */
    SBSDKManagerErrorApiKeyMissing = -99,
    /**
     Already connected to Sensorberg Resolver, disconnect first.
     */
    SBSDKManagerErrorAlreadyConnected = -98,
    /**
     The method of the Sensorberg SDK has been deprecated and should not be used anymore.
     
     @since 1.0.0
     */
    SBSDKManagerErrorMethodDeprecated = -97,
    /**
     Cannot connect to Sensorberg Resolver without a base URL.
     */
    SBSDKManagerErrorBaseUrlMissing = -96,
    /**
     Cannot connect to Sensorberg Resolver without a valid base URL string.
     */
    SBSDKManagerErrorBaseUrlStringInvalid = -95
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

///---------------------------------------------------
/// @name Methods indicating beacon related detections
///---------------------------------------------------

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

///--------------------------------------------------
/// @name Methods indicating beacon triggered actions
///--------------------------------------------------

/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is active, for each single action
 and it asks to display an in app message.

 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param title    Title of the beacon action.
 @param message  Message of the beacon action.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayInAppMessageWithTitle:(NSString *)title message:(NSString *)message __attribute__((deprecated("Replaced by -beaconManager:didResolveBeaconActionWithId:displayInAppMessageWithTitle:message:payload:")));

/**
 Delegate method invoked when a beacon action has been resolved.
 
 This delegate method is being called when the app is active, for each single action
 and it asks to display an in app message.
 
 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param title    Title of the beacon action.
 @param message  Message of the beacon action.
 @param payload  Custom data that has been defined for the beacon action. It is a Foundation
                 object from JSON data in data, or nil.
 
 @see SBSDKManager
 
 @since 1.0.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayInAppMessageWithTitle:(NSString *)title message:(NSString *)message payload:(id)payload;


/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is active, for each single action
 and it asks to display an in app message and open an URL.

 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param title    Title of the beacon action.
 @param message  Message of the beacon action.
 @param url      URL to be visited, or nil.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayInAppMessageWithTitle:(NSString *)title message:(NSString *)message url:(NSURL *)url __attribute__((deprecated("Replaced by -beaconManager:didResolveBeaconActionWithId:displayInAppMessageWithTitle:message:url:payload:")));

/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is active, for each single action
 and it asks to display an in app message and open an URL.
 
 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param title    Title of the beacon action.
 @param message  Message of the beacon action.
 @param url      URL to be visited, or nil.
 @param payload  Custom data that has been defined for the beacon action. It is a Foundation
                 object from JSON data in data, or nil.

 @see SBSDKManager

 @since 0.8.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayInAppMessageWithTitle:(NSString *)title message:(NSString *)message url:(NSURL *)url payload:(id)payload;

/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is in the background, for each single action
 and it asks to display a local notification.

 As local notification do not have a title property, the title is omitted.

 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param title    Title of the beacon action.
 @param message  Message of the beacon action.

 @see SBSDKManager

 @since 0.7.8
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayLocalNotificationWithTitle:(NSString *)title message:(NSString *)message payload:(id)payload __attribute__((deprecated("Replaced by -beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:payload:deliverAt:")));

/**
 Delegate method invoked when a beacon action has been resolved.
 
 This delegate method is being called when the app is in the background, for each single action
 and it asks to display a local notification and open an URL.
 
 As local notification do not have a title property, the title is omitted.
 
 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param message  Message of the beacon action.
 @param title    Title of the beacon action.
 @param payload  Custom data that has been defined for the beacon action. It is a Foundation
 object from JSON data in data, or nil.
 
 @see SBSDKManager
 
 @since 1.0.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayLocalNotificationWithTitle:(NSString *)title message:(NSString *)message payload:(id)payload deliverAt:(NSDate*)deliverDate;

/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is in the background, for each single action
 and it asks to display a local notification and open an URL.

 As local notification do not have a title property, the title is omitted.

 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param message  Message of the beacon action.
 @param title    Title of the beacon action.
 @param url      URL to be visited, or nil.
 @param payload  Custom data that has been defined for the beacon action. It is a Foundation
                 object from JSON data in data, or nil.

 @see SBSDKManager

 @since 0.8.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayLocalNotificationWithTitle:(NSString *)title message:(NSString *)message url:(NSURL *)url payload:(id)payload __attribute__((deprecated("Replaced by -beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:url:payload:deliverAt:")));

/**
 Delegate method invoked when a beacon action has been resolved.
 
 This delegate method is being called when the app is in the background, for each single action
 and it asks to display a local notification and open an URL.
 
 As local notification do not have a title property, the title is omitted.
 
 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param message  Message of the beacon action.
 @param title    Title of the beacon action.
 @param url      URL to be visited, or nil.
 @param payload  Custom data that has been defined for the beacon action. It is a Foundation
 object from JSON data in data, or nil.
 
 @see SBSDKManager
 
 @since 1.0.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayLocalNotificationWithTitle:(NSString *)title message:(NSString *)message url:(NSURL *)url payload:(id)payload deliverAt:(NSDate*)deliverDate;


///----------------------------------
/// @name Methods indicating failures
///----------------------------------

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

/**
 Delegate method invoked when the communication with the Sensorberg Beacon Management failed,
 mainly used when the API Key is invalid.

 @param manager Beacon manager.
 @param error   If an error occurs it contains an `NSError` object
                that describes the problem.

 @see SBSDKManager

 @since 1.0.0
 */
- (void)beaconManager:(SBSDKManager *)manager communicationDidFailWithError:(NSError *)error;

/**
 Delegate method invoked when a beacon action could not be resolved.

 @param manager Beacon manager.
 @param error   If an error occurs it contains an `NSError` object
 that describes the problem.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager resolveBeaconActionsDidFailWithError:(NSError *)error;

///-------------------------
/// @name Deprecated methods
///-------------------------

/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is in the background, for each single action
 and it asks to display a local notification.

 As local notification do not have a title property, the title is omitted.

 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param message  Message of the beacon action.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayLocalNotificationWithMessage:(NSString *)message __attribute__((deprecated("Replaced by -beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:")));

/**
 Delegate method invoked when a beacon action has been resolved.

 This delegate method is being called when the app is in the background, for each single action
 and it asks to display a local notification and open an URL.

 As local notification do not have a title property, the title is omitted.

 @param manager  Beacon manager.
 @param actionId Id of the beacon action.
 @param message  Message of the beacon action.
 @param url      URL to be visited.

 @see SBSDKManager

 @since 0.7.0
 */
- (void)beaconManager:(SBSDKManager *)manager didResolveBeaconActionWithId:(NSString *)actionId displayLocalNotificationWithMessage:(NSString *)message url:(NSURL *)url __attribute__((deprecated("Replaced by -beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:url:")));

@end
