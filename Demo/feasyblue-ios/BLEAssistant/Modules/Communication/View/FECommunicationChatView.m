//
//  FECommunicationChatView.m
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/7.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FECommunicationChatView.h"

@interface FECommunicationChatView ()

@end

@implementation FECommunicationChatView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self setupMonitor];
    }
    return self;;
}

- (void)dealloc {
    [self.sendingProgressBgView removeObserver:self forKeyPath:@"hidden"];
    [self.transformConfigureBtn removeObserver:self forKeyPath:@"enabled" ];
    [self.exportReceiveFileBtn removeObserver:self forKeyPath:@"enabled"];
    [self.clearDataBtn removeObserver:self forKeyPath:@"enabled"];
    [self.sendoutBtn removeObserver:self forKeyPath:@"enabled"];
    [self.sendoutFileBtn removeObserver:self forKeyPath:@"enabled"];
    [self.sendoutFileBtn2 removeObserver:self forKeyPath:@"enabled"];
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithHexString:@"#F2F2F7"];
    // 清除数据按钮
    self.clearDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearDataBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.clearDataBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.clearDataBtn setTitle:LS(@"communication_clear") forState:UIControlStateNormal];
    [self.clearDataBtn setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.clearDataBtn];
    [self.clearDataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 40));
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(self.mas_top).offset(10);
    }];
    // 导出按钮
    self.exportReceiveFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exportReceiveFileBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.exportReceiveFileBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.exportReceiveFileBtn setTitle:LS(@"communication_export") forState:UIControlStateNormal];
    [self.exportReceiveFileBtn setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.exportReceiveFileBtn];
    [self.exportReceiveFileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 40));
        make.right.mas_equalTo(self.clearDataBtn.mas_left).offset(-10);
        make.top.mas_equalTo(self.mas_top).offset(10);
    }];
    // 传输配置按钮
    self.transformConfigureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.transformConfigureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.transformConfigureBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.transformConfigureBtn setTitle:LS(@"communication_transmissionConfiguration") forState:UIControlStateNormal];
    [self.transformConfigureBtn sizeToFit];
    [self.transformConfigureBtn setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.transformConfigureBtn];
    [self.transformConfigureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.right.mas_equalTo(self.exportReceiveFileBtn.mas_left).offset(-10);
        make.top.mas_equalTo(self.mas_top).offset(10);
    }];
    // “累计接收：“
    self.receiveTipLabel = [[UILabel alloc] init];
    self.receiveTipLabel.text = LS(@"communication_receiveTip");
    self.receiveTipLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receiveTipLabel];
    [self.receiveTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.top.mas_equalTo(self.clearDataBtn.mas_bottom).offset(10);
    }];
    // （字节数）
    self.receiveByteCountLabel = [[UILabel alloc] init];
    self.receiveByteCountLabel.text = @"0";
    self.receiveByteCountLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receiveByteCountLabel];
    [self.receiveByteCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.receiveTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.receiveTipLabel.mas_centerY);
    }];
    // “字节”
    self.receiveByteTipLabel = [[UILabel alloc] init];
    self.receiveByteTipLabel.text = LS(@"communication_byteTip");
    self.receiveByteTipLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receiveByteTipLabel];
    [self.receiveByteTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.receiveByteCountLabel.mas_right).offset(2);
        make.centerY.mas_equalTo(self.receiveTipLabel.mas_centerY);
    }];
    // （包数）
    self.receivePackageCountLabel = [[UILabel alloc] init];
    self.receivePackageCountLabel.text = @"0";
    self.receivePackageCountLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receivePackageCountLabel];
    [self.receivePackageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.receiveByteTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.receiveTipLabel.mas_centerY);
    }];
    // ”包“
    self.receivePackageTipLabel = [[UILabel alloc] init];
    self.receivePackageTipLabel.text = LS(@"communication_packageTip");
    self.receivePackageTipLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receivePackageTipLabel];
    [self.receivePackageTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.receivePackageCountLabel.mas_right).offset(2);
        make.centerY.mas_equalTo(self.receiveTipLabel.mas_centerY);
    }];
    // （CRC32数值）
    self.receiveCRCValueLabel = [[UILabel alloc] init];
    self.receiveCRCValueLabel.text = @"00000000";
    self.receiveCRCValueLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receiveCRCValueLabel];
    [self.receiveCRCValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.centerY.mas_equalTo(self.receiveTipLabel.mas_centerY);
    }];
    // ”CRC32:“
    self.receiveCRCTipLabel = [[UILabel alloc] init];
    self.receiveCRCTipLabel.text = @"CRC32:";
    self.receiveCRCTipLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.receiveCRCTipLabel];
    [self.receiveCRCTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.receiveCRCValueLabel.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.receiveTipLabel.mas_centerY);
    }];
    
    // ⚠️发送信息的展示背景墙
    self.sendoutBgView = [[UIView alloc] init];
    self.sendoutBgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F7"];
    [self addSubview:self.sendoutBgView];
    [self.sendoutBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.receiveTipLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    // 接收数据框
    self.receiveTextView = [[UITextView alloc] init];
    self.receiveTextView.editable = NO;
    self.receiveTextView.backgroundColor = [UIColor whiteColor];
    [self.sendoutBgView addSubview:self.receiveTextView];
    [self.receiveTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sendoutBgView.mas_top).offset(0);
        make.left.mas_equalTo(self.sendoutBgView.mas_left).offset(0);
        make.right.mas_equalTo(self.sendoutBgView.mas_right).offset(-0);
        make.bottom.mas_equalTo(self.sendoutBgView.mas_bottom).offset(-260);
    }];
    
    // ”累计发送：“
    self.sendoutTipLabel = [[UILabel alloc] init];
    self.sendoutTipLabel.text = LS(@"communication_sendoutTip");
    self.sendoutTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutTipLabel];
    [self.sendoutTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutBgView.mas_left);
        make.top.mas_equalTo(self.receiveTextView.mas_bottom).offset(10);
    }];
    // （字节数）
    self.sendoutByteCountLabel = [[UILabel alloc] init];
    self.sendoutByteCountLabel.text = @"0";
    self.sendoutByteCountLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutByteCountLabel];
    [self.sendoutByteCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.sendoutTipLabel.mas_centerY);
    }];
    // ”字节“
    self.sendoutByteTipLabel = [[UILabel alloc] init];
    self.sendoutByteTipLabel.text = LS(@"communication_byteTip");
    self.sendoutByteTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutByteTipLabel];
    [self.sendoutByteTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutByteCountLabel.mas_right).offset(2);
        make.centerY.mas_equalTo(self.sendoutTipLabel.mas_centerY);
    }];
    // （包数）
    self.sendoutPackageCountLabel = [[UILabel alloc] init];
    self.sendoutPackageCountLabel.text = @"0";
    self.sendoutPackageCountLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutPackageCountLabel];
    [self.sendoutPackageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutByteTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.sendoutTipLabel.mas_centerY);
    }];
    // ”包“
    self.sendoutPackageTipLabel = [[UILabel alloc] init];
    self.sendoutPackageTipLabel.text = LS(@"communication_packageTip");
    self.sendoutPackageTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutPackageTipLabel];
    [self.sendoutPackageTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutPackageCountLabel.mas_right).offset(2);
        make.centerY.mas_equalTo(self.sendoutTipLabel.mas_centerY);
    }];
    // （CRC32数值）
    self.sendoutCRCValueLabel = [[UILabel alloc] init];
    self.sendoutCRCValueLabel.text = @"00000000";
    self.sendoutCRCValueLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutCRCValueLabel];
    [self.sendoutCRCValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sendoutBgView.mas_right);
        make.centerY.mas_equalTo(self.sendoutTipLabel.mas_centerY);
    }];
    // “CRC32:”
    self.sendoutCRCTipLabel = [[UILabel alloc] init];
    self.sendoutCRCTipLabel.text = @"CRC32:";
    self.sendoutCRCTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.sendoutCRCTipLabel];
    [self.sendoutCRCTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sendoutCRCValueLabel.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.sendoutTipLabel.mas_centerY);
    }];
    // 发送输入框
    self.sendoutTextView = [[UITextView alloc] init];
    self.sendoutTextView.backgroundColor = [UIColor whiteColor];
    [self.sendoutBgView addSubview:self.sendoutTextView];
    [self.sendoutTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sendoutTipLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.sendoutBgView.mas_left);
        make.right.mas_equalTo(self.sendoutBgView.mas_right);
        make.height.mas_equalTo(90);
    }];
    // 发送输入框字符计数Label
    self.sendoutByteCalculateLabel = [[UILabel alloc] init];
    self.sendoutByteCalculateLabel.text = [NSString stringWithFormat:@"0%@",LS(@"communication_byte")];
    self.sendoutByteCalculateLabel.font = [UIFont systemFontOfSize:9];
    [self.sendoutBgView addSubview:self.sendoutByteCalculateLabel];
    [self.sendoutByteCalculateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sendoutTextView.mas_right).offset(-2);
        make.bottom.mas_equalTo(self.sendoutTextView.mas_bottom).offset(-2);
    }];
    // 发送间隔输入框
    self.frequencyInputTextField = [[UITextField alloc] init];
    self.frequencyInputTextField.placeholder = LS(@"communication_frequency");
    self.frequencyInputTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.frequencyInputTextField.font = [UIFont systemFontOfSize:14];
    self.frequencyInputTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.sendoutBgView addSubview:self.frequencyInputTextField];
    [self.frequencyInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutTextView.mas_left);
        make.top.mas_equalTo(self.sendoutTextView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(85, 34));
    }];
    // “ms”
    self.msTipLabel = [[UILabel alloc] init];
    self.msTipLabel.text = @"ms";
    self.msTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.msTipLabel];
    [self.msTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.frequencyInputTextField.mas_right).offset(2);
        make.centerY.mas_equalTo(self.frequencyInputTextField.mas_centerY);
    }];
    // “循环发送”
    self.frequencyTipLabel = [[UILabel alloc] init];
    self.frequencyTipLabel.text = LS(@"communication_circular");
    self.frequencyTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.frequencyTipLabel];
    [self.frequencyTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.frequencyInputTextField.mas_centerY);
    }];
    // 循环发送switch按钮
    self.frequencySwitch = [[UISwitch alloc] init];
    [self.sendoutBgView addSubview:self.frequencySwitch];
    [self.frequencySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.frequencyTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.frequencyTipLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    // “HEX”
    self.hexTipLabel = [[UILabel alloc] init];
    self.hexTipLabel.text = @"HEX";
    self.hexTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.hexTipLabel];
    [self.hexTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendoutTextView.mas_left);
        make.top.mas_equalTo(self.frequencyInputTextField.mas_bottom).offset(20);
    }];
    // 十六进制switch按钮
    self.hexSwitch = [[UISwitch alloc] init];
    [self.sendoutBgView addSubview:self.hexSwitch];
    [self.hexSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hexTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.hexTipLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    //newline textTip
    self.newlineTipLabel = [[UILabel alloc] init];
    self.newlineTipLabel.text = LS(@"newline");
    self.newlineTipLabel.font = [UIFont systemFontOfSize:12];
    [self.sendoutBgView addSubview:self.newlineTipLabel];
    [self.newlineTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.frequencyTipLabel.mas_left);
        make.top.mas_equalTo(self.hexTipLabel.mas_top);
    }];
    //newline switch
    self.newlineSwitch = [[UISwitch alloc] init];
    [self.sendoutBgView addSubview:self.newlineSwitch];
    [self.newlineSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.frequencySwitch.mas_left);
        make.centerY.mas_equalTo(self.hexSwitch.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    // 发送（输入框内容）按钮
    self.sendoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendoutBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.sendoutBtn setTitle:LS(@"communication_send") forState:UIControlStateNormal];
    [self.sendoutBtn setBackgroundColor:[UIColor grayColor]];
    [self.sendoutBgView addSubview:self.sendoutBtn];
    [self.sendoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 40));
        make.right.mas_equalTo(self.sendoutBgView.mas_right);
        make.bottom.mas_equalTo(self.sendoutBgView.mas_bottom).offset(-90);
    }];
    // 发送文件按钮
    self.sendoutFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendoutFileBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendoutFileBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.sendoutFileBtn setTitle:LS(@"communication_sendFile") forState:UIControlStateNormal];
    [self.sendoutFileBtn setBackgroundColor:[UIColor grayColor]];
    [self.sendoutBgView addSubview:self.sendoutFileBtn];
    [self.sendoutFileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 40));
        make.right.mas_equalTo(self.clearDataBtn.mas_right);
        make.bottom.mas_equalTo(self.sendoutBgView.mas_bottom).offset(-40);
    }];
    
    // ⚠️发送文件过程信息展示背景墙
    self.sendingProgressBgView = [[UIView alloc] init];
    self.sendingProgressBgView.hidden = YES;
    self.sendingProgressBgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F7"];
    [self.sendoutBgView addSubview:self.sendingProgressBgView];
    [self.sendingProgressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sendoutTipLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.sendoutBgView.mas_left);
        make.right.mas_equalTo(self.sendoutBgView.mas_right);
        make.bottom.mas_equalTo(self.sendoutBgView.mas_bottom);
    }];
    // 进度条
    self.sendingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.sendingProgress.progress = 0.0f;
    self.sendingProgress.layer.cornerRadius = 15.0;
    self.sendingProgress.layer.masksToBounds = YES;
    [self.sendingProgressBgView addSubview:self.sendingProgress];
    [self.sendingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sendingProgressBgView.mas_top);
        make.left.right.equalTo(self.sendingProgressBgView);
        make.height.mas_equalTo(30);
    }];
    // 进度值（在进度条中展示）
    self.sendingProgressValueLabel = [[UILabel alloc] init];
    self.sendingProgressValueLabel.text = @"0%";
    self.sendingProgressValueLabel.font = [UIFont systemFontOfSize:12];
    [self.sendingProgress addSubview:self.sendingProgressValueLabel];
    [self.sendingProgressValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.sendingProgress);
    }];
    // “已发送：……”
    self.sendedByteCountLabel = [[UILabel alloc] init];
    self.sendedByteCountLabel.text = [NSString stringWithFormat:@"%@0", LS(@"communication_sended")];
    self.sendedByteCountLabel.font = [UIFont systemFontOfSize:14];
    [self.sendingProgressBgView addSubview:self.sendedByteCountLabel];
    [self.sendedByteCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendingProgress.mas_bottom).offset(10);
        make.left.mas_equalTo(self.sendingProgress.mas_left);
    }];
    // “速率：……”
    self.sendedSpeedLabel = [[UILabel alloc] init];
    self.sendedSpeedLabel.text = [NSString stringWithFormat:@"%@ Byte/s", LS(@"communication_sendSpeed")];
    self.sendedSpeedLabel.font = [UIFont systemFontOfSize:14];
    [self.sendingProgressBgView addSubview:self.sendedSpeedLabel];
    [self.sendedSpeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendingProgress.mas_bottom).offset(10);
        make.left.mas_equalTo(self.sendingProgress.mas_left).offset(kScreen_Width/2.f);
    }];
    // “需发送：……”
    self.sendoutNeedCountLabel = [[UILabel alloc] init];
    self.sendoutNeedCountLabel.text = LS(@"communication_sendTotal");
    self.sendoutNeedCountLabel.font = [UIFont systemFontOfSize:14];
    [self.sendingProgressBgView addSubview:self.sendoutNeedCountLabel];
    [self.sendoutNeedCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendedByteCountLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.sendingProgress.mas_left);
    }];
    // “时间：……”
    self.sendedTimeLabel = [[UILabel alloc] init];
    self.sendedTimeLabel.text = [NSString stringWithFormat:@"%@00:00:00", LS(@"communication_sendTime")];
    self.sendedTimeLabel.font = [UIFont systemFontOfSize:14];
    [self.sendingProgressBgView addSubview:self.sendedTimeLabel];
    [self.sendedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendedByteCountLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.sendingProgress.mas_left).offset(kScreen_Width/2.f);
    }];
    // “循环发送间隔”输入框
    self.frequencyInputTextField2 = [[UITextField alloc] init];
    self.frequencyInputTextField2.placeholder = LS(@"communication_frequency");
    self.frequencyInputTextField2.keyboardType = UIKeyboardTypeNumberPad;
    self.frequencyInputTextField2.font = [UIFont systemFontOfSize:14];
    self.frequencyInputTextField2.borderStyle = UITextBorderStyleRoundedRect;
    [self.sendingProgressBgView addSubview:self.frequencyInputTextField2];
    [self.frequencyInputTextField2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendingProgress.mas_left);
        make.top.mas_equalTo(self.sendoutNeedCountLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(85, 34));
    }];
    // “ms”
    self.msTipLabel2 = [[UILabel alloc] init];
    self.msTipLabel2.text = @"ms";
    self.msTipLabel2.font = [UIFont systemFontOfSize:12];
    [self.sendingProgressBgView addSubview:self.msTipLabel2];
    [self.msTipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.frequencyInputTextField2.mas_right).offset(2);
        make.centerY.mas_equalTo(self.frequencyInputTextField2.mas_centerY);
    }];
    // 发送文件按钮
    self.sendoutFileBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendoutFileBtn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendoutFileBtn2.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.sendoutFileBtn2 setTitle:LS(@"communication_sendFile") forState:UIControlStateNormal];
    [self.sendoutFileBtn2 setBackgroundColor:[UIColor grayColor]];
    [self.sendingProgressBgView addSubview:self.sendoutFileBtn2];
    [self.sendoutFileBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 40));
        make.right.mas_equalTo(self.sendingProgressBgView.mas_right);
        make.bottom.mas_equalTo(self.sendingProgressBgView.mas_bottom).offset(-40);
    }];
    // 停止发送按钮
    self.stopSendoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stopSendoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.stopSendoutBtn setImage:[UIImage imageNamed:@"send_stop"] forState:UIControlStateNormal];
    self.stopSendoutBtn.layer.cornerRadius = 23;
    self.stopSendoutBtn.layer.masksToBounds = YES;
    [self.sendingProgressBgView addSubview:self.stopSendoutBtn];
    [self.stopSendoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.left.mas_equalTo(self.sendingProgressBgView.mas_left);
        make.bottom.mas_equalTo(self.sendingProgressBgView.mas_bottom).offset(-40);
    }];
    // 开始、暂停按钮
    self.suspendSendoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.suspendSendoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.suspendSendoutBtn setImage:[UIImage imageNamed:@"send_susp"] forState:UIControlStateNormal];
    [self.suspendSendoutBtn setImage:[UIImage imageNamed:@"send_start"] forState:UIControlStateSelected];
    self.suspendSendoutBtn.layer.cornerRadius = 23;
    self.suspendSendoutBtn.layer.masksToBounds = YES;
    [self.sendingProgressBgView addSubview:self.suspendSendoutBtn];
    [self.suspendSendoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.left.mas_equalTo(self.stopSendoutBtn.mas_right).offset(40);
        make.bottom.mas_equalTo(self.sendingProgressBgView.mas_bottom).offset(-40);
    }];
}

- (void)setupMonitor {
    [self.sendingProgressBgView addObserver:self forKeyPath:@"hidden" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self.transformConfigureBtn addObserver:self forKeyPath:@"enabled" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self.exportReceiveFileBtn addObserver:self forKeyPath:@"enabled" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self.clearDataBtn addObserver:self forKeyPath:@"enabled" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self.sendoutBtn addObserver:self forKeyPath:@"enabled" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self.sendoutFileBtn addObserver:self forKeyPath:@"enabled" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self.sendoutFileBtn2 addObserver:self forKeyPath:@"enabled" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //
    if (object == self.sendingProgressBgView && [keyPath isEqualToString:@"hidden"]) {
        if (!self.sendingProgressBgView.isHidden) {
            self.frequencyInputTextField2.text = self.frequencyInputTextField.text;
        } else {
            self.frequencyInputTextField.text = self.frequencyInputTextField2.text;
        }
    }
    //
    if ([object isKindOfClass:UIButton.class] && [keyPath isEqualToString:@"enabled"]) {
        UIButton *btn = (UIButton *)object;
        if (btn.isEnabled) {
            [btn setAlpha:1.f];
        } else {
            [btn setAlpha:0.4f];
        }
    }
}

@end
