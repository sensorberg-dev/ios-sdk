//
//  NSData+CBValue.h
//  BeaConfig
//
//  Created by andsto on 13/01/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CBValue)

// Don't forget to convert little/big endian when required!

- (UInt8)u8;
- (UInt16)u16;
- (UInt32)u32;

- (UInt8)u8s;

- (NSString*)utf;

-(NSInteger)NSDataToInt;

- (unichar*)hexchars;
- (NSString *)hexadecimalString;

@end
