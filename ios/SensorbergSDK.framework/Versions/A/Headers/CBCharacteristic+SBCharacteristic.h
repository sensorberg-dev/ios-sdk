//
//  CBCharacteristic+SBCharacteristic.h
//  Pods
//
//  Created by Andrei Stoleru on 08/03/16.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "SBEnums.h"

@interface CBCharacteristic (SBCharacteristic)

- (BOOL)matchesUUID:(NSUInteger)uuid;

/**
 *  Helper method that returns a human-readable title for the CBCharacteristic
 *
 *  @return NSString human-readable value
 */
- (NSString *)title;

/**
 *  Helper method that returns a human-readable value for the CBCharacteristic
 *
 *  @return NSString human-readable value
 */
- (NSString*)detail;

- (BOOL)setCharacteristicValue:(NSData*)value;

// Helper method
- (void)logProperties;

@end
