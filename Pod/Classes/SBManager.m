//
//  SBManager.m
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBManager.h"

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
    //
    _bleClient = [[SBBluetooth alloc] init];
    //
    REGISTER();
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
    //
    [_apiClient getLayout];
    //
}

#pragma mark - Location methods

- (void)requestLocationAuthorization {
    if (_locClient) {
        [_locClient requestAuthorization];
    }
}

#pragma mark - Bluetooth methods

- (void)requestBluetoothAuthorization {
    if (_bleClient) {
        [_bleClient requestAuthorization];
    }
}

#pragma mark - Notification methods

- (BOOL)requestNotificationsAuthorization {
    return YES;
}

#pragma mark - Status

//- (SBManagerAvailabilityStatus)availabilityStatus {
//    //
//    switch (self.bluetoothStatus) {
//        case SBManagerBluetoothStatusPoweredOff:
//            return SBManagerAvailabilityStatusBluetoothRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.backgroundAppRefreshStatus) {
//        case SBManagerBackgroundAppRefreshStatusRestricted:
//        case SBManagerBackgroundAppRefreshStatusDenied:
//            return SBManagerAvailabilityStatusBackgroundAppRefreshRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.authorizationStatus) {
//        case SBManagerAuthorizationStatusNotDetermined:
//        case SBManagerAuthorizationStatusUnimplemented:
//        case SBManagerAuthorizationStatusRestricted:
//        case SBManagerAuthorizationStatusDenied:
//            return SBManagerAvailabilityStatusAuthorizationRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.connectionState) {
//        case SBManagerConnectionStateConnecting:
//        case SBManagerConnectionStateDisconnected:
//            return SBManagerAvailabilityStatusConnectionRestricted;
//            
//        default:
//            break;
//    }
//    
//    switch (self.reachabilityState) {
//        case SBManagerReachabilityStateNotReachable:
//            return SBManagerAvailabilityStatusReachabilityRestricted;
//            
//        default:
//            break;
//    }
//    
//    return SBManagerAvailabilityStatusFullyFunctional;
//}

- (SBManagerBackgroundAppRefreshStatus)backgroundAppRefreshStatus {
    //
    UIBackgroundRefreshStatus status = [UIApplication sharedApplication].backgroundRefreshStatus;
    //
    switch (status) {
        case UIBackgroundRefreshStatusRestricted:
            return SBManagerBackgroundAppRefreshStatusRestricted;
            
        case UIBackgroundRefreshStatusDenied:
            return SBManagerBackgroundAppRefreshStatusDenied;
            
        case UIBackgroundRefreshStatusAvailable:
            return SBManagerBackgroundAppRefreshStatusAvailable;
            
        default:
            break;
    }
    
    return SBManagerBackgroundAppRefreshStatusAvailable;
}

- (void)startMonitoring {
    if (layout) {
        [_locClient startMonitoring:layout.accountProximityUUIDs];
    }
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
}

@end
