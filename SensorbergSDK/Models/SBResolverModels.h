//
//  SBResolverModels.h
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

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

#import "SBMSession.h"

#import "SBMBeacon.h"

@class SBMGetLayout;

typedef enum : NSUInteger {
    kSBTriggerEnter=1,
    kSBTriggerExit=2,
    kSBTriggerEnterExit=3,
} SBTriggerType;

typedef enum : NSUInteger {
    kSBActionTypeText=1,
    kSBActionTypeURL=2,
    kSBActionTypeInApp=3,
} SBActionType;

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
@property (nonatomic) SBTriggerType trigger;
@property (strong, nonatomic) NSArray *beacons;
@property (nonatomic) int suppressionTime; // in seconds
@property (nonatomic) int delay; //
@property (nonatomic) BOOL reportImmediately; // when true flush the history immediately
@property (nonatomic) BOOL sendOnlyOnce; //
@property (strong, nonatomic) NSDate *deliverAt;
@property (strong, nonatomic) SBMContent *content;
@property (nonatomic) SBActionType type;
@property (strong, nonatomic) NSArray <SBMTimeframe> *timeframes;
@property (strong, nonatomic) NSString *typeString;
//
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *dt;
@end

// Post objects

@protocol SBMReportAction @end
@interface SBMReportAction : JSONModel
@property (strong, nonatomic) NSString  *eid;
@property (strong, nonatomic) NSString  *pid;
@property (strong, nonatomic) NSDate    *dt;
@property (nonatomic) int trigger;
//@property (strong, nonatomic) NSString  *location; not necessary as we have the location in the event
@property (strong, nonatomic) NSDictionary *reaction;
@end

@protocol SBMPostLayout @end
@interface SBMPostLayout : JSONModel
@property (strong, nonatomic) NSDate *deviceTimestamp;
@property (strong, nonatomic) NSArray <SBMMonitorEvent> *events; // of SBMMonitorEvent type?
@property (strong, nonatomic) NSArray <SBMReportAction> *actions; // of SBMReportAction type?
@end
