//
//  SBManager.m
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBManager.h"

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

#define kSBDefaultResolver  @"https://resolver.sensorberg.com"

#define kSBDefaultAPIKey    @"0000000000000000000000000000000000000000000000000000000000000000"

@interface SBManager () {
    void (^execBlock)();
}

@end

@implementation SBManager

NSString *kSBAPIKey   = nil;
NSString *kSBResolver = nil;

static SBManager * _sharedClient = nil;

+ (instancetype)sharedClient {
    if (!_sharedClient) {
        //
        static dispatch_once_t once;
        dispatch_once(&once, ^ {
            _sharedClient = [[SBManager alloc] init];
        });
    }
    return _sharedClient;
}

+ (void)logoutAndDeleteSharedClient {
    kSBResolver = nil;
    //
    kSBAPIKey = nil;
    //
    _sharedClient = nil;
}

#pragma mark - Designated initializer

- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey {
    //
    kSBAPIKey = apiKey;
    //
    kSBResolver = resolver;
    //
    _apiClient = [[SBResolver alloc] init];
    //
    _locClient = [[SBLocation alloc] init];
}

#pragma mark - Resolver methods

- (void)getLayout {
    if (!kSBAPIKey) {
        kSBAPIKey = kSBDefaultAPIKey;
    }
    //
    if (!kSBResolver) {
        kSBResolver = kSBDefaultAPIKey;
    }
    [_apiClient getLayout];
    //
}

#pragma mark - Location methods

- (BOOL)requestLocationAuthorization {
    return YES;
}

- (BOOL)startMonitoringUUID:(SBMUUID *)uuid {
    if (!uuid) {
        return NO;
    }
    //
    return YES;
}

#pragma mark - Bluetooth methods


#pragma mark - Notification methods

- (BOOL)requestNotificationsAuthorization {
    return YES;
}

#pragma mark - Status

//- (SBSDKManagerAvailabilityStatus)availabilityStatus {
//    //
//    switch (self.bluetoothStatus) {
//        case SBSDKManagerBluetoothStatusPoweredOff:
//            return SBSDKManagerAvailabilityStatusBluetoothRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.backgroundAppRefreshStatus) {
//        case SBSDKManagerBackgroundAppRefreshStatusRestricted:
//        case SBSDKManagerBackgroundAppRefreshStatusDenied:
//            return SBSDKManagerAvailabilityStatusBackgroundAppRefreshRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.authorizationStatus) {
//        case SBSDKManagerAuthorizationStatusNotDetermined:
//        case SBSDKManagerAuthorizationStatusUnimplemented:
//        case SBSDKManagerAuthorizationStatusRestricted:
//        case SBSDKManagerAuthorizationStatusDenied:
//            return SBSDKManagerAvailabilityStatusAuthorizationRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.connectionState) {
//        case SBSDKManagerConnectionStateConnecting:
//        case SBSDKManagerConnectionStateDisconnected:
//            return SBSDKManagerAvailabilityStatusConnectionRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.reachabilityState) {
//        case SBSDKManagerReachabilityStateNotReachable:
//            return SBSDKManagerAvailabilityStatusReachabilityRestricted;
//            
//        default:
//            break;
//    }
//    
//    return SBSDKManagerAvailabilityStatusFullyFunctional;
//}

- (SBSDKManagerBackgroundAppRefreshStatus)backgroundAppRefreshStatus {
    //
    UIBackgroundRefreshStatus status = [UIApplication sharedApplication].backgroundRefreshStatus;
    //
    switch (status) {
        case UIBackgroundRefreshStatusRestricted:
            return SBSDKManagerBackgroundAppRefreshStatusRestricted;
            
        case UIBackgroundRefreshStatusDenied:
            return SBSDKManagerBackgroundAppRefreshStatusDenied;
            
        case UIBackgroundRefreshStatusAvailable:
            return SBSDKManagerBackgroundAppRefreshStatusAvailable;
            
        default:
            break;
    }
    
    return SBSDKManagerBackgroundAppRefreshStatusAvailable;
}

#pragma mark - SBAPIClient events

SUBSCRIBE(SBELayout) {
    if (event.error) {
        // propagate error to delegate
        return;
    }
    //
    NSString *layoutCache = [event.layout toJSONString];
    NSError *error;
    BOOL cached = [layoutCache writeToFile:@"cacheFile" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    //
    if (!cached) {
        NSLog(@"failed to write layout cache");
    }
    //
    layout = event.layout;
    //
    if (self.locClient) {
        NSMutableArray *monitoringUUIDs = [NSMutableArray new];
        for (SBMUUID *beacon in layout.accountProximityUUIDs) {
            if (beacon.proximityUUID) {
                [monitoringUUIDs addObject:beacon.proximityUUID];
            }
        }
        //
        if (monitoringUUIDs.count) {
            [self.locClient startMonitoring:monitoringUUIDs];
        }
    }
    //
}

@end
