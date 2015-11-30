//
//  SBMSession.h
//  SensorbergSDK
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

#import <JSONModel/JSONModel.h>

#import "JSONValueTransformer+SBResolver.h"

@protocol SBMMonitorEvent @end

@interface SBMMonitorEvent : JSONModel
@property (strong, nonatomic) NSString <Optional> *pid;
@property (strong, nonatomic) NSString <Optional> *location;
@property (strong, nonatomic) NSDate <Optional> *dt;
@property (nonatomic) int trigger;
@end

@protocol SBMSession @end

@interface SBMSession : JSONModel

- (instancetype)initWithUUID:(NSString*)UUID;

@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *enter;
@property (strong, nonatomic) NSDate *exit;
@property (strong, nonatomic) NSDate *lastSeen;

@end
