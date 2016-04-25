//
//  CBPeripheral+SBPeripheral.m
//  Pods
//
//  Created by Andrei Stoleru on 09/02/16.
//
//

#import "CBPeripheral+SBPeripheral.h"

#import <objc/runtime.h>

#import "CBCharacteristic+SBCharacteristic.h"

@implementation CBPeripheral (SBPeripheral)

- (SBFirmwareVersion)firmware {
    SBFirmwareVersion fw = FWUnknown;
    NSString *hardware;
    NSString *manufacturer;
    NSString *software;
    NSString *serial;
    NSString *model;
    
    for (CBService *service in self.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic matchesUUID:iBLEHardwareRev]) {
                hardware = [characteristic detail];
            }
            if ([characteristic matchesUUID:iBLEManufacturer]) {
                manufacturer = [characteristic detail];
            }
            if ([characteristic matchesUUID:iBLESoftwareRev]) {
                software = [characteristic detail];
            }
            if ([characteristic matchesUUID:iBLESerialNumber]) {
                serial = [characteristic detail];
            }
            if ([characteristic matchesUUID:iBLEModel]) {
                model = [characteristic detail];
            }
        }
    }
    //
    if ([hardware rangeOfString:@"iBKS105"].location!=NSNotFound) {
        fw = iBKS105v1;
    } else if ([model rangeOfString:@"USB"].location!=NSNotFound) {
        fw = iBKSUSB;
    } else {
        fw = FWUnknown;
    }
    //
    return fw;
}

- (BOOL)connectable {
    return [[self.advertisementData valueForKey:CBAdvertisementDataIsConnectable] boolValue];
}

- (BOOL)isConnected {
    return self.state==CBPeripheralStateConnected || self.state==CBPeripheralStateConnecting;
}

- (void)read {
    [self discoverServices:nil];
}

//RSSI
- (NSNumber *)rssi {
    return objc_getAssociatedObject(self, @selector(rssi));
}

- (void)setRssi:(NSNumber *)_rssi {
    objc_setAssociatedObject(self, @selector(rssi), _rssi, OBJC_ASSOCIATION_RETAIN);
}

//advertisementData
- (NSDictionary *)advertisementData {
    return objc_getAssociatedObject(self, @selector(advertisementData));
}

- (void)setAdvertisementData:(NSDictionary *)_advertisementData {
    objc_setAssociatedObject(self, @selector(advertisementData), _advertisementData, OBJC_ASSOCIATION_RETAIN);
}

//lastSeen
- (NSDate *)lastSeen {
    return objc_getAssociatedObject(self, @selector(lastSeen));
}

- (void)setLastSeen:(NSDate *)_lastSeen {
    objc_setAssociatedObject(self, @selector(lastSeen), _lastSeen, OBJC_ASSOCIATION_RETAIN);
}

//firstSeen
- (NSDate *)firstSeen {
    return objc_getAssociatedObject(self, @selector(firstSeen));
}

- (void)setFirstSeen:(NSDate *)_firstSeen {
    objc_setAssociatedObject(self, @selector(firstSeen), _firstSeen, OBJC_ASSOCIATION_RETAIN);
}

@end
