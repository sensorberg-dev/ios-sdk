//
//  NSUUID+NSString.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "NSUUID+SBUUID.h"

@implementation NSUUID (SBUUID)

+ (BOOL)isValidUUIDString:(NSString *)UUIDString {
    return (BOOL)[[NSUUID alloc] initWithUUIDString:UUIDString];
}

+ (NSString *)stripHyphensFromUUIDString:(NSString *)UUIDString {
    if (UUIDString.length != 36) {
        return nil;
    }
    
    return [UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSString *)hyphenateUUIDString:(NSString *)UUIDString {
    if (UUIDString.length != 32) {
        return nil;
    }
    
    NSMutableString *resultString = [NSMutableString stringWithString:UUIDString];
    
    [resultString insertString:@"-" atIndex:8];
    [resultString insertString:@"-" atIndex:13];
    [resultString insertString:@"-" atIndex:18];
    [resultString insertString:@"-" atIndex:23];
    
    return [resultString copy];
}

@end
