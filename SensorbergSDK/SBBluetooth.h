//
//  SBBluetooth.h
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import <Security/Security.h>

#import "SBEnums.h"

@class SensorbergSDK;

@interface SBBluetooth : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>

/**
 *  Singleton instance of the SBBluetooth, CoreBluetooth wrapper
 *
 *  @return SBBluetooth instance (singleton)
 */
+ (instancetype)sharedManager;

/**
 *  Discovered peripherals, with the UUID (peripheral identifier) as the key
 */
@property (strong, nonatomic, readonly) NSDictionary *peripherals;

/**
 *  @brief *!Important* Call this method before using any Bluetooth functionality
 *
 *  @since 2.0
 */
- (void)requestAuthorization;


/**
 *  @brief Returns a @SBBluetoothStatus value
 *
 *  @return One of SBBluetoothUnknown, SBBluetoothOff, SBBluetoothOn
 *
 *  @since 2.0
 */
- (SBBluetoothStatus)authorizationStatus;

/**
 *  @brief Start bluetooth scanning for the specific services.
 *
 *  @param services The services as a string array
 *
 *  @since 2.0
 */
- (void)scanForServices:(NSArray <NSString*>*)services;


/**
 *  @brief Attempts to connect to the specified peripheral. Will fire a SBEventConnectPeripheral event when there's an update
 *
 *  @param peripheral The CBPeripheral object
 *
 *  @since 2.0
 */
- (void)connectToPeripheral:(CBPeripheral*)peripheral;


/**
 *  @brief Attempts to provide a human-readable title for the CBCharacteristic object
 *
 *  @param characteristic A CBCharacteristic object
 *
 *  @return A string with the title of the CBCharacteristic or the UUID
 *
 *  @since 2.0
 */
- (NSString *)titleForCharacteristic:(CBCharacteristic *)characteristic;


/**
 *  @brief Attempts to provide a human-readable value for the CBCharacteristic object
 *
 *  @param characteristic A CBCharacteristic object
 *
 *  @return A string with the value of the CBCharacteristic or the UUID (This attempts to provide the correct value, independently of the value type and/or endianess
 *
 *  @since 2.0
 */
- (NSString *)valueForCharacteristic:(CBCharacteristic *)characteristic;


@end
