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
#import "SBSettings.h"

// for deviceName
#import <sys/utsname.h>

NSDateFormatter *dateFormatter;

UICKeyChainStore *keychain;

emptyImplementation(SBMUserAgent)

NSString *const kSensorbergSDKVersion = @"2.4";

NSString *const kAPIHeaderTag   = @"X-Api-Key";
NSString *const kUserAgentTag   = @"User-Agent";
NSString *const kContentTag     = @"Content-Type";
NSString *const kInstallId      = @"X-iid";
NSString *const kIDFA           = @"X-aid";

NSString *const kSBDefaultAPIKey = @"0000000000000000000000000000000000000000000000000000000000000000";

NSString *const kSBIdentifier = @"com.sensorberg.sdk";
NSString *const APIDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

NSString *kPostLayout = @"SBPostLayout";
NSString *kSBAppActive = @"SBAppActive";

NSString *const kCacheKey = @"cacheKey";

@implementation SBUtility

+ (void)load
{
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    dateFormatter.dateFormat = APIDateFormat;
}

+ (SBMUserAgent *)userAgent {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundleDisplayName = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleNameKey];
    NSString *bundleIdentifier = [SensorbergSDK applicationIdentifier];
    NSString *bundleVersion = [mainBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    NSString *iosVersion = [NSString stringWithFormat:@"iOS/%lu.%lu.%lu", (unsigned long)osVersion.majorVersion, (unsigned long)osVersion.minorVersion, (unsigned long)osVersion.patchVersion];
    //
    SBMUserAgent *ua = [SBMUserAgent new];
    ua.os = [NSString stringWithFormat:@"%@/%@",iosVersion,[SBUtility deviceName]];
    ua.sdk = kSensorbergSDKVersion;
    ua.app = [NSString stringWithFormat:@"%@/%@/%@",bundleIdentifier,bundleDisplayName,bundleVersion];
    //
    return ua;
}

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
