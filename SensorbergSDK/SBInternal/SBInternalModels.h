//
//  SBInternalModels.h
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "SBModels.h"

@interface SBInternalModels : SBModel
@end

#pragma mark - Resolver models

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

#pragma mark - Post events

@protocol SBMMonitorEvent @end
@interface SBMMonitorEvent : JSONModel
@property (strong, nonatomic) NSString <Optional> *pid;
@property (strong, nonatomic) NSString <Optional> *location;
@property (strong, nonatomic) NSDate <Optional> *dt;
@property (nonatomic) int trigger;
@end

@protocol SBMSession @end
@interface SBMSession : JSONModel
- (instancetype)initWithUUID:(NSString*)UUID;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *enter;
@property (strong, nonatomic) NSDate *exit;
@property (strong, nonatomic) NSDate *lastSeen;
@end

#pragma mark - Post models

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

@protocol SBMGetLayout @end
@interface SBMGetLayout : JSONModel

@property (strong, nonatomic) NSArray <NSString*> *accountProximityUUIDs;
@property (nonatomic) int reportTrigger;
@property (strong, nonatomic) NSArray <SBMAction> *actions;
@property (nonatomic) BOOL currentVersion;
@property (strong, nonatomic) NSArray <SBMContent> *instantActions;

- (void)checkCampaignsForBeacon:(SBMBeacon *)beacon trigger:(SBTriggerType)trigger;

@end

#pragma mark - JSONValueTransformer

@interface JSONValueTransformer (SBResolver)
- (NSDate *)NSDateFromNSString:(NSString*)string;
- (NSString*)JSONObjectFromNSDate:(NSDate *)date;
@end