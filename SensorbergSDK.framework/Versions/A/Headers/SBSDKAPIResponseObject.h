//
//  SBSDKAPIResponseObject.h
//  SensorbergSDK
//
//  Created by Max Horvath on 09/09/2014.
//  Copyright (c) 2014 Sensorberg GmbH. All rights reserved.
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

@import Foundation;

#import <Availability.h>

#import <Mantle/Mantle.h>

#pragma mark -

/**
 The SBSDKAPIResponseObject object is used to parse REST responses from the Sensorberg Beacon
 Management Platform into useable objects.
 */
NS_CLASS_AVAILABLE(NA, 7_0)
@interface SBSDKAPIResponseObject : MTLModel

/**
 Actual response returned from the REST call to the Sensorberg Beacon Management Platform.
 */
@property (nonatomic, readonly) id responseObject __OSX_AVAILABLE_STARTING(__MAC_TBD, __IPHONE_7_0);

/**
 Indication if the request to the Sensorberg Beacon Management Platform executed a
 successful call.
 */
@property (nonatomic, readonly) BOOL success __OSX_AVAILABLE_STARTING(__MAC_TBD, __IPHONE_7_0);

/**
 Pure response content that came with the response from to the Sensorberg Beacon
 Management Platform.
 */
@property (nonatomic, readonly) id response __OSX_AVAILABLE_STARTING(__MAC_TBD, __IPHONE_7_0);

/**
 Designated initializer of the SBSDKAPIResponseObject object. You need to provide a
 response object that was delivered when calling the REST API of the Sensorberg
 Beacon Management Platform.

 @param responseObject Response object that was delivered when calling the REST API
                       of the Sensorberg Beacon Management Platform.

 @return SBSDKAPIResponseObject object
 */
- (instancetype)initWithResponseObject:(id)responseObject NS_DESIGNATED_INITIALIZER __OSX_AVAILABLE_STARTING(__MAC_TBD, __IPHONE_7_0);

@end
