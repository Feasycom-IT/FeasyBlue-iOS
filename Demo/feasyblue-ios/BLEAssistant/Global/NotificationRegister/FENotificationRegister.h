//
//  FENotificationRegister.h
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/29.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FENotificationRegister : NSObject

/// 参数修改完成了一次的通知（设备数+1）
extern NSString * const FEIncreaseModifiedCountNotification;

///
extern NSString * const FENotificationUrlNotification;

/// 空中升级文件下载成功的通知
extern NSString * const FEFileDownloadedNotification;


@end

NS_ASSUME_NONNULL_END
