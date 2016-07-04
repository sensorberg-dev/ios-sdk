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

@interface SBResolver() {
    double timestamp;
    NSString *cacheIdentifier;
}

@property (nonnull, nonatomic, strong) NSMutableDictionary *httpHeader;
@property (nonnull, nonatomic, copy) NSString *baseURLString;

@end

@implementation SBResolver

- (instancetype)initWithResolver:(NSString*)resolverURL apiKey:(NSString*)apiKey
{
    self = [super init];
    if (self) {
        //
        _baseURLString = resolverURL;
        
        _httpHeader = [NSMutableDictionary new];
        NSString *ua = [[SBUtility userAgent] toJSONString];
        [_httpHeader setObject:apiKey forKey:kAPIHeaderTag];
        [_httpHeader setObject:ua forKey:kUserAgentTag];
        [_httpHeader setObject:@"application/json" forKey:kContentTag];

        // IDFA
        NSString *IDFA = [keychain stringForKey:kIDFA];
        if (IDFA && IDFA.length > 0)
        {
            [_httpHeader setObject:IDFA forKey:kIDFA];
        }
        else
        {
            [_httpHeader removeObjectForKey:kIDFA];
        }
        //
        NSString *iid = [[NSUserDefaults standardUserDefaults] valueForKey:kSBIdentifier];
        if (isNull(iid))
        {
            iid = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setValue:iid forKey:kSBIdentifier];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //
        cacheIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:kCacheKey];
        if (![cacheIdentifier isEqualToString:apiKey])
        {
            [[NSUserDefaults standardUserDefaults] setValue:apiKey forKey:kCacheKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            
            SBLog(@"Cleared cache because API Key changed");
        }
        //
        [_httpHeader setObject:iid forKey:kInstallId];
    }
    return self;
}

- (nullable NSURL *)requestURLStringWithPathComponents:(NSArray <NSString *> * _Nonnull)pathComponents
{
    NSMutableArray *components = [pathComponents mutableCopy];
    [components  insertObject:self.baseURLString atIndex:0];
    
    return [NSURL URLWithString:[NSString pathWithComponents:components]];
}
#pragma mark - Resolver calls

- (void)ping {
    timestamp = [NSDate timeIntervalSinceReferenceDate];
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    NSURL *requestURL = [self requestURLStringWithPathComponents:@[@"layout"]];
    
    [manager getDataFromURL:requestURL headerFields:self.httpHeader useCache:NO completion:^(NSData * _Nullable data, NSError * _Nullable error) {
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
    NSURL *requestURL = [self requestURLStringWithPathComponents:@[@"layout"]];
    
    [manager getDataFromURL:requestURL headerFields:self.httpHeader useCache:useCache completion:^(NSData * _Nullable data, NSError * _Nullable error) {
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
    NSURL *requestURL = [self requestURLStringWithPathComponents:@[@"layout"]];
    
    [manager postData:data URL:requestURL headerFields:self.httpHeader completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error)
        {
            PUBLISH((({
                SBEventPostLayout *event = [SBEventPostLayout new];
                event.error = [error copy];
                event;
            })));
        }
        else
        {
            PUBLISH([SBEventPostLayout new]);
        }
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
        [self.httpHeader setObject:IDFA forKey:kIDFA];
    } else {
        [self.httpHeader removeObjectForKey:kIDFA];
    }
}

@end
