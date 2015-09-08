//
//  SBMBeacon.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import <JSONModel/JSONModel.h>

@protocol SBMBeacon @end

@interface SBMBeacon : JSONModel
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;
//
- (instancetype)initWithCLBeacon:(CLBeacon*)beacon;
- (instancetype)initWithString:(NSString*)fullUUID;
//
- (NSString*)fullUUID;
@end
