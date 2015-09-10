//
//  SBSDKBeaconEventResponseObject.m
//  SensorbergSDK
//
//   
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

#import "SBSDKBeaconEventResponseObject.h"

#import "SBSDKBeaconAction.h"
#import "SBSDKBeaconAction+Internal.h"

#pragma mark -

@interface SBSDKBeaconEventResponseObject ()

//
// Properties redefined to be read-write.
//

@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSArray *events;

@end

#pragma mark -

@implementation SBSDKBeaconEventResponseObject

@synthesize success = _success;
@synthesize response = _response;

#pragma mark - Response handling

- (void)setResponse:(id)response {
    if (response != self.response) {
        _response = response;

        if ([_response isKindOfClass:[NSArray class]]) {
            NSMutableArray *newEvents = [NSMutableArray array];

            for (id eachObject in (NSArray *)_response) {
                if ([eachObject isKindOfClass:[NSDictionary class]]) {
                    [newEvents addObject:[[SBSDKBeaconAction alloc] initWithJSONDictionary:(NSDictionary *) eachObject]];
                }
            }

            self.events = [newEvents copy];
        }
    }
}

@end
