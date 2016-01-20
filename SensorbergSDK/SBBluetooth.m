//
//  SBBluetooth.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
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

#import "SBBluetooth.h"

#import "SBInternalEvents.h"

#import "SensorbergSDK.h"

#import "NSData+CBValue.h"

#import <tolo/Tolo.h>

@interface SBBluetooth() {
    CBCentralManager *manager;
    
    BOOL scanning;
    
    NSMutableDictionary *devices;
    NSMutableDictionary *timestamps;
    NSMutableDictionary *rssi;
}

@end

@implementation SBBluetooth

#pragma mark - SBBluetooth

static SBBluetooth * _sharedManager;

static dispatch_once_t once;

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        //
        dispatch_once(&once, ^ {
            _sharedManager = [[self alloc] init];
        });
        //
    }
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _peripherals = [NSDictionary new];
        devices = [NSMutableDictionary new];
        timestamps = [NSMutableDictionary new];
        rssi = [NSMutableDictionary new];
    }
    return self;
}

- (void)requestAuthorization {
    [self centralManagerDidUpdateState:manager];
}

#pragma mark - External methods

- (void)scanForServices:(NSArray*)services {
    if (!services) {
        NSMutableArray *_services = [NSMutableArray new];
        
        for (NSString *serviceNumber in [self defaultServices]) {
            CBUUID *service = [CBUUID UUIDWithString:serviceNumber];
            if (!isNull(service)) {
                [_services addObject:service];
            }
        }
        
        services = [NSArray arrayWithArray:_services];
    } else if (services.count==0) {
        services = nil;
    }
    SBLog(@"Scanning for services: %@",[services componentsJoinedByString:@", "]);
    [manager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)connectToPeripheral:(CBPeripheral*)peripheral {
    if (!isNull(peripheral)) {
        [manager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectPeripheral:(CBPeripheral*)peripheral {
    if (!isNull(peripheral)) {
        [manager cancelPeripheralConnection:peripheral];
    }
}

- (NSString *)titleForCharacteristic:(CBCharacteristic *)c {
    NSString *titleValue = @"";
    //
    if ([c.UUID.UUIDString isEqualToString:kManufacturer.UUIDString]) {
        titleValue = @"Manufacturer";
    } else if ([c.UUID.UUIDString isEqualToString:kSerialNumber.UUIDString]) {
        titleValue = @"Serial Number";
    } else if ([c.UUID.UUIDString isEqualToString:kHardwareRev.UUIDString]) {
        titleValue = @"Hardware Rev.";
    } else if ([c.UUID.UUIDString isEqualToString:kSoftwareRev.UUIDString]) {
        titleValue = @"Software Rev.";
    } else if ([c.UUID.UUIDString isEqualToString:kUUID.UUIDString]) {
        titleValue = @"Proximity UUID";
    } else if ([c.UUID.UUIDString isEqualToString:kMajor.UUIDString]) {
        titleValue = @"Major";
    } else if ([c.UUID.UUIDString isEqualToString:kMinor.UUIDString]) {
        titleValue = @"Minor";
    } else if ([c.UUID.UUIDString isEqualToString:kPower.UUIDString]) {
        titleValue = @"Calibration power";
    } else if ([c.UUID.UUIDString isEqualToString:kInterval.UUIDString]) {
        titleValue = @"Interval";
    } else if ([c.UUID.UUIDString isEqualToString:kTxPower.UUIDString]) {
        titleValue = @"TxPower";
    } else if ([c.UUID.UUIDString isEqualToString:kPassword.UUIDString]) {
        titleValue = @"Password";
    } else if ([c.UUID.UUIDString isEqualToString:kConfig.UUIDString]) {
        titleValue = @"Configuration mode";
    } else if ([c.UUID.UUIDString isEqualToString:kState.UUIDString]) {
        titleValue = @"State";
    } else {
        titleValue = [NSString stringWithFormat:@"Char. %@", c.UUID.UUIDString];
    }
    //
    return titleValue;
}

- (NSString *)valueForCharacteristic:(CBCharacteristic *)c {
    NSString *detailValue = @"";
    //
    if (!c.value) {
        return @"<NULL>";
    }
    //
    if ([c.UUID.UUIDString isEqualToString:kManufacturer.UUIDString]) {
        detailValue = [[NSString alloc] initWithData:c.value encoding:NSUTF8StringEncoding];
    } else if ([c.UUID.UUIDString isEqualToString:kSerialNumber.UUIDString]) {
        detailValue = [[NSString alloc] initWithData:c.value encoding:NSUTF8StringEncoding];
    } else if ([c.UUID.UUIDString isEqualToString:kHardwareRev.UUIDString]) {
        detailValue = [[NSString alloc] initWithData:c.value encoding:NSUTF8StringEncoding];
    } else if ([c.UUID.UUIDString isEqualToString:kSoftwareRev.UUIDString]) {
        detailValue = [[NSString alloc] initWithData:c.value encoding:NSUTF8StringEncoding];
    } else if ([c.UUID.UUIDString isEqualToString:kUUID.UUIDString]) {
        // 16 bytes
        CBUUID *u = [CBUUID UUIDWithData:c.value];
        detailValue = [NSString stringWithFormat:@"%@", u.UUIDString];
    } else if ([c.UUID.UUIDString isEqualToString:kMajor.UUIDString]) {
        // 2 bytes
        detailValue = [NSString stringWithFormat:@"%i",CFSwapInt16([c.value u16])];
    } else if ([c.UUID.UUIDString isEqualToString:kMinor.UUIDString]) {
        // 2 bytes
        detailValue = [NSString stringWithFormat:@"%i",CFSwapInt16([c.value u16])];
    } else if ([c.UUID.UUIDString isEqualToString:kPower.UUIDString]) {
        // 1 byte
        detailValue = [NSString stringWithFormat:@"%i db", [NSNumber numberWithShort:*c.value.hexchars].intValue];
    } else if ([c.UUID.UUIDString isEqualToString:kInterval.UUIDString]) {
        // 2 bytes
        detailValue = [NSString stringWithFormat:@"%i ms", CFSwapInt16([c.value u16])];
    } else if ([c.UUID.UUIDString isEqualToString:kTxPower.UUIDString]) {
        // 1 byte
        // Possible values:  00/01/02/03/04/05/06/07
        // Corresponding to: 30,20,16,12,8,4,0,+4 dB
        //
        NSArray *values = @[@"-30",@"-20",@"-16",@"-12",@"-8",@"-4",@"0",@"4"];
        int index = [c.value hexadecimalString].intValue;
        if (index<values.count) {
            detailValue = [NSString stringWithFormat:@"%@ db", values[index]];
        } else {
            detailValue = [NSString stringWithFormat:@"%@",c.value];
        }
    } else if ([c.UUID.UUIDString isEqualToString:kPassword.UUIDString]) {
        // 2 bytes
        detailValue = [NSString stringWithFormat:@"%i",CFSwapInt16([c.value u16])];
    } else if ([c.UUID.UUIDString isEqualToString:kConfig.UUIDString]) {
        // 1 byte
        // Possible values: 1A/1B/9A/9B/FF
        // First Digit: if the beacon is in “developer mode”(9) or not(1)
        // Second Digit: if send iBeacon(A) standard packet or an extra byte to report the battery level(B).
        detailValue = [NSString stringWithFormat:@"%@",[c.value hexadecimalString]];
    } else if ([c.UUID.UUIDString isEqualToString:kState.UUIDString]) {
        /*
         Possible values: 00/01/02
         State byte:
         0: Password incorrect. Enter the correct password to configure the beacon.
         1: Password correct. Configuration available.
         2: Too many wrong attemps. Wait 3 minutes.
         */
        int index = c.value.hexadecimalString.intValue;
        NSArray *values = @[@"Enter password to configure", @"Configurable", @"Device locked"];
        //
        if (index<values.count) {
            detailValue = [NSString stringWithFormat:@"%@", values[index]];
        } else {
            detailValue = [NSString stringWithFormat:@"%@",c.value.hexadecimalString];
        }
    } else {
        // when we can't identify the service
        detailValue = [NSString stringWithFormat:@"%@",c.value];
    }
    //
    return detailValue;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(nonnull CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    //
    [peripheral setDelegate:self];
    //
    BOOL connectable = [(NSNumber*)[advertisementData valueForKey:CBAdvertisementDataIsConnectable] boolValue];
    
    if (connectable) {
        [timestamps setValue:[NSDate date] forKey:peripheral.identifier.UUIDString];
        [rssi setValue:RSSI forKey:peripheral.identifier.UUIDString];
        [self setPeripheralValue:peripheral forKey:peripheral.identifier.UUIDString];
        //
        [self checkAge];
    }
    //
}

- (void)centralManager:(nonnull CBCentralManager *)central didConnectPeripheral:(nonnull CBPeripheral *)peripheral {
    SBLog(@"%s",__func__);
    [peripheral discoverServices:nil];
    
    PUBLISH((({
        SBEventConnectPeripheral *event = [SBEventConnectPeripheral new];
        event.key = peripheral.identifier.UUIDString;
        event;
    })));
}

- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    SBLog(@"%s",__func__);
    
    [self setPeripheralValue:nil forKey:peripheral.identifier.UUIDString];
}

- (void)centralManager:(nonnull CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    SBLog(@"%s",__func__);
    PUBLISH((({
        SBEventConnectPeripheral *event = [SBEventConnectPeripheral new];
        event.error = error;
        event;
    })));
}

- (void)centralManager:(nonnull CBCentralManager *)central willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict {
    SBLog(@"%s",__func__);
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    PUBLISH(({
        SBEventBluetoothAuthorization *event = [SBEventBluetoothAuthorization new];
        event.bluetoothAuthorization = [self authorizationStatus];
        event;
    }));
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    SBLog(@"%s",__func__);
    
    [self setService:peripheral forKey:peripheral.identifier.UUIDString];
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
        
        [peripheral discoverIncludedServices:nil forService:service];
    }
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error {
    [self setService:peripheral forKey:peripheral.identifier.UUIDString];
    
    for (CBService *sv in service.includedServices) {
        [peripheral discoverCharacteristics:nil forService:sv];
    }
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
    
    for (CBCharacteristic *c in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:c];
        
        [peripheral readValueForCharacteristic:c];
        
    }
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateValueForDescriptor:(nonnull CBDescriptor *)descriptor error:(nullable NSError *)error {
    [self setService:peripheral forKey:peripheral.identifier.UUIDString];
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

    [peripheral readValueForCharacteristic:characteristic];
    
    SBEventWriteCharacteristic *event = [SBEventWriteCharacteristic new];
    
    if (error) {
        event.error = error;
        PUBLISH(event);
        return;
    }
    event.characteristic = characteristic;
    //
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didWriteValueForDescriptor:(nonnull CBDescriptor *)descriptor error:(nullable NSError *)error {
    if (error) {
        SBLog(@"%s: %@", __func__, error);
        return;
    }
    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
//        NSLog(@"%@: %@", characteristic, error);
        return;
    }
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didReadRSSI:(nonnull NSNumber *)RSSI error:(nullable NSError *)error {
    
}

- (void)peripheralDidUpdateName:(nonnull CBPeripheral *)peripheral {
    SBLog(@"%s",__func__);
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didModifyServices:(nonnull NSArray<CBService *> *)invalidatedServices {
    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didAddService:(nonnull CBService *)service error:(nullable NSError *)error {
    SBLog(@"%s",__func__);
}

- (void)peripheralManagerDidStartAdvertising:(nonnull CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    SBLog(@"%s",__func__);
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didSubscribeToCharacteristic:(nonnull CBCharacteristic *)characteristic {
    SBLog(@"%s",__func__);
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didUnsubscribeFromCharacteristic:(nonnull CBCharacteristic *)characteristic {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didReceiveReadRequest:(nonnull CBATTRequest *)request {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didReceiveWriteRequests:(nonnull NSArray<CBATTRequest *> *)requests {
    
}

#pragma mark - Bluetooth status

- (SBBluetoothStatus)authorizationStatus {
    if (manager.state==CBCentralManagerStateUnknown) {
        return SBBluetoothUnknown;
    } else if (manager.state<CBCentralManagerStatePoweredOn) {
        return SBBluetoothOff;
    }
    //
    return SBBluetoothOn;
    //
}

#pragma mark - Internal methods

- (void)setPeripheralValue:(CBPeripheral*)peripheral forKey:(NSString*)key {
    //[_peripherals setValue:peripheral forKey:key];
    [devices setValue:peripheral forKey:key];
    //
//    NSMutableArray *values = [NSMutableArray arrayWithArray:devices.allValues];
//    [values sortUsingComparator:^NSComparisonResult(CBPeripheral *p1, CBPeripheral *p2) {
//        NSNumber *rssi1 = [rssi valueForKey:p1.identifier.UUIDString];
//        NSNumber *rssi2 = [rssi valueForKey:p2.identifier.UUIDString];
//        
//        if (rssi1<rssi2) {
//            return NSOrderedAscending;
//        } else {
//            return NSOrderedDescending;
//        }
//    }];
    
    _peripherals = [NSDictionary dictionaryWithDictionary:devices];
    PUBLISH((({
        SBEventUpdateDevice *event = [SBEventUpdateDevice new];
        event.key = key;
        event.peripheral = [peripheral copy];
        event;
    })));
}

- (void)setService:(CBPeripheral *)peripheral forKey:(NSString*)key {
    [self setPeripheralValue:peripheral forKey:key];
    
    PUBLISH((({
        SBEventUpdateServices *event = [SBEventUpdateServices new];
        event.key = key;
        event;
    })));
}

- (void)setCharacteristic:(CBPeripheral *)peripheral forKey:(NSString*)key {
    [self setPeripheralValue:peripheral forKey:key];
    
    PUBLISH((({
        SBEventUpdateCharacteristics *event = [SBEventUpdateCharacteristics new];
        event.key = key;
        event;
    })));
}

- (void)startScanner {
    //    NSArray *services = [NSArray arrayWithArray:[self defaultServices]];
    NSArray *services = @[];
    
    [manager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)checkAge {
    for (NSString *key in timestamps.allKeys) {
        NSDate *d = timestamps[key];
        if ([[NSDate date] timeIntervalSinceDate:d]>10) {
            BOOL connected = [(CBPeripheral*)[_peripherals valueForKey:key] state]==CBPeripheralStateConnected;
            if (!connected) {
                [self setPeripheralValue:nil forKey:key];
            }
        }
    }
}

- (NSArray *)defaultServices {
    return @[@"180F", // battery service
             @"1805", // current time
             @"180A", // device information
             @"1800", // generic access
             @"1801", // generic attribute
             @"1812", // hid
             @"1821", // indoor positioning
             @"1819", // location and navigation
             @"1804", // tx power
             @"181C", // user data
             @"FFF0", // ble
             @"FFF1", // uuid
             @"FFF5", // transmission power
             @"2A23", // extension
             ];
}



@end
