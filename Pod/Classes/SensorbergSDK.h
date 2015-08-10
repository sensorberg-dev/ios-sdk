//
//  SensorbergSDK.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SensorbergSDK.
FOUNDATION_EXPORT double SensorbergSDKVersionNumber;

//! Project version string for SensorbergSDK.
FOUNDATION_EXPORT const unsigned char SensorbergSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SensorbergSDK/PublicHeader.h>

// general SensorbergSDK domain
static NSString *const kSBSDKIdentifier = @"com.sensorberg.sdk";

#import "SBManager.h"
#import "SBLocation.h"
#import "SBBluetooth.h"
#import "SBAnalytics.h"
#import "SBUtility.h"