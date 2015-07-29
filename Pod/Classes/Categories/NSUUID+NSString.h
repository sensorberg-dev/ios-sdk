//
//  NSUUID+NSString.h
//  SensorbergSDK
//
//  Created by Max Horváth on 10.09.14.
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@interface NSUUID (NSString)

/**
 Returns if the provided UUID string represents a valid UUID string.

 @param UUIDString String to checked for compliance.

 @return YES if the provided UUID string represents a valid UUID string.
 */
+ (BOOL)isValidUUIDString:(NSString *)UUIDString;

/**
 Removes all hyphens from a given UUID string.
 
 Only validation of given string is the length expected length of 36 characters.

 @param UUIDString String to cleaned of hyphens.

 @return UUID string without hyphens.
 */
+ (NSString *)stripHyphensFromUUIDString:(NSString *)UUIDString;

/**
 Adds hyphens to a string that holds a ProximityUUID, as specified in RFC4122.

 Only validation of given string is the length expected length of 32 characters.

 @param UUIDString String to be converted into a valid format.

 @return UUID string with hyphens if given string had a length of 32 characters.
 */
+ (NSString *)hyphenateUUIDString:(NSString *)UUIDString;

@end
