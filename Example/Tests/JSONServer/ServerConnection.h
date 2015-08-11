//
//  ServerConnection.h
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ServerConnection : NSObject

- (instancetype)initWithQueue:(dispatch_queue_t)queue channel:(dispatch_io_t)channel addressData:(NSData *)addressData;

@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) dispatch_io_t channel;

- (void)start;

/// For subclasses to override:
- (void)didReadData:(dispatch_data_t)data;

/// For subclasses to override:
- (void)didFinishReading;

/// Write data back to the connection:
- (void)writeData:(dispatch_data_t)data completionHandler:(dispatch_block_t)handler;

- (void)close;

@end
