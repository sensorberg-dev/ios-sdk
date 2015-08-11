//
//  HTTPServer.m
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "HTTPServer.h"

#import "HTTPServerConnection.h"


@interface HTTPServer ()
@end



@implementation HTTPServer

- (instancetype)initWithRequestQueue:(dispatch_queue_t)queue requestHandler:(RequestHandler)handler;
{
    return [super initWithConnectBlock:^(ServerConnection *c){
        HTTPServerConnection *httpConnection = (id) c;
        dispatch_set_target_queue(httpConnection.queue, queue);
        httpConnection.requestHandler = handler;
        [httpConnection start];
    }];
}

- (Class)connectionClass;
{
    return [HTTPServerConnection class];
}

@end
