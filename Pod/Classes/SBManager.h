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
 *  Call [setupResolver: apiKey:] to setup the back-end and api key
 *
 *  @return SBManager singleton instance
 */
+ (instancetype)sharedManager;

/**
 *  Do not use *init* or *new* to instantiate the SBManager
 *  instead, call [SBManager sharedManager] to get the singleton instance
 *  and [[SBManager sharedManager] setupResolver:<<resolverURL>> apiKey:<<apiKey>>];
 */

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Designated initialiser for the Sensorberg manager. Usage: [[SBManager sharedManager] setupResolver:<resolverURL> apiKey:<apiKey>];
 *
 *  @param resolver URL of the resolver (default is *https://resolver.sensorberg.com*)
 *  @param apiKey   API Key Register on *http://manage.sensorberg.com* to receive one (default is *00..00*)
 */

- (void)setupResolver:(NSString*)resolver apiKey:(NSString*)apiKey;

- (void)requestLocationAuthorization;

- (void)requestBluetoothAuthorization;

/**
 *  Load the layout configuration
 *  Discussion: this will return a cached version if available, otherwise a network call will be made to 
 *  the *resolver*. To *force* a reload, user [[SBManager sharedManager] updateLayout]
 */

- (void)getLayout;

/**
 *  Forces a reload of the *layout* from the *resolver*, ignoring the cache
 */

- (void)updateLayout;

- (void)startMonitoring;

@end
