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

#import "NSData+CBValue.h"

#import <tolo/Tolo.h>

@interface SBBluetooth() {
    CBCentralManager *manager;
    CBPeripheralManager *peripheralManager;
    NSMutableDictionary *peripherals;
    BOOL scanning;
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
        peripherals = [NSMutableDictionary new];
    }
    return self;
}

- (void)requestAuthorization {
    if (!manager) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
}

#pragma mark - External methods

- (NSArray*)devices {
    NSMutableArray *devs = [NSMutableArray arrayWithArray:[peripherals allValues]];
    
    [devs sortUsingComparator:^NSComparisonResult(SBMDevice *before, SBMDevice *after) {
        if (before.rssi==0 || before.rssi>100) {
            return NSOrderedDescending;
        } else if (after.rssi==0 || after.rssi>100) {
            return NSOrderedAscending;
        } else if (before.rssi<after.rssi) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    return [NSArray arrayWithArray:devs];
}

- (void)scanForServices:(NSArray*)services {
    if (!manager) {
        SBLog(@"Warning: Remember to call -requestAuthorization before scanning for Bluetooth services");
        [self requestAuthorization];
    }
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
    } else if ([c.UUID.UUIDString isEqualToString:kCalibrated.UUIDString]) {
        titleValue = @"Calibration power (dB)";
    } else if ([c.UUID.UUIDString isEqualToString:kInterval.UUIDString]) {
        titleValue = @"Interval (ms)";
    } else if ([c.UUID.UUIDString isEqualToString:kTxPower.UUIDString]) {
        titleValue = @"TxPower (dB)";
    } else if ([c.UUID.UUIDString isEqualToString:kPassword.UUIDString]) {
        titleValue = @"Password";
    } else if ([c.UUID.UUIDString isEqualToString:kConfig.UUIDString]) {
        //
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
    } else if ([c.UUID.UUIDString isEqualToString:kCalibrated.UUIDString]) {
        // 1 byte
        detailValue = [NSString stringWithFormat:@"%i", [NSNumber numberWithShort:*c.value.hexchars].intValue];
    } else if ([c.UUID.UUIDString isEqualToString:kInterval.UUIDString]) {
        // 2 bytes
        detailValue = [NSString stringWithFormat:@"%i", CFSwapInt16([c.value u16])];
    } else if ([c.UUID.UUIDString isEqualToString:kTxPower.UUIDString]) {
        // iBKS 105
        // Possible values:     00/01/02/03/04/05/06/07
        // Corresponding to:    30,20,16,12,8,4,0,+4 dB
        // iBKS USB
        // Possible values:     0/1/2/3
        // Corresponding to:    -23/-6/0/+4 dB
        NSArray *values = @[@"-30",@"-20",@"-16",@"-12",@"-8",@"-4",@"0",@"4"];
        int index = [c.value hexadecimalString].intValue;
        if (index<values.count) {
            detailValue = [NSString stringWithFormat:@"%@", values[index]];
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
        NSArray *values = @[@"Locked", @"Unlocked", @"Access denied"];
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

- (void)advertise:(NSString *)proximityUUID major:(int)major minor:(int)minor name:(NSString*)name {
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:proximityUUID]
                                                                     major:major
                                                                     minor:minor
                                                                identifier:name];
    
    [peripheralManager startAdvertising:[region peripheralDataWithMeasuredPower:nil]];
}

- (void)stopAdvertising {
    [peripheralManager stopAdvertising];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(nonnull CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    //
    [peripheral setDelegate:self];
    //
    BOOL connectable = [(NSNumber*)[advertisementData valueForKey:CBAdvertisementDataIsConnectable] boolValue];
    
    if (connectable) {
        SBMDevice *device = [SBMDevice new];
        device.peripheral = peripheral;
        device.rssi = RSSI.intValue;
        device.lastSeen = now;
        [self setDevice:device];
        //
        [self checkAge];
    }
    //
}

- (void)centralManager:(nonnull CBCentralManager *)central didConnectPeripheral:(nonnull CBPeripheral *)peripheral {
    SBLog(@"%s",__func__);
    [peripheral discoverServices:nil];
    
    SBEventDeviceConnected *event = [SBEventDeviceConnected new];
    SBMDevice *device = [SBMDevice new];
    device.peripheral = peripheral;
    event.device = device;
    PUBLISH(event);
}

- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    SBLog(@"%s",__func__);
    
    [peripherals setValue:nil forKey:peripheral.identifier.UUIDString];
    
    SBEventDeviceLost *event = [SBEventDeviceLost new];
    SBMDevice *device = [SBMDevice new];
    device.peripheral = peripheral;
    event.device = device;
    PUBLISH(event);
}

- (void)centralManager:(nonnull CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    SBLog(@"%s",__func__);
    
    SBEventDeviceConnected *event = [SBEventDeviceConnected new];
    event.error = error;
    PUBLISH(event);
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
    
    SBEventCharacteristicWrite *event = [SBEventCharacteristicWrite new];
    
    if (error) {
        event.error = error;
        PUBLISH(event);
        return;
    }
    
    event.characteristic = characteristic;
    PUBLISH(event);
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
        //
        return;
    }
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didReadRSSI:(nonnull NSNumber *)RSSI error:(nullable NSError *)error {
    
    SBMDevice *device = [SBMDevice new];
    device.peripheral = peripheral;
    device.lastSeen = now;
    device.rssi = RSSI.intValue;
    
    [self setDevice:device];
}

- (void)peripheralDidUpdateName:(nonnull CBPeripheral *)peripheral {
    SBLog(@"%s",__func__);
    
    SBMDevice *device = [SBMDevice new];
    device.peripheral = peripheral;
    device.lastSeen = now;
    
    [self setDevice:device];
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
    SBEventBluetoothEmulation *event = [SBEventBluetoothEmulation new];
    event.error = error;
    PUBLISH(event);
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

- (void)setDevice:(SBMDevice*)device {
    SBMDevice *old = [peripherals valueForKey:device.peripheral.identifier.UUIDString];
    SBMDevice *new = [SBMDevice new];
    new.peripheral = device.peripheral ? device.peripheral : old.peripheral;
    new.rssi = device.rssi ? device.rssi : old.rssi;
    new.lastSeen = device.lastSeen ? device.lastSeen : old.lastSeen;
    //
    [peripherals setValue:new forKey:device.peripheral.identifier.UUIDString];
    //
    SBEventDevice *event;
    if (old) {
        event = [SBEventDeviceUpdated new];
    } else {
        event = [SBEventDeviceDiscovered new];
    }
    event.device = new;
    PUBLISH(event);
    
}

- (void)setService:(CBPeripheral *)peripheral forKey:(NSString*)key {
    SBMDevice *device = [SBMDevice new];
    device.peripheral = peripheral;
    device.lastSeen = now;
    
    [peripherals setValue:device forKey:device.peripheral.identifier.UUIDString];
    
    SBEventServicesUpdated *event = [SBEventServicesUpdated new];
    event.device = device;
    PUBLISH(event);
}

- (void)setCharacteristic:(CBPeripheral *)peripheral forKey:(NSString*)key {
    SBMDevice *device = [SBMDevice new];
    device.peripheral = peripheral;
    device.lastSeen = now;
    
    [peripherals setValue:device forKey:device.peripheral.identifier.UUIDString];
    
    SBEventCharacteristicsUpdate *event = [SBEventCharacteristicsUpdate new];
    event.device = device;
    PUBLISH(event);
}

- (void)checkAge {
    for (SBMDevice *device in peripherals.allValues) {
        NSDate *d = device.lastSeen;
        if ([[NSDate date] timeIntervalSinceDate:d]>10) {
            [peripherals setValue:nil forKey:device.peripheral.identifier.UUIDString];
            
            BOOL connected = ([device.peripheral state]==CBPeripheralStateConnected);
            if (!connected) {
                SBEventDeviceLost *event = [SBEventDeviceLost new];
                event.device = device;
                PUBLISH(event);
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
