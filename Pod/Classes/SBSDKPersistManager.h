//
//  SBSDKLayoutPersistManger.h
//  Pods
//
//  Created by Thomas Ploentzke on 15.06.15.
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

#import <Foundation/Foundation.h>
#import "SBSDKBeaconAction.h"

@import GBStorage;

#define SBSDKSyncHistroyIDKey @"historyDumpID"

@protocol SBSDKPersistManagerDelegate;

@interface SBSDKPersistManager : NSObject

+ (SBSDKPersistManager *)sharedInstance;

/**
 *  registerScanBeacon:forEvent
 *
 *  register a seen beacon on exit
 *
 */

- (void) registerScanBeacon:(CLBeacon*)beacon forEvent:(SBSDKBeaconEvent)event;

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

/**
 *  add a observer to get layout update infos
 *
 *  @param delegate observer to add to the delegate list
 */

- (void) addActionsUpdateDelegate:(id<SBSDKPersistManagerDelegate>)delegate;

/**
 *  remove a observer from the update notification
 *
 *  @param delegate observer to remove from the delegate list
 */

- (void) removeActionsUpdateDelegate:(id<SBSDKPersistManagerDelegate>)delegate;


@end


/**
 The SBSDKLayoutPersistManagerDelegate protocol defines the delegate methods to respond to related events.
 */
@protocol SBSDKPersistManagerDelegate

@optional

/**
 *  inform delegate about new layout
 *
 *
 *  @param actions Beacon actions to be executed
 */
- (void)didUpdateBeaconActions:(NSArray *)actions;

@end
