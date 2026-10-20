//
//  NSString+FWString.h
//  FeasyWIFI
//
//  Created by ericj on 2018/8/22.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FWString)

+ (NSString *)fan_dataToHexString:(NSData *)data;

+ (NSString *)getLocalAppVersion;

- (NSString *)dataToHex:(NSData *)data;

- (NSString *)dataToUTF8:(NSData *)data;

+ (NSString *)getWifiName;

@end
