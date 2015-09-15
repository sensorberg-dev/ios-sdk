//
//  SBSDKBeaconAction.h
//  SensorbergSDK
//
//   
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

/**
 SBSDKBeaconAction

 Represents the beacon action types that a beacon can trigger.

 @since 0.7.0
 */
typedef NS_ENUM(NSInteger, SBSDKBeaconActionType) {
    /**
     Action should display a text message.
     */
    SBSDKBeaconActionTypeTextMessage = 1,

    /**
     Action should display a text message with a URL.
     */
    SBSDKBeaconActionTypeUrlTextMessage = 2,

    /**
    Action should be displayed a an InApp URL
    */
    SBSDKBeaconActionTypeUrlInApp = 3,

    /**
     Action should display a text message with a URL.
     */
    SBSDKBeaconActionTypeUnknown = -1
};

/**
 The SBSDKBeaconAction object describes an action triggered by a beacon event.

 @since 0.7.0
 */
@interface SBSDKBeaconAction : NSObject <NSCoding>

@property (nonatomic, readonly) SBSDKBeaconActionType type;
@property (nonatomic, readonly) NSString *actionId;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSNumber *delaySeconds;
@property (nonatomic, readonly) NSDictionary * payload;

@end
