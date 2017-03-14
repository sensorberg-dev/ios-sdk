//
//  SBMagnetometer.m
//  Pods
//
//  Created by Andrei Stoleru on 09/02/17.
//
//

#import "SBMagnetometer.h"

@interface SBMagnetometer () {
    CMMotionManager *motionManager;
    
    NSOperationQueue *queue;
    
    BOOL isMonitoring;
    
    SBMagneticProximity oldProximity;
    
    double farValue;
    double nearValue;
    double immediateValue;
}
@end

@implementation SBMagnetometer

#pragma mark - SBMagnetometer

static SBMagnetometer * _sharedManager;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        queue = [NSOperationQueue new];
        queue.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return self;
}

#pragma mark - 

- (void)startMonitoring {
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
//        motionManager.magnetometerUpdateInterval = 1/5;
    }
    //
    if (!motionManager.magnetometerAvailable) {
        return;
    }
    //
    farValue = [[NSUserDefaults standardUserDefaults] doubleForKey:kSBMagnitudeFarKey];
    if (farValue<1) {
        farValue = kSBMagnitudeFar;
    }
    nearValue = [[NSUserDefaults standardUserDefaults] doubleForKey:kSBMagnitudeNearKey];
    if (nearValue<1) {
        nearValue = kSBMagnitudeNear;
    }
    immediateValue = [[NSUserDefaults standardUserDefaults] doubleForKey:kSBMagnitudeImmediateKey];
    if (immediateValue<1) {
        immediateValue = kSBMagnitudeImmediate;
    }
    //
    [motionManager setMagnetometerUpdateInterval:1/2];
    [motionManager startMagnetometerUpdatesToQueue:queue
                                       withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
                                           double magnitude = sqrt (pow(magnetometerData.magneticField.x,2)+
                                                                     pow(magnetometerData.magneticField.y,2)+
                                                                     pow(magnetometerData.magneticField.z,2));
                                           //
                                           SBMagneticProximity proximity;
                                           if (magnitude>immediateValue) {
                                               proximity = SBMagneticProximityImmediate;
                                           } else if (magnitude>nearValue) {
                                               proximity = SBMagneticProximityNear;
                                           } else if (magnitude>farValue) {
                                               proximity = SBMagneticProximityFar;
                                           } else {
                                               proximity = SBMagneticProximityUnknown;
                                           }
                                           //
//                                           if (oldProximity!=proximity) {
//                                               oldProximity = proximity;
//                                               PUBLISH(({
//                                                   SBEventMagnetometerUpdate *event = [SBEventMagnetometerUpdate new];
//                                                   event.proximity = proximity;
//                                                   event.rawMagnitude = magnitude;
//                                                   event;
//                                               }));
//                                           }
                                           
                                           PUBLISH(({
                                               SBEventMagnetometerUpdate *event = [SBEventMagnetometerUpdate new];
                                               event.proximity = proximity;
                                               event.rawMagnitude = magnitude;
                                               event;
                                           }));
                                           
                                       }];
    //
}

- (void)stopMonitoring {
    [motionManager stopMagnetometerUpdates];
}

- (CMMagnetometerData *)magnetometerData {
    return motionManager.magnetometerData;
}

- (SBMagneticProximity)magneticProximity {
    return oldProximity;
}

#pragma mark -

@end
