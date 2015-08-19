//
//  SBUtility.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 03/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBUtility.h"

// for deviceName
#import <sys/utsname.h>
// for process information
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

NSString *const kSBIdentifier = @"com.sensorberg.sdk";
NSString *const APIDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

@implementation SBUtility

+ (NSString *)userAgent {
    NSBundle *sdkBundle = [NSBundle bundleForClass:[self class]];
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *bundleDisplayName = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleNameKey];
    NSString *bundleIdentifier = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleIdentifierKey];
    NSString *bundleVersion = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    NSString *sdkVersion = [sdkBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    NSString *iosVersion = [NSString stringWithFormat:@"iOS %lu.%lu.%lu", (unsigned long)osVersion.majorVersion, (unsigned long)osVersion.minorVersion, (unsigned long)osVersion.patchVersion];
    
    NSString *sdkString = [NSString stringWithFormat:@"Sensorberg SDK %@", sdkVersion];
    
    return [NSString stringWithFormat:@"%@/%@/%@ (%@) (%@) %@",
            bundleDisplayName,
            bundleIdentifier,
            bundleVersion,
            iosVersion,
            [SBUtility deviceName],
            sdkString];
}

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSArray *)defaultBeacons {
    return @[@"D57092AC-DFAA-446C-8EF3-C81AA22815B5",
             @"73676723-7400-0000-FFFF-0000FFFF0000",
             @"73676723-7400-0000-FFFF-0000FFFF0001",
             @"73676723-7400-0000-FFFF-0000FFFF0002",
             @"73676723-7400-0000-FFFF-0000FFFF0003",
             @"73676723-7400-0000-FFFF-0000FFFF0004",
             @"73676723-7400-0000-FFFF-0000FFFF0005",
             @"73676723-7400-0000-FFFF-0000FFFF0006",
             @"73676723-7400-0000-FFFF-0000FFFF0007"];
}

#pragma mark - DEBUG
// don't change the code bellow!
- (BOOL)debugging
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
