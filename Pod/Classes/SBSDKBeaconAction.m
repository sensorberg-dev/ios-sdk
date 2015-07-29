//
//  SBSDKBeaconAction.m
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

#import "SBSDKBeaconAction.h"
#import "SBSDKMacros.h"
#import "NSUUID+NSString.h"

#pragma mark -

@interface SBSDKBeaconAction ()

//
// Properties redefined to be read-write.
//

@property (nonatomic, strong) NSString *actionID;
@property (nonatomic) SBSDKBeaconEvent trigger;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, strong) NSNumber *suppressionTime;
@property (nonatomic, strong) SBSDKBeaconContent *content;
@property (nonatomic) SBSDKBeaconActionType type;
@property (nonatomic, strong) NSArray *timeFrames;
@property (nonatomic, strong) NSNumber *sendOnlyOnce;
@property (nonatomic, strong) NSDate *deliverAt;

@end

#pragma mark -

@implementation SBSDKBeaconAction

@synthesize actionID = _actionID;
@synthesize trigger = _trigger;
@synthesize delay = _delay;
@synthesize beacons = _beacons;
@synthesize suppressionTime = _suppressionTime;
@synthesize content = _content;
@synthesize type = _type;
@synthesize timeFrames = _timeFrames;
@synthesize sendOnlyOnce = _sendOnlyOnce;
@synthesize deliverAt = _deliverAt;


#pragma mark - Lifecycle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    NON_DESIGNATED_INIT(@"-initWithAction:");
}

- (instancetype)initWithAction:(NSDictionary *)action {
    if ((self = [super init])) {
        self.action = action;
    }

    return self;
}

#pragma clang diagnostic pop

#pragma mark - Beacon parsing

- (CLBeaconRegion *)beaconRegionFromBeaconPid:(NSString *)beaconPid {
    if (![beaconPid isKindOfClass:[NSString class]]) {
        return nil;
    }

    if (beaconPid.length != 42) {
        return nil;
    }

    NSString *UUIDString = [beaconPid substringToIndex:32];;
    NSString *correctedUUIDString = [NSUUID hyphenateUUIDString:UUIDString];

    NSString *majorString = [[beaconPid substringFromIndex:32] substringToIndex:5];
    NSString *minorString = [beaconPid substringFromIndex:37];

    NSString *fullRegionString = [NSString stringWithFormat:@"%@.%@", SBSDKManagerBeaconRegionIdentifier, beaconPid];
    
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:correctedUUIDString];

    return [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                   major:majorString.integerValue
                                                   minor:minorString.integerValue
                                              identifier:fullRegionString];
}

#pragma mark - Values

- (void)setAction:(NSDictionary *)action {
    if (action[@"eid"] && [action[@"eid"] isKindOfClass:[NSString class]]) {
        self.actionID = (NSString *)action[@"eid"];
    }
    if (action[@"trigger"] && [action[@"trigger"] isKindOfClass:[NSNumber class]]) {
        NSNumber *trigger = (NSNumber *)action[@"trigger"];

        switch (trigger.integerValue) {
            case 1:
                self.trigger = SBSDKBeaconEventEnter;
                break;
                
            case 2:
                self.trigger = SBSDKBeaconEventExit;
                break;

            case 3:
                self.trigger = SBSDKBeaconEventEnterExit;
                break;

            default:
                break;
        }
    }

    if (action[@"type"] && [action[@"type"] isKindOfClass:[NSNumber class]]) {
        NSNumber *type = (NSNumber *)action[@"type"];

        switch (type.integerValue) {
            case 1:
                self.type = SBSDKBeaconActionTypeTextMessage;
                break;
                
            case 2:
                self.type = SBSDKBeaconActionTypeUrlTextMessage;
                break;

            case 3:
                self.type = SBSDKBeaconActionTypeInAppTextMessage;
                break;

            default:
                self.type = SBSDKBeaconActionTypeUnknown;
                break;
        }
    }

    if (action[@"beacons"] && [action[@"beacons"] isKindOfClass:[NSArray class]]) {
        [self parseBeaconsArray:action[@"beacons"]];
    }

    if (action[@"delay"] && [action[@"delay"] isKindOfClass:[NSNumber class]]) {
        self.delay = (NSNumber *)action[@"delay"];
        self.deliverAt = Nil;
    } else {
        self.delay = [NSNumber numberWithBool:FALSE];
    }

    if (action[@"suppressionTime"] && [action[@"suppressionTime"] isKindOfClass:[NSNumber class]]) {
        self.suppressionTime = (NSNumber *)action[@"suppressionTime"];
    } else {
        self.suppressionTime = [NSNumber numberWithBool:FALSE];
    }

    if (action[@"content"] && [action[@"content"] isKindOfClass:[NSDictionary class]]) {
        [self parseContentDictionary:action[@"content"]];
    }
    
    if (action[@"timeframes"] && [action[@"timeframes"] isKindOfClass:[NSArray class]]) {
        self.timeFrames = [action[@"timeframes"] copy];
    }
    
    if (action[@"sendOnlyOnce"] && [action[@"sendOnlyOnce"] isKindOfClass:[NSNumber class]]) {
        self.sendOnlyOnce = action[@"sendOnlyOnce"];
    } else {
        self.sendOnlyOnce = [NSNumber numberWithBool:FALSE];
    }
    
    if (action[@"deliverAt"] && [action[@"deliverAt"] isKindOfClass:[NSString class]]) {
        
        NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        
        self.deliverAt = [dateFormater dateFromString:action[@"deliverAt"]];
        self.delay = [NSNumber numberWithBool:FALSE];
    } else {
        self.deliverAt = Nil;
    }
}

- (void)parseBeaconsArray:(NSArray *)beacons {
    if ([beacons isKindOfClass:[NSArray class]]) {
        NSMutableArray *newBeacons = [NSMutableArray array];

        for (id eachObject in (NSArray *)beacons) {
            if ([eachObject isKindOfClass:[NSString class]]) {
                [newBeacons addObject:[self beaconRegionFromBeaconPid:(NSString *)eachObject]];
            }
        }

        self.beacons = [newBeacons copy];
    }
}

- (void)parseContentDictionary:(NSDictionary *)content {
    if ([content isKindOfClass:[NSDictionary class]]) {
        self.content = [[SBSDKBeaconContent alloc] initWithContent:content];
    }
}

#pragma mark- utilities

- (NSString*) description {
    
    NSString* describtion = [NSString stringWithFormat:@"SBSDKBeaconAction: %p\nactionID: %@\ntype: %@\ncontent: %@\ntrigger: %@\nbeacons: %@\ndelay: %@ s\nsuppressionTime: %@ s\ntimeFrames: %@\ndeliverAt: %@\nsendOnlyOnce: %@",self,self.actionID,self.typeString,self.content,self.triggerString,self.beacons,self.delay,self.suppressionTime,self.timeFrames, self.deliverAt, [self.sendOnlyOnce boolValue] ? @"yes" : @"no"];
    
    return [describtion stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"];
    
}

- (NSString*) triggerString {
    
    NSString* triggerString;
    
    switch (self.trigger) {
        case SBSDKBeaconEventEnter:
            triggerString = @"SBSDKBeaconEventEnter";
            break;
        case SBSDKBeaconEventExit:
            triggerString = @"SBSDKBeaconEventExit";
            break;
        case SBSDKBeaconEventEnterExit:
            triggerString = @"SBSDKBeaconEventEnterExit";
            break;
        default:
            triggerString = @"";
    }
    
    return triggerString;
}

- (NSString*) typeString {
    
    NSString* typeString = @"";
    
    switch (self.type) {
        case SBSDKBeaconActionTypeTextMessage:
            typeString = @"SBSDKBeaconActionTypeTextMessage";
            break;
        case SBSDKBeaconActionTypeInAppTextMessage:
            typeString = @"SBSDKBeaconActionTypeInAppTextMessage";
            break;
        case SBSDKBeaconActionTypeUnknown:
            typeString = @"SBSDKBeaconActionTypeUnknown";
            break;
        case SBSDKBeaconActionTypeUrlTextMessage:
            typeString = @"SBSDKBeaconActionTypeUrlTextMessage";
            break;
        default:
            typeString = @"";
    }
    
    return typeString;
}

@end
