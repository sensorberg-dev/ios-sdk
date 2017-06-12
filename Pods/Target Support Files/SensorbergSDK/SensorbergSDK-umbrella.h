#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SBBluetooth.h"
#import "SBEnums.h"
#import "SBEvent.h"
#import "SBMagnetometer.h"
#import "SBManager.h"
#import "SBModel.h"
#import "SensorbergSDK.h"
#import "CBCharacteristic+SBCharacteristic.h"
#import "CBPeripheral+SBPeripheral.h"
#import "NSString+SBUUID.h"

FOUNDATION_EXPORT double SensorbergSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char SensorbergSDKVersionString[];

