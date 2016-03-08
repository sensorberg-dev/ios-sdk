//
//  CBCharacteristic+SBCharacteristic.m
//  Pods
//
//  Created by Andrei Stoleru on 08/03/16.
//
//

#import "CBCharacteristic+SBCharacteristic.h"

#import <objc/runtime.h>

@implementation CBCharacteristic (SBCharacteristic)

- (BOOL)matchesUUID:(NSUInteger)uuid {
    CBUUID *comp = [CBUUID UUIDWithData:[NSData dataWithBytes:&uuid length:16]];

    return ([self.UUID.UUIDString isEqualToString:comp.UUIDString]);
}

@end
