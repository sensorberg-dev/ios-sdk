//
//  SBAnalytics.h
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

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "SBInternalModels.h"

@interface SBAnalytics : NSObject

@property (nonatomic, readonly, copy) NSArray <SBMMonitorEvent> *events;

@property (nonatomic, readonly, copy) NSArray <SBMReportAction> *actions;

@property (nonatomic, readonly, copy) NSArray <SBMReportConversion> *conversions;

/**
 *  Removes from history the events, actions and conversions
 *  After posting the history, we purge the reported objects so that we don't report the same data multiple times
 */
- (void)removePostDataFromHistory:(SBMPostLayout *)postData;

/**
 *  Restore history when a POST request fails;
 *  If a SBEventPostLayout fails (for whatever reason) we recover the request data and re-insert it in the history, to report it at a later date
 *
 *  @param postData The SBMPostLayout object to put back into history
 */
- (void)restoreHistoryFromPostData:(SBMPostLayout*)postData;

@end
