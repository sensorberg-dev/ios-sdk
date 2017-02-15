//
//  SBMagnetometer.m
//  Pods
//
//  Created by Andrei Stoleru on 09/02/17.
//
//

#import "SBMagnetometer.h"

typedef enum : NSUInteger {
    kSBMagnitudeFar = 2000,
    kSBMagnitudeNear = 3000,
    kSBMagnitudeImmediate = 4000,
} kSBMagnitudeLevels;

@interface SBMagnetometer () {
    CMMotionManager *motionManager;
    
    NSOperationQueue *queue;
    
    BOOL isMonitoring;
    
    SBMagneticProximity oldProximity;
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
        motionManager.magnetometerUpdateInterval = 1/5;
    }
    //
    if (!motionManager.magnetometerAvailable) {
        return;
    }
    //
    [motionManager setMagnetometerUpdateInterval:1/60];
    [motionManager startMagnetometerUpdatesToQueue:queue
                                       withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
                                           double magnitude = sqrt (pow(magnetometerData.magneticField.x,2)+
                                                                     pow(magnetometerData.magneticField.y,2)+
                                                                     pow(magnetometerData.magneticField.z,2));
                                           //
                                           SBMagneticProximity proximity;
                                           if (magnitude>kSBMagnitudeImmediate) {
                                               proximity = SBMagneticProximityImmediate;
                                           } else if (magnitude>kSBMagnitudeNear) {
                                               proximity = SBMagneticProximityNear;
                                           } else if (magnitude>kSBMagnitudeFar) {
                                               proximity = SBMagneticProximityFar;
                                           } else {
                                               proximity = SBMagneticProximityUnknown;
                                           }
                                           
                                           
                                           
                                           if (oldProximity!=proximity) {
                                               oldProximity = proximity;
                                               PUBLISH(({
                                                   SBEventMagnetometerUpdate *event = [SBEventMagnetometerUpdate new];
                                                   event.proximity = proximity;
                                                   event;
                                               }));
                                           }
                                           
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
