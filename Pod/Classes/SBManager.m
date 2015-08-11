//
//  SBManager.m
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBManager.h"

@implementation SBManager

- (instancetype)init {
    // throw an exception?
    return [self initWithResolver:@""
                           apiKey:@""];
}

- (instancetype)initWithResolver:(NSString *)baseURL apiKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        //
        _apiClient = [[SBAPIClient alloc] initWithBaseURL:baseURL andAPI:apiKey];
        //
        _locClient = [[SBLocation alloc] init];
    }
    return self;
}

- (void)getLayout {
    [_apiClient layout];
    //
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
    if (self.locClient) {
        
    }
}

@end
