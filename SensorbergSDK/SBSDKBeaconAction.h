//
//  SBSDKBeaconAction.h
//  SensorbergSDK
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

#import "SBSDKDefines.h"
#import "SBSDKBeacon.h"
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
    SBSDKBeaconActionTypeTextMessage,

    /**
     Action should display a text message with a URL.
     */
    SBSDKBeaconActionTypeUrlTextMessage,

    /**
     Action should display a text message with an In-App URL.
     
     @since 1.0.0
     */
    SBSDKBeaconActionTypeInAppTextMessage,

    /**
     Action should display a text message with a URL.
     */
    SBSDKBeaconActionTypeUnknown
};

/**
 The SBSDKBeaconAction object describes an action triggered by a beacon event.

 @since 0.7.0
 */
@interface SBSDKBeaconAction : NSObject

/**
 Id of the action.

 @since 0.7.0
 */
@property (nonatomic, readonly) NSString *actionID;

/**
 Trigger event that should execute the action.

 @since 1.0.0
 */
@property (nonatomic, readonly) SBSDKBeaconEvent trigger;

/**
 Delay time that should be applied before executing the action.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) NSNumber *delay;

/**
 Array of beacons that should trigger the action.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSArray *beacons;

/**
 Suppression time until another event will be resolved on the beacon.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) NSNumber *suppressionTime;

/**
 Content of the beacon action.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKBeaconContent *content;

/**
 Action type that should be executed.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) SBSDKBeaconActionType type;


/**
 Array of timeFrames containing timeslots when that action should be triggered.
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSArray *timeFrames;

/**
 Flag for executing onlyOnce action or executing multitimes.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) NSNumber *sendOnlyOnce;

/**
 Action type as string that should be executed.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) NSString* typeString;

/**
 Action trigger as string that should be executed.
 
 @since 0.7.0
 */
@property (nonatomic, readonly) NSString* triggerString;

/**
 Action trigger time as string that present the time when the action should be executed.
 
 override the delay feature
 
 @since 1.0.0
 */
@property (nonatomic, readonly) NSDate* deliverAt;


///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the `SBSDKBeaconAction` object. You need to provide a `NSDictionary`
 object that holds action information.

 @param action Action object to be handled.

 @return `SBSDKBeaconAction` object

 @since 0.7.0
 */
- (instancetype)initWithAction:(NSDictionary *)action;

@end
