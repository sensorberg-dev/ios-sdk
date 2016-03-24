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

#import "SensorbergSDK.h"

#import "SBInternalEvents.h"

#import "SBInternalModels.h"

static float const kMonitoringDelay = 5.0f; // in seconds

@interface SBLocation() {
    CLLocationManager *manager;
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
    CLLocation *gps;
}

@end

@implementation SBLocation

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        //
        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            _iBeaconsAvailable = YES;
        }
    }
    return self;
}

#pragma mark - SBLocation

//

- (void)requestAuthorization {
    [manager requestAlwaysAuthorization];
}

//

- (void)startMonitoring:(NSArray*)regions {
    _isMonitoring = YES;
    //
    if (!self.iBeaconsAvailable) {
        return;
    }
    //
    monitoredRegions = [NSArray arrayWithArray:regions];
    //
    for (NSString *region in monitoredRegions) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:region]];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:region];
        //
        beaconRegion.notifyEntryStateOnDisplay = NO;
        //
        [beaconRegion setNotifyOnEntry:YES];
        [beaconRegion setNotifyOnExit:YES];
        //
        if (isNull(beaconRegion)) {
            SBLog(@"❌ Invalid region: %@",region);
        } else {
            [manager startMonitoringForRegion:beaconRegion];
            //
            [manager startRangingBeaconsInRegion:beaconRegion];
            //
            NSLog(@"Starting monitoring for %@",region);
            //
            [manager startUpdatingLocation];
            [manager startUpdatingHeading];
        }
    }
}

- (void)stopMonitoring {
    _isMonitoring = NO;
    for (NSString *region in monitoredRegions) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:region]];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:region];
        [manager stopMonitoringForRegion:beaconRegion];
        SBLog(@"Stoping monitoring for %@",region);
    }
}

- (void)startBackgroundMonitoring {
    [manager stopMonitoringSignificantLocationChanges];
    //
    [manager startMonitoringSignificantLocationChanges];
}

- (void)stopBackgroundMonitoring {
    [manager stopMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    PUBLISH(({
        SBEventLocationAuthorization *event = [SBEventLocationAuthorization new];
        event.locationAuthorization = [self authorizationStatus];
        event;
    }));
}

- (void)locationManager:(nonnull CLLocationManager *)locationManager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region {
    //
    if (state==CLRegionStateInside && [region isKindOfClass:[CLBeaconRegion class]]) {
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    //
    [self checkRegionExit];
}

- (void)locationManager:(nonnull CLLocationManager *)_manager didEnterRegion:(nonnull CLRegion *)region {
    //    SBLog(@"%s: %@",__func__,region.identifier);
    //
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:region.identifier]];
    if (uuid) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:region.identifier];
        [_manager startRangingBeaconsInRegion:beaconRegion];
    }
    //
    [self checkRegionExit];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    //    SBLog(@"%s: %@",__func__,region.identifier);
    //
    [self checkRegionExit];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
    //    SBLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFinishDeferredUpdatesWithError:(nullable NSError *)error {
    //    SBLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
    if (!sessions) {
        sessions = [NSMutableDictionary new];
    }
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        for (CLBeacon *clBeacon in beacons) {
            SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithCLBeacon:clBeacon];
            //
            PUBLISH(({
                SBEventRangedBeacon *event = [SBEventRangedBeacon new];
                event.beacon = sbBeacon;
                event.rssi = [NSNumber numberWithInteger:clBeacon.rssi].intValue;
                event.proximity = clBeacon.proximity;
                event.accuracy = clBeacon.accuracy;
                //
                event;
            }));
            //
            SBMSession *session = [sessions objectForKey:sbBeacon.fullUUID];
            //
            if (isNull(session)) {
                session = [[SBMSession alloc] initWithUUID:sbBeacon.fullUUID];
                //
                SBEventRegionEnter *enter = [SBEventRegionEnter new];
                enter.beacon = [[SBMBeacon alloc] initWithString:session.pid];
                enter.rssi = [NSNumber numberWithInteger:clBeacon.rssi].intValue;
                enter.proximity = clBeacon.proximity;
                enter.accuracy = clBeacon.accuracy;
                enter.location = gps;
                PUBLISH(enter);
                //
            } else {
                session.lastSeen = now;
                //
            }
            //
            [sessions setObject:session forKey:sbBeacon.fullUUID];
            //
        }
    });
    //
    [self checkRegionExit];
}

- (void)locationManager:(nonnull CLLocationManager *)locationManager didStartMonitoringForRegion:(nonnull CLRegion *)region {
    //    SBLog(@"%s: %@",__func__,region.identifier);
    //
    [manager requestStateForRegion:region];
    //
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading {
    //    SBLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    //    SBLog(@"%s: %@",__func__,locations);
    gps = locations.lastObject;
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
    [self checkRegionExit];
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
    
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
        authStatus = SBLocationAuthorizationStatusUnimplemented;
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
    appActiveDate = now;
}

#pragma mark - Helper methods

- (void)checkRegionExit {
    if (!isNull(appActiveDate) && ABS([appActiveDate timeIntervalSinceNow])<kMonitoringDelay) { // suppress the region check for kMonitoringDelay seconds after the app becomes active
        return;
    }
    //
    for (SBMSession *session in sessions.allValues) {
        //
        if (ABS([session.lastSeen timeIntervalSinceNow])>=kMonitoringDelay) {
            session.exit = now;
            //
            SBEventRegionExit *exit = [SBEventRegionExit new];
            exit.beacon = [[SBMBeacon alloc] initWithString:session.pid];
            exit.location = gps;
            PUBLISH(exit);
            //
            [sessions removeObjectForKey:session.pid];
        }
    }
}

@end
