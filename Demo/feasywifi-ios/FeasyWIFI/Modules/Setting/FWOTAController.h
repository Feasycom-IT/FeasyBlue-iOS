//
//  FWOTAController.h
//  FeasyWIFI
//
//  Created by wenyewei on 2019/7/31.
//  Copyright © 2019年 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

/// OTA升级的配置界面
@interface FWOTAController : UIViewController

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
