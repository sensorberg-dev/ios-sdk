//
//  SBEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 12/08/15.
//
//

#import <Foundation/Foundation.h>

#import "SBResolver.h"
#import "SBUtility.h"
#import "SBLocation.h"
#import "SBBluetooth.h"

@interface SBELocationAuthorization : NSObject
@property (nonatomic) SBLocationAuthorizationStatus locationAuthorization;
@end

@interface SBEBluetoothAuthorization : NSObject
@property (nonatomic) SBBluetoothStatus bluetoothAuthorization;
@end

@interface SBEvents : NSObject

@end
