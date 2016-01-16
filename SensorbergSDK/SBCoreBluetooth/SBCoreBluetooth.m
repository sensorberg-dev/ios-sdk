//
//  SBCoreBluetooth.m
//  BeaConfig
//
//  Created by andsto on 11/01/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import "SBCoreBluetooth.h"

#import "SensorbergSDK.h"

@implementation SBEventUpdateDevice @end

@implementation SBEventUpdateServices @end

@implementation SBEventUpdateCharacteristics @end

@implementation SBEventWriteCharacteristic @end

@implementation SBEventConnectPeripheral @end

@interface SBCoreBluetooth () {
    CBCentralManager *manager;
    
    BOOL scanning;
    
    NSMutableDictionary *timestamps;
}

@end

@implementation SBCoreBluetooth

static SBCoreBluetooth * _sharedManager;

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

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Powered off");
            scanning = NO;
            break;
        case CBCentralManagerStatePoweredOn:
        {
            if (!scanning) {
                scanning = YES;
                [self startScanner];
            }
            break;
        }
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnsupported:
            NSLog(@"Unsupported/Unauthorized");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    
    [peripheral setDelegate:self];
    [peripheral readRSSI];
    //
    BOOL connectable = [(NSNumber*)[advertisementData valueForKey:CBAdvertisementDataIsConnectable] boolValue];
    
    if (connectable) {
        [timestamps setValue:[NSDate date] forKey:peripheral.identifier.UUIDString];
        [self setPeripheralValue:peripheral forKey:peripheral.identifier.UUIDString];
        //
        [self checkAge];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self setPeripheralValue:nil forKey:peripheral.identifier.UUIDString];
    
    NSLog(@"%@",timestamps);
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"%s: %@", __func__, peripheral);
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self setService:peripheral forKey:peripheral.identifier.UUIDString];
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
    NSLog(@"services for %@: %@", peripheral.name, peripheral.services);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
    
    for (CBCharacteristic *c in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:c];
        
        [peripheral readValueForCharacteristic:c];
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {    
    //
    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"%@: %@", characteristic, error);
        return;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing value to characteristic: %@",characteristic);
        return;
    }
    
    NSLog(@"Wrote value to char: %@",characteristic);
    [peripheral discoverCharacteristics:nil forService:characteristic.service];
//    [self setCharacteristic:peripheral forKey:peripheral.identifier.UUIDString];
}

#pragma mark - Internal methods

- (void)setPeripheralValue:(CBPeripheral*)peripheral forKey:(NSString*)key {
    [_peripherals setValue:peripheral forKey:key];
    
    PUBLISH((({
        SBEventUpdateDevice *event = [SBEventUpdateDevice new];
        event.key = key;
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

#pragma mark - External methods

- (void)connectToPeripheral:(CBPeripheral*)peripheral {
    [manager connectPeripheral:peripheral options:nil];
}

@end
