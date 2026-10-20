//
//  FEChangeDetailViewController.h
//  BLEAssistant
//
//  Created by ericj on 2018/2/8.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FEPeripheral;

/// 参数修改过程-日志打印VC
@interface FEChangeDetailViewController : UIViewController

/// 初始化参数修改会话VC
/// @param peripheral 需要进行参数修改的蓝牙外设
/// @param commands 参数修改指令数组
- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral commands:(NSArray *)commands;

@end
