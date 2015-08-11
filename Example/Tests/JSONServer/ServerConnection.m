//
//  ServerConnection.m
//  WebServer
//
//  Created by Andrei Stoleru on 16/01/15.
//  Copyright (c) 2015 magooos. All rights reserved.
//

#import "ServerConnection.h"



@interface ServerConnection ()

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_io_t channel;
@property (nonatomic, copy) NSData *addressData;

@end



@implementation ServerConnection

- (instancetype)initWithQueue:(dispatch_queue_t)queue channel:(dispatch_io_t)channel addressData:(NSData *)addressData;
{
    self = [super init];
    if (self) {
        self.queue = queue;
        self.channel = channel;
        self.addressData = addressData;
    }
    return self;
}

- (void)start;
{
    [self configureChannel];
}

- (void)configureChannel;
{
    // Configure the channel...
    dispatch_io_set_low_water(self.channel, 1);
    dispatch_io_set_high_water(self.channel, SIZE_MAX);
    
    // Setup read handler
    
    __weak ServerConnection *weakSelf = self;
    dispatch_io_read(self.channel, 0, SIZE_MAX, self.queue, ^(bool done, dispatch_data_t data, int error) {
        ServerConnection *connection = weakSelf;
        if (connection == nil) {
            return;
        }
        if (error) {
            NSLog(@"Error on channel: %s (%d)", strerror(error), error);
        }
        if (data != NULL) {
            [self didReadData:data];
        }
        if (done) {
            [connection didFinishReading];
        }
    });
}

- (void)didReadData:(dispatch_data_t)data;
{
    [self writeData:data completionHandler:nil];
}

- (void)didFinishReading;
{
    [self close];
}

- (void)writeData:(dispatch_data_t)data completionHandler:(dispatch_block_t)handler;
{
    handler = [handler copy];
    dispatch_io_write(self.channel, 0, data, self.queue, ^(bool done, dispatch_data_t data, int error) {
        if (error) {
            NSLog(@"Error on channel: %s (%d)", strerror(error), error);
        }
        if (done && (handler != nil)) {
            handler();
        }
    });
}

- (void)close;
{
    dispatch_io_t channel = self.channel;
    self.channel = nil;
    dispatch_async(self.queue, ^{
        dispatch_io_close(channel, DISPATCH_IO_STOP);
    });
}

- (void)stop;
{
    [self close];
}

@end
