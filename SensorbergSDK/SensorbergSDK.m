//
//  SensorbergSDK.m
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

#import "SensorbergSDK.h"

// for deviceName
#import <sys/utsname.h>
// for process information
#include <assert.h>
#include <sys/sysctl.h>

void sbLogFuncObjC_impl(const char * f, int l, NSString *fmt, ...) {
    va_list argList;
    va_start(argList, fmt);
    NSLogv([[NSString alloc] initWithFormat:@"%@", fmt], argList);
    va_end(argList);
}

float const kMonitoringDelay  = 15.0f;

@implementation SensorbergSDK

+ (NSString *)applicationIdentifier {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleIdentifierKey];
}

+ (NSDictionary *)defaultBeaconRegions {
    return @{
             @"73676723-7400-0000-FFFF-0000FFFF0000":@"SB-0",
             @"73676723-7400-0000-FFFF-0000FFFF0001":@"SB-1",
             @"73676723-7400-0000-FFFF-0000FFFF0002":@"SB-2",
             @"73676723-7400-0000-FFFF-0000FFFF0003":@"SB-3",
             @"73676723-7400-0000-FFFF-0000FFFF0004":@"SB-4",
             @"73676723-7400-0000-FFFF-0000FFFF0005":@"SB-5",
             @"73676723-7400-0000-FFFF-0000FFFF0006":@"SB-6",
             @"73676723-7400-0000-FFFF-0000FFFF0007":@"SB-7",
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D":@"Estimote",
             @"F7826DA6-4FA2-4E98-8024-BC5B71E0893E":@"Kontakt.io",
             @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6":@"Radius Network",
             @"F0018B9B-7509-4C31-A905-1A27D39C003C":@"Beacon Inside"
             };
}

@end
