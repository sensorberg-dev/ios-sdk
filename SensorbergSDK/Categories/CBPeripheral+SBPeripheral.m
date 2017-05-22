//
//  CBPeripheral+SBPeripheral.m
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

#import "CBPeripheral+SBPeripheral.h"

#import <objc/runtime.h>

#import "CBCharacteristic+SBCharacteristic.h"

@implementation CBPeripheral (SBPeripheral)

- (SBFirmwareVersion)firmware {
    SBFirmwareVersion fw = FWUnknown;
    NSString *hardware;
    NSString *model;
    
    for (CBService *service in self.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic matchesUUID:iBLEHardwareRev]) {
                hardware = [characteristic detail];
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

- (void)read:(NSArray*)services {
    [self discoverServices:services];
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
