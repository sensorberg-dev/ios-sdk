//
//  SBResolver+Models.h
//  SensorbergSDK
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

#import "SBResolver.h"

#import <CoreLocation/CoreLocation.h>

@protocol SBMBeacon @end
@interface SBMBeacon : JSONModel
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;
//
- (instancetype)initWithCLBeacon:(CLBeacon*)beacon;
- (instancetype)initWithString:(NSString*)fullUUID;
@end

@protocol SBMContent @end
@interface SBMContent : JSONModel
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDictionary <Optional> *payload;
@property (strong, nonatomic) NSString *url;
@end

@protocol SBMTimeframe @end
@interface SBMTimeframe : JSONModel
@property (strong, nonatomic) NSDate <Optional> *start;
@property (strong, nonatomic) NSDate <Optional> *end;
@end

@protocol SBMAction @end
@interface SBMAction : JSONModel
@property (strong, nonatomic) NSString *eid;
@property (nonatomic) int trigger;
@property (strong, nonatomic) NSArray *beacons;
@property (nonatomic) int supressionTime;
@property (nonatomic) int suppressionTime;
@property (nonatomic) int delay; //
@property (nonatomic) BOOL reportImmediately; // when true flush the history immediately
@property (nonatomic) BOOL sendOnlyOnce; //
@property (strong, nonatomic) NSDate *deliverAt;
@property (strong, nonatomic) SBMContent *content;
@property (nonatomic) int type;
@property (strong, nonatomic) NSArray <SBMTimeframe> *timeframes;
@property (strong, nonatomic) NSString *typeString;
//
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *dt;
@end

@protocol SBMLayout @end
@interface SBMLayout : JSONModel
@property (strong, nonatomic) NSArray <NSString*> *accountProximityUUIDs;
@property (nonatomic) int reportTrigger;
@property (strong, nonatomic) NSArray <SBMAction> *actions;
@property (nonatomic) BOOL currentVersion;
@property (strong, nonatomic) NSArray <SBMAction> *instantActions;
@end

// Post objects
@protocol SBMProximity @end
@interface SBMProximity
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *eventDate;
@property (nonatomic) int trigger;
@property (strong, nonatomic) NSString *location;
@end

@protocol SBMEvents @end
@interface SBMEvents : JSONModel
@property (strong, nonatomic) NSArray <SBMProximity> *events;
@end

@interface SBResolver (Models)

@end
