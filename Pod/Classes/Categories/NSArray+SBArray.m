//
//  NSArray+SBArray.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "NSArray+SBArray.h"

@implementation NSArray (SBArray)

- (BOOL)containsString:(NSString *)aString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self];
    
    return [predicate evaluateWithObject:aString];
}

- (BOOL)containsBeacon:(CLBeacon *)beacon {
    BOOL found = NO;
    for (id item in self) {
        if ([item isKindOfClass:[CLBeacon class]]) {
            CLBeacon *b = (CLBeacon*)item;
            if ([b.proximityUUID.UUIDString isEqualToString:beacon.proximityUUID.UUIDString]) {
                found = YES;
            }
        }
    }
    return found;
}

@end
