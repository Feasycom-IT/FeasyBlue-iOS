//
//  NSString+FEString.h
//  BLEAssistant
//
//  Created by 余明悦 on 16/9/21.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FEString)
- (NSData *)hexToData;
- (NSData *)UTF8ToData;
+ (NSString *)dataToHex:(NSData *)data;
+ (NSString *)dataToUTF8:(NSData *)data;
+ (NSString *)dataToASCII:(NSData *)data;
@end
