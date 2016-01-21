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

#import "SBEnums.h"

@interface SBModel : NSObject
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

#pragma mark - SBBluetooth models

#pragma mark - iBKS105:

#define kManufacturer           [CBUUID UUIDWithString:@"2A29"]
#define kSerialNumber           [CBUUID UUIDWithString:@"2A25"]
#define kHardwareRev            [CBUUID UUIDWithString:@"2A27"]
#define kSoftwareRev            [CBUUID UUIDWithString:@"2A28"]

#define kUUID                   [CBUUID UUIDWithString:@"FFF1"]
#define kMajor                  [CBUUID UUIDWithString:@"FFF2"]
#define kMinor                  [CBUUID UUIDWithString:@"FFF3"]

#define kPower                  [CBUUID UUIDWithString:@"FFF4"]
#define kInterval               [CBUUID UUIDWithString:@"FFF5"]
#define kTxPower                [CBUUID UUIDWithString:@"FFF6"]

#define kPassword               [CBUUID UUIDWithString:@"FFF7"]
#define kConfig                 [CBUUID UUIDWithString:@"FFF8"]
#define kState                  [CBUUID UUIDWithString:@"FFF9"]

#pragma mark -