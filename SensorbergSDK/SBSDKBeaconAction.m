//
//  SBSDKBeaconAction.m
//  SensorbergSDK
//
//   
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights#import <Foundation/Foundation.h>
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

#import "SBSDKBeaconAction.h"

#import "SBSDKMacros.h"

#pragma mark -

@interface SBSDKBeaconAction ()

@property (nonatomic, assign) SBSDKBeaconActionType type;
@property (nonatomic, strong) NSString *actionId;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSNumber *delaySeconds;
@property (nonatomic, strong) NSDictionary * payload;

@end

#pragma mark -

@implementation SBSDKBeaconAction

@synthesize type = _type;
@synthesize actionId = _actionId;
@synthesize subject = _subject;
@synthesize body = _body;
@synthesize url = _url;
@synthesize delaySeconds = _delaySeconds;
@synthesize payload = _payload;

#pragma mark - Lifecycle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    NON_DESIGNATED_INIT(@"initWithJSONDictionary:");
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)action {
    if ((self = [super init])) {
        self.action = action;
    }

    return self;
}

#pragma clang diagnostic pop

#pragma mark - Values

- (void)setAction:(NSDictionary *)action {
    self.type = SBSDKBeaconActionTypeUnknown;

    if (action[@"type"] && [action[@"type"] isKindOfClass:[NSNumber class]]) {
        NSNumber *type = (NSNumber *)action[@"type"];

        if (type.integerValue == 1) {
            self.type = SBSDKBeaconActionTypeTextMessage;
        } else if (type.integerValue == 2) {
            self.type = SBSDKBeaconActionTypeUrlTextMessage;
        } else if ( type.integerValue == 3){
            self.type = SBSDKBeaconActionTypeUrlInApp;
        }
    }

    if (action[@"id"] && [action[@"id"] isKindOfClass:[NSString class]]) {
        self.actionId = (NSString *)action[@"id"];
    }

    if (action[@"content"] && [action[@"content"] isKindOfClass:[NSString class]]) {
        self.content = (NSString *)action[@"content"];
    }

    if (action[@"delayTime"] && [action[@"delayTime"] isKindOfClass:[NSNumber class]]) {
        self.delaySeconds = (NSNumber *)action[@"delayTime"];
    }
}

- (void)setContent:(NSString *)content {
    NSError *jsonError;

    NSDictionary *contentDictionary = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];

    if (jsonError == nil){
        if (contentDictionary[@"subject"] && [contentDictionary[@"subject"] isKindOfClass:[NSString class]]) {
            self.subject = (NSString *)contentDictionary[@"subject"];
        }

        if (contentDictionary[@"body"] && [contentDictionary[@"body"] isKindOfClass:[NSString class]]) {
            self.body = (NSString *)contentDictionary[@"body"];
        }

        if (contentDictionary[@"url"] && [contentDictionary[@"url"] isKindOfClass:[NSString class]]) {
            self.url = [NSURL URLWithString:(NSString *)contentDictionary[@"url"]];
        }
        if (contentDictionary[@"payload"]) {
            self.payload = contentDictionary[@"payload"];
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.actionId      forKey:@"actionId"];
    [coder encodeObject:self.url           forKey:@"url"];
    [coder encodeObject:self.payload       forKey:@"payload"];
    [coder encodeObject:self.body          forKey:@"body"];
    [coder encodeObject:self.subject       forKey:@"subject"];
    [coder encodeObject:self.delaySeconds  forKey:@"delaySeconds"];
    [coder encodeInt:   self.type          forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.actionId     = [decoder decodeObjectForKey:@"actionId"];
    self.url          = [decoder decodeObjectForKey:@"url"];
    self.payload      = [decoder decodeObjectForKey:@"payload"];
    self.body         = [decoder decodeObjectForKey:@"body"];
    self.subject      = [decoder decodeObjectForKey:@"subject"];
    self.type         = [decoder decodeIntForKey:@"type"];
    self.delaySeconds = [decoder decodeObjectForKey:@"delaySeconds"];


    return self;
}


@end
