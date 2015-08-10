//
//  SBManager.h
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBAPIClient.h"
#import "SBLocation.h"

@interface SBManager : NSObject {
    //
}
//
@property (strong, nonatomic) SBAPIClient *apiClient;


// 
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithResolver:(NSString *)baseURL apiKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

@end
