//
//  HTTPServerConnection.m
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "HTTPServerConnection.h"



@interface HTTPServerConnection ()

@property (nonatomic) CFHTTPMessageRef currentMessage;
@property (nonatomic) id strongCurrentMessage;

@end



@implementation HTTPServerConnection

- (void)didReadData:(dispatch_data_t)data;
{
    if (self.currentMessage == nil) {
        self.currentMessage = CFHTTPMessageCreateEmpty(NULL, YES);
    }
    dispatch_data_apply(data, ^bool(dispatch_data_t region, size_t offset, const void *buffer, size_t size) {
        CFHTTPMessageAppendBytes(self.currentMessage, buffer, size);
        return YES;
    });
    [self parseMessage];
}

- (void)didFinishReading;
{
    [self parseMessage];
}

- (NSInteger)bodyLengthFromHeaders;
{
    // https://tools.ietf.org/html/rfc2616 section 4.4 "Message Length"
    // NSString * const method = CFBridgingRelease(CFHTTPMessageCopyRequestMethod(self.currentMessage));
    NSString * const contentLength = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(self.currentMessage, (__bridge CFStringRef) @"Content-Length"));
    NSString * const transferEncoding = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(self.currentMessage, (__bridge CFStringRef) @"Transfer-Encoding"));
    
    if ((contentLength == nil) && (transferEncoding == nil)) {
        return 0;
    }
    return contentLength.integerValue;
}

- (void)parseMessage;
{
    if ((self.currentMessage == NULL) || ! CFHTTPMessageIsHeaderComplete(self.currentMessage)) {
        return;
    }
    
    // Check if we received the entire body:
    NSUInteger bodyLengthFromHeaders = [self bodyLengthFromHeaders];
    NSData *body = CFBridgingRelease(CFHTTPMessageCopyBody(self.currentMessage));
    if ((bodyLengthFromHeaders != 0) &&
        (body.length < bodyLengthFromHeaders))
    {
        return;
    }
    
    CFHTTPMessageRef response = self.requestHandler(self.currentMessage);
    if (response != NULL) {
        // We don't support keep-alive:
        CFHTTPMessageSetHeaderFieldValue(response, (__bridge CFStringRef) @"Connection", (__bridge CFStringRef) @"close");
        
        CFDataRef serialized = CFHTTPMessageCopySerializedMessage(response);
        if (serialized == NULL) {
            [self close];
        } else {
            dispatch_data_t data = dispatch_data_create(CFDataGetBytePtr(serialized), CFDataGetLength(serialized), dispatch_get_global_queue(0, 0), ^{
                CFRelease(serialized);
            });
            __weak HTTPServerConnection *weakSelf = self;
            [self writeData:data completionHandler:^{
                [weakSelf close];
            }];
            self.currentMessage = nil;
        }
        CFRelease(response);
    } else {
        [self close];
    }
}

- (CFHTTPMessageRef)currentMessage;
{
    return (__bridge CFHTTPMessageRef) self.strongCurrentMessage;
}

- (void)setCurrentMessage:(CFHTTPMessageRef)currentMessage;
{
    self.strongCurrentMessage = CFBridgingRelease(currentMessage);
}

@end
