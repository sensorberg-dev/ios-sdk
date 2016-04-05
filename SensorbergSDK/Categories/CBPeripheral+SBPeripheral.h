//
//  CBPeripheral+SBPeripheral.h
//  Pods
//
//  Created by Andrei Stoleru on 09/02/16.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "SBEnums.h"

@interface CBPeripheral (SBPeripheral)

- (SBFirmwareVersion)firmware;

- (BOOL)connectable;

- (BOOL)isConnected;

@property (strong, nonatomic) NSNumber      *rssi;
@property (strong, nonatomic) NSDate        *firstSeen;
@property (strong, nonatomic) NSDate        *lastSeen;
@property (strong, nonatomic) NSDictionary  *advertisementData;

@end
