//
//  SensorbergSDK.m
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

#import "SensorbergSDK.h"

// for deviceName
#import <sys/utsname.h>
// for process information
#include <assert.h>
#include <sys/sysctl.h>

void sbLogFuncC_impl(const char * f, int l, const char * fmt, ...) {
    va_list argList;
    va_start(argList, fmt);
    NSLogv([[NSString alloc] initWithFormat:@"|%@:%d| %s", [@(f) lastPathComponent], l, fmt], argList);
    va_end(argList);
}

void sbLogFuncObjC_impl(const char * f, int l, NSString *fmt, ...) {
    va_list argList;
    va_start(argList, fmt);
    //    NSLogv([[NSString alloc] initWithFormat:@"|%@:%d| %@", [@(f) lastPathComponent], l, fmt], argList);
    NSLogv([[NSString alloc] initWithFormat:@"%@", fmt], argList);
    va_end(argList);
    //    printf([fmt cStringUsingEncoding:NSUTF8StringEncoding]);
}

NSString *const kSBDefaultResolver = @"https://resolver.sensorberg.com";

NSString *const kSBDefaultAPIKey = @"0000000000000000000000000000000000000000000000000000000000000000";

NSString *const kSBIdentifier = @"com.sensorberg.sdk";
NSString *const APIDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

NSString *kPostLayout = @"SBPostLayout";

NSString *kSBAppActive = @"SBAppActive";

float kPostSuppression = 15; // delay (in minutes) between layout posts

@implementation SensorbergSDK

+ (NSString *)applicationIdentifier {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleIdentifierKey];
}

+ (NSArray *)defaultBeaconRegions {
    return @[
             @"D57092AC-DFAA-446C-8EF3-C81AA22815B5", // Sensorberg
             @"73676723-7400-0000-FFFF-0000FFFF0000",
             @"73676723-7400-0000-FFFF-0000FFFF0001",
             @"73676723-7400-0000-FFFF-0000FFFF0002",
             @"73676723-7400-0000-FFFF-0000FFFF0003",
             @"73676723-7400-0000-FFFF-0000FFFF0004",
             @"73676723-7400-0000-FFFF-0000FFFF0005",
             @"73676723-7400-0000-FFFF-0000FFFF0006",
             @"73676723-7400-0000-FFFF-0000FFFF0007",
             @"b9407f30-f5f8-466e-aff9-25556b57fe6d", // EM
             @"f7826da6-4fa2-4e98-8024-bc5b71e0893e", // KT
             @"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6", // RN
             @"f0018b9b-7509-4c31-a905-1a27d39c003c", // BI
             ];
}

#pragma mark - DEBUG
// don't change the code bellow!
+ (BOOL)debugging
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

@end
