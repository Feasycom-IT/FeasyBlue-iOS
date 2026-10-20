//
//  FEServicesViewController.h
//  BLEAssistant
//
//  Created by yumingyue on 2016/11/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FEPeripheral;

/// 通讯-传输配置VC
@interface FEServicesViewController : UITableViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral;

@end
