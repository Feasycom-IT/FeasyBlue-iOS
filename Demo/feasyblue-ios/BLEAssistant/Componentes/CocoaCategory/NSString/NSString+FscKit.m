//
//  NSString+FscKit.m
//  BLEAssistant
//
//  Created by ericj on 2018/1/13.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "NSString+FscKit.h"

@implementation NSString (FscKit)

+ (NSString *)getLocalAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getNowTimeTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm:ss.SSS"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [formatter stringFromDate:datenow];
    return timeSp;
}

@end


