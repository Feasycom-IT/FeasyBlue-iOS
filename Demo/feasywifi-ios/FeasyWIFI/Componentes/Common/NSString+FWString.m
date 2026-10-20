//
//  NSString+FWString.m
//  FeasyWIFI
//
//  Created by ericj on 2018/8/22.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "NSString+FWString.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation NSString (FWString)

// 十六进制数据转字符串
+ (NSString *)fan_dataToHexString:(NSData *)data {
    Byte *bytehex =(Byte *) data.bytes;
    NSMutableString *hexString=[[NSMutableString alloc]init];
    for (int i=0; i<data.length; i++) {
        Byte b=bytehex[i];
        [hexString appendFormat:@"%02x",b];
    }
    return hexString;
}

//获取bundle版本
+ (NSString *)getLocalAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)dataToHex:(NSData *)data {
    if (data.length) {
        NSString *string = [[[NSString stringWithFormat:@"%@",data]
                             stringByReplacingOccurrencesOfString: @"<" withString: @""]
                            stringByReplacingOccurrencesOfString: @">" withString: @""];
        return string.uppercaseString;
    } else {
        return @"";
    }
}

+ (NSString *)getWifiName {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (NSString *)dataToUTF8:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
