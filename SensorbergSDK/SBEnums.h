//
//  SBEnums.h
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kSBTriggerEnter=1,
    kSBTriggerExit=2,
    kSBTriggerEnterExit=3,
} SBTriggerType;

typedef enum : NSUInteger {
    kSBActionTypeText=1,
    kSBActionTypeURL=2,
    kSBActionTypeInApp=3,
} SBActionType;

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
 SBManagerBackgroundAppRefreshStatus
 
 Represents the app’s Background App Refresh status.
 
 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBManagerBackgroundAppRefreshStatus) {
    /**
     Background App Refresh is enabled, the app is authorized to use location services and
     Bluetooth is turned on.
     */
    SBManagerBackgroundAppRefreshStatusAvailable,
    
    /**
     This application is not enabled to use Background App Refresh. Due
     to active restrictions on Background App Refresh, the user cannot change
     this status, and may not have personally denied availability.
     
     Do not warn the user if the value of this property is set to
     SBManagerBackgroundAppRefreshStatusRestricted; a restricted user does not have
     the ability to enable multitasking for the app.
     */
    SBManagerBackgroundAppRefreshStatusRestricted,
    
    /**
     User has explicitly disabled Background App Refresh for this application, or
     Background App Refresh is disabled in Settings.
     */
    SBManagerBackgroundAppRefreshStatusDenied,
    
    /**
     This application runs on a device that does not support Background App Refresh.
     */
    SBManagerBackgroundAppRefreshStatusUnavailable
};

/**
 SBManagerAuthorizationStatus
 
 Represents the app’s authorization status for using location services.
 
 @since 0.7.0
 */

typedef NS_ENUM(NSInteger, SBLocationAuthorizationStatus) {
    /**
     User has not yet made a choice with regards to this application
     */
    SBLocationAuthorizationStatusNotDetermined,
    
    /**
     Authorization procedure has not been fully implemeneted in app.
     NSLocationAlwaysUsageDescription is missing from Info.plist.
     */
    SBLocationAuthorizationStatusUnimplemented,
    
    /**
     This application is not authorized to use location services. Due
     to active restrictions on location services, the user cannot change
     this status, and may not have personally denied authorization.
     
     Do not warn the user if the value of this property is set to
     SBManagerAuthorizationStatusRestricted; a restricted user does not have
     the ability to enable multitasking for the app.
     */
    SBLocationAuthorizationStatusRestricted,
    
    /**
     User has explicitly denied authorization for this application, or
     location services are disabled in Settings.
     */
    SBLocationAuthorizationStatusDenied,
    
    /**
     User has granted authorization to use their location at any time,
     including monitoring for regions, visits, or significant location changes.
     */
    SBLocationAuthorizationStatusAuthorized,
    
    /**
     This application runs on a device that does not support iBeacon.
     */
    SBLocationAuthorizationStatusUnavailable
};

typedef enum : NSUInteger {
    SBBluetoothUnknown, // it's resetting or unknown, try again later
    SBBluetoothOff, // it's off, unsupported or restricted
    SBBluetoothOn, // it's on, supported and accessible
} SBBluetoothStatus;

@interface SBEnums : NSObject

@end
