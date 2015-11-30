//
//  SBMGetLayout.m
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

#import "SBMGetLayout.h"

#import "SBProtocolModels.h"
#import "SBProtocolEvents.h"

#import <tolo/Tolo.h>

@implementation SBMGetLayout

- (void)checkCampaignsForBeacon:(SBMBeacon *)beacon trigger:(SBTriggerType)trigger {
    //
    BOOL shouldFire;
    //
    for (SBMAction *action in self.actions) {
        for (SBMBeacon *actionBeacon in action.beacons) {
            shouldFire = YES;
            if ([actionBeacon.fullUUID isEqualToString:beacon.fullUUID]) {
                if (trigger==action.trigger || action.trigger==kSBTriggerEnterExit) {
                    for (SBMTimeframe *time in action.timeframes) {
                        if (!isNull(time.start) && [now laterDate:time.start]==time.start) {
                            SBLog(@"❌ %@-%@",now,time.start);
                            shouldFire = NO;
                        }
                        //
                        if (!isNull(time.end) && [now earlierDate:time.end]==time.end) {
                            SBLog(@"❌ %@-%@",now,time.end);
                            shouldFire = NO;
                        }
                        //
                    }
                    //
                    if (action.sendOnlyOnce) {
                        if ([self campaignHasFired:action.eid]) {
                            SBLog(@"❌ Already fired");
                            shouldFire = NO;
                        }
                    }
                    //
                    SBCampaignAction *campaignAction = [SBCampaignAction new];
                    //
                    if (!isNull(action.deliverAt)) {
                        if ([action.deliverAt earlierDate:now]==action.deliverAt) {
                            SBLog(@"❌ Send at it's in the past");
                            shouldFire = NO;
                        } else {
                            SBLog(@"❌ Will deliver at: %@",action.deliverAt);
                            campaignAction.fireDate = action.deliverAt;
                        }
                    }
                    //
                    if (action.suppressionTime) {
                        NSTimeInterval previousFire = [self secondsSinceLastFire:action.eid];
                        if (previousFire > 0 && previousFire < action.suppressionTime) {
                            SBLog(@"❌ Suppressed");
                            shouldFire = NO;
                        }
                    }
                    //
                    if (action.delay) {
                        campaignAction.fireDate = [NSDate dateWithTimeIntervalSinceNow:action.delay];
                        SBLog(@"🔵 Delayed %i",action.delay);
                    }
                    //
                    if (shouldFire) {
                        campaignAction.eid = action.eid;
                        campaignAction.subject = action.content.subject;
                        campaignAction.body = action.content.body;
                        campaignAction.payload = action.content.payload;
                        campaignAction.trigger = trigger;
                        campaignAction.type = action.type;
                        //
                        campaignAction.beacon = beacon;
                        //
                        SBLog(@"🔥 Campaign \"%@\"",campaignAction.subject);
                        //
                        PUBLISH((({
                            SBEventPerformAction *event = [SBEventPerformAction new];
                            event.campaign = campaignAction;
                            event;
                        })));
                        //
                        if (action.reportImmediately) {
                            PUBLISH([SBEventReportHistory new]);
                        }
                    }
                    //
                } else {
                    SBLog(@"❌ TRIGGER %lu-%lu",(unsigned long)trigger,(unsigned long)action.trigger);
                }
            } else {
                //
            }
        }
    }
    //
}

#pragma mark - Helper methods

- (BOOL)campaignHasFired:(NSString*)eid {
    return !isNull([keychain stringForKey:eid]);
}

- (NSTimeInterval)secondsSinceLastFire:(NSString*)eid {
    //
    NSString *lastFireString = [keychain stringForKey:eid];
    if (isNull(lastFireString)) {
        return -1;
    }
    //
    NSDate *lastFireDate = [dateFormatter dateFromString:lastFireString];
    return [now timeIntervalSinceDate:lastFireDate];
}

@end
