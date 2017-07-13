//
//  SBBluetooth.m
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

#import "SBBluetooth.h"

#import "SBInternalEvents.h"

#import "SensorbergSDK.h"

#import "SBSettings.h"

#import <tolo/Tolo.h>

@interface SBBluetooth() {
    CBCentralManager *manager;
    CBPeripheralManager *peripheralManager;
    
    NSMutableDictionary *devices;
    
    SBBluetoothStatus oldStatus;
    
    NSMutableArray *profiles;
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
        devices = [NSMutableDictionary new];
    }
    return self;
}


#pragma mark - External methods

- (void)requestAuthorization {
    if (!manager) {
        dispatch_queue_t queue = dispatch_queue_create("com.sensorberg.sdk.bluetooth", NULL);
        //
        dispatch_sync( queue, ^{
            manager = [[CBCentralManager alloc] initWithDelegate:self
                                                           queue:queue
                                                         options:@{CBCentralManagerOptionShowPowerAlertKey: @(YES)}];
            
            peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                        queue:queue
                                                                      options:@{CBPeripheralManagerOptionShowPowerAlertKey: @(YES),
                                                                                CBPeripheralManagerOptionRestoreIdentifierKey: @"SensorbergSDK"}];
        });
    }
}

- (void)startAdvertising:(NSString *)proximityUUID major:(int)major minor:(int)minor name:(NSString*)name {
    if (!peripheralManager) {
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    //
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:proximityUUID]
                                                                     major:major
                                                                     minor:minor
                                                                identifier:name];
    [peripheralManager startAdvertising:[region peripheralDataWithMeasuredPower:nil]];
}

- (void)stopAdvertising {
    [peripheralManager stopAdvertising];
}

- (void)startServiceScan:(NSArray *)services {
    if (!manager) {
        [self requestAuthorization];
        //
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startServiceScan:services];
        });
        return;
    }
    //
    profiles = [NSMutableArray new];
    for (NSString *serviceID in services) {
        CBUUID *cb = [CBUUID UUIDWithString:serviceID];
        if (cb) {
            [profiles addObject:cb];
        }
    }
    //
    [manager scanForPeripheralsWithServices:profiles options:@{
                                                               CBCentralManagerScanOptionAllowDuplicatesKey : @YES,
                                                               CBCentralManagerOptionShowPowerAlertKey: @YES,
                                                               CBCentralManagerScanOptionSolicitedServiceUUIDsKey : profiles
                                                               }];
}

- (void)stopServiceScan {
    [manager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    [manager connectPeripheral:peripheral options:nil];
}

- (void)cancelConnection:(CBPeripheral *)peripheral {
    [manager cancelPeripheralConnection:peripheral];
}

- (void)subscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic && characteristic.service.peripheral.isConnected) {
        [characteristic.service.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)unsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    [characteristic.service.peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

- (NSArray *)devices {
    NSMutableArray *temps = [NSMutableArray arrayWithArray:devices.allValues];
    
    NSMutableIndexSet *toRemove = [NSMutableIndexSet new];
    double monitoringDelay = [[SBSettings sharedManager] settings].monitoringDelay;
    
    for (CBPeripheral *p in temps) {
        if (p.lastSeen && ABS([p.lastSeen timeIntervalSinceNow]) > monitoringDelay) {
            [toRemove addIndex:[temps indexOfObject:p]];
        }
    }
    [temps removeObjectsAtIndexes:toRemove];
    
    [temps sortUsingComparator:^NSComparisonResult(CBPeripheral *p1, CBPeripheral *p2) {
        if ([p1.name isEqualToString:@"iBKS105"]) {
            return NSOrderedAscending;
        } else if ([p2.name isEqualToString:@"iBKS105"]) {
            return NSOrderedDescending;
        }
        if ([p1.name isEqualToString:@"iBeacon"]) {
            return NSOrderedAscending;
        } else if ([p2.name isEqualToString:@"iBeacon"]) {
            return NSOrderedDescending;
        }
        
        if (p1.firstSeen < p2.firstSeen) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    return temps;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self updatePeripheral:peripheral];
    //
    PUBLISH((({
        SBEventDeviceConnected *event = [SBEventDeviceConnected new];
        event.peripheral = peripheral;
        event;
    })));
    //
    [peripheral read:profiles];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self updatePeripheral:peripheral];
    //
    PUBLISH((({
        SBEventDeviceDisconnected *event = [SBEventDeviceDisconnected new];
        event.error = error;
        event.peripheral = peripheral;
        event;
    })));
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self updatePeripheral:peripheral];
    //
    PUBLISH((({
        SBEventDeviceDisconnected *event = [SBEventDeviceDisconnected new];
        event.error = error;
        event.peripheral = peripheral;
        event;
    })));
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![devices objectForKey:peripheral.identifier.UUIDString]) {
        peripheral.firstSeen = [NSDate date];
        peripheral.delegate = self;
        [devices setObject:peripheral forKey:peripheral.identifier.UUIDString];
    }
    peripheral.rssi = RSSI;
    peripheral.advertisementData = advertisementData;
    //
    PUBLISH((({
        SBEventDeviceDiscovered *event = [SBEventDeviceDiscovered new];
        event.peripheral = peripheral;
        event;
    })));
    //
    [self updatePeripheral:peripheral];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    SBBluetoothStatus newStatus = [self authorizationStatus];
    if (oldStatus==newStatus) {
        return;
    }
    oldStatus = newStatus;
    PUBLISH(({
        SBEventBluetoothAuthorization *event = [SBEventBluetoothAuthorization new];
        event.bluetoothAuthorization = oldStatus;
        event;
    }));
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self updatePeripheral:peripheral];
    //
    PUBLISH((({
        SBEventServicesUpdated *event = [SBEventServicesUpdated new];
        event.error = error;
        event.peripheral = peripheral;
        event;
    })));
    //
    for (CBService *service in peripheral.services) {
        [peripheral discoverIncludedServices:nil forService:service];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    [self updatePeripheral:peripheral];
    //
    PUBLISH((({
        SBEventServicesUpdated *event = [SBEventServicesUpdated new];
        event.error = error;
        event.peripheral = peripheral;
        event;
    })));
    //
    [peripheral discoverCharacteristics:nil forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self updatePeripheral:peripheral];
    //
    PUBLISH((({
        SBEventDeviceUpdated *event = [SBEventDeviceUpdated new];
        event.error = error;
        event.peripheral = peripheral;
        event;
    })));
    //
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
        
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self updatePeripheral:peripheral];
    
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [peripheral readValueForDescriptor:descriptor];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self updatePeripheral:peripheral];
    
    PUBLISH((({
        SBEventCharacteristicsUpdate *event = [SBEventCharacteristicsUpdate new];
        event.peripheral = peripheral;
        event.characteristic = characteristic;
        event.error = error;
        event;
    })));
    //
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    [self updatePeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self updatePeripheral:peripheral];
    
    PUBLISH((({
        SBEventCharacteristicWrite *event = [SBEventCharacteristicWrite new];
        event.peripheral = peripheral;
        event.characteristic = characteristic;
        event.error = error;
        event;
    })));
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    [self updatePeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self updatePeripheral:peripheral];
    if (error) {
        NSLog(@"error:!!!!!");
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    [self updatePeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    peripheral.rssi = RSSI;
    [self updatePeripheral:peripheral];
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    [self updatePeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    [self updatePeripheral:peripheral];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didAddService:(nonnull CBService *)service error:(nullable NSError *)error {
    //    SBLog(@"%s",__func__);
}

- (void)peripheralManagerDidStartAdvertising:(nonnull CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    PUBLISH((({
        SBEventBluetoothEmulation *event = [SBEventBluetoothEmulation new];
        event.error = error;
        event;
    })));
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didSubscribeToCharacteristic:(nonnull CBCharacteristic *)characteristic {
    //    SBLog(@"%s",__func__);
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
    return SBBluetoothOn;
}

#pragma mark - Internal methods

- (void)updatePeripheral:(CBPeripheral*)peripheral {
    if (!peripheral) {
        return;
    }
    //
    peripheral.lastSeen = [NSDate date];
    [devices setObject:peripheral forKey:peripheral.identifier.UUIDString];
    //
    PUBLISH((({
        SBEventDeviceUpdated *event = [SBEventDeviceUpdated new];
        event.peripheral = peripheral;
        event;
    })));
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

- (void)disconnectPeripheral:(CBPeripheral*)peripheral {
    [manager cancelPeripheralConnection:peripheral];
}

@end
