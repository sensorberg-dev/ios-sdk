//
//  SBLocation.m
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

#import "SBLocation.h"

#import "NSString+SBUUID.h"

#import "SBUtility.h"

#import <tolo/Tolo.h>

#import <UIKit/UIApplication.h>

#import "SensorbergSDK.h"

#import "SBInternalEvents.h"

#import "SBInternalModels.h"

#import "SBSettings.h"

@interface SBLocation() {
    CLLocationManager *locationManager;
    //
    NSArray *monitoredRegions;
    //
    NSArray *defaultBeacons;
    //
    float prox;
    //
    NSMutableDictionary *sessions;
    //
    NSDate *appActiveDate;
    //
    NSTimeInterval lastRegionExitCheckTime;
}

@end

@implementation SBLocation

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    return self;
}

#pragma mark - SBLocation

//

- (void)requestAuthorization:(BOOL)always {
    if (always) {
        [locationManager requestAlwaysAuthorization];
    } else {
        [locationManager requestWhenInUseAuthorization];
    }
    
    if ([self authorizationStatus] == SBLocationAuthorizationStatusUnimplemented)
    {
        NSLog(@"💀👿😡💀👿😡 ⚠️Please set \"NSLocationAlwaysUsageDescription\" or \"NSLocationWhenInUseUsageDescription\" in info.plist of your Application!!💀👿😡💀👿😡");
    }
}

//

- (void)startMonitoring:(NSArray*)regions {
    if (_isMonitoring) {
        [self stopMonitoring];
    }
    
    _isMonitoring = YES;
    
    sessions = [NSMutableDictionary new];
    monitoredRegions = [NSArray arrayWithArray:regions];
    //
    for (NSString *region in monitoredRegions) {
        [self startMonitoringForBeaconRegion:region];
    }
    //
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

- (void)stopMonitoring {
    if (!_isMonitoring) {
        return;
    }
    _isMonitoring = NO;
    for (CLRegion *region in locationManager.monitoredRegions.allObjects) {
        if ([region.identifier rangeOfString:kSBIdentifier].location!=NSNotFound) {
            [locationManager stopMonitoringForRegion:region];
            SBLog(@"Stopped monitoring for %@",region.identifier);
        }
    }
    //
}

- (void)startBackgroundMonitoring {
    [locationManager stopMonitoringSignificantLocationChanges];
//    [manager startMonitoringVisits];
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopBackgroundMonitoring {
    [locationManager stopMonitoringSignificantLocationChanges];
//    [manager stopMonitoringVisits];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    PUBLISH(({
        SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
        event.locationAuthorization = [self authorizationStatus];
        event;
    }));
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
    //    SBLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFinishDeferredUpdatesWithError:(nullable NSError *)error {
    //    SBLog(@"%s",__func__);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self checkRegionExitWithRegionUUID:[(CLBeaconRegion *)region proximityUUID].UUIDString inRegion:YES];
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region
{
    __block NSTimeInterval blockTimeinterval = lastRegionExitCheckTime;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didFindBeacons:beacons];
        
        if (/* time since state change > monitoringDelay */)
        {
            [self checkRegionExitWithRegionUUID:region.proximityUUID.UUIDString inRegion:YES];
        }
    });
    
    // save last timeinterval.
    lastRegionExitCheckTime = [NSDate date].timeIntervalSince1970;
    //
}

- (void)locationManager:(nonnull CLLocationManager *)manager didStartMonitoringForRegion:(nonnull CLRegion *)region {
    //    SBLog(@"%s: %@",__func__,region.identifier);
    //
    [locationManager requestStateForRegion:region];
    //
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading {
    //    SBLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    //    SBLog(@"%s: %@",__func__,locations);
    _gps = locations.lastObject;
}

- (void)locationManager:(nonnull CLLocationManager *)manager didVisit:(nonnull CLVisit *)visit {
    //    SBLog(@"%s: %@",__func__,visit);
}

- (void)locationManager:(nonnull CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(nonnull NSError *)error {
    //    SBLog(@"%s: %@" ,__func__, error);
}

- (void)locationManager:(nonnull CLLocationManager *)manager rangingBeaconsDidFailForRegion:(nonnull CLBeaconRegion *)region withError:(nonnull NSError *)error {
    //    SBLog(@"%s",__func__);
    //
    [self checkRegionExitWithRegionUUID:region.proximityUUID.UUIDString inRegion:YES];
}

- (void)locationManagerDidPauseLocationUpdates:(nonnull CLLocationManager *)manager {
    //    SBLog(@"%s",__func__);
}

- (void)locationManagerDidResumeLocationUpdates:(nonnull CLLocationManager *)manager {
    //    SBLog(@"%s",__func__);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(nonnull CLLocationManager *)manager {
    //    SBLog(@"%s",__func__);
    return NO;
}

#pragma mark - Location status

- (SBLocationAuthorizationStatus)authorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    SBLocationAuthorizationStatus authStatus;
    
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] &&
        ![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
        authStatus = SBLocationAuthorizationStatusUnimplemented;
        return authStatus;
    }
    //
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        {
            authStatus = SBLocationAuthorizationStatusRestricted;
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            authStatus = SBLocationAuthorizationStatusDenied;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            authStatus = SBLocationAuthorizationStatusAuthorized;
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            authStatus = SBLocationAuthorizationStatusAuthorized;
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        {
            authStatus = SBLocationAuthorizationStatusNotDetermined;
            break;
        }
    }
    //
    return authStatus;
}

//

#pragma mark SBEventApplicationActive
SUBSCRIBE(SBEventApplicationActive) {
    appActiveDate = [NSDate date];
}

#pragma mark - Helper methods

- (void)startMonitoringForBeaconRegion:(NSString *)region
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:region]];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[kSBIdentifier stringByAppendingPathExtension:region]];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    //
    if (isNull(beaconRegion)) {
        SBLog(@"❌ Invalid region: %@",region);
    } else {
        [locationManager startMonitoringForRegion:beaconRegion];
        //
        [locationManager startRangingBeaconsInRegion:beaconRegion];
        //
        SBLog(@"Starting monitoring for %@",beaconRegion.identifier);
    }
}

- (void)didFindBeacons:(NSArray <CLBeacon *> *)beacons
{
    if (!sessions)
    {
        sessions = [NSMutableDictionary new];
    }
    
    for (CLBeacon *clBeacon in beacons) {
        SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithCLBeacon:clBeacon];
        //
        SBMSession *session = [sessions objectForKey:sbBeacon.fullUUID];
        //
        if (isNull(session)) {
            session = [[SBMSession alloc] initWithUUID:sbBeacon.fullUUID];
            //
            SBEventRegionEnter *enter = [SBEventRegionEnter new];
            enter.beacon = [[SBMBeacon alloc] initWithCLBeacon:clBeacon];
            enter.rssi = [NSNumber numberWithInteger:clBeacon.rssi].intValue;
            enter.proximity = clBeacon.proximity;
            enter.accuracy = clBeacon.accuracy;
            enter.location = _gps;
            PUBLISH(enter);
            //
        }
        session.lastSeen = [NSDate date];
        //
        [sessions setObject:session forKey:sbBeacon.fullUUID];
        //
        if (clBeacon.proximity!=CLProximityUnknown) {
            PUBLISH(({
                SBEventRangedBeacon *event = [SBEventRangedBeacon new];
                event.beacon = sbBeacon;
                event.rssi = [NSNumber numberWithInteger:clBeacon.rssi].intValue;
                event.proximity = clBeacon.proximity;
                event.accuracy = clBeacon.accuracy;
                //
                event;
            }));
        }
        //
    }
}

// This method should be called in BackgroundMode.
- (void)checkRegionExitWithRegionUUID:(NSString *)UUID inRegion:(BOOL)inRegion lastCheckTimeintervalSince1970:(NSTimeInterval)lastDispatchTimeInterval
{
    static NSTimeInterval allowedTimeInterval = 0;
    NSTimeInterval currentTimeInterval = [NSDate date].timeIntervalSince1970;
    if (currentTimeInterval - lastDispatchTimeInterval > 3.0f)
    {
        allowedTimeInterval = currentTimeInterval + 4.0f;
    }
    
    if (currentTimeInterval >= allowedTimeInterval)
    {
        [self checkRegionExitWithRegionUUID:UUID inRegion:inRegion];
    }
}

- (void)checkRegionExitWithRegionUUID:(NSString *)UUID inRegion:(BOOL)inRegion
{
    
    float monitoringDelay = [[SBSettings sharedManager] settings].monitoringDelay;
    if (!isNull(appActiveDate) && ABS([appActiveDate timeIntervalSinceNow]) < monitoringDelay)
    {   // suppress the region check for kMonitoringDelay seconds after the app becomes active
        return;
    }
    
    NSString *proximityUUIDPrefix = [[NSString stripHyphensFromUUIDString:UUID] lowercaseString];
    for (SBMSession *session in sessions.allValues) {
        //
        BOOL needToCheck = NO;
        
        if (inRegion)
        {
            needToCheck = [session.pid hasPrefix:proximityUUIDPrefix];
        }
        else
        {
            needToCheck = ![session.pid hasPrefix:proximityUUIDPrefix];
        }
        
        if (!needToCheck)
        {
            continue;
        }
        
        NSTimeInterval timeGap = [NSDate date].timeIntervalSince1970 - session.lastSeen.timeIntervalSince1970;
        if (timeGap >= monitoringDelay)
        {
            session.exit = [NSDate date];
            //
            SBEventRegionExit *exit = [SBEventRegionExit new];
            exit.beacon = [[SBMBeacon alloc] initWithString:session.pid];
            exit.location = _gps;
            PUBLISH(exit);
            //
            [sessions removeObjectForKey:session.pid];
        }
    }
}

#pragma mark - Events

SUBSCRIBE(SBEventApplicationWillEnterForeground) {
    
}

SUBSCRIBE(SBEventApplicationDidEnterBackground) {
    
}

#pragma mark - For Unit Tests

- (NSDictionary *)currentSessions
{
    return [sessions copy];
}

@end
