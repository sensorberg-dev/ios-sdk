//
//  SBSDKDeviceID.h
//  SensorbergSDK
//
//  Created by Max Horvath.
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
#import <UIKit/UIKit.h>

/**
 The SBSDKDeviceID object return a UUID for the current device.
 
 The UUID will change with every reinstallation of the app.
 */
@interface SBSDKDeviceID : NSObject

/**
 UUID for the current device.
 */
@property (nonatomic, readonly) NSString *UUIDString;

/**
 User agent used to categorize the device dirung HTTP requests.
 */
@property (nonatomic, readonly) NSString *userAgent;

/**
 Type of device the app is running on.
 */
@property (nonatomic, readonly) NSString *deviceType;

///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the SBSDKDeviceID object.

 @return SBSDKDeviceID object
 */
- (instancetype)init;

///------------------------
/// @name Device Identifier
///------------------------

/**
 Resets the UUID for the current device.
 */
+ (void)resetDeviceIdentifier;

@end
