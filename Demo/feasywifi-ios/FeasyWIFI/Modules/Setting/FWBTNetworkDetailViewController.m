//
//  FWBTNetworkDetailViewController.m
//  FeasyWIFI
//
//  Created by ericj on 2018/8/29.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "FWBTNetworkDetailViewController.h"
#import "FWDistributionNetworkView.h"
#import "FEBluetoothSDK.h"
#import "FEWiFi.h"

@interface FWBTNetworkDetailViewController () <UITextFieldDelegate> {
    NSTimer *_timer;
    NSInteger _timeCounter;
    MBProgressHUD *_progressHUD;
}

@property (nonatomic, strong) FEPeripheral *peripheral;
@property (nonatomic, strong) FEWiFi *wifi;
@property (nonatomic, strong) FWDistributionNetworkView *distributionNetworkView;
@property (nonatomic, copy) NSArray *configerNameArray;
@property (nonatomic, copy) NSArray *configerInputPlaceholderArray;

@end

@implementation FWBTNetworkDetailViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral {
    if (self = [super init]) {
        _peripheral = peripheral;
        [FEBluetoothSDK sharedFEBluetoothSDK].isShowLog = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_progressHUD) {
        [_progressHUD hideAnimated:NO];
        [_progressHUD removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LS(@"BluetoothDistributionNetwork");

    [self showProgressHUD];
    __weak __typeof(self) weakSelf = self;
    [self.wifi check:@"DNS" complete:^(NSString * _Nullable key, NSString * _Nullable value, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            strongSelf.configerNameArray = @[@"SSID:", LS(@"Password"), LS(@"Static IP"), @"GW:", @"MASK:", @"DNS:"];
            strongSelf.configerInputPlaceholderArray = @[LS(@"Please enter a WiFi name"), LS(@"Please enter a WiFi password"), LS(@"Please enter the preset static IP"), LS(@"Please enter the preset GW"), LS(@"Please enter the preset MASK"), LS(@"Please enter the preset DNS")];
        } else {
            strongSelf.configerNameArray = @[@"SSID:", LS(@"Password"), LS(@"Static IP"), @"GW:", @"MASK:"];
            strongSelf.configerInputPlaceholderArray = @[LS(@"Please enter a WiFi name"), LS(@"Please enter a WiFi password"), LS(@"Please enter the preset static IP"), LS(@"Please enter the preset GW"), LS(@"Please enter the preset MASK")];
        }
        [strongSelf.view addSubview:self.distributionNetworkView];
        [strongSelf.distributionNetworkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(strongSelf.view);
            make.left.mas_equalTo(strongSelf.view);
            make.height.mas_equalTo(strongSelf.view.mas_height);
            make.width.mas_equalTo(strongSelf.view.mas_width);
        }];
        // 读取模块当前的DHCP状态
        [strongSelf checkDHCPOption];
    }];
}

- (void)checkDHCPOption {
    __weak __typeof(self) weakSelf = self;
    [self.wifi checkConfigDynamicOrStaticNetworkCompleteBlock:^(BOOL isSwitchedDynamic, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
        if (!error) {
            if (isSwitchedDynamic) {
                strongSelf.distributionNetworkView.DHCPSwitch.on = YES;
                [strongSelf.distributionNetworkView changedDHCPSwitch];
            } else {
                strongSelf.distributionNetworkView.DHCPSwitch.on = NO;
                [strongSelf.distributionNetworkView changedDHCPSwitch];
            }
        }
    }];
}

#pragma mark - HUD
- (void)showProgressHUD {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    [self.view setUserInteractionEnabled:NO];
    [self.view addSubview:_progressHUD];
    [_progressHUD showAnimated:YES];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_progressHUD hideAnimated:YES];
        [self performSelector:@selector(progressHUDDidHide:) withObject:_progressHUD afterDelay:0.5];
    }
}

- (void)progressHUDDidHide:(UIView *)progressHUD {
    if (progressHUD == _progressHUD) {
        [self.view setUserInteractionEnabled:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

- (FEWiFi *)wifi {
    if (!_wifi) {
        _wifi = [[FEWiFi alloc] initWithPeripheral:_peripheral];
    }
    return _wifi;
}

// 蓝牙配网View
- (FWDistributionNetworkView *)distributionNetworkView {
    if (!_distributionNetworkView) {
        _distributionNetworkView = [[FWDistributionNetworkView alloc] initWithTitles:self.configerNameArray inputPlaceHolders:self.configerInputPlaceholderArray];
        _distributionNetworkView.frame = self.view.bounds;
        [_distributionNetworkView.DHCPSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_distributionNetworkView.configButton addTarget:self action:@selector(configIP) forControlEvents:UIControlEventTouchUpInside];
        _distributionNetworkView.networkNameTextField.delegate = self;
        _distributionNetworkView.passwordTextField.delegate = self;
        _distributionNetworkView.IPTextField.delegate = self;
    }
    return _distributionNetworkView;
}

// DHCP切换Action
- (void)switchValueChanged:(UISwitch *)sender {
    [self showProgressHUD];
    __weak __typeof(self) weakSelf = self;
    // 每次切换DHCP需要从模块拿到反馈
    [self.wifi switchConfigDynamicOrStaticNetwork:sender.isOn completeBlock:^(BOOL isSwitchedDynamic, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf performSelector:@selector(valueDidChange:) withObject:[NSNumber numberWithBool:isSwitchedDynamic] afterDelay:0.5];
        }
    }];
}

- (void)valueDidChange:(NSNumber *)value {
    [self hideProgressHUD];
    if (value.boolValue) {
        self.distributionNetworkView.DHCPSwitch.on = YES;
    } else {
        self.distributionNetworkView.DHCPSwitch.on = NO;
    }
}

// 配网Action
- (void)configIP {
    [self.view endEditing:YES];
    NSString *networkName = self.distributionNetworkView.networkNameTextField.text;
    NSString *password = self.distributionNetworkView.passwordTextField.text;
    
    NSString *configer_StaticIP = [self.distributionNetworkView.networkConfigerInfoDic objectForKey:@"staticIP"];
    NSString *configer_GW = [self.distributionNetworkView.networkConfigerInfoDic objectForKey:@"GW"];
    NSString *configer_MASL = [self.distributionNetworkView.networkConfigerInfoDic objectForKey:@"MASK"];
    NSString *configer_DNS = [self.distributionNetworkView.networkConfigerInfoDic objectForKey:@"DNS"];
    
    if (networkName.length == 0) {
        [self showAlertControllerWithTitle:LS(@"SSID input error, please re-enter")];
        return;
    }
    
    if (!self.distributionNetworkView.DHCPSwitch.isOn && configer_StaticIP.length == 0) {
        [self showAlertControllerWithTitle:LS(@"Static IP input error, please re-enter")];
        return;
    }
    
    if (self.distributionNetworkView.DHCPSwitch.isOn) {
        [self showProgressHUDWithTitle:LS(@"Configuring network")];
        __weak __typeof(self) weakSelf = self;
        [self.wifi btConfigDynamicNetwork:networkName password:password reconnect:YES completeBlock:^(NSString * _Nullable IPAddress, NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf hideProgressHUD];
            if (error) {
                [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
            } else {
                if (IPAddress) {
                    [strongSelf showAlertControllerWithTitle:LS(@"Config network success") message:[NSString stringWithFormat:@"IP Address:%@", IPAddress]];
                } else {
                    [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
                }
            }
        }];
    } else {
        [self showProgressHUDWithTitle:LS(@"Configuring network")];
        __weak __typeof(self) weakSelf = self;
        [self.wifi btConfigStaticNetwork:networkName password:password staticIp:configer_StaticIP GW:configer_GW MASK:configer_MASL DNS:configer_DNS reconnect:YES completeBlock:^(NSString * _Nullable IPAddress, NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf hideProgressHUD];
            if (error) {
                [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
            } else {
                if (IPAddress) {
                    [strongSelf showAlertControllerWithTitle:LS(@"Config network success") message:[NSString stringWithFormat:@"IP Address:%@", IPAddress]];
                } else {
                    [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
                }
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// 第三种键盘弹起方法（调整view的约束）
- (void)showKeyboard:(NSNotification *)notification {
    
    if (self.distributionNetworkView.networkNameTextField.isFirstResponder ||
        self.distributionNetworkView.passwordTextField.isFirstResponder ||
        self.distributionNetworkView.IPTextField.isFirstResponder) {
        return;
    }
    
    // 读取userInfo中的动画种类
    NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // 读取userInfo中的动画时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 获取弹起的键盘的frame中的左顶点位置的y
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [self.distributionNetworkView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(-height+60);
    }];
    
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

// 第三种键盘弹起方法（调整view的约束）
- (void)closeKeyboard:(NSNotification *)notification {
    [self.distributionNetworkView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
}

- (void)showProgressHUDWithTitle:(NSString *)title {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    
    UIView *view = self.view;
    
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
    }
    
    _progressHUD.label.text = title;
    
    [view setUserInteractionEnabled:NO];
    [view addSubview:_progressHUD];
    
    [_progressHUD showAnimated:YES];
}

@end
