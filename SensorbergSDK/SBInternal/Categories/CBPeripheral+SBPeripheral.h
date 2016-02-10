//
//  CBPeripheral+SBPeripheral.h
//  Pods
//
//  Created by Andrei Stoleru on 09/02/16.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (SBPeripheral)

@property (strong, nonatomic) NSNumber *eRSSI;

@end
