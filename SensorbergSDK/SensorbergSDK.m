//
//  SensorbergSDK.m
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
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

float kPostSuppression = 0; // delay (in minutes) between layout posts

@implementation SensorbergSDK

+ (NSString *)applicationIdentifier {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleIdentifierKey];
}

+ (NSArray *)defaultBeacons {
    return @[
             // Sensorberg beacons
             @"D57092AC-DFAA-446C-8EF3-C81AA22815B5",
             @"73676723-7400-0000-FFFF-0000FFFF0000",
             @"73676723-7400-0000-FFFF-0000FFFF0001",
             @"73676723-7400-0000-FFFF-0000FFFF0002",
             @"73676723-7400-0000-FFFF-0000FFFF0003",
             @"73676723-7400-0000-FFFF-0000FFFF0004",
             @"73676723-7400-0000-FFFF-0000FFFF0005",
             @"73676723-7400-0000-FFFF-0000FFFF0006",
             @"73676723-7400-0000-FFFF-0000FFFF0007"
             // Sensoro
             
             // Estimote
             
             //
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
