//
//  SBManager.h
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBResolver.h"
#import "SBResolver+Models.h"
#import "SBResolver+Events.h"

#import "SBLocation.h"

#import "SBBluetooth.h"

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


@interface SBManager : NSObject {
    SBMLayout *layout;
}
//
@property (strong, nonatomic) SBResolver    *apiClient;
//
@property (strong, nonatomic) SBLocation    *locClient;
//
@property (strong, nonatomic) SBBluetooth   *bleClient;
//

// 
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithResolver:(NSString *)baseURL apiKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

@end
