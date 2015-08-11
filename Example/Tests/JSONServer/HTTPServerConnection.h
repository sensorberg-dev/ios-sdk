//
//  HTTPServerConnection.h
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "ServerConnection.h"

#import "HTTPServer.h"



@interface HTTPServerConnection : ServerConnection

@property (nonatomic, copy) RequestHandler requestHandler;

@end
