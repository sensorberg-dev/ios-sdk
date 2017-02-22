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

#import "SBSettings.h"

#pragma mark - Constants

NSString * const kSBEvents = @"events";
NSString * const kSBActions = @"actions";
NSString * const kSBConversions = @"conversions";

@interface SBAnalytics () {
    NSUserDefaults *defaults;
    //
    NSMutableSet <SBMMonitorEvent> *events;
    //
    NSMutableSet <SBMReportAction> *actions;
    
    NSMutableSet <SBMReportConversion> *conversions;
    
    CLLocation *currentLocation;
}

@end

@implementation SBAnalytics

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    enter.pid = event.beacon.tid;
    enter.dt = [NSDate date];
    enter.trigger = 1;
    enter.location = [GeoHash hashForLatitude:event.location.coordinate.latitude longitude:event.location.coordinate.longitude length:9];
    enter.pairingId = event.pairingId;
    //
    [events addObject:enter];
    //
    [self updateHistory];
}

SUBSCRIBE(SBEventRegionExit) {
    //
    SBMMonitorEvent *exit = [SBMMonitorEvent new];
    exit.pid = event.beacon.tid;
    exit.dt = [NSDate date];
    exit.trigger = 2;
    exit.location = [GeoHash hashForLatitude:event.location.coordinate.latitude longitude:event.location.coordinate.longitude length:9];
    exit.pairingId = event.pairingId;
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
    report.pid = event.campaign.beacon.tid;
    if (currentLocation) {
        report.location = [GeoHash hashForLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude length:9];
    }
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
    report.pid = event.campaign.beacon.tid;
    if (currentLocation) {
        report.location = [GeoHash hashForLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude length:9];
    }
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

SUBSCRIBE(SBEventLocationUpdated) {
    if (event.error) {
        return;
    }
    currentLocation = event.location;
}

#pragma mark - Resolver events

SUBSCRIBE(SBEventPostLayout) {
    if (isNull(event.error)) {
        for (SBMMonitorEvent *monitor in event.postData.events)
        {
            [events removeObject:monitor];
        }
        
        for (SBMReportAction *action in event.postData.actions)
        {
            [actions removeObject:action];
        }
        
        for (SBMReportConversion *conversion in event.postData.conversions)
        {
            [conversions removeObject:conversion];
        }
        //
        [self updateHistory];
    }
}

- (void)updateHistory {
    NSMutableSet *keyedEvents = [NSMutableSet new];
    NSLock *mutableSetLock = [[NSLock alloc] init];
    [events.allObjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *jsonString = [obj toJSONString];
        [mutableSetLock lock];
        [keyedEvents addObject:jsonString];
        [mutableSetLock unlock];
    }];
    //
    NSMutableSet *keyedActions = [NSMutableSet new];
    [actions.allObjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *jsonString = [obj toJSONString];
        [mutableSetLock lock];
        [keyedEvents addObject:jsonString];
        [mutableSetLock unlock];
    }];
    //
    NSMutableSet *keyedConversions = [NSMutableSet new];
    [conversions.allObjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *jsonString = [obj toJSONString];
        [mutableSetLock lock];
        [keyedEvents addObject:jsonString];
        [mutableSetLock unlock];
    }];
    //
    [defaults setObject:keyedEvents.allObjects forKey:kSBEvents];
    [defaults setObject:keyedActions.allObjects forKey:kSBActions];
    [defaults setObject:keyedConversions.allObjects forKey:kSBConversions];
    //
    [defaults synchronize];
    //
    PUBLISH([SBEventReportHistory new]);
}

@end
