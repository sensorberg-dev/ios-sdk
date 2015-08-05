//
//  SBSDKDeviceID.m
//  SensorbergSDK
//
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

#import "SBSDKDeviceID.h"
#import <sys/utsname.h>
#import "NSUUID+NSString.h"
#import "SensorbergSDK+Version.h"

#pragma mark -

// Domain used by the Sensorberg SDK for NSUserDefaults
NSString *const SBSDKDeviceIDUserDefaultsDomain = @"com.sensorberg.sdk.ios.userdefaults.deviceid";

#pragma mark -

@implementation SBSDKDeviceID

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *deviceId = [userDefaults stringForKey:SBSDKDeviceIDUserDefaultsDomain];

        if (deviceId == nil){
            [SBSDKDeviceID resetDeviceIdentifier];
        }
    }

    return self;
}

#pragma mark - Device Identifier handling

+ (void)resetDeviceIdentifier {
    NSString *deviceId = [[NSUUID UUID] UUIDString];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:deviceId forKey:SBSDKDeviceIDUserDefaultsDomain];

    [userDefaults synchronize];
}

#pragma mark - Values

- (NSString *)UUIDString {
    return [[NSUserDefaults standardUserDefaults] stringForKey:SBSDKDeviceIDUserDefaultsDomain];
}

- (NSString *)userAgent {
    NSBundle *bundle = [NSBundle mainBundle];


    NSString *bundleDisplayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *bundleIdentifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *bundleVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];

    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    NSString *iosVersion = [NSString stringWithFormat:@"iOS %lu.%lu.%lu", (unsigned long)osVersion.majorVersion, (unsigned long)osVersion.minorVersion, (unsigned long)osVersion.patchVersion];

    NSString *sdkString = [NSString stringWithFormat:@"Sensorberg SDK %@", SBSDKSensorbergSDKVersionString];

    return [NSString stringWithFormat:@"%@/%@/%@ (%@) (%@) %@",
                                      bundleDisplayName,
                                      bundleIdentifier,
                                      bundleVersion,
                                      iosVersion,
                                      [self modelString],
                                      sdkString];
}

- (NSString *)modelString {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
