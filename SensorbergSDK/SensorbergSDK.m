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

+ (NSDictionary *)defaultBeaconRegions {
    return @{
             @"D57092AC-DFAA-446C-8EF3-C81AA22815B5":@"Custom",
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
