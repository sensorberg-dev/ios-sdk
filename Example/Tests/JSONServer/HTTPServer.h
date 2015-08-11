//
//  HTTPServer.h
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "Server.h"


// Takes a CFHTTPMessage (request) and returns a CFHTTPMessage (response)
typedef CFHTTPMessageRef(^RequestHandler)(CFHTTPMessageRef);



@interface HTTPServer : Server

- (instancetype)initWithRequestQueue:(dispatch_queue_t)queue requestHandler:(RequestHandler)handler;

@end
