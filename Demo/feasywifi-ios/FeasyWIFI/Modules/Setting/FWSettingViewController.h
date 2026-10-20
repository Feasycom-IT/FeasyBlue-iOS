//
//  FWSettingViewController.h
//  FeasyWIFI
//
//  Created by ericj on 2018/7/5.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FEPeripheral;

/// 功能选择VC（蓝牙配网、OTA升级）
@interface FWSettingViewController : UIViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral;

@end
