//
//  SBResolver.m
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

#import "SBResolver.h"

#import "SBResolver+Events.h"
#import "SBResolver+Models.h"
#import "JSONValueTransformer+SBResolver.h"

#import "SBManager.h"

#define kAPIHeaderTag   @"X-Api-Key"
#define kUserAgentTag   @"User-Agent"

@interface SBResolver() {
    AFHTTPRequestOperationManager *manager;
    NSOperationQueue *operationQueue;
    //
    BOOL noCache;
}

@end

emptyImplementation(SBReachabilityEvent)

@implementation SBResolver

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kSBResolver]];
        //
        NSString *ua = [SBUtility userAgent];
        [manager.requestSerializer setValue:kSBAPIKey forHTTPHeaderField:kAPIHeaderTag];
        [manager.requestSerializer setValue:ua forHTTPHeaderField:kUserAgentTag];
        //
        operationQueue = manager.operationQueue;
        //
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    PUBLISH(({
                        SBReachabilityEvent *event = [SBReachabilityEvent new];
                        event.reachable = YES;
                        event;
                    }));
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    PUBLISH(({
                        SBReachabilityEvent *event = [SBReachabilityEvent new];
                        event.reachable = NO;
                        event;
                    }));
                    break;
            }
        }];
    }
    return self;
}

#pragma mark - External methods

- (void)updateLayout {
    noCache = YES;
    //
    [self requestLayout];
}

#pragma mark - Resolver calls

- (void)ping {
    AFHTTPRequestOperation *ping = [manager GET:@"ping"
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            //
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            //
                                        }];
    //
    [ping resume];
}

- (void)requestLayout {
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    //
    if (noCache) {
        noCache = false;
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    //
    AFHTTPRequestOperation *getLayout = [manager GET:@"layout"
                                          parameters:@{}
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 NSError *error;
                                                 //
                                                 SBMLayout *layout = [[SBMLayout alloc] initWithDictionary:responseObject error:&error];
                                                 //
                                                 SBELayout *event = [SBELayout new];
                                                 event.error = [error copy];
                                                 event.layout = layout;
                                                 PUBLISH(event);
                                                 //
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 SBELayout *event = [SBELayout new];
                                                 event.error = [error copy];
                                                 PUBLISH(event);
                                             }];
    //
    [getLayout resume];
}

- (void)postLayout:(NSDictionary*)postData {
    //
    AFHTTPRequestOperation *postLayout = [manager POST:@"layout"
                                            parameters:postData
                                               success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                   //
                                               }
                                               failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                                   //
                                               }];
    //
    [postLayout resume];
}

#pragma mark - Reachability event

SUBSCRIBE(SBReachabilityEvent) {
    operationQueue.suspended = !event.reachable;
}

#pragma mark - Connection availability

- (BOOL)isConnected {
    return !operationQueue.suspended;
}

@end
