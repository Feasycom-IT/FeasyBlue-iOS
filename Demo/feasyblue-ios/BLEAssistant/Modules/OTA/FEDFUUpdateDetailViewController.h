//
//  FEDFUUpdateDetailViewController.h
//  BLEAssistant
//
//  Created by ericj on 2018/1/26.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FEPeripheral;

@interface FEDFUUpdateDetailViewController : UIViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral peripherals:(NSArray<FEPeripheral *> *)peripherals;

@end
