//
//  SBSDKAPIResponseObject.m
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

#import "SBSDKAPIResponseObject.h"

#import "SBSDKMacros.h"

#pragma mark -

@interface SBSDKAPIResponseObject ()

//
// Properties redefined to be read-write.
//

@property (nonatomic, strong) id responseObject;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) id response;

@end

#pragma mark -

@implementation SBSDKAPIResponseObject

@synthesize responseObject = _responseObject;
@synthesize success = _success;
@synthesize response = _response;

#pragma mark - Lifecycle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    NON_DESIGNATED_INIT(@"initWithResponseObject:");
}

- (instancetype)initWithResponseObject:(id)responseObject {
    if ((self = [super init])) {
        self.responseObject = responseObject;
    }

    return self;
}

#pragma clang diagnostic pop

#pragma mark - Response handling

- (void)setResponseObject:(id)responseObject {
    if (responseObject != self.responseObject) {
        self.success = NO;

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"success"] isKindOfClass:[NSValue class]]) {
                if ([responseObject[@"success"] isEqualToValue:@YES]) {
                    self.success = YES;
                }
            }

            self.response = responseObject[@"response"];
        }
    }
}

@end
