//
//  SBSDKActionManager.h
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
#import "SBSDKDefines.h"
#import "SBSDKBeacon.h"

@protocol SBSDKBeaconActionManagerDelegate;

@interface SBSDKBeaconActionManager : NSObject

+ (SBSDKBeaconActionManager *)sharedInstance;

- (void)resolveActionForBeacon:(SBSDKBeacon *)beacon event:(SBSDKBeaconEvent)beaconEvent andDelegate:(id<SBSDKBeaconActionManagerDelegate>)delegate;

- (void)didUpdateBeaconActions:(NSArray *)actions;

@end

/**
 The SBSDKActionManagerDelegate protocol defines the delegate methods to respond to related events.
 */
@protocol SBSDKBeaconActionManagerDelegate <NSObject>

@optional


 /**
 @param manager Action manager
 @param actions Beacon actions to be executed
 */
- (void)didResolveBeaconActions:(NSArray *)actions forBeaconIdentifier:(NSString*)beaconIdentifier;

/**
 Delegate method invoked when trying to resolve a beacon actions


 @param manager Action manager
 @param error   If an error occurs it contains an `NSError` object
 that describes the problem.
 */
- (void)resolveBeaconActionsDidFailWithError:(NSError *)error;

@end
