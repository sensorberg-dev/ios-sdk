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
    NSMutableSet <SBMMonitorEvent> *events;
    //
    NSMutableSet <SBMReportAction> *actions;
    
    NSMutableSet <SBMReportConversion> *conversions;
}

@end

@implementation SBAnalytics

- (instancetype)init
{
    self = [super init];
    if (self) {
#if SECURE
        //
        events = [NSMutableSet <SBMMonitorEvent> new];
        NSData *eventsData = [keychain dataForKey:kSBEvents];
        if (!isNull(eventsData)) {
            NSArray *keyedEvents = [NSKeyedUnarchiver unarchiveObjectWithData:eventsData];
            NSSet *monitorEventSet = [NSSet setWithArray:keyedEvents];
            for (NSString *event in monitorEventSet) {
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
        actions = [NSMutableSet <SBMReportAction> new];
        NSData *actionsData = [keychain dataForKey:kSBActions];
        if (!isNull(actionsData)) {
            NSArray *keyedActions = [NSKeyedUnarchiver unarchiveObjectWithData:actionsData];
            NSSet *actionEventSet = [NSSet setWithArray:keyedActions];
            for (NSString *action in actionEventSet) {
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
        conversions = [NSMutableSet <SBMReportConversion> new];
        NSData *conversionsData = [keychain dataForKey:kSBConversions];
        if (!isNull(conversions)) {
            NSArray *keyedConversions = [NSKeyedUnarchiver unarchiveObjectWithData:conversionsData];
            NSSet *conversionEventSet = [NSSet setWithArray:keyedConversions];
            for (NSString *conversion in conversionEventSet) {
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
        NSSet *monitorEventSet = [NSSet setWithArray:keyedEvents];
        events = [NSMutableSet <SBMMonitorEvent> new];
        for (NSString *json in monitorEventSet) {
            NSError *error;
            SBMMonitorEvent *event = [[SBMMonitorEvent alloc] initWithString:json error:&error];
            if (!error && !isNull(event)) {
                [events addObject:event];
            }
        }
        //
        NSArray *keyedActions = [defaults objectForKey:kSBActions];
        NSSet *actionEventSet = [NSSet setWithArray:keyedActions];
        actions = [NSMutableSet <SBMReportAction> new];
        for (NSString *json in actionEventSet) {
            NSError *error;
            SBMReportAction *action = [[SBMReportAction alloc] initWithString:json error:&error];
            if (!error && !isNull(action)) {
                [actions addObject:action];
            }
        }
        
        NSArray *keyedConversions = [defaults objectForKey:kSBConversions];
        NSSet *conversionEventSet = [NSSet setWithArray:keyedConversions];
        conversions = [NSMutableSet <SBMReportConversion> new];
        for (NSString *json in conversionEventSet) {
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
    return (NSArray <SBMMonitorEvent> *)[NSArray arrayWithArray:events.allObjects];
}

- (NSArray <SBMReportAction> *)actions {
    return (NSArray <SBMReportAction> *)[NSArray arrayWithArray:actions.allObjects];
}

- (NSArray <SBMReportConversion> *)conversions {
    return (NSArray <SBMReportConversion> *)[NSArray arrayWithArray:conversions.allObjects];
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
    }
}

- (void)updateHistory {
    NSMutableSet *keyedEvents = [NSMutableSet new];
    for (SBMMonitorEvent *event in events) {
        [keyedEvents addObject:[event toJSONString]];
    }
    //
    NSMutableSet *keyedActions = [NSMutableSet new];
    for (SBMReportAction *action in actions) {
        [keyedActions addObject:[action toJSONString]];
    }
    //
    NSMutableSet *keyedConversions = [NSMutableSet new];
    for (SBMReportConversion *conversion in conversions) {
        [keyedConversions addObject:[conversion toJSONString]];
    }
    //
#if SECURE
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedEvents.allObjects] forKey:kSBEvents];
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedActions.allObjects] forKey:kSBActions];
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedConversions.allObjects] forKey:kSBConversions];
#else
    [defaults setObject:keyedEvents.allObjects forKey:kSBEvents];
    [defaults setObject:keyedActions.allObjects forKey:kSBActions];
    [defaults setObject:keyedConversions.allObjects forKey:kSBConversions];
    //
    [defaults synchronize];
#endif
    //
    PUBLISH([SBEventReportHistory new]);
}

@end
