//
//  NSArray+SBArray.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SBArray)

/**
 Checks whether the elements of the array that are of NSString contain a given string.
 
 @param aString The string to compare with.
 
 @return YES if the array contains a NSString with the given string.
 */
- (BOOL)containsString:(NSString *)aString;

@end
