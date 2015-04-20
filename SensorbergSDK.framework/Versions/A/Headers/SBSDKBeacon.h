//
//  SBSDKBeacon.h
//  SensorbergSDK
//
//  Created by Max Horvath on 09/09/2014.
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

#import <Availability.h>
#import <CoreLocation/CoreLocation.h>

@class CLBeacon;

/**
 The SBSDKBeacon object describes a beacon detected by the Sensorberg SDK.
 */
@interface SBSDKBeacon : NSObject

/**
 Beacon object.
 */
@property (nonatomic, strong) CLBeacon *beacon;

/**
 UUID string of the beacon object.
 */
@property (nonatomic, readonly) NSString *UUIDString;

/**
 Major of the beacon object.
 */
@property (nonatomic, readonly) NSNumber *major;

/**
 Minor of the beacon object.
 */
@property (nonatomic, readonly) NSNumber *minor;

/**
 Last time beacon has been detected.
 */
@property (nonatomic, strong) NSDate *lastSeenAt;

///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the SBSDKBeacon object. You need to provide a CLBeacon object.

 @param beacon Beacon object to be handled.

 @return SBSDKBeacon object
 */
- (instancetype)initWithBeacon:(CLBeacon *)beacon;

@end
