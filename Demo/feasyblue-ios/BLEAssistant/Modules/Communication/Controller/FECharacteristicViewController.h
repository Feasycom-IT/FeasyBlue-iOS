//
//  FECharacteristicViewController.h
//  BLEAssistant
//
//  Created by ericj on 2018/1/8.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class FEPeripheral;

/// 通讯-传输配置-特征配置
@interface FECharacteristicViewController : UITableViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

@end
