//
//  SBSettingManager.h
//  WhiteLabel
//
//  Created by ParkSanggeon on 27/04/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSettingEvent : NSObject
@property (nullable, nonatomic, strong) NSDictionary *settingsDictionary;
@property (nullable, nonatomic, strong) NSError *error;
@end

@interface SBSettingManager : NSObject

+ (instancetype _Nonnull)sharedManager;

// Please Subscribe "SBSettingEvent".
- (void)requestSettingWithAPIKey:(NSString * _Nonnull)key;

@end
