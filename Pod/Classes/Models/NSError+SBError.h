//
//  NSError+SBError.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (SBError)

+ (NSError*)SBErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)info;

@end
