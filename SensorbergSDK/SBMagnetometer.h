//
//  SBMagnetometer.h
//  Pods
//
//  Created by Andrei Stoleru on 09/02/17.
//
//

#import <Foundation/Foundation.h>

#import <CoreMotion/CoreMotion.h>

#import <tolo/Tolo.h>

#import "SBEvent.h"

@interface SBMagnetometer : NSObject

+ (instancetype)sharedManager;

- (void)startMonitoring;

- (void)stopMonitoring;

- (SBMagneticProximity)magneticProximity;

@property (readonly) CMMagnetometerData *magnetometerData;

@end
