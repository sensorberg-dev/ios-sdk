//
//  SBUtility.h
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
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

#import <JSONModel/JSONModel.h>

#import <UICKeyChainStore/UICKeyChainStore.h>

@interface SBMUserAgent : JSONModel
@property (strong, nonatomic) NSString *sdk;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSString *app;
@end

extern NSDateFormatter  *dateFormatter;

extern UICKeyChainStore *keychain;

extern NSString *const kSensorbergSDKVersion;

extern NSString *const kAPIHeaderTag;
extern NSString *const kUserAgentTag;
extern NSString *const kInstallId;
extern NSString *const  kIDFA;

extern NSString *const  kSBDefaultResolver;
extern NSString *const  kSBDefaultAPIKey;
extern NSString         *kPostLayout;
extern NSString         *kSBAppActive;
extern float            kPostSuppression;

extern NSString *const  kCacheKey;

@interface SBUtility : NSObject

+ (SBMUserAgent *)userAgent;

@end
