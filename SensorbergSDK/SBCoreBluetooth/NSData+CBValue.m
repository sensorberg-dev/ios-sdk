//
//  NSData+CBValue.m
//  BeaConfig
//
//  Created by andsto on 13/01/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import "NSData+CBValue.h"

@implementation NSData (CBValue)

- (UInt8)u8 {
    if (self.length>1) {
        UInt8 byte = 0x00;
        [self getBytes:&byte length:1];
        return byte;
    }
    return 0x00;
}

- (UInt16)u16 {
    if (self.length>1) {
        UInt16 word = 0x0000;
        [self getBytes:&word length:2];
        return word;
    }
    return 0x0000;
}

- (UInt32)u32 {
    if (self.length>1) {
        UInt16 longword = 0x00000000;
        [self getBytes:&longword length:4];
        return longword;
    }
    return 0x00000000;
}

- (UInt8)u8s {
    if (self.length>1) {
        UInt8 buffer;
        [self getBytes:&buffer length:self.length];
        return buffer;
    }
    return 0x00;
}

- (NSString*)utf {
    return [[NSString alloc] initWithData:self encoding:8];
}

-(NSInteger)NSDataToInt {
    unsigned char bytes[4];
    [self getBytes:bytes length:4];
    NSInteger n = (int)bytes[0] << 24;
    n |= (int)bytes[1] << 16;
    n |= (int)bytes[2] << 8;
    n |= (int)bytes[3];
    return n;
}

@end
