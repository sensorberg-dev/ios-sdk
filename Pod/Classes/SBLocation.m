//
//  SBLocation.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 28/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBLocation.h"

static float const kFilteringFactor = 0.3f;

@implementation SBLocation

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        // check if the text is present in the plist file
        [manager requestAlwaysAuthorization];
        //
    }
    return self;
}

#pragma mark - SBLocation

- (void)startMonitoring:(NSArray*)regions {
    
    monitoredRegions = [NSArray arrayWithArray:regions];
    //
    if (monitoredRegions.count>20) {
        // iOS limits the number of regions that can be monitored to 20!
    }
    //
    for (NSString *region in monitoredRegions) {
        NSUUID *regionUUID = [[NSUUID alloc] initWithUUIDString:region];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID identifier:region];
        [manager startRangingBeaconsInRegion:beaconRegion];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s",__func__);
    //
    if ([self authorizationStatus]==SBSDKLocationAuthorizationStatusAuthorized) {
        if (monitoredRegions && monitoredRegions.count) {
            [self startMonitoring:monitoredRegions];
        }
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFinishDeferredUpdatesWithError:(nullable NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
    NSLog(@"%s",__func__);
    //
    if (prox) {
        prox = [self lowPass:prox newValue:beacons.firstObject.rssi];
    } else {
        prox = beacons.firstObject.rssi;
    }
    NSLog(@"prox: %.2f",prox);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didStartMonitoringForRegion:(nonnull CLRegion *)region {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didVisit:(nonnull CLVisit *)visit {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(nonnull NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)locationManager:(nonnull CLLocationManager *)manager rangingBeaconsDidFailForRegion:(nonnull CLBeaconRegion *)region withError:(nonnull NSError *)error {
    NSLog(@"%s",__func__);
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

- (SBSDKLocationAuthorizationStatus)authorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            return SBSDKLocationAuthorizationStatusUnimplemented;
        }
    }
    
    switch (status) {
        case kCLAuthorizationStatusRestricted:
            return SBSDKLocationAuthorizationStatusRestricted;
            
        case kCLAuthorizationStatusDenied:
            return SBSDKLocationAuthorizationStatusDenied;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            return SBSDKLocationAuthorizationStatusAuthorized;
            
        default:
            break;
    }
    
    return SBSDKLocationAuthorizationStatusNotDetermined;
}

#pragma mark - Helper methods

- (float)lowPass:(float)oldValue newValue:(float)newValue {
    float result = (newValue * kFilteringFactor) + (oldValue * (1.0 - kFilteringFactor));
    //
    return result;
}

@end
