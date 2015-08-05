//
//  SBSDKNetworkManager.h
//  SensorbergSDK
//
//   
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Availability.h>
#import <Foundation/Foundation.h>

#import "SBSDKBeaconEvent.h"

@class AFHTTPSessionManager;
@class SBSDKBeacon;

@protocol SBSDKNetworkManagerDelegate;

#pragma mark -

/**
 The SBSDKNetworkManager object handles the network communication with
 the Sensorberg Beacon Management Platform.
 */
@interface SBSDKNetworkManager : NSObject

/**
 Delegate for SBSDKNetworkManager.
 */
@property(assign, nonatomic) id <SBSDKNetworkManagerDelegate> delegate;

/**
 Base URL of the Sensorberg Beacon Management Platform.
 */
@property (nonatomic, readonly) NSURL *baseURL;

/**
 API Key used to access the Sensorberg Beacon Management Platform.
 */
@property (nonatomic, copy) NSString *apiKey;

/**
 The network manager object used by the SBSDKNetworkManager object.
 */
@property (nonatomic, readonly) AFHTTPSessionManager *manager;

///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the SBSDKNetworkManager object. You need to provide an API Key
 to access the Sensorberg Beacon Management Platform.

 @param apiKey API Key to access the Sensorberg Beacon Management Platform.

 @return SBSDKNetworkManager object
 */
- (instancetype)initWithApiKey:(NSString *)apiKey;

///----------------
/// @name API calls
///----------------

/**
 Method to retrieve the beacon regions to be monitored by the SDK.
 */
- (void)updateRegions;

/**
 Method to resolve the action for a beacon trigger.
 
 @param beacon      Beacon that triggered an event.
 @param beaconEvent Beacon event that should be resolved.
 */
- (void)resolveBeaconActionForBeacon:(SBSDKBeacon *)beacon beaconEvent:(SBSDKBeaconEvent)beaconEvent;

///----------------
/// @name Constants
///----------------

/**
 Error domain used in network manager of Sensorberg SDK.
 */
extern NSString *const SBSDKNetworkManagerErrorDomain;

typedef NS_ENUM(NSInteger, SBSDKNetworkManagerErrorCode) {
    SBSDKNetworkManagerErrorUpdateRegionsFailed = -100,
    SBSDKNetworkManagerErrorResolveBeaconActionFailed = -99
};

@end

#pragma mark - 

/**
 The SBSDKNetworkManager protocol defines the delegate methods to respond to related events.
 */
@protocol SBSDKNetworkManagerDelegate <NSObject>

@optional

/**
 Delegate method invoked when a list of beacon regions to be monitored has been retrieved
 from the Sensorberg Beacon Management Platform.

 @param manager Network manager
 @param regions Beacon regions to be monitored
 */
- (void)networkManager:(SBSDKNetworkManager *)manager didUpdateRegions:(NSArray *)regions;

/**
 Delegate method invoked when trying to retrieve a list of beacon regions to be monitored
 from the Sensorberg Beacon Management Platform has failed.

 @param manager Network manager
 @param error   If an error occurs it contains an `NSError` object
                that describes the problem.
 */
- (void)networkManager:(SBSDKNetworkManager *)manager updateRegionsDidFailWithError:(NSError *)error;

/**
 Delegate method invoked when a list of beacon actions has been resolved and retrieved
 from the Sensorberg Beacon Management Platform.

 @param manager Network manager
 @param actions Beacon actions to be executed
 */
- (void)networkManager:(SBSDKNetworkManager *)manager didResolveBeaconActions:(NSArray *)actions;

/**
 Delegate method invoked when trying to resolve a list of beacon actions
 from the Sensorberg Beacon Management Platform has failed.

 @param manager Network manager
 @param error   If an error occurs it contains an `NSError` object
                that describes the problem.
 */
- (void)networkManager:(SBSDKNetworkManager *)manager resolveBeaconActionsDidFailWithError:(NSError *)error;

/**
 Delegate method invoked when the reachability status to the Sensorberg Beacon Management
 Platform changes.

 @param manager   Network manager
 @param reachable Indicates if the Sensorberg Beacon Management Platform is reachable.
 */
- (void)networkManager:(SBSDKNetworkManager *)manager sensorbergPlatformIsReachable:(BOOL)reachable;

@end
