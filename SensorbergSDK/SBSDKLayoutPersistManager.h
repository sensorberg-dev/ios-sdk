//
//  SBSDKLayoutPersistManger.h
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
#import "SBSDKBeaconAction.h"

#import "GBStorage.h"
#import "Tolo.h"

#define SBSDKSyncHistroyIDKey @"historyDumpID"


@interface SBSDKLayoutPersistManager : NSObject

+ (SBSDKLayoutPersistManager *)sharedInstance;

/**
 *  registerScanEvent
 *
 *  register a seen beacon
 *
 */
- (void) registerScanEvent:(SBSDKBeacon*)beacon;

/**
 *  include beaconActions to history
 *
 *  @param beaconActions delivered beacon action
 */

- (void) addDeliveredActionsToHistorie:(NSArray*)beaconActions forBeaconIdentifier:(NSString*)identifier;


- (BOOL) shouldDeliverOnlyOnceBeaconAction:(SBSDKBeaconAction*)beaconAction;

- (BOOL) shouldSuppressBeaconAction:(SBSDKBeaconAction*)beaconAction;

- (NSMutableDictionary*)historyToSync;

- (void) historySyncSuccessWithIdentifier:(NSString*)syncHistoryID;

/**
 *  set a new layout in our persist layer
 *
 *  @param layout the layout to persist
 *
 *  @param maxAgeTimeInterval the http cache max-age value
 */
- (void) setPersistLayout:(NSDictionary*)layout withMaxAgeInterval:(NSNumber*) maxAgeTimeInterval;

/**
 *  add a observer to get layout update infos
 *
 *  @param delegate observer to add to the delegate list
 */
- (NSDictionary*)persistLayout;

@end

/**
 *  Beacon actions updated event
 *
 *
 *  @param beaconActions Beacon actions to be executed
 */

@interface SBSDKEventUpdatedActions : NSObject
@property (strong, nonatomic) NSArray *beaconAction;
@end

