//
//  NSError+SBError.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "NSError+SBError.h"

@implementation NSError (SBError)

+ (NSError*)SBErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)info {
    NSError *error = [NSError errorWithDomain:kSBSDKIdentifier code:code userInfo:info];
    
    return error;
}

@end
