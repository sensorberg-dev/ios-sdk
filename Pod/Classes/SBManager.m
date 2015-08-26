//
//  SBManager.m
//  SensorbergSDK
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

@interface SBManager ()
@property (readonly, nonatomic) SBResolver    *apiClient;

@property (readonly, nonatomic) SBLocation    *locClient;

@property (readonly, nonatomic) SBBluetooth   *bleClient;
@end

@implementation SBManager

NSString *kSBAPIKey   = nil;
NSString *kSBResolver = nil;

static SBManager * _sharedManager = nil;

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        //
        static dispatch_once_t once;
        dispatch_once(&once, ^ {
            _sharedManager = [super new];
        });
    }
    return _sharedManager;
}

+ (void)logoutAndDeleteSharedClient {
    kSBResolver = nil;
    //
    kSBAPIKey = nil;
    //
    _sharedManager = nil;
}

#pragma mark - Designated initializer

- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey {
    //
    kSBAPIKey = apiKey;
    //
    kSBResolver = resolver;
    //
    _apiClient = [SBResolver new];
    //
    _locClient = [SBLocation new];
    //
    _bleClient = [SBBluetooth new];
    //
    REGISTER();
}

#pragma mark - Resolver methods

- (SBMLayout *)currentLayout {
    return layout;
}

- (void)requestLayout {
    if (!_locClient) {
        _locClient = [SBLocation new];
    }
    if (!kSBAPIKey) {
        kSBAPIKey = kSBDefaultAPIKey;
    }
    //
    if (!kSBResolver) {
        kSBResolver = kSBDefaultAPIKey;
    }
    //
    [_apiClient requestLayout];
}

- (void)updateLayout {
    if (!_locClient) {
        _locClient = [SBLocation new];
    }
    if (!kSBAPIKey) {
        kSBAPIKey = kSBDefaultAPIKey;
    }
    //
    if (!kSBResolver) {
        kSBResolver = kSBDefaultAPIKey;
    }
    //
    [_apiClient updateLayout];
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

- (SBManagerAvailabilityStatus)availabilityStatus {
    //
    switch (self.bleClient.authorizationStatus) {
        case SBBluetoothOff:
            return SBManagerAvailabilityStatusBluetoothRestricted;
            
        default:
            break;
    }
    
    switch (self.backgroundAppRefreshStatus) {
        case SBManagerBackgroundAppRefreshStatusRestricted:
        case SBManagerBackgroundAppRefreshStatusDenied:
            return SBManagerAvailabilityStatusBackgroundAppRefreshRestricted;
            
        default:
            break;
    }
    
    switch (self.locClient.authorizationStatus) {
        case SBLocationAuthorizationStatusNotDetermined:
        case SBLocationAuthorizationStatusUnimplemented:
        case SBLocationAuthorizationStatusRestricted:
        case SBLocationAuthorizationStatusDenied:
        case SBLocationAuthorizationStatusUnavailable:
            return SBManagerAvailabilityStatusAuthorizationRestricted;
            
        default:
            break;
    }
    
    if (!self.apiClient.isConnected) {
        return SBManagerAvailabilityStatusConnectionRestricted;
    }
    
    return SBManagerAvailabilityStatusFullyFunctional;
}

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
        NSLog(@"* %@",event.error.localizedDescription);
        return;
    }
    //
    layout = event.layout;
    //
    [self startMonitoring];
}

#pragma mark - SBLocation events

SUBSCRIBE(SBERangedBeacons) {
    NSDate *now = [NSDate date];
    //
    SBMAction *beaconAction;
    //
    for (SBMBeacon *beacon in event.beacons) {
        for (SBMAction *action in layout.actions) {
            for (SBMTimeframe *timeframe in action.timeframes) {
                if (!isNull(timeframe.start) && ![now isEqualToDate:[now laterDate:timeframe.start]]) {
                    // current date is before the timeframe start
                    return;
                }
                //
                if (!isNull(timeframe.end) && ![now isEqualToDate:[now earlierDate:timeframe.end]]) {
                    // current date is before the timeframe end
                    return;
                }
                //
                NSLog(@"inside timeframe");
                //
                for (SBMBeacon *actionBeacon in action.beacons) {
                    if ([beacon isEqual:actionBeacon]) {
                        if (self.delegate) {
                            [self.delegate performAction:action];
                        }
                    }
                }
            }
            
        }
    }
    //
    
}

@end
