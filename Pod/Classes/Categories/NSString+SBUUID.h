//
//  NSUUID+NSString.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 04/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SBUUID)

/**
 Check if the provided UUID string represents a valid UUID string.
 
 @param UUIDString String to check for compliance.
 
 @return YES if the provided UUID string represents a valid UUID string.
 */
+ (BOOL)isValidUUIDString:(NSString *)UUIDString;

/**
 Removes all hyphens from a given UUID string.
 
 The only validation of given string is the length expected length of 36 characters.
 
 @param UUIDString String to be cleaned of hyphens.
 
 @return UUID string without hyphens.
 */
+ (NSString *)stripHyphensFromUUIDString:(NSString *)UUIDString;

/**
 Adds hyphens to a string that holds a ProximityUUID, as specified in http://www.ietf.org/rfc/rfc4122.txt.
 
 The only validation of given string is the strings expected length of 32 characters.
 
 @param UUIDString String to be converted into a valid format.
 
 @return UUID string with hyphens if given string had a length of 32 characters.
 */
+ (NSString *)hyphenateUUIDString:(NSString *)UUIDString;

@end
