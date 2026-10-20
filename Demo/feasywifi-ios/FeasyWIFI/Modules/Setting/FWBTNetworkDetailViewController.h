//
//  FWBTNetworkDetailViewController.h
//  FeasyWIFI
//
//  Created by ericj on 2018/8/29.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEBluetoothSDK.h"

/// 蓝牙配网界面
@interface FWBTNetworkDetailViewController : UIViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral;

@end
