//
//  SBManager.h
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBResolver.h"
#import "SBResolver+Models.h"
#import "SBResolver+Events.h"

#import "SBLocation.h"

#import "SBBluetooth.h"


@interface SBManager : NSObject {
    SBMLayout *layout;
}
//
@property (strong, nonatomic) SBResolver    *apiClient;
//
@property (strong, nonatomic) SBLocation    *locClient;
//
@property (strong, nonatomic) SBBluetooth   *bleClient;
//

extern NSString *kSBAPIKey;

extern NSString *kSBResolver;

/**
 *  Singleton instance of the Sensorberg manager
 *  Call setAPIKey and setResolver first
 *
 *  @return SBManager singleton instance
 */
+ (instancetype)sharedClient;

/**
 *  Designated initialiser for the Sensorberg manager. Usage: [SBManager sharedManager] setupResolver:<resolverURL> apiKey:<apiKey>]; 
 *
 *  @param resolver URL of the resolver (default is *https://resolver.sensorberg.com*)
 *  @param apiKey   API Key Register on *http://manage.sensorberg.com* to receive one (default is *0000*)
 */

- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey;

- (BOOL)requestLocationAuthorization;

- (BOOL)requestNotificationsAuthorization;

- (BOOL)startMonitoringUUID:(SBMUUID*)uuid;

//

- (void)getLayout;

@end
