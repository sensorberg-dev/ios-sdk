//
//  SBResolver.m
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//
//

#import "SBResolver.h"

#import "SBResolver+Events.h"
#import "SBResolver+Models.h"

#import "SBManager.h"

#define kAPIHeaderTag   @"X-Api-Key"
#define kUserAgentTag   @"User-Agent"

@interface SBResolver() {
    AFHTTPRequestOperationManager *manager;
    NSOperationQueue *operationQueue;
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
        [manager.requestSerializer setValue:kSBAPIKey forHTTPHeaderField:kAPIHeaderTag];
        [manager.requestSerializer setValue:[SBUtility userAgent] forHTTPHeaderField:kUserAgentTag];
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

- (void)getLayout {
    //
    AFHTTPRequestOperation *getLayout = [manager GET:@"layout"
                                               parameters:@{}
                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                      NSError *error;
                                                      SBMLayout *layout = [[SBMLayout alloc] initWithDictionary:responseObject error:&error];
                                                      //
                                                      SBELayout *event = [SBELayout new];
                                                      event.error = error;
                                                      event.layout = layout;
                                                      PUBLISH(event);
                                                      //
                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      SBELayout *event = [SBELayout new];
                                                      event.error = error;
                                                      PUBLISH(event);
                                                  }];
    [getLayout resume];
}

#pragma mark - Reachability event

SUBSCRIBE(SBReachabilityEvent) {
    operationQueue.suspended = !event.reachable;
}

@end
