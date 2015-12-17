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

#import "SBResolver.h"
#import "SBLocation.h"
#import "SBBluetooth.h"
#import "SBAnalytics.h"

#import "SBInternalEvents.h"

#import "SensorbergSDK.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

#import <UIKit/UIKit.h>

#import <tolo/Tolo.h>


@interface SBManager () {
    //
    double ping;
    //
    double delay;
}

@property (readonly, nonatomic) SBResolver      *apiClient;
@property (readonly, nonatomic) SBLocation      *locClient;
@property (readonly, nonatomic) SBBluetooth     *bleClient;
@property (readonly, nonatomic) SBAnalytics     *anaClient;

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
        [self performSelectorOnMainThread:@selector(resetSharedClient) withObject:nil waitUntilDone:NO];
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
    [[Tolo sharedInstance] unsubscribe:_anaClient];
    [[Tolo sharedInstance] unsubscribe:_apiClient];
    [[Tolo sharedInstance] unsubscribe:_locClient];
    [[Tolo sharedInstance] unsubscribe:_bleClient];
    //
    _anaClient = nil;
    _apiClient = nil;
    _locClient = nil;
    _bleClient = nil;
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
        if (isNull(_locClient)) {
            _locClient = [SBLocation new];
            [[Tolo sharedInstance] subscribe:_locClient];
        }
        //
        if (isNull(_bleClient)) {
            _bleClient = [SBBluetooth new];
            [[Tolo sharedInstance] subscribe:_bleClient];
        }
        //
        if (isNull(_anaClient)) {
            _anaClient = [SBAnalytics new];
            [[Tolo sharedInstance] subscribe:_anaClient];
        }
        //
        UNREGISTER();
        REGISTER();
        // set the latency to a negative value before the first health check
        ping = -1;
        [_apiClient ping];
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

- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate {
    if ([NSThread currentThread]!=[NSThread mainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupResolver:resolver apiKey:apiKey delegate:delegate];
            return;
        });
    }
    //
    SBResolverURL = isNull(resolver) ? kSBDefaultResolver : resolver;
    //
    SBAPIKey = isNull(apiKey) ? kSBDefaultAPIKey : apiKey;
    //
    if (isNull(_apiClient)) {
        _apiClient = [[SBResolver alloc] initWithResolver:SBResolverURL apiKey:SBAPIKey];
        [[Tolo sharedInstance] subscribe:_apiClient];
    }
    //
    keychain = [UICKeyChainStore keyChainStoreWithService:[SensorbergSDK applicationIdentifier]];
    keychain.accessibility = UICKeyChainStoreAccessibilityAlways;
    keychain.synchronizable = YES;
    //
    if (!isNull(delegate)) {
        SBLog(@" %@",delegate);
        [[Tolo sharedInstance] subscribe:delegate];
    }
    //
    SBLog(@"👍 SBManager");
}

#pragma mark - Resolver methods

- (void)requestLayout {
    [_apiClient requestLayoutForBeacon:nil trigger:0 useCache:NO];
}

- (double)resolverLatency {
    return ping;
}

- (void)requestResolverStatus {
    [_apiClient ping];
}

SUBSCRIBE(SBEventPing) {
    if (isNull(event.error)) {
        ping = event.latency;
    }
}

#pragma mark - Location methods

- (void)requestLocationAuthorization {
    if (_locClient) {
        [_locClient requestAuthorization];
        
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = [[SBManager sharedManager] locationAuthorization];
            event;
        }));
    }
}

- (SBLocationAuthorizationStatus)locationAuthorization {
    return [_locClient authorizationStatus];
}

#pragma mark - Bluetooth methods

- (void)requestBluetoothAuthorization {
    if (_bleClient) {
        [_bleClient requestAuthorization];
    }
}

- (SBBluetoothStatus)bluetoothAuthorization {
    return [_bleClient authorizationStatus];
}

SUBSCRIBE(SBEventBluetoothAuthorization) {
    //
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
    
    return status||notifs;
}

#pragma mark - Status

- (SBManagerAvailabilityStatus)availabilityStatus {
    //
    switch (self.bleClient.authorizationStatus) {
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
    //
    if (!self.apiClient.isConnected) {
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

- (void)startMonitoring:(NSArray*)UUIDs { //pass the proximity uuids directly
    if (!isNull(UUIDs)) {
        //
        [self.locClient startMonitoring:UUIDs];
    }
}

- (void)stopMonitoring {
    [self.locClient stopMonitoring];
}

- (void)startBackgroundMonitoring {
    [self.locClient startBackgroundMonitoring];
}

- (void)stopBackgroundMonitoring {
    [self.locClient stopBackgroundMonitoring];
}

#pragma mark - Resolver events

#pragma mark SBEventGetLayout
SUBSCRIBE(SBEventGetLayout) {
    if (event.error) {
        SBLog(@"💀 Error reading layout: %@",event.error.localizedDescription);
        //
        if (delay<0.1f) {
            delay = 0.1f;
        }
        delay *= 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.apiClient requestLayoutForBeacon:event.beacon trigger:event.trigger useCache:YES];
        });
        //
        return;
    }
    //
    SBLog(@"👍 GET layout");
    //
    delay = 0.1f;
    //
    if (isNull(event.beacon)) {
        [self startMonitoring:event.layout.accountProximityUUIDs];
    }
}

#pragma mark SBEventPostLayout
SUBSCRIBE(SBEventPostLayout) {
    if (isNull(event.error)) {
        NSString *lastPostString = [dateFormatter stringFromDate:now];
        [keychain setString:lastPostString forKey:kPostLayout];
        //
        SBLog(@"👍 POST layout");
        //
        return;
    }
    SBLog(@"💀 Error posting layout: %@",event.error);
}

#pragma mark - Location events

#pragma mark SBEventLocationAuthorization
SUBSCRIBE(SBEventLocationAuthorization) {
    [self requestLayout];
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
    [self.apiClient requestLayoutForBeacon:event.beacon trigger:triggerType useCache:YES];
}

#pragma mark SBEventRegionExit
SUBSCRIBE(SBEventRegionExit) {
    SBLog(@"🏁 %@",[event.beacon description]);
    //
    SBTriggerType triggerType = kSBTriggerExit;
    //
    [self.apiClient requestLayoutForBeacon:event.beacon trigger:triggerType useCache:YES];
}

#pragma mark - Analytics
SUBSCRIBE(SBEventReportHistory) {
    NSString *lastPostString = [keychain stringForKey:kPostLayout];
    if (!isNull(lastPostString)) {
        NSDate *lastPostDate = [dateFormatter dateFromString:lastPostString];
        //
        if ([now timeIntervalSinceDate:lastPostDate]<kPostSuppression*5) {
            return;
        }
    }
    //
    if (self.anaClient.events && self.anaClient.actions) {
        SBMPostLayout *postData = [SBMPostLayout new];
        postData.events = [self.anaClient events];
        postData.deviceTimestamp = now;
        postData.actions = [self.anaClient actions];
        SBLog(@"❓ POST layout");
        [self.apiClient postLayout:postData];
    }
}

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunchingWithOptions:(NSNotification *)notification {
    PUBLISH([SBEventApplicationLaunched new]);
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    PUBLISH([SBEventApplicationActive new]);
    // hack for notifications status change
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self canReceiveNotifications];
    });
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