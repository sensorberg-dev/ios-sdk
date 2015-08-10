//
//  CLBeacon+SBBeacon.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLBeacon (SBBeacon)

/**
 Compares two instances of CLBeacon.
 
 @param otherBeacon Beacon object to compare against.
 
 @return YES or NO.
 */
- (BOOL)isEqualToBeacon:(CLBeacon *)otherBeacon;

@end
