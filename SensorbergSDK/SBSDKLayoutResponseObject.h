//
//  SBSDKBeaconEventResponseObject.h
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

//#import <Availability.h>
#import <Foundation/Foundation.h>

/**
 The SBSDKBeaconEventResponseObject object is used to parse the REST responses of resolving
 a beacon event from the Sensorberg Beacon Management Platform into an useable object.
 */
@interface SBSDKLayoutResponseObject : NSObject

/**
 Holds a list of beacons for the request api key.
 
 */
@property (nonatomic, readonly) NSArray *accountProximityUUIDs;

/**
 Holds a list of resolved actions.
 */
@property (nonatomic, readonly) NSArray *actions;

/**
 Actual response returned from the REST call to the Sensorberg Beacon Management Platform.
 */
@property (nonatomic, readonly) id responseObject;

/**
 Indication if the request to the Sensorberg Beacon Management Platform executed a
 successful call.
 */
@property (nonatomic, readonly) BOOL success;

/**
 Pure task that came with the response from to the Sensorberg Resolver.
 */
@property (nonatomic, readonly) NSURLSessionTask *task;

/**
 Pure response content that came with the response from to the Sensorberg Resolver.
 */
@property (nonatomic, readonly) id response;

/**
 Etag content for this response.
 */
@property (nonatomic, readonly) NSString* Etag;

/**
 Maximal validity age in seconds content for this response.
 */
@property (nonatomic, readonly) NSNumber* maxAge;

/**
 Http StatusCode for this response
 */
@property (nonatomic, readonly) NSInteger statusCode;

/**
 Designated initializer of the SBSDKAPIResponseObject object. You need to provide a
 response object that was delivered when calling the REST API of the Sensorberg
 Beacon Management Platform.
 
 @param responseObject Response object that was delivered when calling the REST API
 of the Sensorberg Beacon Management Platform.
 
 @return SBSDKAPIResponseObject object
 */
- (instancetype)initWithTask:(NSURLSessionTask *)task responseObject:(id)responseObject;


@end
