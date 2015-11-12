//
//  SBSettings.h
//  Pods
//
//  Created by andsto on 12/11/15.
//
//

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

@interface SBMSettings : JSONModel

@end

@interface SBSettings : NSObject

- (SBMSettings *)settings;

- (void)requestSettingsForAPIKey:(NSString*)APIKey;

@end
