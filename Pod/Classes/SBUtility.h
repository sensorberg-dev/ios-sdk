//
//  SBUtility.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 03/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBUtility : NSObject

#define APIDateFormat   @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

+ (NSString *)userAgent;
+ (NSString *)deviceName;

+ (NSString *)baseURL;
+ (NSString *)apiKey;

@end
