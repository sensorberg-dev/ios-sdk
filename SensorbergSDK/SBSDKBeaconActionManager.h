//
//  SBSDKActionManager.h
//  Pods
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

#import "Tolo.h"

#import "SBSDKDefines.h"
#import "SBSDKBeacon.h"


@interface SBSDKBeaconActionManager : NSObject

+ (SBSDKBeaconActionManager *)sharedInstance;

- (void)resolveActionForBeacon:(SBSDKBeacon *)beacon event:(SBSDKBeaconEvent)beaconEvent;

- (void)didUpdateBeaconActions:(NSArray *)actions;

@end

/**
 *  Beacon actions resolved event
 *
 *  @param  beaconAction        Array containing the actions for this beacon
 *  @param  beaconIdentifier    String containing the UUID/Major/Minor of the beacon
 *  @param  error               Error object - only in case of error!
 */

@interface SBSDKEventResolvedActions:NSObject
@property (strong, nonatomic) NSArray   *beaconActions;
@property (strong, nonatomic) NSString  *beaconIdentifier;
@property (strong, nonatomic) NSError   *error;
@end

