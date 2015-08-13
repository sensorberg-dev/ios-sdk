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

@implementation SBResolver

- (instancetype)init {
    //should we throw an exception?
    return [[SBResolver alloc] initWithBaseURL:@""
                                         andAPI:@""];
}

- (instancetype)initWithBaseURL:(NSString*)baseURL andAPI:(NSString*)apiKey {
    self = [super init];
    if (self) {
        //
        [JSONAPI setAPIBaseURLWithString:baseURL];
        //
        [[JSONHTTPClient requestHeaders] setValue:apiKey forKey:@"X-Api-Key"];
        [[JSONHTTPClient requestHeaders] setValue:[SBUtility userAgent] forKey:@"User-Agent"];
    }
    return self;
}

- (void)ping {
    
}

- (void)getLayout {
    //
    [JSONAPI getWithPath:@"layout"
               andParams:nil
              completion:^(id json, JSONModelError *err) {
                  SBELayout *event = [SBELayout new];
                  //
                  if (err) {
                      event.error = err;
                      PUBLISH(event);
                      return;
                  }
                  //
                  event.layout = json;
                  PUBLISH(event);
              }];
    //
}

@end
