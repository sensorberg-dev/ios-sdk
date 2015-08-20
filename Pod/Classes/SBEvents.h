//
//  SBEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 12/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBResolver.h"
#import "SBUtility.h"
#import "SBLocation.h"
#import "SBBluetooth.h"

@interface SBEBluetoothAuthorization : NSObject
@property (nonatomic) SBBluetoothStatus bluetoothAuthorization;
@end

@interface SBEvents : NSObject

@end
