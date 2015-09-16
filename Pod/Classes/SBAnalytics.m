//
//  SBAnalytics.m
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
#import <Tolo/tolo.h>

#import "SBAnalytics.h"

#import "SBMSession.h"

#import "SBEvent.h"

#import "SBProtocolEvents.h"

#import "SBLocationEvents.h"

#import "SBResolverModels.h"

#import "SBResolver.h"

#import <UICKeychainStore/UICKeychainStore.h>

#define kSBEvents   @"events"

#define kSBActions  @"actions"

#define SECURE      0

@interface SBAnalytics () {
#if SECURE
    UICKeyChainStore *keychain;
#else
    NSUserDefaults *defaults;
#endif
    //
    NSMutableArray <SBMMonitorEvent> *events;
    //
    NSMutableArray <SBMReportAction> *actions;
}

@end

@implementation SBAnalytics

@synthesize events;
@synthesize actions;

- (instancetype)init
{
    self = [super init];
    if (self) {
#if SECURE
        keychain = [UICKeyChainStore keyChainStoreWithService:[SBUtility applicationIdentifier]];
        keychain.accessibility = UICKeyChainStoreAccessibilityAlways;
        keychain.synchronizable = YES;
        //
        events = [NSMutableArray <SBMMonitorEvent> new];
        NSData *eventsData = [keychain dataForKey:kSBEvents];
        NSArray *keyedEvents = [NSKeyedUnarchiver unarchiveObjectWithData:eventsData];
        for (NSString *event in keyedEvents) {
            NSError *error;
            SBMMonitorEvent *toAdd = [[SBMMonitorEvent alloc] initWithString:event error:&error];
            if (error) {
                NSLog(@"Read event error: %@", error);
            }
            if (!isNull(toAdd)) {
                [events addObject:toAdd];
            }
        }
        //
        actions = [NSMutableArray <SBMReportAction> new];
        NSData *actionsData = [keychain dataForKey:kSBActions];
        NSArray *keyedActions = [NSKeyedUnarchiver unarchiveObjectWithData:actionsData];
        for (NSString *action in keyedActions) {
            NSError *error;
            SBMReportAction *toAdd = [[SBMReportAction alloc] initWithString:action error:&error];
            if (error) {
                NSLog(@"Read action error: %@", error);
            }
            if (!isNull(toAdd)) {
                [actions addObject:toAdd];
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

#pragma mark - Location events

SUBSCRIBE(SBERegionEnter) {
    //
    SBMMonitorEvent *enter = [SBMMonitorEvent new];
    enter.pid = event.fullUUID;
    enter.dt = now;
    enter.trigger = 1;
    //
    [events addObject:enter];
    //
    [self updateHistory];
}

SUBSCRIBE(SBERegionExit) {
    //
    SBMMonitorEvent *exit = [SBMMonitorEvent new];
    exit.pid = event.fullUUID;
    exit.dt = now;
    exit.trigger = 2;
    //
    [events addObject:exit];
    //
    [self updateHistory];
}

SUBSCRIBE(SBEventPerformAction) {
    SBMReportAction *report = [SBMReportAction new];
    report.eid = event.campaign.eid;
    report.dt = now;
    report.trigger = event.campaign.trigger;
    report.pid = event.campaign.beacon.fullUUID;
    report.location = @"";
    //
    [actions addObject:report];
    //
    [self updateHistory];
    //
    
}

//

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
#if SECURE
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedEvents] forKey:kSBEvents];
    [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:keyedActions] forKey:kSBActions];
#else
    [defaults setObject:keyedEvents forKey:kSBEvents];
    [defaults setObject:keyedActions forKey:kSBActions];
    //
    [defaults synchronize];
#endif
}

@end
