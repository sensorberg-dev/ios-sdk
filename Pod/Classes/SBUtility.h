//
//  SBUtility.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 03/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

// empty class implementation template
#define emptyImplementation(classname)      @implementation classname @end

// general SensorbergSDK domain
extern NSString *const                      kSBIdentifier;
// resolver date format
extern NSString *const                      APIDateFormat;

@interface SBUtility : NSObject

+ (NSString *)userAgent;

+ (NSString *)deviceName;

// default beacon regions
+ (NSArray *)defaultBeacons;

@end
