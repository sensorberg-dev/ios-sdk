//
//  SBEvent.m
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

#import "SBEvent.h"

#import "SensorbergSDK.h"

#import <CoreBluetooth/CoreBluetooth.h>

emptyImplementation(SBEvent)

#pragma mark - Protocol events

@implementation SBEventPerformAction

- (NSDictionary *)toDictionary {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    if (self.campaign.fireDate) {
        [ret setValue:[NSNumber numberWithDouble:[self.campaign.fireDate timeIntervalSince1970]] forKey:@"fireDate"];
    } else {
        [ret setValue:[NSNumber numberWithDouble:[[NSDate dateWithTimeIntervalSinceNow:1] timeIntervalSince1970]] forKey:@"fireDate"];
    }
    [ret setValue:self.campaign.subject forKey:@"subject"];
    [ret setValue:self.campaign.body forKey:@"body"];
    if (self.campaign.payload) {
        [ret setValue:self.campaign.payload forKey:@"payload"];
    }
    if (self.campaign.url) {
        [ret setValue:self.campaign.url forKey:@"url"];
    }
    [ret setValue:self.campaign.eid forKey:@"eid"];
    [ret setValue:[NSNumber numberWithInteger:self.campaign.trigger] forKey:@"trigger"];
    [ret setValue:[NSNumber numberWithInteger:self.campaign.type] forKey:@"type"];
    [ret setValue:self.campaign.uuid forKey:@"uuid"];
    return ret;
}

@end

emptyImplementation(SBEventResetManager)

emptyImplementation(SBEventReportHistory)

emptyImplementation(SBEventReportConversion)

emptyImplementation(SBEventUpdateHeaders)

emptyImplementation(SBEventStatusUpdate)

#pragma mark - Location events

emptyImplementation(SBEventRangedBeacon)

emptyImplementation(SBEventRegionEnter)

emptyImplementation(SBEventRegionExit)

#pragma mark - Authorization events

emptyImplementation(SBEventLocationAuthorization)

emptyImplementation(SBEventBluetoothAuthorization)

emptyImplementation(SBEventNotificationsAuthorization)

#pragma mark - CoreBluetooth events

emptyImplementation(SBEventBluetoothEmulation)

emptyImplementation(SBEventDeviceDiscovered)

emptyImplementation(SBEventDeviceUpdated)

emptyImplementation(SBEventDeviceDisconnected)

emptyImplementation(SBEventDeviceConnected)

emptyImplementation(SBEventServicesUpdated)

emptyImplementation(SBEventCharacteristicsUpdate)

emptyImplementation(SBEventCharacteristicWrite)

#pragma mark - Magnetometer events

emptyImplementation(SBEventMagnetometerUpdate)

#pragma mark - Application life-cycle events

emptyImplementation(SBEventApplicationLaunched)

emptyImplementation(SBEventApplicationActive)

emptyImplementation(SBEventApplicationForeground)

emptyImplementation(SBEventApplicationWillResignActive)

emptyImplementation(SBEventApplicationWillTerminate)

emptyImplementation(SBEventApplicationWillEnterForeground)

emptyImplementation(SBEventApplicationDidEnterBackground)

#pragma mark - Resolver events

emptyImplementation(SBEventReachabilityEvent)

emptyImplementation(SBEventUpdateResolver)

#pragma mark - SBSettings events

emptyImplementation(SBUpdateSettingEvent);

emptyImplementation(SBSettingEvent);
