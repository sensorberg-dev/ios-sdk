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

#import "SBEvent.h"

#import "SBInternalModels.h"

#import "SBSettings.h"

#import <objc_geohash/GeoHash.h>

@interface SBLocation() {
    CLLocationManager *locationManager;
    //
    NSMutableDictionary *monitoredRegions;
    NSArray *rawRegions;
    //
    NSMutableDictionary *sessions;
    
    BOOL pendingLocation;
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
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.distanceFilter = [SBSettings sharedManager].settings.monitoredRadius;
        //
        sessions = [NSMutableDictionary new];
        //
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
}

#pragma mark - External methods

- (void)requestAuthorization:(BOOL)always {
    if (![CLLocationManager locationServicesEnabled]) {
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = SBLocationAuthorizationStatusUnavailable;
            event;
        }));
        return;
    }
    //
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] && ![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = SBLocationAuthorizationStatusUnavailable;
            event;
        }));
        return;
    }
    //
    if (always) {
        [locationManager requestAlwaysAuthorization];
    } else {
        [locationManager requestWhenInUseAuthorization];
    }
    //
    if ([self authorizationStatus] == SBLocationAuthorizationStatusUnimplemented) {
        PUBLISH(({
            SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
            event.locationAuthorization = SBLocationAuthorizationStatusUnimplemented;
            event;
        }));
        //
        SBLog(@"Please set \"NSLocationAlwaysUsageDescription\" or \"NSLocationWhenInUseUsageDescription\" in info.plist of your Application!!");
    }
}

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

- (void)startMonitoring:(NSArray *)regions {
    _isMonitoring = YES;
    //
    [locationManager startUpdatingLocation];
    SBLog(@"Location updates enabled");
    //
    if (regions.count==0) {
        return;
    }
    //
    rawRegions = [NSArray arrayWithArray:regions];
    //
    if (!_gps) {
        pendingLocation = YES;
        return;
    }
    //
    [self sortAndMatchRegions];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    PUBLISH(({
        SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
        event.locationAuthorization = [self authorizationStatus];
        event;
    }));
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    SBLog(@"Entered region %@", region.identifier);
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    } else if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self updateSessionsWithGeofences:@[region]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    SBLog(@"Exit region %@", region.identifier);
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self checkRegionExit];
    } else if ([region isKindOfClass:[CLCircularRegion class]]) {
        NSString *geohash = region.identifier.pathExtension;
        if (geohash.length==14) {
            PUBLISH(({
                SBEventRegionExit *exit = [SBEventRegionExit new];
                exit.beacon = [[SBMGeofence alloc] initWithGeoHash:geohash];
                exit.location = _gps;
                exit;
            }));
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count) {
        [self updateSessionsWithBeacons:beacons];
    }
    //
    [self checkRegionExit];
    //
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
//    SBLog(@"LM Monitoring failed for %@", region.identifier);
    [self handleLocationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    [self handleLocationError:error];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    SBLog(@"Location events paused");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    SBLog(@"Location events resumed");
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]] && state == CLRegionStateInside) {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    if (!currentLocation) {
        return;
    }
    //
    if (currentLocation.horizontalAccuracy<0 || currentLocation.horizontalAccuracy>[SBSettings sharedManager].settings.monitoredRadius) {
        return;
    }
    //
    if ([currentLocation distanceFromLocation:_gps]>[SBSettings sharedManager].settings.monitoredRadius) {
        PUBLISH(({
            SBEventLocationUpdated *event = [SBEventLocationUpdated new];
            event.location = currentLocation;
            event;
        }));
    }
    //
    _gps = currentLocation;
    if (pendingLocation) {
        pendingLocation = NO;
        [self sortAndMatchRegions];
    }
    //
    if ([SBSettings sharedManager].settings.activeTracking==NO) {
        SBLog(@"Location events disabled");
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self handleLocationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    [self handleLocationError:error];
}

#pragma mark - Internal methods

- (void)updateSessionsWithGeofences:(NSArray *)geofences {
    for (CLCircularRegion *region in geofences) {
        NSString *regionID = region.identifier.pathExtension;
        //
        SBMSession *session = [sessions objectForKey:regionID];
        if (!session) {
            session = [[SBMSession alloc] initWithId:regionID];
            if (regionID.length==14) {
                PUBLISH(({
                    SBEventRegionEnter *enter = [SBEventRegionEnter new];
                    enter.beacon = [[SBMGeofence alloc] initWithGeoHash:region.identifier.pathExtension];
                    enter.location = _gps;
                    enter.accuracy = _gps.horizontalAccuracy;
                    enter.pairingId = session.pairingId;
                    enter;
                }));
            }
        }
        //
        session.lastSeen = [[NSDate date] timeIntervalSince1970];
        if (session.exit) {
            session.exit = 0;
        }
        //
        [sessions setObject:session forKey:regionID];
        //
    }
}

- (void)updateSessionsWithBeacons:(NSArray *)beacons {
    if (!sessions) {
        sessions = [NSMutableDictionary new];
    }
    
    for (CLBeacon *beacon in beacons) {
        SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithCLBeacon:beacon];
        
        SBMSession *session = [sessions objectForKey:sbBeacon.tid];
        if (!session) {
            session = [[SBMSession alloc] initWithId:sbBeacon.tid];
            // Because we don't have a session with this beacon, let's fire an SBEventRegionEnter event
            PUBLISH(({
                SBEventRegionEnter *enter = [SBEventRegionEnter new];
                enter.beacon = sbBeacon;
                enter.rssi = [NSNumber numberWithInteger:beacon.rssi].intValue;
                enter.proximity = beacon.proximity;
                enter.accuracy = beacon.accuracy;
                enter.location = _gps;
                enter.pairingId = session.pairingId;
                enter;
            }));
        }
        session.lastSeen = [[NSDate date] timeIntervalSince1970];
        if (session.exit) {
            session.exit = 0;
        }
        //
        [sessions setObject:session forKey:sbBeacon.tid];
        //
        if (beacon.proximity!=CLProximityUnknown) {
            PUBLISH(({
                SBEventRangedBeacon *event = [SBEventRangedBeacon new];
                event.beacon = sbBeacon;
                event.rssi = [NSNumber numberWithInteger:beacon.rssi].intValue;
                event.proximity = beacon.proximity;
                event.accuracy = beacon.accuracy;
                event.pairingId = session.pairingId;
                event;
            }));
        }
    }
}

- (void)checkRegionExit {
    //
    NSTimeInterval monitoringDelay = [SBSettings sharedManager].settings.monitoringDelay;
    NSTimeInterval rangingDelay = [SBSettings sharedManager].settings.rangingSuppression;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    for (SBMSession *session in sessions.allValues) {
        if (session.lastSeen + monitoringDelay <= now ) {
            if (session.exit<=0) {
                SBLog(@"Setting exit for %@", session.pid);
                session.exit = now;
            } else if ( session.exit + rangingDelay <= now ) {
                PUBLISH(({
                    SBEventRegionExit *exit = [SBEventRegionExit new];
                    if (session.pid.length==14) {
                        exit.beacon = [[SBMGeofence alloc] initWithGeoHash:session.pid];
                    } else if (session.pid.length==42) {
                        exit.beacon = [[SBMBeacon alloc] initWithString:session.pid];
                    }
                    exit.location = _gps;
                    exit.pairingId = session.pairingId;
                    exit;
                }));
            }
        }
    }
}

- (void)startMonitoringForBeaconRegion:(SBMTrigger *)region {
    NSUUID *uuid;
    CLBeaconRegion *beaconRegion;
    //
    if ([region isKindOfClass:[SBMRegion class]]) {
        uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:region.tid]];
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[kSBIdentifier stringByAppendingPathExtension:region.tid]];
    } else if ([region isKindOfClass:[SBMBeacon class]]) {
        uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:[(SBMBeacon*)region uuid]]];
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                               major:[(SBMBeacon*)region major]
                                                               minor:[(SBMBeacon*)region minor]
                                                          identifier:[kSBIdentifier stringByAppendingPathExtension:region.tid]];
    }
    [locationManager startMonitoringForRegion:beaconRegion];
}

- (void)startMonitoringForGeoRegion:(SBMGeofence *)region {
    CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(region.latitude, region.longitude) radius:region.radius identifier:[kSBIdentifier stringByAppendingPathExtension:region.tid]];
    [locationManager startMonitoringForRegion:circularRegion];
}

- (void)stopMonitoring {
    for (CLRegion *region in locationManager.monitoredRegions.allObjects) {
        if ([region.identifier rangeOfString:kSBIdentifier].location!=NSNotFound) {
            [locationManager stopMonitoringForRegion:region];
            SBLog(@"Stopped monitoring for %@",region.identifier);
        }
    }
}

- (void)handleLocationError:(NSError *)error {
    if (isNull(error)) {
        return;
    }
    SBLog(@"Location error: %@", error);
    switch (error.code) {
        case kCLErrorDenied: {
            // user denied!
            break;
        }
        case kCLErrorRangingUnavailable: {
            // airplane mode, location or bluetooth unavailable!
            break;
        }
        case kCLErrorRegionMonitoringDenied: {
            // user denied access to region monitoring!
            break;
        }
        case kCLErrorRegionMonitoringSetupDelayed: {
            // region monitoring was delayed
            break;
        }
        case kCLErrorRegionMonitoringFailure: {
            // failed to start monitoring for a region (too many monitored regions or radius of geofence is too high
            break;
        }
        case kCLErrorRangingFailure: {
            // general ranging error
            break;
        }
        case kCLErrorRegionMonitoringResponseDelayed: {
            SBLog(@"Alternate region: %@",kCLErrorUserInfoAlternateRegionKey);
            break;
        }
        default:
            break;
    }
}

- (void)sortAndMatchRegions {
    NSMutableSet *triggers = [NSMutableSet new];
    NSMutableSet *beaconRegions = [NSMutableSet new];
    NSMutableSet *geofences = [NSMutableSet new];
    NSMutableSet *beacons = [NSMutableSet new];
    //
    for (NSString *region in rawRegions) {
        if (region.length==14) {
            SBMGeofence *fence = [[SBMGeofence alloc] initWithGeoHash:region];
            if (!isNull(fence)) {
                [triggers addObject:fence];
                [geofences addObject:fence];
            }
        } else if (region.length==32) {
            SBMRegion *beacon = [[SBMRegion alloc] initWithString:region];
            if (!isNull(beacon)) {
                [triggers addObject:beacon];
                [beaconRegions addObject:beacon];
            }
        } else if (region.length==42) {
            SBMBeacon *beacon = [[SBMBeacon alloc] initWithString:region];
            if (!isNull(beacon)) {
                [triggers addObject:beacon];
                [beacons addObject:beacon];
            }
        }
    }
    //
    if (triggers.count < kSBMaxMonitoringRegionCount) {
        // if we have less that 20 regions, we don't need to do any tricks
        monitoredRegions = [NSMutableDictionary new];
        for (SBMTrigger *t in triggers) {
            [monitoredRegions setObject:t forKey:t.tid];
        }
    } else {
        // we add the beacon regions first
        monitoredRegions = [NSMutableDictionary new];
        for (SBMTrigger *t in beaconRegions) {
            [monitoredRegions setObject:t forKey:t.tid];
        }
        // we sort geofences by distance from us
        NSMutableArray *locations = [NSMutableArray arrayWithArray:[self sortGeolocations:geofences.allObjects]];
        // and build our monitoredRegions
        while (monitoredRegions.allKeys.count<kSBMaxMonitoringRegionCount && locations.count>0) {
            SBMTrigger *trigger = [locations firstObject];
            if (trigger) {
                [locations removeObject:trigger];
                [monitoredRegions setObject:trigger forKey:trigger.tid];
            }
        }
    }
    // we remove already monitored regions
    NSArray *regionIDs = [NSArray arrayWithArray:locationManager.monitoredRegions.allObjects];
    for (CLRegion *region in regionIDs) {
        NSString *rid = region.identifier.pathExtension;
        if (!isNull([monitoredRegions valueForKey:rid])) {
            [monitoredRegions removeObjectForKey:rid];
            [locationManager requestStateForRegion:region];
        } else {
            SBLog(@"We'll stop monitoring for %@", rid);
            [locationManager stopMonitoringForRegion:region];
        }
    }
    //
    SBLog(@"We'll start monitoring for %@", monitoredRegions.allKeys);
    // we start monitoring for the remaining regions
    for (SBMTrigger *trigger in monitoredRegions.allValues) {
        if ([trigger isKindOfClass:[SBMGeofence class]]) {
            [self startMonitoringForGeoRegion:(SBMGeofence *)trigger];
        } else if ([trigger isKindOfClass:[SBMRegion class]] || ([trigger isKindOfClass:[SBMBeacon class]])) {
            [self startMonitoringForBeaconRegion:trigger];
        }
    }
}

- (NSArray *)sortGeolocations:(NSArray *)locations {
    CLLocation *currentLocation = _gps;
    //
    NSArray *sorted = [locations sortedArrayUsingComparator:^NSComparisonResult(SBMGeofence *location1, SBMGeofence *location2) {
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:location1.latitude longitude:location1.longitude];
        
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location2.latitude longitude:location2.longitude];
        
        if ([currentLocation distanceFromLocation:loc1] < [currentLocation distanceFromLocation:loc2]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return sorted;
}

#pragma mark - Events
#pragma mark SBEventApplicationWillEnterForeground
SUBSCRIBE(SBEventApplicationWillEnterForeground) {
    if ([SBManager sharedManager].locationAuthorization==SBLocationAuthorizationStatusAuthorized) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [locationManager stopMonitoringSignificantLocationChanges];
            SBLog(@"Significant location events disabled");
        }
    }
}

#pragma mark SBEventApplicationDidEnterBackground
SUBSCRIBE(SBEventApplicationDidEnterBackground) {
    if ([SBManager sharedManager].locationAuthorization==SBLocationAuthorizationStatusAuthorized) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [locationManager startMonitoringSignificantLocationChanges];
            SBLog(@"Significant location events enabled");
        }
    }
}

SUBSCRIBE(SBEventRegionExit) {
    [sessions removeObjectForKey:event.beacon.tid];
    SBLog(@"Session closed for %@", event.beacon.tid);
}

#pragma mark - For Unit Tests

- (NSDictionary *)currentSessions {
    return [sessions copy];
}

@end
