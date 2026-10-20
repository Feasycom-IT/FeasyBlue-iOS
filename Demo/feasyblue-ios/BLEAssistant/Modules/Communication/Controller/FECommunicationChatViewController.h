//
//  FECommunicationChatViewController.h
//  FeasycomLE
//
//  Created by 余明悦 on 16/7/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FEPeripheral;

/// 通讯主页面VC
@interface FECommunicationChatViewController : UIViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral;

@end

