//
//  NSString+FEString.m
//  BLEAssistant
//
//  Created by 余明悦 on 16/9/21.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "NSString+FEString.h"

@implementation NSString (FEString)
- (NSData *)hexToData {
    NSMutableData* data = [NSMutableData data];
    int idx;
    NSString *str = [[[self stringByReplacingOccurrencesOfString:@" " withString:@""]
                     stringByReplacingOccurrencesOfString:@"\r" withString:@""]
                     stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

- (NSData *)UTF8ToData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)dataToHex:(NSData *)data {
    const NSInteger length = data.length;
    if (0 < length) {
        const UInt8 *bytes = data.bytes;
        NSMutableString *string = [[NSMutableString alloc] initWithCapacity:length * 2];
        
        for (NSInteger i = 0; i < length; ++ i) {
            [string appendFormat:@"%02X", bytes[i]];
        }
        return string;
    } else {
        return @"";
    }
}

+ (NSString *)dataToUTF8:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)dataToASCII:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
