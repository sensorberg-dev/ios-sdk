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
    }
    //
    isMonitoring = YES;
    //
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
    isMonitoring = NO;
    //
    [motionManager stopMagnetometerUpdates];
}

#pragma mark - Events

SUBSCRIBE(SBEventApplicationActive) {
    if (isMonitoring) {
        [self startMonitoring];
    }
}

SUBSCRIBE(SBEventApplicationWillResignActive) {
    if (isMonitoring) {
        [self stopMonitoring];
        isMonitoring = YES;
    }
}

@end
