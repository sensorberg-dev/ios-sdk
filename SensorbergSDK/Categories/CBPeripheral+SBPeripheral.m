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

static void *SBeRSSI = &SBeRSSI;

@implementation CBPeripheral (SBPeripheral)

- (NSNumber *)eRSSI {
    return objc_getAssociatedObject(self, SBeRSSI);
}

- (void)setERSSI:(NSNumber *)eRSSI {
    objc_setAssociatedObject(self, SBeRSSI, eRSSI, OBJC_ASSOCIATION_ASSIGN);
}

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

@end
