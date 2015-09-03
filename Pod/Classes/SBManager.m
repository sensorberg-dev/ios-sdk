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

#import "SBLocation+Events.h"

#import "SBAnalytics+Models.h"
#import "SBAnalytics+Events.h"

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

#define kSBCache            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

#define now                 [NSDate date]

@interface SBManager () {
    //
}
@property (readonly, nonatomic) SBResolver      *apiClient;
@property (readonly, nonatomic) SBLocation      *locClient;
@property (readonly, nonatomic) SBBluetooth     *bleClient;
@property (readonly, nonatomic) SBAnalytics     *anaClient;
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
            //
            [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:5];
            //
            [[NSNotificationCenter defaultCenter] addObserver:_sharedManager selector:@selector(applicationDidFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
            //
            [[NSNotificationCenter defaultCenter] addObserver:_sharedManager selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
            //
            [[NSNotificationCenter defaultCenter] addObserver:_sharedManager selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            //
            [[NSNotificationCenter defaultCenter] addObserver:_sharedManager selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
            //
            [[NSNotificationCenter defaultCenter] addObserver:_sharedManager selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        });
        //
//        NSString *logPath = [kSBCache stringByAppendingPathComponent:@"console.log"];
//        freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
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
    _anaClient = [SBAnalytics new];
    //
    [[Tolo sharedInstance] subscribe:_anaClient];
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

- (void)requestNotificationAuthorization {
    //
}

#pragma mark - Status

- (SBManagerAvailabilityStatus)availabilityStatus {
    //- (void)didChangeAvailabilityStatus:(SBManagerAvailabilityStatus)status;
    SBManagerAvailabilityStatus status;
    //
    switch (self.bleClient.authorizationStatus) {
        case SBBluetoothOff:
            status = SBManagerAvailabilityStatusBluetoothRestricted;
            
        default:
            break;
    }
    
    switch (self.backgroundAppRefreshStatus) {
        case SBManagerBackgroundAppRefreshStatusRestricted:
        case SBManagerBackgroundAppRefreshStatusDenied:
            status = SBManagerAvailabilityStatusBackgroundAppRefreshRestricted;
            
        default:
            break;
    }
    
    switch (self.locClient.authorizationStatus) {
        case SBLocationAuthorizationStatusNotDetermined:
        case SBLocationAuthorizationStatusUnimplemented:
        case SBLocationAuthorizationStatusRestricted:
        case SBLocationAuthorizationStatusDenied:
        case SBLocationAuthorizationStatusUnavailable:
            status = SBManagerAvailabilityStatusAuthorizationRestricted;
            
        default:
            break;
    }
    
    if (!self.apiClient.isConnected) {
        status = SBManagerAvailabilityStatusConnectionRestricted;
    }
    //
    if (self.delegate) {
        [self.delegate didChangeAvailabilityStatus:status];
    }
    //
    return status;
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
    if (layout && layout.accountProximityUUIDs) {
        [self.locClient startMonitoring:layout.accountProximityUUIDs];
    }
}

- (void)startBackgroundMonitoring {
    [self.locClient startBackgroundMonitoring];
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

SUBSCRIBE(SBELocationAuthorization) {
    [self availabilityStatus];
}

SUBSCRIBE(SBERangedBeacons) {
    //
}

SUBSCRIBE(SBERegionEnter) {
    //
    SBEMonitorEvent *enter = [SBEMonitorEvent new];
    enter.pid = event.uuid;
    enter.dt = now;
    enter.trigger = 1;
    PUBLISH(enter);
    //
}

SUBSCRIBE(SBERegionExit) {
    //
    SBEMonitorEvent *exit = [SBEMonitorEvent new];
    exit.pid = event.uuid;
    exit.dt = now;
    exit.trigger = 2;
    PUBLISH(exit);
    //
}

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunchingWithOptions:(NSNotification *)notification {
    NSLog(@"%s",__func__);
    //
    NSArray *events = [self.anaClient events];
    if (events.count) {
        SBMLocationEvents *postData = [SBMLocationEvents new];
        postData.deviceTimestamp = now;
        postData.events = events;
        //
        [self.apiClient postLayout:[postData toDictionary]];
    }
    //
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"%s",__func__);
    //
    NSArray *events = [self.anaClient events];
    if (events.count) {
        SBMLocationEvents *postData = [SBMLocationEvents new];
        postData.deviceTimestamp = now;
        postData.events = events;
        //
        [self.apiClient postLayout:[postData toDictionary]];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    NSLog(@"%s",__func__);
    // fire an event instead
    [[SBManager sharedManager] startBackgroundMonitoring];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"%s",__func__);
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSLog(@"%s",__func__);
}

@end
