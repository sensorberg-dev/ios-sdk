//
//  SBAPIClient.m
//  Pods
//
//  Created by Andrei Stoleru on 06/08/15.
//
//

#import "SBAPIClient.h"

@implementation SBELayout
@end

@implementation SBAPIClient

- (instancetype)init {
    //should we throw an exception?
    return [[SBAPIClient alloc] initWithBaseURL:@""
                                         andAPI:@""];
}

- (instancetype)initWithBaseURL:(NSString*)baseURL andAPI:(NSString*)apiKey {
    self = [super init];
    if (self) {
        //
        [JSONAPI setAPIBaseURLWithString:baseURL];
        [[JSONHTTPClient requestHeaders] setValue:apiKey forKey:@"X-Api-Key"];
    }
    return self;
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
