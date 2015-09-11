//
//  SBLocation.m
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

#import "SBLocation.h"

#import "NSString+SBUUID.h"

#import "SBMSession.h"

#import "SBLocationEvents.h"

#define now         [NSDate date]

static float const kFilteringFactor = 0.3f;

static float const kMonitoringDelay = 0.1*60.0f; // in seconds

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
    
    if (!self.iBeaconsAvailable) {
        return;
    }
    
    monitoredRegions = [NSArray arrayWithArray:regions];
    //
    if (monitoredRegions.count>20) {
        // iOS limits the number of regions that can be monitored to 20!
    }
    //
    for (NSString *region in monitoredRegions) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:region]];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:region];
        //
        beaconRegion.notifyEntryStateOnDisplay = YES;
        //
        [beaconRegion setNotifyOnEntry:YES];
        [beaconRegion setNotifyOnExit:YES];
        //
        if (beaconRegion) {
            [manager startMonitoringForRegion:beaconRegion];
            //
            [manager startRangingBeaconsInRegion:beaconRegion];
            //
        } else {
            NSLog(@"invalid region: %@",beaconRegion);
        }
    }
}

//

- (void)startBackgroundMonitoring {
    [manager stopMonitoringSignificantLocationChanges];
    //
    [manager startMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    PUBLISH(({
        SBELocationAuthorization *event = [SBELocationAuthorization new];
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
    NSLog(@"%s: %@",__func__,region.identifier);
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
    NSLog(@"%s: %@",__func__,region.identifier);
    //
    [self checkRegionExit];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFinishDeferredUpdatesWithError:(nullable NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        for (CLBeacon *clBeacon in beacons) {
            SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithCLBeacon:clBeacon];
            //
            PUBLISH(({
                SBERangedBeacons *event = [SBERangedBeacons new];
                event.beacon = sbBeacon;
                event.rssi = clBeacon.rssi;
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
                SBERegionEnter *enter = [SBERegionEnter new];
                enter.fullUUID = session.pid;
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
    if (!sessions) {
        sessions = [NSMutableDictionary new];
    }
    //
    [self checkRegionExit];
}

- (void)locationManager:(nonnull CLLocationManager *)locationManager didStartMonitoringForRegion:(nonnull CLRegion *)region {
//    NSLog(@"%s: %@",__func__,region.identifier);
    //
    [manager requestStateForRegion:region];
    //
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    NSLog(@"%s: %@",__func__,locations);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didVisit:(nonnull CLVisit *)visit {
    NSLog(@"%s: %@",__func__,visit);
}

- (void)locationManager:(nonnull CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(nonnull NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager rangingBeaconsDidFailForRegion:(nonnull CLBeaconRegion *)region withError:(nonnull NSError *)error {
    NSLog(@"%s",__func__);
    //
    [self checkRegionExit];
}

- (void)locationManagerDidPauseLocationUpdates:(nonnull CLLocationManager *)manager {
    NSLog(@"%s",__func__);
}

- (void)locationManagerDidResumeLocationUpdates:(nonnull CLLocationManager *)manager {
    NSLog(@"%s",__func__);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(nonnull CLLocationManager *)manager {
    NSLog(@"%s",__func__);
    return NO;
}

#pragma mark - Location status

- (SBLocationAuthorizationStatus)authorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    SBLocationAuthorizationStatus authStatus;
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            authStatus = SBLocationAuthorizationStatusUnimplemented;
            //
            NSLog(@"ERROR");
        }
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
        default:
        {
            authStatus = SBLocationAuthorizationStatusNotDetermined;
            break;
        }
    }
    //
    return authStatus;
}

//

#pragma mark - Helper methods

- (float)lowPass:(float)oldValue newValue:(float)newValue {
    float result = (newValue * kFilteringFactor) + (oldValue * (1.0 - kFilteringFactor));
    //
    return result;
}

- (void)checkRegionExit {
    for (SBMSession *session in sessions.allValues) {
        //
        if ([now timeIntervalSinceDate:session.lastSeen]>=kMonitoringDelay) {
            session.exit = now;
            //
            SBERegionExit *exit = [SBERegionExit new];
            exit.fullUUID = session.pid;
            PUBLISH(exit);
            //
            [sessions removeObjectForKey:session.pid];
        }
    }
}

@end
