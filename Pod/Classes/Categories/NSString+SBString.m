//
//  NSString+SBString.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "NSString+SBString.h"

@implementation NSString (SBString)

- (BOOL)containsString:(NSString *)aString {
    return [self rangeOfString:aString].location != NSNotFound;
}

@end
