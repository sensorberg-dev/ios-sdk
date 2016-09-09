//
//  SBAnalytics.m
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
#import <tolo/Tolo.h>

#import "GeoHash.h"

#import "SensorbergSDK.h"

#import "SBInternalEvents.h"

#import "SBAnalytics.h"

#import "SBResolver.h"

#pragma mark - Constants

NSString * const kSBEvents = @"events";
NSString * const kSBActions = @"actions";
NSString * const kSBConversions = @"conversions";

#define SECURE 0            // Before enabling, be aware that using the Keychain to store
                            // is very CPU intensive


@interface SBAnalytics () {
    NSUserDefaults *defaults;
    //
    NSMutableArray <SBMMonitorEvent> *events;
    //
    NSMutableArray <SBMReportAction> *actions;
    
    NSMutableArray <SBMReportConversion> *conversions;
}

@end

@implementation SBAnalytics

@synthesize events;
@synthesize actions;
@synthesize conversions;

- (instancetype)init
{
    self = [super init];
    if (self) {
#if SECURE
        //
        events = [NSMutableArray <SBMMonitorEvent> new];
        NSData *eventsData = [keychain dataForKey:kSBEvents];
        if (!isNull(eventsData)) {
            NSArray *keyedEvents = [NSKeyedUnarchiver unarchiveObjectWithData:eventsData];
            for (NSString *event in keyedEvents) {
                NSError *error;
                SBMMonitorEvent *toAdd = [[SBMMonitorEvent alloc] initWithString:event error:&error];
                if (error) {
//                    SBLog(@"Read event error: %@", error);
                }
                if (!isNull(toAdd)) {
                    [events addObject:toAdd];
                }
            }
        }
        //
        actions = [NSMutableArray <SBMReportAction> new];
        NSData *actionsData = [keychain dataForKey:kSBActions];
        if (!isNull(actionsData)) {
            NSArray *keyedActions = [NSKeyedUnarchiver unarchiveObjectWithData:actionsData];
            for (NSString *action in keyedActions) {
                NSError *error;
                SBMReportAction *toAdd = [[SBMReportAction alloc] initWithString:action error:&error];
                if (error) {
//                    SBLog(@"Read action error: %@", error);
                }
                if (!isNull(toAdd)) {
                    [actions addObject:toAdd];
                }
            }
        }
        //
        conversions = [NSMutableArray <SBMReportConversion> new];
        NSData *conversionsData = [keychain dataForKey:kSBConversions];
        if (!isNull(conversions)) {
            NSArray *keyedConversions = [NSKeyedUnarchiver unarchiveObjectWithData:conversionsData];
            for (NSString *conversion in keyedConversions) {
                NSError *error;
                SBMReportConversion *toAdd = [[SBMReportConversion alloc] initWithString:conversion error:&error];
                if (error) {
//                    SBLog(@"Conversion error: %@", error);
                }
                if (!isNull(toAdd)) {
                    [conversions addObject:toAdd];
                }
            }
        }
#else
        defaults = [[NSUserDefaults alloc] initWithSuiteName:kSBIdentifier];
        //
        NSArray *keyedEvents = [defaults objectForKey:kSBEvents];
        events = [NSMutableArray <SBMMonitorEvent> new];
        for (NSString *json in keyedEvents) {
            NSError *error;
            SBMMonitorEvent *event = [[SBMMonitorEvent alloc] initWithString:json error:&error];
            if (!error && !isNull(event)) {
                [events addObject:event];
            }
        }
        //
        NSArray *keyedActions = [defaults objectForKey:kSBActions];
        actions = [NSMutableArray <SBMReportAction> new];
        for (NSString *json in keyedActions) {
            NSError *error;
            SBMReportAction *action = [[SBMReportAction alloc] initWithString:json error:&error];
            if (!error && !isNull(action)) {
                [actions addObject:action];
            }
        }
        
        NSArray *keyedConversions = [defaults objectForKey:kSBConversions];
        conversions = [NSMutableArray <SBMReportConversion> new];
        for (NSString *json in keyedConversions) {
            NSError *error;
            SBMReportConversion *conversion = [[SBMReportConversion alloc] initWithString:json error:&error];
            if (!error && !isNull(conversion)) {
                [conversions addObject:conversion];
            }
        }
        //
#endif
    }
    return self;
}

- (NSArray <SBMMonitorEvent> *)events {
    return [NSArray <SBMMonitorEvent> arrayWithArray:events];
}

- (NSArray <SBMReportAction> *)actions {
    return [NSArray <SBMReportAction> arrayWithArray:actions];
}

- (NSArray <SBMReportConversion> *)conversions {
    return [NSArray <SBMReportConversion> arrayWithArray:conversions];
}

- (void)purgeHistory {
    [events removeAllObjects];
    [actions removeAllObjects];
    [conversions removeAllObjects];
}

- (void)restoreHistoryFromPostData:(SBMPostLayout*)postData {
    for (SBMMonitorEvent *event in postData.events) {
        [events addObject:event];
    }
    for (SBMReportAction *action in postData.actions) {
        [actions addObject:action];
    }
    for (SBMReportConversion *conversion in postData.conversions) {
        [conversions addObject:conversion];
    }
}

#pragma mark - Location events

SUBSCRIBE(SBEventRegionEnter) {
    //
    SBMMonitorEvent *enter = [SBMMonitorEvent new];
    enter.pid = event.beacon.fullUUID;
    enter.dt = [NSDate date];
    enter.trigger = 1;
    enter.location = [GeoHash hashForLatitude:event.location.coordinate.latitude longitude:event.location.coordinate.longitude length:9];
    //
    [events addObject:enter];
    //
    [self updateHistory];
}

SUBSCRIBE(SBEventRegionExit) {
    //
    SBMMonitorEvent *exit = [SBMMonitorEvent new];
    exit.pid = event.beacon.fullUUID;
    exit.dt = [NSDate date];
    exit.trigger = 2;
    exit.location = [GeoHash hashForLatitude:event.location.coordinate.latitude longitude:event.location.coordinate.longitude length:9];
    //
    [events addObject:exit];
    //
    [self updateHistory];
}

SUBSCRIBE(SBEventPerformAction) {
    SBMReportAction *report = [SBMReportAction new];
    report.eid = event.campaign.eid;
    if (event.campaign.fireDate) {
        report.dt = event.campaign.fireDate;
    } else {
        report.dt = [NSDate date];
    }
    report.trigger = event.campaign.trigger;
    report.pid = event.campaign.beacon.fullUUID;
    //
    [actions addObject:report];
    //
    [self updateHistory];
    //
}

SUBSCRIBE(SBEventInternalAction) {
    SBMReportAction *report = [SBMReportAction new];
    report.eid = event.campaign.eid;
    if (event.campaign.fireDate) {
        report.dt = event.campaign.fireDate;
    } else {
        report.dt = [NSDate date];
    }
    report.trigger = event.campaign.trigger;
    report.pid = event.campaign.beacon.fullUUID;
    //
    [actions addObject:report];
    //
    [self updateHistory];
    //
}

SUBSCRIBE(SBEventReportConversion) {
    if (event.error) {
        return;
    }
    SBMReportConversion *conversion = [SBMReportConversion new];
    conversion.dt = [NSDate date];
    conversion.action = event.action;
    conversion.type = event.conversionType;
    conversion.location = [GeoHash hashForLatitude:event.gps.coordinate.latitude longitude:event.gps.coordinate.longitude length:9];
    //
    [conversions addObject:conversion];
    //
    [self updateHistory];
}

#pragma mark - Resolver events

SUBSCRIBE(SBEventPostLayout) {
    if (isNull(event.error)) {
#if SECURE
        [keychain removeItemForKey:kSBEvents];
        [keychain removeItemForKey:kSBActions];
        [keychain removeItemForKey:kSBConversions];
#else
        [events removeAllObjects];
        [defaults removeObjectForKey:kSBEvents];
        
        [actions removeAllObjects];
        [defaults removeObjectForKey:kSBActions];
        
        [conversions removeAllObjects];
        [defaults removeObjectForKey:kSBConversions];
        
        [defaults synchronize];
#endif
    } else {
        [self restoreHistoryFromPostData:event.postData];
    }
}

- (void)updateHistory {
    NSMutableArray *keyedEvents = [NSMutableArray new];
    for (SBMMonitorEvent *event in events) {
        [keyedEvents addObject:[event toJSONString]];
    }
    //
    NSMutableArray *keyedActions = [NSMutableArray new];
    for (SBMReportAction *action in actions) {
        [keyedActions addObject:[action toJSONString]];
    }
    //
    NSMutableArray *keyedConversions = [NSMutableArray new];
    for (SBMReportConversion *conversion in conversions) {
        [keyedConversions addObject:[conversion toJSONString]];
    }
    //
#if SECURE
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedEvents] forKey:kSBEvents];
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedActions] forKey:kSBActions];
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedConversions] forKey:kSBConversions];
#else
    [defaults setObject:keyedEvents forKey:kSBEvents];
    [defaults setObject:keyedActions forKey:kSBActions];
    [defaults setObject:keyedConversions forKey:kSBConversions];
    //
    [defaults synchronize];
#endif
    //
    PUBLISH([SBEventReportHistory new]);
}

@end
