//
//  SBSDKDefines.h
//  SensorbergSDK
//
//  Created by Thomas Ploentzke.
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

#ifndef Pods_SBSDKDefines_h
#define Pods_SBSDKDefines_h


// Domain used for beacon region identifiers.
static NSString *const SBSDKManagerBeaconRegionIdentifier = @"com.sensorberg.sdk.ios.region";

// Error domain used in Sensorberg SDK
static NSString *const SBSDKManagerErrorDomain = @"com.sensorberg.sdk.ios.error.manager";

// Time interval after which the active beacons should be analyzed for an exit event.
static NSTimeInterval const SBSDKBeaconExitEventTimeInterval = 1.0;

// Time interval after which the a detected beacons should be asumed as gone.
static NSTimeInterval const SBSDKBeaconCleanupTimeInterval = 5.0;

/**
 SBSDKBeaconEvent
 
 Represents the event types that a beacon can trigger.
 */
typedef NS_ENUM(NSInteger, SBSDKBeaconEvent) {
    /**
     Event that is triggered when entering a beacon region.
     */
    SBSDKBeaconEventEnter,
    
    /**
     Event that is triggered when leaving a beacon region.
     */
    SBSDKBeaconEventExit,
    
    /**
     Event that is triggered when entering and leaving a beacon region.
     
     @since 1.0.0
     */
    SBSDKBeaconEventEnterExit
};

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


#endif
