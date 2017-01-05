//
//  SBModel.h
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
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

#import <CoreLocation/CoreLocation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "SBEnums.h"

@interface SBModel : NSObject
@end

@protocol SBMTrigger @end
@interface SBMTrigger : SBModel
@property (strong, nonatomic) NSString *tid;
@end

@protocol SBMBeacon @end
@interface SBMBeacon : SBMTrigger
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;

/**
 Initializer for SBMBeacon with a CLBeacon object

 @param beacon A CLBeacon object
 @return A SBMBeacon object
 */
- (instancetype)initWithCLBeacon:(CLBeacon*)beacon;

/**
 Initializer for SBMBeacon with full UUID string.

 @param fullUUID The full UUID string (hyphenated or not)
 @return Returns a SBMBeacon object. The return can also be nil if the full UUID is invalid
 */
- (instancetype)initWithString:(NSString*)fullUUID;
- (NSString*)fullUUID;
- (NSUUID*)UUID;
@end

@protocol SBMGeofence @end
@interface SBMGeofence : SBMTrigger

/**
 Initializer for the SBMGeofence

 @param region A CLCircularRegion object
 @return A SBMGeofence object
 */
- (instancetype)initWithRegion:(CLCircularRegion *)region;

@property (nonatomic) CLLocationDegrees     latitude;
@property (nonatomic) CLLocationDegrees     longitude;
@property (nonatomic) CLLocationDistance    radius;
@end

@protocol  SBMCampaignAction @end
@interface SBMCampaignAction : NSObject
@property (strong, nonatomic) NSDate        *fireDate;
@property (strong, nonatomic) NSString      *subject;
@property (strong, nonatomic) NSString      *body;
@property (strong, nonatomic) NSDictionary  *payload;
@property (strong, nonatomic) NSString      *url;
@property (strong, nonatomic) NSString      *eid;
@property (nonatomic) SBTriggerType         trigger;
@property (nonatomic) SBActionType          type;
@property (strong, nonatomic) SBMTrigger    *beacon;
@property (strong, nonatomic) NSString      *action; // unique action fire event identifier
@end
