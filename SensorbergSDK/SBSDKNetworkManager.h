//
//  SBSDKNetworkManager.h
//  SensorbergSDK
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

#import <Foundation/Foundation.h>
#import "SBSDKDefines.h"

#import "Tolo.h"

@class AFHTTPSessionManager;
@class SBSDKBeacon;

#pragma mark -

/**
 The SBSDKNetworkManager object handles the network communication with
 the Sensorberg Beacon Management Platform.
 */
@interface SBSDKNetworkManager : NSObject

/**
 Base URL of the Sensorberg Beacon Management Platform.
 */
@property (nonatomic, readonly) NSURL *baseURL;

/**
 API Key used to access the Sensorberg Beacon Management Platform.
 */
@property (nonatomic, copy) NSString *apiKey;

/**
 Layout holding all beacons and actions.

 @since 1.0.0
 */
@property (nonatomic, readonly) NSDictionary *beaconLayout;

/**
 The network manager object used by the SBSDKNetworkManager object.
 */
@property (nonatomic, readonly) AFHTTPSessionManager *manager;

///---------------------
/// @name Initialization
///---------------------

/**
 Designated initializer of the SBSDKNetworkManager object. You need to provide the base URL to
 a Sensorberg Resolver and an API Key to access it.

 @param baseURL      Base URL to access a Sensorberg Resolver.
 @param apiKey       API Key to access a Sensorberg Resolver.

 @return SBSDKNetworkManager object
 
 @since 1.0.0
 */
- (instancetype)initWithBaseUrl:(NSURL *)baseURL apiKey:(NSString *)apiKey;

/**
 Designated initializer of the SBSDKNetworkManager object. You need to provide an API Key
 to access the Sensorberg Beacon Management Platform.

 @deprecated This method has been deprecated. Use -initWithBaseUrl:apiKey: instead.

 @param apiKey API Key to access the Sensorberg Beacon Management Platform.

 @return SBSDKNetworkManager object

 @since 0.7.0
 @until 0.8.0
 */
- (instancetype)initWithApiKey:(NSString *)apiKey DEPRECATED_ATTRIBUTE;

///----------------
/// @name API calls
///----------------

/**
 Method to retrieve the beacon regions to be monitored by the SDK.
 
 @since 0.7.0
 */
- (void)updateLayout;

/**
 Method to retrieve the beacon layout from a Sensorberg Resolver.

 @since 1.0.0
 */
- (void)retrieveBeaconLayout;

/**
 Method to resolve the action for a beacon trigger.
 
 @param beacon      Beacon that triggered an event.
 @param beaconEvent Beacon event that should be resolved.

 @since 0.7.0
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
    SBSDKNetworkManagerErrorResolveBeaconActionFailed = -99 //not used?
};

@end

#pragma mark - 

/**
 *  SBSDKEventUpdatedRegions    Event fired when beacon regions have been updated
 *
 *  @param  networkManager      The SBSDKNetworkManager that fires the event
 *  @param  beaconRegions       The regions (in an array) that have been updated
 *  @param  error               In case of error, this object contains the code/description
 */

@interface SBSDKEventUpdatedRegions : NSObject
@property (strong, nonatomic) SBSDKNetworkManager *networkManager;
@property (strong, nonatomic) NSArray *beaconRegions;
@property (strong, nonatomic) NSError *error;
@end

/**
 *  SBSDKEventReachability      Event fired when resolver changes rechability
 *  
 *  @param  reachable           Boolean value indicating resolver rechability
 */

@interface SBSDKEventReachability : NSObject
@property (nonatomic) BOOL reachable;
@end

