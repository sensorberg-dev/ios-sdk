//
//  SensorbergSDK.h
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

//! Project version number for SensorbergSDK.
FOUNDATION_EXPORT double SensorbergSDKVersionNumber;

//! Project version string for SensorbergSDK.
FOUNDATION_EXPORT const unsigned char SensorbergSDKVersionString[];


#ifdef __cplusplus
extern "C" {
#endif
    void sbLogFuncC_impl(const char * f, int l, const char * fmt, ...) __attribute__ ((format (__printf__, 3, 4)));
#define sbLogFunc sbLogFuncC_impl
    
#ifdef __OBJC__
    
    void sbLogFuncObjC_impl(const char * f, int l, NSString * fmt, ...) NS_FORMAT_FUNCTION(3,4);
#undef sbLogFunc
#define sbLogFunc sbLogFuncObjC_impl
    
#endif
    
#ifdef __cplusplus
}
#endif

//#define SB_NO_LOGGING

#ifdef SB_NO_LOGGING
#define SBLog(s...) do {} while(0)
#else
#define SBLog(s...) sbLogFunc(__FILE__, __LINE__, s)
#endif

#define emptyImplementation(className)      @implementation className @end

#define kSBCacheFolder      [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

#define now                 [NSDate date]

extern NSString *const kSBDefaultResolver;

extern NSString *const kSBDefaultAPIKey;

extern NSString             *kPostLayout;

extern NSString             *kSBAppActive;

extern float                kPostSuppression;

// general SensorbergSDK domain
extern NSString *const                      kSBIdentifier;
// ```Resolver``` date format
extern NSString *const                      APIDateFormat;

//

@interface SensorbergSDK : NSObject

+ (NSString *)applicationIdentifier;

// default beacon regions
+ (NSArray *)defaultBeacons;

// don't use this :)
+ (BOOL)debugging;

@end
