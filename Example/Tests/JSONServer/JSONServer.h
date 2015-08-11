//
//  JSONServer.h
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONResponse;
@class JSONRequest;
@protocol JSONServerResponseGenerator;



@interface JSONServer : NSObject

- (instancetype)initWithResponseGenerator:(id<JSONServerResponseGenerator>)generator;

@property (nonatomic, readonly, weak) id<JSONServerResponseGenerator> requestGenerator;
@property (nonatomic, readonly) int port;

@end



@protocol JSONServerResponseGenerator <NSObject>

- (JSONResponse *)responseForJSONServer:(JSONServer *)server request:(JSONRequest *)request;

@end



@interface JSONResponse : NSObject

@property (nonatomic, copy) id jsonObject;
@property (nonatomic) NSInteger statusCode;

@end



@interface JSONRequest : NSObject

@property (nonatomic, readonly, copy) NSString *path;
@property (nonatomic, readonly) id jsonObject;

@end
