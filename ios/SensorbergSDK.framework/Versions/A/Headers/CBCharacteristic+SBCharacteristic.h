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

/**
 *  Helper method to set the value of a CBCharacteristic
 *
 *  @param value A NSData object containing the new value for the CBCharacteristic
 *
 *  @return Returns YES if the CBCharacteristic is writable, NO otherwise. A different - SBEventCharacteristicWrite - is fired after the write process
 */
- (BOOL)setCharacteristicValue:(NSData*)value;

// Helper method
- (void)logProperties;

@end
