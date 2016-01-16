//
//  SBCoreBluetooth.h
//  BeaConfig
//
//  Created by andsto on 11/01/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import <CoreLocation/CoreLocation.h>

#import "SBEvent.h"

#import <tolo/Tolo.h>

#pragma mark iBKS105

//#define kUUID           [CBUUID UUIDWithString:@"FFF1"]
//#define kMajor          [CBUUID UUIDWithString:@"FFF2"]
//#define kMinor          [CBUUID UUIDWithString:@"FFF3"]
//
//#define kPower          [CBUUID UUIDWithString:@"FFF4"]
//#define kInterval       [CBUUID UUIDWithString:@"FFF5"]
//#define kTxPower        [CBUUID UUIDWithString:@"FFF6"]
//
//#define kPassword       [CBUUID UUIDWithString:@"FFF7"]
//#define kConfig         [CBUUID UUIDWithString:@"FFF8"]
//#define kState          [CBUUID UUIDWithString:@"FFF9"]

//typedef enum : NSUInteger {
//    kUUID = 0xFFF1,
//    kMajor = 0xFFF2,
//    kMinor = 0xFF3,
//    kPower = 0xFF4,
//    kInternal = 0xFF5,
//    kTxPower  = 0xFF6,
//    kPassword = 0xFFF7,
//    kConfig = 0xFFF8,
//    kState = 0xFFF9,
//} kServiceIDs105;

#define kManufacturer           [CBUUID UUIDWithString:@"2A29"]
#define kSerialNumber           [CBUUID UUIDWithString:@"2A25"]
#define kHardwareRev            [CBUUID UUIDWithString:@"2A27"]
#define kSoftwareRev            [CBUUID UUIDWithString:@"2A28"]

#define kUUID                   [CBUUID UUIDWithString:@"FFF1"]
#define kMajor                  [CBUUID UUIDWithString:@"FFF2"]
#define kMinor                  [CBUUID UUIDWithString:@"FFF3"]

#define kPower                  [CBUUID UUIDWithString:@"FFF4"]
#define kInterval               [CBUUID UUIDWithString:@"FFF5"]
#define kTxPower                [CBUUID UUIDWithString:@"FFF6"]

#define kPassword               [CBUUID UUIDWithString:@"FFF7"]
#define kConfig                 [CBUUID UUIDWithString:@"FFF8"]
#define kState                  [CBUUID UUIDWithString:@"FFF9"]


@interface SBEventUpdateDevice : SBEvent
@property (strong, nonatomic) NSString *key;
@end

@interface SBEventUpdateServices : SBEvent
@property (strong, nonatomic) NSString *key;
@end

@interface SBEventUpdateCharacteristics : SBEvent
@property (strong, nonatomic) NSString *key;
@end

@interface SBEventWriteCharacteristic : SBEvent
@property (strong, nonatomic) NSString *key;
@end

@interface SBEventConnectPeripheral : SBEvent
@property (strong, nonatomic) NSString *key;
@end

@interface SBCoreBluetooth : NSObject <CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>

/**
 *  Singleton instance of the CoreBluetooth Central manager
 *
 *  @return SBCoreBluetooth instance (singleton)
 */
+ (instancetype)sharedManager;

/**
 *  A (read-only) dictionary containing the discovered peripherals with the UUID of each peripheral as the key
 */
@property (strong, nonatomic, readonly) NSMutableDictionary *peripherals;


/**
 *  Connect to a specific peripheral to
 *
 *  @param peripheral A CBPeripheral object to which to attempt connection
 */
- (void)connectToPeripheral:(CBPeripheral*)peripheral;

@end
