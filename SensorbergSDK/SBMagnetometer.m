//
//  SBMagnetometer.m
//  Pods
//
//  Created by Andrei Stoleru on 09/02/17.
//
//

#import "SBMagnetometer.h"

#import "SBEvent.h"

@interface SBMagnetometer () {
    CMMotionManager *motionManager;
    
    CMDeviceMotion *deviceManager;
    
    CMCalibratedMagneticField field;
    
    NSOperationQueue *queue;
    
    BOOL isMonitoring;
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
        
//        [motionManager devi
    }
    //
    switch (field.accuracy) {
        case CMMagneticFieldCalibrationAccuracyLow:
        {
            NSLog(@"LOW");
            break;
        }
        case CMMagneticFieldCalibrationAccuracyMedium:
        {
            NSLog(@"MEDIUM");
            break;
        }
        case CMMagneticFieldCalibrationAccuracyHigh:
        {
            NSLog(@"HIGH");
            break;
        }
        case CMMagneticFieldCalibrationAccuracyUncalibrated: {
            NSLog(@"UNCALIBRATED");
            break;
        }
        default:
            break;
    }
    //
    if (!motionManager.magnetometerAvailable) {
        return;
    }
    //
    [motionManager startMagnetometerUpdates];
    [motionManager startMagnetometerUpdatesToQueue:queue
                                       withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
                                           PUBLISH(({
                                               SBEventMagnetometerUpdate *event = [SBEventMagnetometerUpdate new];
                                               event.field = magnetometerData.magneticField;
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

#pragma mark -

@end
