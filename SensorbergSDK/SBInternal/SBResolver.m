//
//  SBResolver.m
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

#import "SBResolver.h"

#import "SensorbergSDK.h"

#import "SBInternalEvents.h"
#import "SBHTTPRequestManager.h"

#import <tolo/Tolo.h>

static NSString * const kAPIKeyPlaceholder = @"{apiKey}";

static NSString * const kBaseURLKey         = @"SBSDKbaseURLPath";
static NSString * const kInteractionsKey    = @"SBSDKinteractionsPath";
static NSString * const kSettingsKey        = @"SBSDKsettingsPath";
static NSString * const kAnalyticsKey       = @"SBSDKanalyticsPath";
static NSString * const kPingKey            = @"SBSDKpingPath";

NSString * const SBDefaultResolverURL = @"https://resolver.sensorberg.com";
NSString * const SBDefaultInteractionsPath = @"/layout";
NSString * const SBDefaultSettingsPath = @"/applications/{apiKey}/settings/iOS";
NSString * const SBDefaultAnalyticsPath = @"/layout";
NSString * const SBDefaultPingPath = @"/";

@interface SBResolver() {
    double timestamp;
    
    NSUserDefaults *defaults;
    
    NSString *cacheIdentifier;
    
    NSMutableDictionary *httpHeader;
    
    NSString *apiKey;
    
    NSString *baseURLString;
    
    NSString *interactionsPath;
    NSString *settingsPath;
    NSString *analyticsPath;
    NSString *pingPath;
}

@end

@implementation SBResolver

- (instancetype)initWithApiKey:(NSString*)key
{
    self = [super init];
    if (self) {
        //
        apiKey = key;
        /*
         Check if we have a value in NSUserDefaults
         if yes, use those values
         if not, use the default values
         
         */
        defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults valueForKey:kBaseURLKey]) {
            baseURLString = [defaults valueForKey:kBaseURLKey];
        } else {
            baseURLString = SBDefaultResolverURL;
        }
        baseURLString = [defaults valueForKey:kBaseURLKey] ? : SBDefaultResolverURL;
        interactionsPath = [defaults valueForKey:kInteractionsKey] ? : SBDefaultInteractionsPath;
        settingsPath = [defaults valueForKey:kSettingsKey] ? : SBDefaultSettingsPath;
        analyticsPath = [defaults valueForKey:kAnalyticsKey] ? : SBDefaultAnalyticsPath;
        pingPath = [defaults valueForKey:kPingKey] ? : SBDefaultPingPath;
        //
        httpHeader = [NSMutableDictionary new];
        NSString *ua = [[SBUtility userAgent] toJSONString];
        [httpHeader setObject:apiKey forKey:kAPIHeaderTag];
        [httpHeader setObject:ua forKey:kUserAgentTag];
        [httpHeader setObject:@"application/json" forKey:kContentTag];

        // IDFA
        NSString *IDFA = [keychain stringForKey:kIDFA];
        if (IDFA && IDFA.length > 0)
        {
            [httpHeader setObject:IDFA forKey:kIDFA];
        }
        else
        {
            [httpHeader removeObjectForKey:kIDFA];
        }
        //
        NSString *iid = [defaults valueForKey:kSBIdentifier];
        if (isNull(iid))
        {
            iid = [[NSUUID UUID] UUIDString];
            [defaults setValue:iid forKey:kSBIdentifier];
            [defaults synchronize];
        }
        //
        cacheIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:kCacheKey];
        if (![cacheIdentifier isEqualToString:apiKey])
        {
            [defaults setValue:apiKey forKey:kCacheKey];
            [defaults synchronize];
            
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            
            SBLog(@"Cleared cache because API Key changed");
        }
        //
        [httpHeader setObject:iid forKey:kInstallId];
        //
    }
    return self;
}

- (nonnull NSURL *)interactionsURL {
    NSString *urlString = [[baseURLString stringByAppendingString:interactionsPath] stringByReplacingOccurrencesOfString:kAPIKeyPlaceholder withString:apiKey];
    return [NSURL URLWithString:urlString];
}

- (nonnull NSURL *)settingsURL {
    NSString *urlString = [[baseURLString stringByAppendingString:settingsPath] stringByReplacingOccurrencesOfString:kAPIKeyPlaceholder withString:apiKey];
    return [NSURL URLWithString:urlString];
}

- (nonnull NSURL *)analyticsURL {
    NSString *urlString = [[baseURLString stringByAppendingString:analyticsPath] stringByReplacingOccurrencesOfString:kAPIKeyPlaceholder withString:apiKey];
    return [NSURL URLWithString:urlString];
}

- (nonnull NSURL *)pingURL {
    NSString *urlString = [[baseURLString stringByAppendingString:pingPath] stringByReplacingOccurrencesOfString:kAPIKeyPlaceholder withString:apiKey];
    return [NSURL URLWithString:urlString];
}

#pragma mark - Resolver calls

- (void)ping {
    timestamp = [NSDate timeIntervalSinceReferenceDate];
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    NSURL *requestURL = [self pingURL];
    
    [manager getDataFromURL:requestURL headerFields:httpHeader useCache:NO completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error)
        {
            PUBLISH(({
                SBEventPing *event = [SBEventPing new];
                event.error = [error copy];
                event;
            }));
            
            PUBLISH((({
                SBEventReachabilityEvent *event = [SBEventReachabilityEvent new];
                event.reachable = NO;
                event;
            })));
            
            return;
        }
        PUBLISH((({
            SBEventPing *event = [SBEventPing new];
            event.latency = [NSDate timeIntervalSinceReferenceDate]-timestamp;
            event;
        })));
        //
        PUBLISH((({
            SBEventReachabilityEvent *event = [SBEventReachabilityEvent new];
            event.reachable = YES;
            event;
        })));
    }];
    //
}

- (void)publishSBEventGetLayoutWithBeacon:(SBMBeacon*)beacon trigger:(SBTriggerType)trigger error:(NSError *)error
{
    PUBLISH(({
        SBEventGetLayout *event = [SBEventGetLayout new];
        event.error = [error copy];
        event.beacon = beacon;
        event.trigger = trigger;
        event;
    }));
}

- (void)requestLayoutForBeacon:(SBMBeacon*)beacon trigger:(SBTriggerType)trigger useCache:(BOOL)useCache {
    SBLog(@"❓ GET Layout %@|%@|%@",
          isNull(beacon) ? @"Without UUID" : beacon.description,
          trigger==1 ? @"Enter"  : @"Exit",
          useCache==YES ? @"Cached" : @"No cache");
    
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    NSURL *requestURL = [self interactionsURL];
    
    [manager getDataFromURL:requestURL headerFields:httpHeader useCache:useCache completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error)
        {
            [self publishSBEventGetLayoutWithBeacon:beacon trigger:trigger error:error];
            return;
        }
        
        NSError *parseError = nil;
        NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:&parseError];
        if (parseError)
        {
            [self publishSBEventGetLayoutWithBeacon:beacon trigger:trigger error:parseError];
            return;
        }
        NSError *jsonError;
        //
        SBMGetLayout *layout = [[SBMGetLayout alloc] initWithDictionary:responseObject error:&jsonError];
        //
        if (isNull(beacon))
        {
            PUBLISH((({
                SBEventGetLayout *event = [SBEventGetLayout new];
                event.error = [jsonError copy];
                event.layout = layout;
                event;
            })));
        }
        else
        {
            [layout checkCampaignsForBeacon:beacon trigger:trigger];
        }
    }];
}

- (void)postLayout:(SBMPostLayout*)postData {
    NSError *parseError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[postData toDictionary] options:0 error:&parseError];
    if (parseError)
    {
        PUBLISH((({
            SBEventPostLayout *event = [SBEventPostLayout new];
            event.error = [parseError copy];
            event;
        })));
        return;
    }
    
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    NSURL *requestURL = [self analyticsURL];
    
    [manager postData:data
                  URL:requestURL
         headerFields:httpHeader
           completion:^(NSData * _Nullable data, NSError * _Nullable error) {
               //
               SBEventPostLayout *postEvent = [SBEventPostLayout new];
               if (!isNull(error)) {
                   postEvent.error = [error copy];
               }
               postEvent.postData = postData;
               PUBLISH(postEvent);
    }];
}

- (void)requestSettingsWithAPIKey:(NSString *)key
{
    if (key.length == 0)
    {
        PUBLISH((({
            SBUpdateSettingEvent *event = [SBUpdateSettingEvent new];
            event.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorBadURL userInfo:nil];
            event;
        })));
        return;
    }

    NSURL *URL = [self settingsURL];
    
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    [manager getDataFromURL:URL headerFields:nil useCache:YES completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        NSError *blockError = error;
        NSDictionary *responseDict = nil;
        
        if (isNull(blockError))
        {
            NSError *parseError =nil;
            responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:&parseError];
            if (parseError)
            {
                blockError = parseError;
            }
        }
        //
        PUBLISH((({
            SBUpdateSettingEvent *event = [SBUpdateSettingEvent new];
            event.responseDictionary = responseDict;
            event.error = blockError;
            event.apiKey = key;
            event;
        })));
    }];
}

#pragma mark - Connection availability

- (BOOL)isConnected {
    return [[SBHTTPRequestManager sharedManager] isReachable];
}

#pragma mark - SBEventUpdateHeaders

SUBSCRIBE(SBEventUpdateHeaders) {
    
    NSString *IDFA = [keychain stringForKey:kIDFA];
    
    if (IDFA && IDFA.length>0) {
        [httpHeader setObject:IDFA forKey:kIDFA];
    } else {
        [httpHeader removeObjectForKey:kIDFA];
    }
}

#pragma mark - SBEventUpdateResolver

SUBSCRIBE(SBEventUpdateResolver) {
    BOOL hasChanged = NO;
    
    if (event.baseURL) {
        baseURLString = event.baseURL;
        [defaults setValue:baseURLString forKey:kBaseURLKey];
        hasChanged = YES;
    } else {
        baseURLString = SBDefaultResolverURL;
        [defaults removeObjectForKey:kBaseURLKey];
    }
    
    if (event.interactionsPath) {
        interactionsPath = event.interactionsPath;
        [defaults setValue:interactionsPath forKey:kInteractionsKey];
        hasChanged = YES;
    } else {
        interactionsPath = SBDefaultInteractionsPath;
        [defaults removeObjectForKey:kInteractionsKey];
    }
    
    if (event.settingsPath) {
        settingsPath = event.settingsPath;
        [defaults setValue:settingsPath forKey:kSettingsKey];
        hasChanged = YES;
    } else {
        settingsPath = SBDefaultSettingsPath;
        [defaults removeObjectForKey:kSettingsKey];
    }
    
    if (event.analyticsPath) {
        analyticsPath = event.analyticsPath;
        [defaults setValue:analyticsPath forKey:kAnalyticsKey];
        hasChanged = YES;
    } else {
        analyticsPath = SBDefaultAnalyticsPath;
        [defaults removeObjectForKey:kAnalyticsKey];
    }
    
    if (event.pingPath) {
        pingPath = event.pingPath;
        [defaults setValue:pingPath forKey:kPingKey];
        hasChanged = YES;
    } else {
        pingPath = SBDefaultPingPath;
        [defaults removeObjectForKey:kPingKey];
    }
    //
    [defaults synchronize];
    //
    if (hasChanged) {
        [self requestLayoutForBeacon:nil trigger:0 useCache:NO];
    }
}

@end
