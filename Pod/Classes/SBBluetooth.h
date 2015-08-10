//
//  SBBluetooth.h
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import <Security/Security.h>

@interface SBBluetooth : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>

@end
