//
//  FECommunicationChatView.h
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/7.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FECommunicationChatView : UIView

@property (nonatomic, strong) UIButton *transformConfigureBtn;// 传输配置
@property (nonatomic, strong) UIButton *exportReceiveFileBtn;// 导出接收到的文件
@property (nonatomic, strong) UIButton *clearDataBtn;// 清除数据按钮

// 接收
@property (nonatomic, strong) UILabel *receiveTipLabel;

@property (nonatomic, strong) UILabel *receiveByteCountLabel;// 接收字节量
@property (nonatomic, strong) UILabel *receiveByteTipLabel;

@property (nonatomic, strong) UILabel *receivePackageCountLabel;// 接收包量
@property (nonatomic, strong) UILabel *receivePackageTipLabel;

@property (nonatomic, strong) UILabel *receiveCRCTipLabel;
@property (nonatomic, strong) UILabel *receiveCRCValueLabel;// 接收数据的crc32

@property (nonatomic, strong) UITextView *receiveTextView;// 接收框

// 发送
@property (nonatomic, strong) UIView *sendoutBgView;
@property (nonatomic, strong) UILabel *sendoutTipLabel;

@property (nonatomic, strong) UILabel *sendoutByteCountLabel;// 发送字节量
@property (nonatomic, strong) UILabel *sendoutByteTipLabel;

@property (nonatomic, strong) UILabel *sendoutPackageCountLabel;// 发送包量
@property (nonatomic, strong) UILabel *sendoutPackageTipLabel;

@property (nonatomic, strong) UILabel *sendoutCRCTipLabel;
@property (nonatomic, strong) UILabel *sendoutCRCValueLabel;// 发送数据的crc32

@property (nonatomic, strong) UITextView *sendoutTextView;// 发送框
@property (nonatomic, strong) UILabel *sendoutByteCalculateLabel;// 输入框右下角的字节计数Label

//
@property (nonatomic, strong) UITextField *frequencyInputTextField;// 发送间隔输入框
@property (nonatomic, strong) UILabel *msTipLabel;

@property (nonatomic, strong) UILabel *frequencyTipLabel;
@property (nonatomic, strong) UISwitch *frequencySwitch;// 循环发送switch

@property (nonatomic, strong) UILabel *hexTipLabel;
@property (nonatomic, strong) UISwitch *hexSwitch;// 十六进制转换
@property (nonatomic, strong) UILabel *newlineTipLabel;
@property (nonatomic, strong) UISwitch *newlineSwitch; //发送新行切换

//
@property (nonatomic, strong) UIButton *sendoutBtn;// 发送按钮
@property (nonatomic, strong) UIButton *sendoutFileBtn;// 发送文件按钮

//
@property (nonatomic, strong) UIView *sendingProgressBgView;// bgView
@property (nonatomic, strong) UIProgressView *sendingProgress;// 进度条
@property (nonatomic, strong) UILabel *sendingProgressValueLabel;// 进度条上的进度值100.0%
@property (nonatomic, strong) UILabel *sendedByteCountLabel;// 已发送Label
@property (nonatomic, strong) UILabel *sendedSpeedLabel;// 发送速率
@property (nonatomic, strong) UILabel *sendoutNeedCountLabel;// 总大小Label
@property (nonatomic, strong) UILabel *sendedTimeLabel;// 发送耗时
@property (nonatomic, strong) UITextField *frequencyInputTextField2;// 发送间隔输入框
@property (nonatomic, strong) UILabel *msTipLabel2;
@property (nonatomic, strong) UIButton *sendoutFileBtn2;// 发送文件按钮
@property (nonatomic, strong) UIButton *stopSendoutBtn;// 停止发送按钮
@property (nonatomic, strong) UIButton *suspendSendoutBtn;// 暂停发送按钮

@end

NS_ASSUME_NONNULL_END
