//
//  CBPeripheral+SBPeripheral.m
//  Pods
//
//  Created by Andrei Stoleru on 09/02/16.
//
//

#import "CBPeripheral+SBPeripheral.h"

#import <objc/runtime.h>

static void *SBeRSSI = &SBeRSSI;

@implementation CBPeripheral (SBPeripheral)

- (NSNumber *)eRSSI {
    return objc_getAssociatedObject(self, SBeRSSI);
}

- (void)setERSSI:(NSNumber *)eRSSI {
    objc_setAssociatedObject(self, SBeRSSI, eRSSI, OBJC_ASSOCIATION_ASSIGN);
}

@end
