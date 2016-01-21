//
//  SBUtility.m
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

#import "SBUtility.h"

#import "SensorbergSDK.h"

// for deviceName
#import <sys/utsname.h>
// for process information
#include <assert.h>
#include <sys/sysctl.h>

NSDateFormatter *dateFormatter;

UICKeyChainStore *keychain;

emptyImplementation(SBMUserAgent)

@implementation SBUtility

//if (![SBUtility debugging]) {
//    SBLog(@"📄 console.log");
//    NSString *logPath = [kSBCacheFolder stringByAppendingPathComponent:@"console.log"];
//    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
//}

+ (NSString *)userAgent {
    NSBundle *sdkBundle = [NSBundle bundleForClass:[self class]];
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *bundleDisplayName = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleNameKey];
    NSString *bundleIdentifier = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleIdentifierKey];
    NSString *bundleVersion = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    NSString *sdkVersion = [sdkBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    NSString *iosVersion = [NSString stringWithFormat:@"iOS/%lu.%lu.%lu", (unsigned long)osVersion.majorVersion, (unsigned long)osVersion.minorVersion, (unsigned long)osVersion.patchVersion];
    //
    NSString *sdkString = [NSString stringWithFormat:@"%@", sdkVersion];
    //
    SBMUserAgent *ua = [SBMUserAgent new];
    ua.os = [NSString stringWithFormat:@"%@/%@",iosVersion,[SBUtility deviceName]];
    ua.sdk = sdkString;
    ua.app = [NSString stringWithFormat:@"%@/%@/%@",bundleIdentifier,bundleDisplayName,bundleVersion];
    //
    return [ua toJSONString];
}

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)applicationIdentifier {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleIdentifierKey];
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
