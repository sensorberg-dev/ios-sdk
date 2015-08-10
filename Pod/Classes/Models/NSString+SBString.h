//
//  NSString+SBString.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SBString)

/**
 Returns YES if the target string is contained within the receiver.
 
 Same as calling rangeOfString:options: with no options, thus doing a case-sensitive,
 non-literal search.
 
 Added in iOS 8, retrofitted for iOS 7.
 
 @param aString The string to compare with.
 
 @return YES if the target string is contained within the receiver.
 */
- (BOOL)containsString:(NSString *)aString;

@end
