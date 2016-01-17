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

#import <tolo/Tolo.h>

@interface SBBluetooth() {
    CBCentralManager *manager;
    
    BOOL scanning;
    
    NSMutableDictionary *timestamps;
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
        _peripherals = [NSMutableDictionary new];
        
        timestamps = [NSMutableDictionary new];
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
        
//        services = [NSArray arrayWithArray:_services];
    }
    SBLog(@"Scanning for services: %@",[services componentsJoinedByString:@", "]);
    [manager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)connectToPeripheral:(CBPeripheral*)peripheral {
    [manager connectPeripheral:peripheral options:nil];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(nonnull CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    //
    [peripheral setDelegate:self];
    //
    BOOL connectable = [(NSNumber*)[advertisementData valueForKey:CBAdvertisementDataIsConnectable] boolValue];
    
    if (connectable) {
        [timestamps setValue:[NSDate date] forKey:peripheral.identifier.UUIDString];
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
    if (error) {
        NSLog(@"Error writing value to characteristic: %@",characteristic);
        return;
    }
    
    NSLog(@"Wrote value to char: %@",characteristic);
    [peripheral discoverCharacteristics:nil forService:characteristic.service];
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
        NSLog(@"%@: %@", characteristic, error);
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
    [_peripherals setValue:peripheral forKey:key];
    
    PUBLISH((({
        SBEventUpdateDevice *event = [SBEventUpdateDevice new];
        event.key = key;
        event.peripheral = [peripheral copy];
        event;
    })));
}

- (void)setService:(CBPeripheral *)peripheral forKey:(NSString*)key {
    [_peripherals setValue:peripheral forKey:key];
    
    PUBLISH((({
        SBEventUpdateServices *event = [SBEventUpdateServices new];
        event.key = key;
        event;
    })));
}

- (void)setCharacteristic:(CBPeripheral *)peripheral forKey:(NSString*)key {
    [_peripherals setValue:peripheral forKey:key];
    
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
