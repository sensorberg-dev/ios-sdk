//
//  SBSDKBeacon.h
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


/**
 The SBSDKBeaconContent object describes the content of an action triggered by a beacon event.
 
 @since 1.0.0
 */
@interface SBSDKBeaconContent : NSObject

/**
 Subject of the action, encoded in the content dictionary of the beacon action.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSString *subject;

/**
 Body of the action, encoded in the content dictionary of the beacon action.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSString *body;

/**
 URL of the action, encoded in the content dictionary of the beacon action.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSURL *url;

/**
 Custom data that has been defined for the beacon action. It is a Foundation object from
 JSON data in data, or nil.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) id payload;

///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the `SBSDKBeaconContent` object. You need to provide a `NSDictionary`
 object that holds content information.
 
 @param content Content object to be handled.
 
 @return `SBSDKBeaconContent` object
 
 @since 1.0.0
 */
- (instancetype)initWithContent:(NSDictionary *)content;

@end
