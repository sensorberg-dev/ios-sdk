//
//  Server.h
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerConnection;



@interface Server : NSObject

- (instancetype)initWithConnectBlock:(void(^)(ServerConnection *))block;

@property (nonatomic, readonly) int port;

@end
