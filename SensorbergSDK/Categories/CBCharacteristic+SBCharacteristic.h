//
//  CBCharacteristic+SBCharacteristic.h
//  Pods
//
//  Created by Andrei Stoleru on 08/03/16.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBCharacteristic (SBCharacteristic)

- (BOOL)matchesUUID:(NSUInteger)uuid;

@end
