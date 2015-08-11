//
//  Server.m
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "Server.h"

#import "ServerConnection.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <stdlib.h>



@interface Server ()

@property (nonatomic) int port;
@property (nonatomic) int serverSocket;
@property (nonatomic, copy) void (^connectionBlock)(ServerConnection *);

@end



@implementation Server

- (instancetype)initWithConnectBlock:(void(^)(ServerConnection *))block;
{
    self = [super init];
    if (self) {
        self.connectionBlock = block;
        [self start];
    }
    return self;
}

- (void)start;
{
    // Create a socket:
    int const serverSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    NSAssert(0 <= serverSocket, @"socket() failed: %s (%d).", strerror(errno), errno);
    self.serverSocket = serverSocket;
    
    // Bind the socket to a specific port:
    struct sockaddr_in echoServAddr = {};
    echoServAddr.sin_family = AF_INET;
    echoServAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    int port = 8000 + arc4random_uniform(1000);
    for (; port < 10000; ++port) {
        echoServAddr.sin_port = htons(port);
        int const bindResult = bind(serverSocket, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr));
        if (0 <= bindResult) {
            break;
        }
    }
    self.port = port;
    
    // Make the socket non-blocking:
    int const fcntlResult = fcntl(serverSocket, F_SETFL, O_NONBLOCK);
    NSAssert(0 <= fcntlResult, @"fcntl() failed: %s (%d).", strerror(errno), errno);
    
    // Set up the dispatch source that will alert us to new incoming connections
    NSString *queueName = [NSString stringWithFormat:@"server on port %d", self.port];
    dispatch_queue_t const q = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t acceptSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, serverSocket, 0, q);
    
    void (^connectionBlock)(ServerConnection *) = self.connectionBlock;

    dispatch_source_set_event_handler(acceptSource, ^{
        const unsigned long numPendingConnections = dispatch_source_get_data(acceptSource);
        for (unsigned long i = 0; i < numPendingConnections; i++) {
            // Wait for a client to connect
            struct sockaddr_in clientAddress = {};
            socklen_t clientAddressLength = (socklen_t) sizeof(clientAddress);
            int const clientSocket = accept(serverSocket, (struct sockaddr *) &clientAddress, &clientAddressLength);
            if (clientSocket == -1) {
                NSLog(@"Failed to accept() a connection: %s (%d).", strerror(errno), errno);
            } else {
                NSData *addressData = [NSData dataWithBytes:&clientAddress length:clientAddressLength];
                NSString *clientName = [NSString stringWithFormat:@"client (fd=%d)", clientSocket];
                dispatch_queue_t const clientQueue = dispatch_queue_create(clientName.UTF8String, DISPATCH_QUEUE_CONCURRENT);
                dispatch_io_t const channel = dispatch_io_create(DISPATCH_IO_STREAM, clientSocket, clientQueue, ^(int error) {
                    if (error != 0) {
                        NSLog(@"Failed to create client channel: %s (%d).", strerror(error), error);
                    }
                    close(clientSocket);
                });
                
                if (channel != NULL) {
                    ServerConnection *c = [[self.connectionClass alloc] initWithQueue:clientQueue channel:channel addressData:addressData];
                    connectionBlock(c);
                }
            }
        }
    });
    
    // Resume the source:
    dispatch_resume(acceptSource);

    // Listen on the socket:
    int const listenResult = listen(serverSocket, SOMAXCONN);
    NSAssert(listenResult == 0, @"Failed to listen(): %s (%d).", strerror(errno), errno);
    
    NSLog(@"Listening on port %d", self.port);
}

- (Class)connectionClass;
{
    return [ServerConnection class];
}

- (void)stop;
{
    if (0 <= self.serverSocket) {
        close(self.serverSocket);
        self.serverSocket = 0;
    }
}

@end
