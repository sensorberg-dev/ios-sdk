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

@property (strong, nonatomic) NSNumber *eRSSI;

- (SBFirmwareVersion)firmware;

@end
