//
//  JSONServer.m
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "JSONServer.h"

#import "HTTPServer.h"
#import <time.h>
#import <xlocale.h>



@interface NSDate (RFC822)

- (NSString *)httpHeaderString;

@end



@interface NSString (HTML)

- (NSString *)stringByEncodingToHTMLEntities;

@end



@interface JSONRequest ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic) id jsonObject;

@end



@interface JSONServer ()

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) HTTPServer *httpServer;
@property (nonatomic, weak) id<JSONServerResponseGenerator> requestGenerator;

@end



@implementation JSONServer

- (instancetype)initWithResponseGenerator:(id<JSONServerResponseGenerator>)generator;
{
    self = [super init];
    if (self) {
        self.requestGenerator = generator;
        [self setup];
    }
    return self;
}

- (void)setup;
{
    self.queue = dispatch_get_global_queue(0, 0);
    __weak JSONServer *weakSelf = self;
    self.httpServer = [[HTTPServer alloc] initWithRequestQueue:self.queue requestHandler:^CFHTTPMessageRef(CFHTTPMessageRef request) {
        JSONServer *server = weakSelf;
        return [server responseForRequest:request];
    }];
}

- (int)port;
{
    return self.httpServer.port;
}

- (CFHTTPMessageRef)responseForRequest:(CFHTTPMessageRef)request;
{
    NSURL *url = CFBridgingRelease(CFHTTPMessageCopyRequestURL(request));
    NSString *contentType = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(request, (__bridge CFStringRef) @"Content-Type"));
    NSData *requestBody = CFBridgingRelease(CFHTTPMessageCopyBody(request));
    JSONRequest *jsonRequest = [[JSONRequest alloc] init];
    jsonRequest.path = url.path;
    if (0 < requestBody.length) {
        if (![contentType isEqualToString:@"application/json; charset=utf-8"]) {
            return [self responseWithStatusCode:415 description:@"Unsupported Media Type"];
        }
        NSError *error;
        jsonRequest.jsonObject = [NSJSONSerialization JSONObjectWithData:requestBody options:0 error:&error];
        if (jsonRequest.jsonObject == nil) {
            return [self responseWithStatusCode:400 description:@"Bad Request"];
        }
    }
    JSONResponse *jsonResponse = [self.requestGenerator responseForJSONServer:self request:jsonRequest];
    if (jsonResponse == nil) {
        return [self responseWithStatusCode:501 description:@"Not Implemented"];
    }
    return [self responseWithStatusCode:jsonResponse.statusCode JSONObject:jsonResponse.jsonObject];
}

/// Assumes that the object can be encoded to JSON
- (CFHTTPMessageRef)responseWithStatusCode:(NSInteger)statusCode JSONObject:(id)object;
{
    NSData *body;
    if (object != nil) {
        NSError *error;
        body = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
        if (body == nil) {
            return [self internalServerErrorResponseWithError:error];
        }
    }
    return [self responseWithStatusCode:statusCode bodyData:body contentType:@"application/json; charset=utf-8" date:[NSDate date]];
}

- (CFHTTPMessageRef)responseWithFileURL:(NSURL *)fileURL;
{
    NSString *uti;
    NSDate *fileDate;
    NSError *error;
    if (![fileURL getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:&error] ||
        ![fileURL getResourceValue:&fileDate forKey:NSURLCreationDateKey error:&error]) {
        return [self internalServerErrorResponseWithError:error];
    }
    NSString *contentType = /*CFBridgingRelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef) uti, kUTTagClassMIMEType)) ?:*/ @"application/binary";
    NSData *body = [NSData dataWithContentsOfURL:fileURL];
    return [self responseWithStatusCode:200 bodyData:body contentType:contentType date:fileDate];
}

- (CFHTTPMessageRef)responseWithStatusCode:(NSInteger)statusCode bodyData:(NSData *)body contentType:(NSString *)contentType date:(NSDate *)date;
{
    CFHTTPMessageRef response = [self responseWithStatusCode:statusCode description:@"Ok"];
    if (body != nil) {
        if (contentType != nil) {
            CFHTTPMessageSetHeaderFieldValue(response, (__bridge CFStringRef) @"Content-Type", (__bridge CFStringRef) contentType);
        }
        CFHTTPMessageSetHeaderFieldValue(response, (__bridge CFStringRef) @"Content-Length", (__bridge CFStringRef) [NSString stringWithFormat:@"%llu", (long long unsigned) body.length]);
        CFHTTPMessageSetBody(response, (__bridge CFDataRef) body);
    }
    CFHTTPMessageSetHeaderFieldValue(response, (__bridge CFStringRef) @"Date", (__bridge CFStringRef) [NSDate date].httpHeaderString);
    return response;
}

- (CFHTTPMessageRef)responseWithStatusCode:(NSInteger)statusCode description:(NSString *)description;
{
    return CFHTTPMessageCreateResponse(NULL, statusCode, (__bridge CFStringRef) description, kCFHTTPVersion1_1);
}

- (CFHTTPMessageRef)notFoundResponse;
{
    CFHTTPMessageRef response = [self responseWithStatusCode:404 description:@"Not Found"];
    NSString *bodyString = @"<html><body>Not Found</body></html>";
    CFHTTPMessageSetHeaderFieldValue(response, (__bridge CFStringRef) @"Content-Type", (__bridge CFStringRef) @"text/html; charset=UTF-8");
    CFHTTPMessageSetBody(response, (__bridge CFDataRef) [bodyString dataUsingEncoding:NSUTF8StringEncoding]);
    return response;
}

- (CFHTTPMessageRef)internalServerErrorResponseWithError:(NSError *)error;
{
    CFHTTPMessageRef response = [self responseWithStatusCode:500 description:@"Internal Server Error"];
    NSString *errorAsHTML = [NSString stringWithFormat:@"description: %@<p>\ndomain: %@<p>\ncode: %lu<p>\n",
                             error.localizedDescription.stringByEncodingToHTMLEntities,
                             error.domain.stringByEncodingToHTMLEntities,
                             (unsigned long) error.code];
    NSString *bodyString = [NSString stringWithFormat:@"<html><body><h1>Internal Server Error<h1><p>%@</body></html>", errorAsHTML];
    CFHTTPMessageSetHeaderFieldValue(response, (__bridge CFStringRef) @"Content-Type", (__bridge CFStringRef) @"text/html; charset=UTF-8");
    CFHTTPMessageSetBody(response, (__bridge CFDataRef) [bodyString dataUsingEncoding:NSUTF8StringEncoding]);
    return response;
}

@end



@implementation NSDate (RFC822)

- (NSString *)httpHeaderString;
{
    locale_t const locale = NULL; // POSIX
    struct tm time_tm;
    time_t time = lround([self timeIntervalSince1970]);
    gmtime_r(&time, &time_tm);
    char buffer[200];
    if (0 < strftime_l(buffer, sizeof buffer, "%a, %d %b %Y %H:%M:%S +0000", &time_tm, locale)) {
        return [NSString stringWithUTF8String:buffer];
    }
    return @"";
}

@end



@implementation NSString (HTML)
                             
- (NSString *)stringByEncodingToHTMLEntities;
{
    // This is super inefficient, but works for us:
    NSDictionary *map = @{@"<": @"&lt;",
                          @">": @"&gt;",
                          @"&": @"&amp;"};
    NSMutableString *result = [NSMutableString string];
    NSCharacterSet *invalid = [NSCharacterSet characterSetWithCharactersInString:[map.allKeys componentsJoinedByString:@""]];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    while (! scanner.isAtEnd) {
        NSString *validString;
        if ([scanner scanUpToCharactersFromSet:invalid intoString:&validString]) {
            [result appendString:validString];
        }
        NSString *invalidString;
        if ([scanner scanCharactersFromSet:invalid intoString:&invalidString]) {
            [invalidString enumerateSubstringsInRange:NSMakeRange(0, invalidString.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                NSString *replacement = map[substring] ?: substring;
                [result appendString:replacement];
            }];
        }
    }
    return result;
}

@end



@implementation JSONResponse
@end



@implementation JSONRequest
@end
