//
//  MemoryInfo.h
//  BLEAssistant
//
//  Created by ericj on 2018/1/17.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATIONRELODATA     @"notificationRelodata"

@interface MemoryInfo : NSObject

@property (nonatomic, assign) BOOL pop;
@property (nonatomic, assign) BOOL shouldPop;

+ (instancetype)shareMemoryInfo;

@end


