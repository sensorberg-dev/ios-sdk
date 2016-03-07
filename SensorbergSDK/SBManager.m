//
//  SBManager.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
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

#import "SensorbergSDK.h"

#import "SBManager.h"

#import "SBResolver.h"
#import "SBLocation.h"
#import "SBBluetooth.h"
#import "SBAnalytics.h"

#import "SBInternalEvents.h"

#import "SBUtility.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

#import <UIKit/UIKit.h>

#import <tolo/Tolo.h>


@interface SBManager () {
    //
    double ping;
    //
    double delay;
    
    SBResolver      *apiClient;
    SBLocation      *locClient;
    SBBluetooth     *bleClient;
    SBAnalytics     *anaClient;
}

@end

@implementation SBManager

NSString *SBAPIKey = nil;
NSString *SBResolverURL = nil;

static SBManager * _sharedManager;

static dispatch_once_t once;

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        //
        dispatch_once(&once, ^ {
            _sharedManager = [[self alloc] init];
        });
        //
    }
    return _sharedManager;
}

- (void)resetSharedClient {
    // enforce main thread
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetSharedClient];
        });
        return;
    }
    //
    SBResolverURL = nil;
    //
    SBAPIKey = nil;
    //
    _sharedManager = nil;
    // we reset the dispatch_once_t to 0 (it's a long) so we can re-create the singleton instance
    once = 0;
    // we also reset the latency value to -1 (no connectivity)
    ping = -1;
    //
    [keychain removeAllItems];
    keychain = nil;
    //
    UNREGISTER();
    [[Tolo sharedInstance] unsubscribe:anaClient];
    [[Tolo sharedInstance] unsubscribe:apiClient];
    [[Tolo sharedInstance] unsubscribe:locClient];
    [[Tolo sharedInstance] unsubscribe:bleClient];
    //
    anaClient = nil;
    apiClient = nil;
    locClient = nil;
    bleClient = nil;
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    PUBLISH([SBEventResetManager new]);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:APIDateFormat];
        //
        if (isNull(locClient)) {
            locClient = [SBLocation new];
            [[Tolo sharedInstance] subscribe:locClient];
        }
        //
        if (isNull(bleClient)) {
            bleClient = [SBBluetooth sharedManager];
            [[Tolo sharedInstance] subscribe:bleClient];
        }
        //
        if (isNull(anaClient)) {
            anaClient = [SBAnalytics new];
            [[Tolo sharedInstance] subscribe:anaClient];
        }
        //
        UNREGISTER();
        REGISTER();
        // set the latency to a negative value before the first health check
        ping = -1;
        [apiClient ping];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        //
    }
    return self;
}

#pragma mark - Designated initializer

- (void)setApiKey:(NSString *)apiKey delegate:(id)delegate {
    [self setResolver:nil apiKey:apiKey delegate:delegate];
    
    [self canReceiveNotifications];
}

- (void)setResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate {
    if ([NSThread currentThread]!=[NSThread mainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setResolver:resolver apiKey:apiKey delegate:delegate];
        });
        return;
    }
    //
    if (isNull(resolver)) {
        SBResolverURL = kSBDefaultResolver;
    } else {
        SBResolverURL = resolver;
    }
    //
    if (isNull(apiKey)) {
        SBAPIKey = kSBDefaultAPIKey;
        //
    } else {
        SBAPIKey = apiKey;
    }
    //
    if (isNull(apiClient)) {
        apiClient = [[SBResolver alloc] initWithResolver:SBResolverURL apiKey:SBAPIKey];
        [[Tolo sharedInstance] subscribe:apiClient];
    }
    //
    keychain = [UICKeyChainStore keyChainStoreWithService:apiKey];
    keychain.accessibility = UICKeyChainStoreAccessibilityAlways;
    keychain.synchronizable = YES;
    //
    if (!isNull(delegate)) {
        [[Tolo sharedInstance] subscribe:delegate];
    }
    //
    SBLog(@"👍 Sensorberg SDK [%@]",[SBUtility userAgent].sdk);
}

#pragma mark - Resolver methods

- (double)resolverLatency {
    return ping;
}

- (void)requestResolverStatus {
    [apiClient ping];
}

SUBSCRIBE(SBEventPing) {
    if (isNull(event.error)) {
        ping = event.latency;
    }
}

#pragma mark - Location methods

- (void)requestLocationAuthorization {
    if (locClient) {
        [locClient requestAuthorization];
    }
}

- (SBLocationAuthorizationStatus)locationAuthorization {
    return [locClient authorizationStatus];
}

#pragma mark - Bluetooth methods

- (void)requestBluetoothAuthorization {
    [bleClient requestAuthorization];
}

- (SBBluetoothStatus)bluetoothAuthorization {
    return [bleClient authorizationStatus];
}

#pragma mark - Notifications

- (void)requestNotificationsAuthorization {
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
}

- (BOOL)canReceiveNotifications {
    UIUserNotificationSettings *notificationSettings =  [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    BOOL status = (notificationSettings.types & UIUserNotificationTypeSound) || (notificationSettings.types & UIUserNotificationTypeAlert) || (notificationSettings.types & UIUserNotificationTypeBadge);
    
    BOOL notifs = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    
    PUBLISH(({
        SBEventNotificationsAuthorization *event = [SBEventNotificationsAuthorization new];
        event.notificationsAuthorization = status||notifs;
        event;
    }));
    
    if (!status&&!notifs) {
        SBLog(@"🔇 Notifications disabled");
    }
    
    return status||notifs;
}

#pragma mark - Status

- (SBManagerAvailabilityStatus)availabilityStatus {
    //
    switch (bleClient.authorizationStatus) {
        case SBBluetoothOff: {
            return SBManagerAvailabilityStatusBluetoothRestricted;
        }
        default: {
            break;
        }
    }
    //
    switch (self.backgroundAppRefreshStatus) {
        case SBManagerBackgroundAppRefreshStatusRestricted:
        case SBManagerBackgroundAppRefreshStatusDenied:
            return SBManagerAvailabilityStatusBackgroundAppRefreshRestricted;
            
        default:
            break;
    }
    //
    switch (locClient.authorizationStatus) {
        case SBLocationAuthorizationStatusNotDetermined:
        case SBLocationAuthorizationStatusUnimplemented:
        case SBLocationAuthorizationStatusRestricted:
        case SBLocationAuthorizationStatusDenied:
        case SBLocationAuthorizationStatusUnavailable:
            return SBManagerAvailabilityStatusAuthorizationRestricted;
            
        default:
            break;
    }
    //
    if (!apiClient.isConnected) {
        return SBManagerAvailabilityStatusConnectionRestricted;
    }
    //
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
    [self startMonitoring:[SensorbergSDK defaultBeaconRegions].allKeys];
}

- (void)startMonitoring:(NSArray <NSString*>*)UUIDs {
    if (!isNull(UUIDs)) {
        //
        [locClient startMonitoring:UUIDs];
    }
}

- (void)stopMonitoring {
    [locClient stopMonitoring];
}

- (void)startBackgroundMonitoring {
    [locClient startBackgroundMonitoring];
}

- (void)stopBackgroundMonitoring {
    [locClient stopBackgroundMonitoring];
}

#pragma mark - Resolver events

#pragma mark SBEventGetLayout
SUBSCRIBE(SBEventGetLayout) {
    if (event.error) {
        SBLog(@"💀 Error reading layout (%@)",event.error.localizedDescription);
        //
        if (delay<.1f || delay>200.f) {
            delay = .1f;
        }
        delay *= 3;
        //
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [apiClient requestLayoutForBeacon:event.beacon trigger:event.trigger useCache:YES];
        });
        //
        return;
    }
    //
    SBLog(@"👍 GET layout");
    //
    if (delay>3) {
        PUBLISH([SBEventReportHistory new]);
    }
    //
    delay = 0.1f;
    // the first time we get this event, it will be for the whole layout so event.beacon will be nil
    if (isNull(event.beacon) && event.layout.accountProximityUUIDs) {
        [self startMonitoring:event.layout.accountProximityUUIDs];
    }
}

#pragma mark SBEventPostLayout
SUBSCRIBE(SBEventPostLayout) {
    if (event.error) {
        SBLog(@"💀 Error posting layout: %@",event.error);
        return;
    }
    //
    NSString *lastPostString = [dateFormatter stringFromDate:now];
    [keychain setString:lastPostString forKey:kPostLayout];
    //
    SBLog(@"👍 POST layout");
}

#pragma mark - Location events

#pragma mark SBEventLocationAuthorization
SUBSCRIBE(SBEventLocationAuthorization) {
    [apiClient requestLayoutForBeacon:nil trigger:0 useCache:NO];
}

#pragma mark SBEventRangedBeacons
SUBSCRIBE(SBEventRangedBeacon) {
    //
}

#pragma mark SBEventRegionEnter
SUBSCRIBE(SBEventRegionEnter) {
    SBLog(@"👀 %@",[event.beacon description]);
    //
    SBTriggerType triggerType = kSBTriggerEnter;
    //
    [apiClient requestLayoutForBeacon:event.beacon trigger:triggerType useCache:YES];
}

#pragma mark SBEventRegionExit
SUBSCRIBE(SBEventRegionExit) {
    SBLog(@"🏁 %@",[event.beacon description]);
    //
    SBTriggerType triggerType = kSBTriggerExit;
    //
    [apiClient requestLayoutForBeacon:event.beacon trigger:triggerType useCache:YES];
}

#pragma mark - Analytics
SUBSCRIBE(SBEventReportHistory) {
    if (!event.forced) {
        NSString *lastPostString = [keychain stringForKey:kPostLayout];
        if (!isNull(lastPostString)) {
            NSDate *lastPostDate = [dateFormatter dateFromString:lastPostString];
            //
            if ([now timeIntervalSinceDate:lastPostDate]<kPostSuppression*60) {
                return;
            }
        }
    }
    //
    if (anaClient.events) {
        SBMPostLayout *postData = [SBMPostLayout new];
        postData.events = [anaClient events];
        postData.deviceTimestamp = now;
        postData.actions = [anaClient actions];
        SBLog(@"❓ POST layout");
        [apiClient postLayout:postData];
    }
}

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunchingWithOptions:(NSNotification *)notification {
    PUBLISH([SBEventApplicationLaunched new]);
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    PUBLISH([SBEventApplicationActive new]);
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    PUBLISH([SBEventApplicationWillResignActive new]);
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    PUBLISH([SBEventApplicationWillTerminate new]);
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    PUBLISH([SBEventApplicationWillEnterForeground new]);
}

#pragma mark - Application events

#pragma mark SBEventPerformAction
SUBSCRIBE(SBEventPerformAction) {
    [keychain setString:[dateFormatter stringFromDate:now] forKey:event.campaign.eid];
}

#pragma mark SBEventApplicationActive
SUBSCRIBE(SBEventApplicationActive) {
    PUBLISH([SBEventReportHistory new]);
}

#pragma mark SBEventApplicationWillResignActive
SUBSCRIBE(SBEventApplicationWillResignActive) {
    [[SBManager sharedManager] startBackgroundMonitoring];
}

#pragma mark SBEventApplicationWillEnterForeground
SUBSCRIBE(SBEventApplicationWillEnterForeground) {
    [self stopBackgroundMonitoring];
}

@end
