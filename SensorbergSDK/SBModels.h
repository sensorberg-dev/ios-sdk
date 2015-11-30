//
//  SBModels.h
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "SBEnums.h"

@interface SBModel : NSObject
@end

@interface SBModels : NSObject
@end

@protocol  SBMBeacon @end
@interface SBMBeacon : NSObject
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;
- (instancetype)initWithCLBeacon:(CLBeacon*)beacon;
- (instancetype)initWithString:(NSString*)fullUUID;
- (NSString*)fullUUID;
@end

@protocol  SBCampaignAction @end
@interface SBCampaignAction : NSObject
@property (strong, nonatomic) NSDate *fireDate;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDictionary *payload;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *eid;
@property (nonatomic) SBTriggerType trigger;
@property (nonatomic) SBActionType type;
@property (strong, nonatomic) SBMBeacon *beacon;
@end