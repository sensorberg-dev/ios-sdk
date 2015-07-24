//
//  SBSDKManager.m
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

#import "SBSDKManager.h"
#import <GBDeviceInfo/GBDeviceInfo.h>
#import "CLBeacon+Equal.h"
#import "NSArray+ContainsString.h"
#import "NSString+ContainsString.h"
#import "NSUUID+NSString.h"
#import "SBSDKBeacon.h"
#import "SBSDKBeaconAction.h"
#import "SBSDKDeviceID.h"
#import "SBSDKMacros.h"
#import "SBSDKDefines.h"
#import "SBSDKBeaconActionManager.h"
#import "SBSDKLayoutPersistManager.h"

#pragma mark -

#import "MSWeakTimer.h"

@interface SBSDKManager ()

/**
 Timer used to detect beacon exit events.
 */
@property (nonatomic, strong) MSWeakTimer *beaconExitEventTimer;

///---------------------------------------------
/// @name Properties redefined to be read-write.
///---------------------------------------------

@property (nonatomic, assign) BOOL iBeaconSupported;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, strong) NSArray *detectedBeacons;
//@property (nonatomic, strong) NSDictionary *beaconLayout;
@property (nonatomic, strong) SBSDKNetworkManager *networkManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, assign) SBSDKManagerBluetoothStatus bluetoothStatus;
@property (nonatomic, assign) SBSDKManagerConnectionState connectionState;
@property (nonatomic, assign) SBSDKManagerReachabilityState reachabilityState;

///------------------------------------
/// @name Application delegate handling
///------------------------------------

/**
 Starts to monitor for beacons with a given region identifier.
 
 @param regionString Region string to monitor beacons
 */
- (void)startMonitoringBeaconsWithRegionString:(NSString *)regionString;

///-----------------------
/// @name Internal helpers
///-----------------------

/**
 Returns a CLBeaconRegion object constructed from a given region identifier.
 
 @param regionString Region string to be used for the CLBeaconRegion object.
 
 @return CLBeaconRegion object constructed from a given region identifier.
 */
- (CLBeaconRegion *)beaconRegionFromString:(NSString *)regionString;

///------------
/// @name Timer
///------------

/**
 Method to activate the timer used to detect beacon exit events.
 */
- (void)activateBeaconExitEventTimer;

/**
 Method to deactivate and invalidate the timer used to detect beacon exit events.
 */
- (void)deactivateBeaconExitEventTimer;

@end


#pragma mark -

@implementation SBSDKManager

@synthesize defaultRegions = _defaultRegions;
@synthesize regions = _regions;
@synthesize detectedBeacons = _detectedBeacons;
@synthesize locationManager = _locationManager;
@synthesize bluetoothManager = _bluetoothManager;
@synthesize bluetoothStatus = _bluetoothStatus;
@synthesize reachabilityState = _reachabilityState;

#pragma mark - Lifecycle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    NON_DESIGNATED_INIT(@"-initWithDelegate:");
}

- (instancetype)initWithDelegate:(id<SBSDKManagerDelegate>)delegate {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];

    self = [self initWithDelegate:delegate locationManager:locationManager];
    //
    return self;
}

- (instancetype)initWithDelegate:(id<SBSDKManagerDelegate>)delegate locationManager:(CLLocationManager *)locationManager {
    if ((self = [super init])) {

        self.delegate = delegate;

        if ([GBDeviceInfo deviceDetails].majoriOSVersion >= 7) {
            self.iBeaconSupported = YES;
        } else {
            self.iBeaconSupported = NO;
        }

        self.locationManager = locationManager;
        self.locationManager.delegate = self;

        self.bluetoothStatus = self.iBeaconSupported ? SBSDKManagerBluetoothStatusUnknown : SBSDKManagerBluetoothStatusUnavailable;

        #pragma deploymate push "ignored-api-availability"
            if ([GBDeviceInfo deviceDetails].majoriOSVersion >= 7) {
                self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                             queue:dispatch_get_main_queue()
                                                                           options:@{ CBCentralManagerOptionShowPowerAlertKey: @(NO) }];
            }
        #pragma deploymate pop

        self.connectionState = SBSDKManagerConnectionStateDisconnected;

        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeSensorbergPlatformConnectionState:)]) {
            [self.delegate beaconManager:self didChangeSensorbergPlatformConnectionState:self.connectionState];
        }

        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeBackgroundAppRefreshStatus:)]) {
            [self.delegate beaconManager:self didChangeBackgroundAppRefreshStatus:self.backgroundAppRefreshStatus];
        }

        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
            [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
        }

        #pragma deploymate push "ignored-api-availability"
            if ([GBDeviceInfo deviceDetails].majoriOSVersion >= 7) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(applicationBackgroundRefreshStatusDidChangeNotification:)
                                                             name:UIApplicationBackgroundRefreshStatusDidChangeNotification
                                                           object:nil];
            }
        #pragma deploymate pop
    }
    //
    REGISTER();
    //
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma clang diagnostic pop

#pragma mark - Regions

- (NSArray *)defaultRegions {
    if (!self.iBeaconSupported) {
        return nil;
    }

    if (_defaultRegions == nil) {
        _defaultRegions = [NSArray new];
    }

    return _defaultRegions;
}

- (NSArray *)regions {
    if (!self.iBeaconSupported) {
        return nil;
    }

    if (_regions == nil) {
        _regions = self.regions = self.defaultRegions;
    }

    return _regions;
}

- (void)setRegions:(NSArray *)regions {
    if (!self.iBeaconSupported) {
        return;
    }

    // Set region to be monitored
    NSMutableArray *newRegions = [NSMutableArray arrayWithArray:self.defaultRegions];

    for (NSString *eachRegionString in regions) {
        if (![newRegions containsString:eachRegionString]) {
            [newRegions addObject:eachRegionString];
        }
    }

    _regions = [newRegions copy];

    // Filter unmonitored regions
    NSMutableArray *unprocessedBeacons = [NSMutableArray arrayWithArray:_regions];
    NSMutableArray *unneededBeacons = [NSMutableArray array];

    NSArray *monitoredRegions = self.locationManager.monitoredRegions.allObjects;

    #pragma deploymate push "ignored-api-availability"
        if ([CLBeaconRegion class]) {
            for (CLBeaconRegion *eachBeaconRegion in monitoredRegions) {
                if ([eachBeaconRegion.identifier containsString:SBSDKManagerBeaconRegionIdentifier]) {
                    if ([_regions containsString:eachBeaconRegion.proximityUUID.UUIDString]) {
                        [unprocessedBeacons removeObject:eachBeaconRegion.proximityUUID.UUIDString];
                    } else {
                        [unneededBeacons addObject:eachBeaconRegion.proximityUUID.UUIDString];
                    }
                }
            }
        }
    #pragma deploymate pop

    // Start monitoring unmonitored regions
    for (NSString *eachRegionString in unprocessedBeacons) {
        [self startMonitoringBeaconsWithRegionString:eachRegionString];
    }

    // Stop monitoring unneeded regions
    for (NSString *eachRegionString in unneededBeacons) {
        [self stopMonitoringBeaconsWithRegionString:eachRegionString];
    }
}

#pragma mark - Authorization handling

- (void)requestAuthorization {
    if (!self.iBeaconSupported) {
        return;
    }

    SEL requestAuthorizationSelector = NSSelectorFromString(@"requestAlwaysAuthorization");

    if ([self.locationManager respondsToSelector:requestAuthorizationSelector]) {
        ((void (*)(id, SEL))[self.locationManager methodForSelector:requestAuthorizationSelector])(self.locationManager, requestAuthorizationSelector);
    } else {
        [self startMonitoringBeaconsWithRegionString:@"00000000-0000-0000-0000-000000000000"];
    }
}

#pragma mark - Webservice handling

- (BOOL)connectToResolver:(NSString *)baseUrlString apiKey:(NSString *)apiKey error:(NSError * __autoreleasing *)error {
    if (!self.iBeaconSupported) {
        NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"iOS 7 or later is required to support iBeacon functionality.", @"SensorbergSDK", nil) };

        if (error) {
            *error = [[NSError alloc] initWithDomain:SBSDKManagerErrorDomain
                                                code:SBSDKManagerErrorIOSUnsupported
                                            userInfo:userInfo];
        }

        return NO;
    }

    if (baseUrlString == nil) {
        NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Cannot connect to Sensorberg Resolver without a base URL.", @"SensorbergSDK", nil) };

        if (error) {
            *error = [[NSError alloc] initWithDomain:SBSDKManagerErrorDomain
                                                code:SBSDKManagerErrorBaseUrlMissing
                                            userInfo:userInfo];
        }

        return NO;
    }

    NSURL *baseURL = [NSURL URLWithString:baseUrlString];

    if (baseURL == nil) {
        NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Cannot connect to Sensorberg Resolver without a valid base URL string.", @"SensorbergSDK", nil) };

        if (error) {
            *error = [[NSError alloc] initWithDomain:SBSDKManagerErrorDomain
                                                code:SBSDKManagerErrorBaseUrlStringInvalid
                                            userInfo:userInfo];
        }

        return NO;
    }

    if (apiKey == nil) {
        NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Cannot connect to Sensorberg Resolver without an API key.", @"SensorbergSDK", nil) };

        if (error) {
            *error = [[NSError alloc] initWithDomain:SBSDKManagerErrorDomain
                                                code:SBSDKManagerErrorApiKeyMissing
                                            userInfo:userInfo];
        }

        return NO;
    }

    if (self.connectionState == SBSDKManagerConnectionStateConnected) {
        NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Already connected to Sensorberg Resolver, disconnect first.", @"SensorbergSDK", nil) };

        if (error) {
            *error = [[NSError alloc] initWithDomain:SBSDKManagerErrorDomain
                                                code:SBSDKManagerErrorAlreadyConnected
                                            userInfo:userInfo];
        }

        return NO;
    }

    self.connectionState = SBSDKManagerConnectionStateConnecting;

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeSensorbergPlatformConnectionState:)]) {
        [self.delegate beaconManager:self didChangeSensorbergPlatformConnectionState:self.connectionState];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }

    self.networkManager = [[SBSDKNetworkManager alloc] initWithBaseUrl:baseURL apiKey:apiKey];
    
    return YES;
}

- (BOOL)connectToBeaconManagementPlatformUsingApiKey:(NSString *)apiKey error:(NSError * __autoreleasing *)error {
    NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"-connectToBeaconManagementPlatformUsingApiKey:error: has been deprecated. Use -connectToResolver:apiKey:error: instead.", @"SensorbergSDK", nil) };

    if (error) {
        *error = [[NSError alloc] initWithDomain:SBSDKManagerErrorDomain
                                            code:SBSDKManagerErrorMethodDeprecated
                                        userInfo:userInfo];
    }

    return NO;
}

- (void)disconnectFromBeaconManagementPlatform {
    if (!self.iBeaconSupported) {
        return;
    }

    self.networkManager = nil;

    self.connectionState = SBSDKManagerConnectionStateDisconnected;

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeSensorbergPlatformConnectionState:)]) {
        [self.delegate beaconManager:self didChangeSensorbergPlatformConnectionState:self.connectionState];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }
}

- (void)disconnectFromBeaconManagementPlatformAndResetDeviceIdentifier {
    if (!self.iBeaconSupported) {
        return;
    }

    [self disconnectFromBeaconManagementPlatform];

    [SBSDKDeviceID resetDeviceIdentifier];
}

- (void)disconnectFromResolver {
    if (!self.iBeaconSupported) {
        return;
    }
    //
    self.networkManager = nil;
    //
    self.connectionState = SBSDKManagerConnectionStateDisconnected;
    //
    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeSensorbergPlatformConnectionState:)]) {
        [self.delegate beaconManager:self didChangeSensorbergPlatformConnectionState:self.connectionState];
    }
    
    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }
}

- (void)disconnectFromResolverAndResetDeviceIdentifier {
    [self disconnectFromResolver];
    //
    [SBSDKDeviceID resetDeviceIdentifier];
}

#pragma mark - Beacon monitoring

- (void)startMonitoringBeacons {
    if (!self.iBeaconSupported) {
        return;
    }

    for (NSString *eachRegionString in self.regions) {
        [self startMonitoringBeaconsWithRegionString:eachRegionString];
    }

    [self startRangingBeacons];
}

- (void)startMonitoringBeaconsWithRegionString:(NSString *)regionString {
    if (!self.iBeaconSupported) {
        return;
    }

    NSArray *monitoredRegions = self.locationManager.monitoredRegions.allObjects;

    BOOL regionIsUnmonitored = YES;

    #pragma deploymate push "ignored-api-availability"
        if ([CLBeaconRegion class]) {
            for (CLBeaconRegion *eachBeaconRegion in monitoredRegions) {
                if ([eachBeaconRegion.identifier containsString:SBSDKManagerBeaconRegionIdentifier]) {
                    if ([eachBeaconRegion.proximityUUID.UUIDString.lowercaseString isEqualToString:regionString.lowercaseString]) {
                        regionIsUnmonitored = NO;
                    }
                }
            }
        }
    #pragma deploymate pop

    if (regionIsUnmonitored) {
        [self.locationManager startMonitoringForRegion:[self beaconRegionFromString:regionString]];
    }
}

- (void)stopMonitoringBeacons {
    if (!self.iBeaconSupported) {
        return;
    }

    [self stopRangingBeacons];

    for (NSString *eachRegionString in self.regions) {
        [self stopMonitoringBeaconsWithRegionString:eachRegionString];
    }
}

- (void)stopMonitoringBeaconsWithRegionString:(NSString *)regionString {
    if (!self.iBeaconSupported) {
        return;
    }

    [self.locationManager stopMonitoringForRegion:[self beaconRegionFromString:regionString]];
}

#pragma mark - Beacon ranging

- (void)startRangingBeacons {
    if (!self.iBeaconSupported) {
        return;
    }

    for (NSString *eachRegionString in self.regions) {
        [self startRangingBeaconsWithRegionString:eachRegionString];
    }
}

- (void)startRangingBeaconsWithRegionString:(NSString *)regionString {
    if (!self.iBeaconSupported) {
        return;
    }

    if ([self.locationManager respondsToSelector:@selector(rangedRegions)]) {
        #pragma deploymate push "ignored-api-availability"
            NSArray *rangedRegions = self.locationManager.rangedRegions.allObjects;
        #pragma deploymate pop

        BOOL regionIsUnranged = YES;

        #pragma deploymate push "ignored-api-availability"
            if ([CLBeaconRegion class]) {
                for (CLBeaconRegion *eachBeaconRegion in rangedRegions) {
                    if ([eachBeaconRegion.identifier containsString:SBSDKManagerBeaconRegionIdentifier]) {
                        if ([eachBeaconRegion.proximityUUID.UUIDString.lowercaseString isEqualToString:regionString.lowercaseString]) {
                            regionIsUnranged = NO;
                        }
                    }
                }

                if (regionIsUnranged) {
                    CLBeaconRegion *region = [self beaconRegionFromString:regionString];
                    
                    if (region != Nil) {
                        
                        [self activateBeaconExitEventTimer];
                        
                        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didStartRangingForRegion:)]) {
                            [self.delegate beaconManager:self didStartRangingForRegion:region];
                        }
                        
                        [self.locationManager startRangingBeaconsInRegion:region];
                    }
                }
            }
        #pragma deploymate pop
    }
}

- (void)stopRangingBeacons {
    if (!self.iBeaconSupported) {
        return;
    }

    for (NSString *eachRegionString in self.regions) {
        [self stopRangingBeaconsWithRegionString:eachRegionString];
    }
}

- (void)stopRangingBeaconsWithRegionString:(NSString *)regionString {
    if (!self.iBeaconSupported) {
        return;
    }

    if ([self.locationManager respondsToSelector:@selector(rangedRegions)]) {
        #pragma deploymate push "ignored-api-availability"
            NSArray *rangedRegions = self.locationManager.rangedRegions.allObjects;
        #pragma deploymate pop

        BOOL regionIsRanged = NO;

        #pragma deploymate push "ignored-api-availability"
            if ([CLBeaconRegion class]) {
                for (CLBeaconRegion *eachBeaconRegion in rangedRegions) {
                    if ([eachBeaconRegion.identifier containsString:SBSDKManagerBeaconRegionIdentifier]) {
                        if ([eachBeaconRegion.proximityUUID.UUIDString.lowercaseString isEqualToString:regionString.lowercaseString]) {
                            regionIsRanged = YES;
                        }
                    }
                }

                if (regionIsRanged) {
                    CLBeaconRegion *region = [self beaconRegionFromString:regionString];

                    [self.locationManager stopRangingBeaconsInRegion:region];

                    if (self.locationManager.rangedRegions.count == 1) {
                        [self deactivateBeaconExitEventTimer];
                    }

                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didStopRangingForRegion:)]) {
                        [self.delegate beaconManager:self didStopRangingForRegion:region];
                    }
                }
            }
        #pragma deploymate pop
    }
}

#pragma mark - Detected Beacon processing

- (void)processDetectedBeacons:(NSArray *)beacons {

    if (!self.iBeaconSupported) {
        return;
    }

    if ((beacons != nil) && (beacons.count > 0)) {
        NSMutableArray *mutableDetectedBeacons = [self.detectedBeacons mutableCopy];

        if (mutableDetectedBeacons == nil) {
            mutableDetectedBeacons = [NSMutableArray array];
        }

        #pragma deploymate push "ignored-api-availability"
            if ([CLBeaconRegion class]) {
                for (CLBeacon *eachBeacon in beacons) {
                    NSUInteger existingBeaconIndex = [mutableDetectedBeacons indexOfObjectPassingTest:^BOOL(SBSDKBeacon *otherBeacon, NSUInteger index, BOOL *stop) {
                        return [eachBeacon isEqualToBeacon:otherBeacon.beacon];
                    }];

                    if (existingBeaconIndex != NSNotFound) {
                        SBSDKBeacon *existingBeacon = [mutableDetectedBeacons objectAtIndex:existingBeaconIndex];
                        
                        existingBeacon.beacon = eachBeacon;
                        existingBeacon.lastSeenAt = [NSDate date];
                    } else {
                        SBSDKBeacon *newBeacon = [[SBSDKBeacon alloc] initWithBeacon:eachBeacon];

                        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didDetectBeaconEnterEventForBeacon:)]) {
                            [self.delegate beaconManager:self didDetectBeaconEnterEventForBeacon:newBeacon.beacon];
                        }

                        [mutableDetectedBeacons addObject:newBeacon];

                        [[SBSDKBeaconActionManager sharedInstance] resolveActionForBeacon:newBeacon event:SBSDKBeaconEventEnter];
                    }
                }
            }
        #pragma deploymate pop

        self.detectedBeacons = [mutableDetectedBeacons copy];
    }
}

- (void)cleanupDetectedBeacons {
    if (!self.iBeaconSupported) {
        return;
    }

    if (self.detectedBeacons != nil) {
        NSMutableArray *mutableDetectedBeacons = [self.detectedBeacons mutableCopy];
        NSDate *now = [NSDate date];

        for (SBSDKBeacon *eachBeacon in self.detectedBeacons) {
            NSTimeInterval age = [now timeIntervalSinceDate:eachBeacon.lastSeenAt];

            if (age > SBSDKBeaconCleanupTimeInterval) {
                if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didDetectBeaconExitEventForBeacon:)]) {
                    [self.delegate beaconManager:self didDetectBeaconExitEventForBeacon:eachBeacon.beacon];
                }

                [mutableDetectedBeacons removeObject:eachBeacon];

                [[SBSDKBeaconActionManager sharedInstance] resolveActionForBeacon:eachBeacon event:SBSDKBeaconEventExit];
            }
        }

        self.detectedBeacons = [mutableDetectedBeacons copy];
    }
}

- (void)setDetectedBeacons:(NSArray *)detectedBeacons {
    if (!self.iBeaconSupported) {
        return;
    }

    _detectedBeacons = detectedBeacons;

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didUpdateDetectedBeacons:)]) {
        [self.delegate beaconManager:self didUpdateDetectedBeacons:_detectedBeacons];
    }
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (!self.iBeaconSupported) {
        return;
    }

    if (manager == self.locationManager && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAuthorizationStatus:)]) {
        [self.delegate beaconManager:self didChangeAuthorizationStatus:self.authorizationStatus];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if (!self.iBeaconSupported) {
        return;
    }

    if (manager == self.locationManager && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didStartMonitoringForRegion:)]) {
        [self.delegate beaconManager:self didStartMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    if (!self.iBeaconSupported) {
        return;
    }

    if (manager == self.locationManager && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:monitoringDidFailForRegion:withError:)]) {
        [self.delegate beaconManager:self monitoringDidFailForRegion:region withError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (!self.iBeaconSupported) {
        return;
    }

    if (manager == self.locationManager && [region isKindOfClass:[CLBeaconRegion class]] && [region.identifier containsString:SBSDKManagerBeaconRegionIdentifier]) {
        if (state == CLRegionStateInside) {
            [self startRangingBeaconsWithRegionString:[(CLBeaconRegion *)region proximityUUID].UUIDString];
        } else if(state == CLRegionStateOutside) {
            [self stopRangingBeaconsWithRegionString:[(CLBeaconRegion *)region proximityUUID].UUIDString];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if (!self.iBeaconSupported) {
        return;
    }
    
    if (manager == self.locationManager && [region.identifier containsString:SBSDKManagerBeaconRegionIdentifier]) {
        [self processDetectedBeacons:beacons];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    if (!self.iBeaconSupported) {
        return;
    }

    if (manager == self.locationManager && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:rangingDidFailForRegion:withError:)]) {
        [self.delegate beaconManager:self rangingDidFailForRegion:region withError:error];
    }
}

#pragma mark - CBCentralManager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (!self.iBeaconSupported) {
        self.bluetoothStatus = SBSDKManagerBluetoothStatusUnavailable;

        return;
    }

    if (central.state == CBCentralManagerStatePoweredOn) {
        self.bluetoothStatus = SBSDKManagerBluetoothStatusPoweredOn;
    } else if (central.state == CBCentralManagerStateUnknown) {
        self.bluetoothStatus = SBSDKManagerBluetoothStatusUnknown;
    } else {
        self.bluetoothStatus = SBSDKManagerBluetoothStatusPoweredOff;
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeBluetoothStatus:)]) {
        [self.delegate beaconManager:self didChangeBluetoothStatus:self.bluetoothStatus];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }
}

#pragma mark - Statuses

- (SBSDKManagerAvailabilityStatus)availabilityStatus {
    if (!self.iBeaconSupported) {
        return SBSDKManagerAvailabilityStatusIBeaconUnavailable;
    }

    switch (self.bluetoothStatus) {
        case SBSDKManagerBluetoothStatusPoweredOff:
            return SBSDKManagerAvailabilityStatusBluetoothRestricted;

        default:
            break;
    }

    switch (self.backgroundAppRefreshStatus) {
        case SBSDKManagerBackgroundAppRefreshStatusRestricted:
        case SBSDKManagerBackgroundAppRefreshStatusDenied:
            return SBSDKManagerAvailabilityStatusBackgroundAppRefreshRestricted;

        default:
            break;
    }

    switch (self.authorizationStatus) {
        case SBSDKManagerAuthorizationStatusNotDetermined:
        case SBSDKManagerAuthorizationStatusUnimplemented:
        case SBSDKManagerAuthorizationStatusRestricted:
        case SBSDKManagerAuthorizationStatusDenied:
            return SBSDKManagerAvailabilityStatusAuthorizationRestricted;

        default:
            break;
    }

    switch (self.connectionState) {
        case SBSDKManagerConnectionStateConnecting:
        case SBSDKManagerConnectionStateDisconnected:
            return SBSDKManagerAvailabilityStatusConnectionRestricted;

        default:
            break;
    }

    switch (self.reachabilityState) {
        case SBSDKManagerReachabilityStateNotReachable:
            return SBSDKManagerAvailabilityStatusReachabilityRestricted;

        default:
            break;
    }

    return SBSDKManagerAvailabilityStatusFullyFunctional;
}

- (SBSDKManagerBackgroundAppRefreshStatus)backgroundAppRefreshStatus {
    if (!self.iBeaconSupported) {
        return SBSDKManagerBackgroundAppRefreshStatusUnavailable;
    }

    UIBackgroundRefreshStatus status = [UIApplication sharedApplication].backgroundRefreshStatus;

    switch (status) {
        case UIBackgroundRefreshStatusRestricted:
            return SBSDKManagerBackgroundAppRefreshStatusRestricted;

        case UIBackgroundRefreshStatusDenied:
            return SBSDKManagerBackgroundAppRefreshStatusDenied;

        case UIBackgroundRefreshStatusAvailable:
            return SBSDKManagerBackgroundAppRefreshStatusAvailable;

        default:
            break;
    }

    return SBSDKManagerBackgroundAppRefreshStatusAvailable;
}

- (SBSDKManagerAuthorizationStatus)authorizationStatus {
    if (!self.iBeaconSupported) {
        return SBSDKManagerAuthorizationStatusUnavailable;
    }

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if (status == kCLAuthorizationStatusNotDetermined && [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            return SBSDKManagerAuthorizationStatusUnimplemented;
        }
    }

    switch (status) {
        case kCLAuthorizationStatusRestricted:
            return SBSDKManagerAuthorizationStatusRestricted;

        case kCLAuthorizationStatusDenied:
            return SBSDKManagerAuthorizationStatusDenied;

        case kCLAuthorizationStatusAuthorized:
            return SBSDKManagerAuthorizationStatusAuthorized;

        default:
            break;
    }

    return SBSDKManagerAuthorizationStatusNotDetermined;
}


#pragma mark - Application lifecycle handling

- (void)applicationBackgroundRefreshStatusDidChangeNotification:(NSNotification *)notification {
    if (!self.iBeaconSupported) {
        return;
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeBackgroundAppRefreshStatus:)]) {
        [self.delegate beaconManager:self didChangeBackgroundAppRefreshStatus:self.backgroundAppRefreshStatus];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }
}

#pragma mark - SBSDKNetworkManager events handling

SUBSCRIBE(SBSDKEventUpdatedRegions) {
    if (!self.iBeaconSupported) {
        return;
    }
    
    if (event.error) {
        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:communicationDidFailWithError:)]) {
            [self.delegate beaconManager:self communicationDidFailWithError:event.error];
        }
    }
    
    self.connectionState = SBSDKManagerConnectionStateConnected;

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeSensorbergPlatformConnectionState:)]) {
        [self.delegate beaconManager:self didChangeSensorbergPlatformConnectionState:self.connectionState];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }

    NSMutableArray *newRegions = [NSMutableArray arrayWithArray:self.defaultRegions];

    for (NSString *eachRegionString in event.beaconRegions) {
        
        if ([eachRegionString rangeOfString:@"-"].location == NSNotFound) {
            
            NSString *correctedRegionString = [self checkForValidUUIDString:eachRegionString];
            
            if (![self.defaultRegions containsString:correctedRegionString]) {
                [newRegions addObject:correctedRegionString];
            }
            
        } else {
            if (![self.defaultRegions containsString:eachRegionString]) {
                [newRegions addObject:eachRegionString];
            }
        }
    }

    self.regions = [newRegions copy];
}

SUBSCRIBE(SBSDKEventResolvedActions) {
    
    [[SBSDKLayoutPersistManager sharedInstance] addDeliveredActionsToHistorie:event.beaconActions forBeaconIdentifier:event.beaconIdentifier];
    
    if (!self.iBeaconSupported) {
        return;
    }
    
    if (event.error) {
        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:resolveBeaconActionsDidFailWithError:)]) {
            [self.delegate beaconManager:self resolveBeaconActionsDidFailWithError:event.error];
        }
        return;
    }

    for (SBSDKBeaconAction *eachBeaconAction in event.beaconActions) {
        switch (eachBeaconAction.type) {
            case SBSDKBeaconActionTypeTextMessage:
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive && ![eachBeaconAction.delay boolValue] && eachBeaconAction.deliverAt == Nil) {
                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayInAppMessageWithTitle:message:payload:)]) {
                        [self.delegate beaconManager:self
                        didResolveBeaconActionWithId:eachBeaconAction.actionID
                        displayInAppMessageWithTitle:eachBeaconAction.content.subject
                                             message:eachBeaconAction.content.body
                                             payload:eachBeaconAction.content.payload];
                        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayInAppMessageWithTitle:message:)]) {
                            [self.delegate beaconManager:self
                            didResolveBeaconActionWithId:eachBeaconAction.actionID
                            displayInAppMessageWithTitle:eachBeaconAction.content.subject
                                                 message:eachBeaconAction.content.body];
                        }
#pragma clang diagnostic pop
                        
                    }
                } else {
                    
                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:payload:deliverAt:)]) {
                        
                        NSDate* deliverDate = Nil;
                        if (eachBeaconAction.delay.boolValue) {
                            deliverDate = [NSDate dateWithTimeIntervalSinceNow:eachBeaconAction.delay.doubleValue];
                        }
                        
                        if (eachBeaconAction.deliverAt != Nil) {
                            deliverDate = [eachBeaconAction.deliverAt copy];
                        }
                        
                        [self.delegate beaconManager:self
                        didResolveBeaconActionWithId:eachBeaconAction.actionID
                   displayLocalNotificationWithTitle:eachBeaconAction.content.subject
                                             message:eachBeaconAction.content.body
                                             payload:eachBeaconAction.content.payload
                                           deliverAt:deliverDate];
                    }

                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:payload:)]) {
                        [self.delegate beaconManager:self
                        didResolveBeaconActionWithId:eachBeaconAction.actionID
                   displayLocalNotificationWithTitle:eachBeaconAction.content.subject
                                             message:eachBeaconAction.content.body
                                             payload:eachBeaconAction.content.payload];
                    }
                    #pragma clang diagnostic pop
                }

                break;

            case SBSDKBeaconActionTypeUrlTextMessage:
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive  && ![eachBeaconAction.delay boolValue]  && eachBeaconAction.deliverAt == Nil) {
                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayInAppMessageWithTitle:message:url:payload:)]) {
                        [self.delegate beaconManager:self
                        didResolveBeaconActionWithId:eachBeaconAction.actionID
                        displayInAppMessageWithTitle:eachBeaconAction.content.subject
                                             message:eachBeaconAction.content.body
                                                 url:eachBeaconAction.content.url
                                             payload:eachBeaconAction.content.payload];
                    }
                } else {
                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:url:payload:deliverAt:)]) {
                        
                        NSDate* deliverDate = Nil;
                        if (eachBeaconAction.delay.boolValue) {
                            deliverDate = [NSDate dateWithTimeIntervalSinceNow:eachBeaconAction.delay.doubleValue];
                        }
                        
                        if (eachBeaconAction.deliverAt != Nil) {
                            deliverDate = [eachBeaconAction.deliverAt copy];
                        }
                        
                        [self.delegate beaconManager:self
                        didResolveBeaconActionWithId:eachBeaconAction.actionID
                   displayLocalNotificationWithTitle:eachBeaconAction.content.subject
                                             message:eachBeaconAction.content.body
                                                 url:eachBeaconAction.content.url
                                             payload:eachBeaconAction.content.payload
                                           deliverAt:deliverDate];
                    }

                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didResolveBeaconActionWithId:displayLocalNotificationWithTitle:message:url:payload:)]) {
                        [self.delegate beaconManager:self
                        didResolveBeaconActionWithId:eachBeaconAction.actionID
                   displayLocalNotificationWithTitle:eachBeaconAction.content.subject
                                             message:eachBeaconAction.content.body
                                                 url:eachBeaconAction.content.url
                                             payload:eachBeaconAction.content.payload];
                    }
                    #pragma clang diagnostic pop
                }

                break;

            default:
                break;
        }
    }
}

SUBSCRIBE(SBSDKEventReachability) {
    if (!self.iBeaconSupported) {
        return;
    }

    self.reachabilityState = event.reachable ? SBSDKManagerReachabilityStateReachable : SBSDKManagerReachabilityStateNotReachable;

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeSensorbergPlatformReachabilityState:)]) {
        [self.delegate beaconManager:self didChangeSensorbergPlatformReachabilityState:self.reachabilityState];
    }

    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKManagerDelegate)] && [self.delegate respondsToSelector:@selector(beaconManager:didChangeAvailabilityStatus:)]) {
        [self.delegate beaconManager:self didChangeAvailabilityStatus:self.availabilityStatus];
    }
}

#pragma mark - Internal helpers

- (CLBeaconRegion *)beaconRegionFromString:(NSString *)regionString {
    NSString *finalRegionString = [NSString stringWithFormat:@"%@.%@", SBSDKManagerBeaconRegionIdentifier, regionString];

    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:regionString.lowercaseString] identifier:finalRegionString.lowercaseString];

    beaconRegion.notifyEntryStateOnDisplay = YES;
    
    return beaconRegion;
}

- (NSString *)checkForValidUUIDString:(NSString *)UUIDString {
    
    if (UUIDString.length != 32) {
        return nil;
    }
    
    NSMutableString *resultString = [NSMutableString stringWithString:UUIDString];
    
    [resultString insertString:@"-" atIndex:8];
    [resultString insertString:@"-" atIndex:13];
    [resultString insertString:@"-" atIndex:18];
    [resultString insertString:@"-" atIndex:23];
    
    resultString = [resultString uppercaseString];
    
    return [resultString copy];
}

#pragma mark - Timer

- (void)activateBeaconExitEventTimer {
    if (!self.iBeaconSupported) {
        return;
    }

    if (self.beaconExitEventTimer == nil) {
        self.beaconExitEventTimer = [MSWeakTimer scheduledTimerWithTimeInterval:SBSDKBeaconExitEventTimeInterval
                                                                         target:self
                                                                       selector:@selector(cleanupDetectedBeacons)
                                                                       userInfo:nil
                                                                        repeats:YES
                                                                  dispatchQueue:dispatch_get_main_queue()];

        self.beaconExitEventTimer.tolerance = 1.0;
    }
}

- (void)deactivateBeaconExitEventTimer {
    if (self.beaconExitEventTimer != nil) {
        [self.beaconExitEventTimer invalidate];

        self.beaconExitEventTimer = nil;
    };
}

@end
