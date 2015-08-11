//
//  SBUtility.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 03/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

// empty class implementation model
#define emptyImplementation(classname)      @implementation classname @end

// general SensorbergSDK domain
extern NSString *const                      kSBSDKIdentifier;
// resolver date format
extern NSString *const                      APIDateFormat;

@interface SBUtility : NSObject

+ (NSString *)userAgent;
+ (NSString *)deviceName;

@end
