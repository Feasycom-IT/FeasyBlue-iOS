//
//  NSString+FscKit.h
//  BLEAssistant
//
//  Created by ericj on 2018/1/13.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REVERSE16(v) (((uint16_t)(v) << 8) | ((uint16_t)(v) >> 8))

@interface NSString (FscKit)

+ (NSString *)getLocalAppVersion;

+ (NSString *)getNowTimeTimestamp;

@end


