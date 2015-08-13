//
//  NSError+SBError.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBManager;

@interface NSError (SBError)

+ (NSError*)SBErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)info;

/**
 Returns YES if the networking error is fatal and retrying not necessary.
 
 @return YES if the networking error is fatal and retrying not necessary.
 */
- (BOOL)isFatalNetworkingError;

@end
