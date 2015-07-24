//
//  SBSDKBeaconActionManager.m
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

#import "SBSDKBeaconActionManager.h"
#import "SBSDKLayoutPersistManager.h"
#import "SBSDKBeaconAction.h"

@implementation SBSDKEventResolvedActions
@end

@interface SBSDKBeaconActionManager ()

@property (strong) NSMutableArray* actions;
@property (strong) NSMutableDictionary* beacons;
@property (strong) NSDate* earlystDelayedAction;
@property (strong) NSPredicate* timeFramePredicate;

@end

@implementation SBSDKBeaconActionManager

+ (SBSDKBeaconActionManager *)sharedInstance
{
    static SBSDKBeaconActionManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    // fix for concurrency issue
    if (sharedInstance) return sharedInstance;
    
    dispatch_once(&pred, ^{
        sharedInstance = [SBSDKBeaconActionManager alloc];
        sharedInstance = [sharedInstance init];
        sharedInstance.actions = [NSMutableArray new];
        sharedInstance.beacons = [NSMutableDictionary new];
        
        [sharedInstance didUpdateBeaconActions:[SBSDKLayoutPersistManager sharedInstance].persistLayout[@"actions"]];
        
    });
    //
    return sharedInstance;
}

- (void)resolveActionForBeacon:(SBSDKBeacon *)beacon event:(SBSDKBeaconEvent)beaconEvent {
    
    if (beacon != Nil) {
        
        __block __typeof(self) __weak weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            NSString* identifier = [NSString stringWithFormat:@"%@%05d%05d",beacon.beacon.proximityUUID.UUIDString,beacon.beacon.major.intValue,beacon.minor.intValue];
            
            NSMutableArray *allActionsForThisBeacon = [NSMutableArray arrayWithArray:[weakSelf.beacons objectForKey:identifier]];
            
            NSArray* filteredActions = [weakSelf filterActions:allActionsForThisBeacon forBeaconEvent:beaconEvent];
            
            if (filteredActions != Nil && filteredActions.count > 0) {
                SBSDKEventResolvedActions *eventResolved = [SBSDKEventResolvedActions new];
                eventResolved.beaconActions = filteredActions;
                eventResolved.beaconIdentifier = identifier;
                PUBLISH(eventResolved);
            }
    
        });
        
    }
    
}

- (NSArray*) filterActions:(NSMutableArray*)allActions forBeaconEvent:(SBSDKBeaconEvent)beaconEvent {
    
    if (self.timeFramePredicate == Nil) {
        self.timeFramePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedAction, NSDictionary *bindings) {
            
            NSArray* timeFrames = [evaluatedAction timeFrames];
            
            if (timeFrames != Nil && timeFrames.count > 0) {
                NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
            
                for (NSDictionary* timeFrame in timeFrames) {
                
                    NSDate* startDate = [dateFormater dateFromString:[timeFrame objectForKey:@"start"]];
                    NSDate* endDate = [dateFormater dateFromString:[timeFrame objectForKey:@"end"]];

                    if ([startDate timeIntervalSinceNow] <= 0 && [endDate timeIntervalSinceNow] >= 0) {
                        // just one valid timeframe is enough
                        return TRUE;
                    };
                }
            }
            return FALSE;
        }];
    }
    
    // filter for eventType
    
    [allActions filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedAction, NSDictionary *bindings) {
        
        if ([evaluatedAction trigger] == SBSDKBeaconEventEnterExit) {
            return TRUE;
        }
        
        return [evaluatedAction trigger] == beaconEvent;
    }]];
    
    // filter for timeFrame
    [allActions filterUsingPredicate:self.timeFramePredicate];
    
    // filter for sendOnlyOnce
    
    allActions = [self filterSendOnlyOnceBeaconActions:allActions];
    
    // filter for suppressAction out
    
    allActions = [self filterSuppressBeaconActions:allActions];
    
    return allActions;
}

/**
 *  filterSendOnlyOnceBeaconActions
 *
 *  @param allActions array with beacon action to filter for 'sendOnlyOnce' actions
 *
 *  @return updated beacon array
 */

- (NSMutableArray*) filterSendOnlyOnceBeaconActions:(NSMutableArray*)allActions {
    
    NSMutableArray* alreadyDeliverdOnceBeaconActions = [NSMutableArray new];
    
    for (SBSDKBeaconAction* beaconAction in allActions) {
        
        if ([beaconAction.sendOnlyOnce boolValue]) {
            
            if (![[SBSDKLayoutPersistManager sharedInstance] shouldDeliverOnlyOnceBeaconAction:beaconAction]) {
                [alreadyDeliverdOnceBeaconActions addObject:beaconAction];
            }
        }
    }
    
    [allActions removeObjectsInArray:alreadyDeliverdOnceBeaconActions];
    
    return allActions;
}

/**
 *  filterSuppressBeaconActions
 *
 *  @param allActions array with beacon action to filter with suppresstime
 *
 *  @return updated beacon array
 */

- (NSMutableArray*) filterSuppressBeaconActions:(NSMutableArray*)allActions {
    
    NSMutableArray* suppressedBeaconActions = [NSMutableArray new];
    
    for (SBSDKBeaconAction* beaconAction in allActions) {
        
        if (beaconAction.suppressionTime.doubleValue > 0) {
            
            if ([[SBSDKLayoutPersistManager sharedInstance] shouldSuppressBeaconAction:beaconAction]) {
                [suppressedBeaconActions addObject:beaconAction];
            }
        }
    }
    
    [allActions removeObjectsInArray:suppressedBeaconActions];
    
    return allActions;
}

- (void)didUpdateBeaconActions:(NSArray *)newActions {
    
    @synchronized(self) {
        
        [self.actions removeAllObjects];
        
        for (NSDictionary* actionDict in newActions) {
            
            SBSDKBeaconAction* action = [[SBSDKBeaconAction alloc] initWithAction:actionDict];
            
            [self.actions addObject:action];
        }
        
        [self orderActions];
    }
}

/**
 *  orderActions
 *
 *  creates a dictionary with action for certain beacons
 *
 */

- (void) orderActions {
    
    [self.beacons removeAllObjects];
    
    for (SBSDKBeaconAction* action in self.actions) {
        
        for(CLBeaconRegion* beaconRegion in action.beacons) {
            
            NSString* identifier = [NSString stringWithFormat:@"%@%05d%05d",beaconRegion.proximityUUID.UUIDString,beaconRegion.major.intValue,beaconRegion.minor.intValue];
            
            if ([self.beacons objectForKey:identifier]) {
                NSMutableArray* actions = [self.beacons objectForKey:identifier];
                [actions addObject:action];
            } else {
                NSMutableArray* actions = [NSMutableArray arrayWithObject:action];
                [self.beacons setObject:actions forKey:identifier];
            }
        }
    }
}


@end
