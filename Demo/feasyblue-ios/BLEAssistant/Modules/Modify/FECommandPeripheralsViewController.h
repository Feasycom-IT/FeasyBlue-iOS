//
//  FECommandPeripheralsViewController.h
//  BLEAssistant
//
//  Created by LiDong on 2021/4/21.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FEPeripheralsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FECommandPeripheralsViewController : FEPeripheralsViewController

/// 参数修改-蓝牙外设列表
- (instancetype)initWithCommands:(NSArray *)commands;

@end

NS_ASSUME_NONNULL_END
