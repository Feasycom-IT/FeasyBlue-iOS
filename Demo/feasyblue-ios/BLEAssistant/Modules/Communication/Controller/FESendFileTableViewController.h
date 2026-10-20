//
//  FESendFileTableViewController.h
//  BLEAssistant
//
//  Created by yumingyue on 2016/11/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FESendFileTableViewController;

@protocol FESendFileTableViewControllerDelegate <NSObject>
- (void)sendData:(NSData *)data;
@end

/// 通讯-选择发送的文件VC
@interface FESendFileTableViewController : UITableViewController

@property(nonatomic,weak)id<FESendFileTableViewControllerDelegate> delegate;

@end
