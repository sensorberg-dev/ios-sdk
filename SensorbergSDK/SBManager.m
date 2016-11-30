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
#import "SBAnalytics.h"
#import "SBSettings.h"

#import "SBInternalEvents.h"

#import "SBUtility.h"
#import "SBSettings.h"
#import "NSString+SBUUID.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

#import <UIKit/UIKit.h>

#import <tolo/Tolo.h>

#pragma mark - Constants

static const NSInteger kSBMaxMonitoringRegionCount = 20;

#pragma mark - SBManager

@interface SBManager () {
    //
    double ping;
    //
    double delay;
    
    SBResolver      *apiClient;
    SBLocation      *locClient;
    SBBluetooth     *bleClient;
    SBAnalytics     *anaClient;
    
    SBMGetLayout    *layout;
    
    NSDictionary    *targetAttributes;
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
    [self stopMonitoring];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        //
    }
    return self;
}

#pragma mark - Designated initializer

- (void)setApiKey:(NSString*)apiKey delegate:(id)delegate {
    if ([NSThread currentThread]!=[NSThread mainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setApiKey:apiKey delegate:delegate];
        });
        return;
    }
    //
#ifndef DEBUG
    if ([self availabilityStatus]==SBManagerAvailabilityStatusIBeaconUnavailable) {
        // fire error event
        return;
    }
#endif
    //
    [self canReceiveNotifications];
    // if apiKey is changed, reset Settings.
    if (!apiKey.length || [apiKey isEqualToString:(SBAPIKey ? SBAPIKey : @"")])
    {
        [[SBSettings sharedManager] reset];
    }
    //
    keychain = [UICKeyChainStore keyChainStoreWithService:kSBIdentifier];
    //
    keychain.accessibility = UICKeyChainStoreAccessibilityAlways;
    keychain.synchronizable = YES;
    //
    SBAPIKey = apiKey.length ? apiKey : kSBDefaultAPIKey;
    //
    if (isNull(apiClient)) {
        apiClient = [[SBResolver alloc] initWithApiKey:SBAPIKey];
        [[Tolo sharedInstance] subscribe:apiClient];
        
        // publish event
        SBEventUpdateTargetAttributes *event = [SBEventUpdateTargetAttributes new];
        event.targetAttributes = targetAttributes;
        PUBLISH(event);
    }
    //
    if (!isNull(delegate)) {
        [[Tolo sharedInstance] subscribe:delegate];
    }
    //
    [apiClient requestLayoutForBeacon:nil trigger:kSBTriggerNone useCache:NO];
    //
    [apiClient requestSettingsWithAPIKey:SBAPIKey];
    //
    SBLog(@"👍 Sensorberg SDK [%@]",[SBUtility userAgent].sdk);
}

#pragma mark - Resolver methods

- (NSString *)resolverURL
{
    return [SBSettings sharedManager].settings.resolverURL;
}

- (double)resolverLatency {
    return ping;
}

- (void)requestResolverStatus {
    [apiClient ping];
}

SUBSCRIBE(SBEventPing) {
    if (event.error) {
        return;
    }
    ping = event.latency;
}

#pragma mark - Location methods

- (void)requestLocationAuthorization {
    [self requestLocationAuthorization:YES];
}

- (void)requestLocationAuthorization:(BOOL)always {
    if (locClient) {
        [locClient requestAuthorization:always];
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
    
    if (!status&&!notifs) {
        SBLog(@"🔇 Notifications disabled");
    }
    
    return status||notifs;
}

#pragma mark - Status

- (SBManagerAvailabilityStatus)availabilityStatus {
    //
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        return SBManagerAvailabilityStatusIBeaconUnavailable; // not possible
    }
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

- (void)startMonitoring
{
    [self startMonitoring:[self monitoringBeaconRegions]];
}

- (void)startMonitoring:(NSArray <NSString*>*)UUIDs {
    [locClient startMonitoring:UUIDs];
}

- (void)stopMonitoring {
    [locClient stopMonitoring];
}

- (void)setIDFAValue:(NSString*)IDFA {
    if (IDFA && [IDFA isKindOfClass:[NSString class]] && IDFA.length>0) {
        [keychain setString:IDFA forKey:kIDFA];
    } else {
        [keychain removeItemForKey:kIDFA];
    }
    //
    PUBLISH([SBEventUpdateHeaders new]);
}

- (void)setTargetAttributes:(NSDictionary*)attributes {
    targetAttributes = [attributes copy];
    //
    SBEventUpdateTargetAttributes *event = [SBEventUpdateTargetAttributes new];
    event.targetAttributes = attributes;
    PUBLISH(event);
}

- (void)reportConversion:(SBConversionType)type forCampaignAction:(NSString *)action {
    if (isNull(action) || ![action isKindOfClass:[NSString class]] || !action.length) {
        return;
    }
    //
    PUBLISH((({
        SBEventReportConversion *event = [SBEventReportConversion new];
        event.action = action;
        event.conversionType = type;
        event.gps = locClient.gps;
        event;
    })));
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
    
    if (layout && [layout.toDictionary isEqualToDictionary:event.layout.toDictionary])
    {
        return;
    }
    
    //
    SBLog(@"👍 GET layout");
    layout = event.layout;
    //
    if (delay>3) {
        PUBLISH([SBEventReportHistory new]);
    }
    //
    if (locClient.isMonitoring) {
        [self startMonitoring];
    }
    //
    delay = 0.1f;
    //
}

#pragma mark SBEventPostLayout
SUBSCRIBE(SBEventPostLayout) {
    if (event.error) {
        SBLog(@"💀 Error posting layout: %@",event.error);
        return;
    }
    //
    SBLog(@"👍 POST layout");
}

#pragma mark - Location events

#pragma mark SBEventLocationAuthorization
SUBSCRIBE(SBEventLocationAuthorization) {
    //
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
    if ([UIApplication sharedApplication].applicationState!=UIApplicationStateBackground) {
        [apiClient requestLayoutForBeacon:event.beacon trigger:triggerType useCache:YES];
    } else {
        [layout checkCampaignsForBeacon:event.beacon trigger:triggerType];
    }
}

#pragma mark SBEventRegionExit
SUBSCRIBE(SBEventRegionExit) {
    SBLog(@"🏁 %@",[event.beacon description]);
    //
    SBTriggerType triggerType = kSBTriggerExit;
    //
    if ([UIApplication sharedApplication].applicationState!=UIApplicationStateBackground) {
        [apiClient requestLayoutForBeacon:event.beacon trigger:triggerType useCache:YES];
    } else {
        [layout checkCampaignsForBeacon:event.beacon trigger:triggerType];
    }
}

#pragma mark - Analytics
SUBSCRIBE(SBEventReportHistory) {
    if (!event.forced) {
        NSString *lastPostString = [keychain stringForKey:kPostLayout];
        if (!isNull(lastPostString)) {
            NSDate *lastPostDate = [dateFormatter dateFromString:lastPostString];
            if (!isNull(lastPostDate)) {
                if ([[NSDate date] timeIntervalSinceDate:lastPostDate] < [SBSettings sharedManager].settings.postSuppression) {
                    return;
                }
            }
        }
    }
    //
    if (anaClient.events.count || anaClient.actions.count || anaClient.conversions.count) {
        // Create postData object to send
        SBMPostLayout *postData = [SBMPostLayout new];
        postData.events = [anaClient events];
        postData.actions = [anaClient actions];
        postData.conversions = [anaClient conversions];
        postData.deviceTimestamp = [NSDate date];
        SBLog(@"❓ POST layout");
        //
        // Set lastPost timestamp
        NSString *lastPostString = [dateFormatter stringFromDate:[NSDate date]];
        [keychain setString:lastPostString forKey:kPostLayout];
        //
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

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    PUBLISH([SBEventApplicationDidEnterBackground new]);
}

#pragma mark - Application events

#pragma mark SBEventPerformAction
SUBSCRIBE(SBEventPerformAction) {
    //
}

#pragma mark SBEventApplicationActive
SUBSCRIBE(SBEventApplicationActive) {
    PUBLISH([SBEventReportHistory new]);
}

#pragma mark SBEventApplicationDidEnterBackground
SUBSCRIBE(SBEventApplicationDidEnterBackground) {
    PUBLISH(({
        SBEventReportHistory *reportEvent = [SBEventReportHistory new];
        reportEvent.forced = YES;
        reportEvent;
    }));
}

#pragma mark SBEventApplicationWillEnterForeground
SUBSCRIBE(SBEventApplicationWillEnterForeground) {
    //
}

#pragma mark - SBSettingEvent

SUBSCRIBE(SBSettingEvent)
{
    if (!event.error)
    {
        [apiClient requestLayoutForBeacon:nil trigger:kSBTriggerNone useCache:YES];
    }
}

#pragma mark - Internal Methods

- (NSArray * _Nonnull)monitoringBeaconRegions
{
    NSMutableSet *proximityUUIDSet = [NSMutableSet new];
    //
    if (isNull(layout) || layout.accountProximityUUIDs.count==0) {
        for (NSString *proximityUUIDString in [SBSettings sharedManager].settings.customBeaconRegions.allKeys)
        {
            if (proximityUUIDSet.count<kSBMaxMonitoringRegionCount) {
                [proximityUUIDSet addObject:[[NSString stripHyphensFromUUIDString:proximityUUIDString] lowercaseString]];
            }
        }
        return proximityUUIDSet.allObjects;
    }
    //
    NSMutableSet *proximityBeacons = [NSMutableSet new];
    //
    for (SBMAction *action in layout.actions) {
        for (SBMBeacon *bid in action.beacons) {
            [proximityBeacons addObject:bid.fullUUID];
        }
    }
    
    if ([SBSettings sharedManager].settings.enableBeaconScanning &&
        proximityBeacons.count<kSBMaxMonitoringRegionCount) {
        //
        [proximityUUIDSet addObjectsFromArray:[proximityBeacons allObjects]];
        
        for (NSString *region in layout.accountProximityUUIDs)
        {
            if (proximityUUIDSet.count < kSBMaxMonitoringRegionCount) {
                [proximityUUIDSet addObject:[[NSString stripHyphensFromUUIDString:region] lowercaseString]];
            } else {
                return proximityUUIDSet.allObjects;
            }
        }
        
    } else {
        [proximityUUIDSet addObjectsFromArray:layout.accountProximityUUIDs];
    }
    
    for (NSString *proximityUUIDString in [SBSettings sharedManager].settings.customBeaconRegions.allKeys)
    {
        if (proximityUUIDSet.count < kSBMaxMonitoringRegionCount) {
            [proximityUUIDSet addObject:[[NSString stripHyphensFromUUIDString:proximityUUIDString] lowercaseString]];
        } else {
            break;
        }
    }
    
    return proximityUUIDSet.allObjects;
}

@end
