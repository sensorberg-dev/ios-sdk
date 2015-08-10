//
//  SBManager.m
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBManager.h"

@implementation SBManager

- (instancetype)init {
    //should we throw an exception?
    return [self initWithResolver:@""
                           apiKey:@""];
}

- (instancetype)initWithResolver:(NSString *)baseURL apiKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        //
        _apiClient = [[SBAPIClient alloc] initWithBaseURL:baseURL andAPI:apiKey];
        //
        
    }
    return self;
}

@end
