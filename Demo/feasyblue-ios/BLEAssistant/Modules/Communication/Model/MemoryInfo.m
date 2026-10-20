//
//  MemoryInfo.m
//  BLEAssistant
//
//  Created by ericj on 2018/1/17.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "MemoryInfo.h"

@implementation MemoryInfo

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

+ (instancetype)shareMemoryInfo {
    static MemoryInfo *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[MemoryInfo alloc] init];
    });
    return share;
}


@end


