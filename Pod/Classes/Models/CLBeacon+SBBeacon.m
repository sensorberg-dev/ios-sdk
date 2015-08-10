//
//  CLBeacon+SBBeacon.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "CLBeacon+SBBeacon.h"

@implementation CLBeacon (SBBeacon)

- (BOOL)isEqualToBeacon:(CLBeacon *)otherBeacon {
    return ([self.proximityUUID.UUIDString isEqualToString:otherBeacon.proximityUUID.UUIDString] &&
            [self.major isEqualToNumber:otherBeacon.major] &&
            [self.minor isEqualToNumber:otherBeacon.minor]);
}

@end
