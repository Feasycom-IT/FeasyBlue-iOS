//
//  FWOTAController.m
//  FeasyWIFI
//
//  Created by wenyewei on 2019/7/31.
//  Copyright © 2019年 Feasycom. All rights reserved.
//

typedef enum {
    START_TYPE,
    OPEN_TYPE,
    LIP_TYPE,
    RAP_TYPE,
    OTA_TYPE,
    END_TYPE
}RECIVE_TYPE;

#import "FWOTAController.h"
#import "FEBluetoothSDK.h"
#import "FEWiFi.h"
#import "SVProgressHUD.h"
#import "UIImage+Color.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>
//#import <NetworkExtension/NetworkExtension.h>


@interface FWOTAController () <UITextFieldDelegate>
{
    UITextField *_upgradeTextField;
    UILabel *_IPLabel;
    UILabel *_versionLabel;
    UIButton *_upgradeButton;
    UIButton *_queryIPButton;
    UIButton *_queryVersionButton;
    UIButton *_restoreButton;
    
    MBProgressHUD *_progressHUD;
}

@property (nonatomic, strong) FEPeripheral *peripheral;
@property (nonatomic, strong) FEWiFi *wifi;
@property (nonatomic) BOOL upgrading;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSTimer *otaTimeoutTimer;

@end

@implementation FWOTAController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [SVProgressHUD dismiss];
}

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _peripheral = peripheral;
        _wifi = [[FEWiFi alloc] initWithPeripheral:_peripheral];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self progressHUDDidHide:_progressHUD];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"OTAUpgrade");
    [FEBluetoothSDK sharedFEBluetoothSDK].isShowLog = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupView];
    [self tapBackgroundToClose];
    [self hideProgressHUD];
}

- (void)showProgressHUD {
    [_upgradeTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _restoreButton.enabled = NO;
    _queryIPButton.enabled = NO;
    _upgradeButton.enabled = NO;
    _queryVersionButton.enabled = NO;
}

- (void)hideProgressHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _restoreButton.enabled = YES;
    _queryIPButton.enabled = YES;
    _upgradeButton.enabled = YES;
    _queryVersionButton.enabled = YES;
}

- (void)tapBackgroundToClose {//需要在- (void)viewDidLoad{}中调用
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];

    [tap setNumberOfTapsRequired:1];//触击次数设为1
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tap];//添加手势到view中
}

- (void)backgroundTapped {
    [_upgradeTextField resignFirstResponder];
}

//查询Ip
- (void)queryIP {
    [self showProgressHUD];
    __weak __typeof(self) weakSelf = self;
    [_wifi checkIPWithHandler:^(NSString * _Nullable IPAddress, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:0.5];
        if (0 < IPAddress.length && ![IPAddress isEqualToString:@"0.0.0.0"]) {
            strongSelf->_IPLabel.text = IPAddress;
        } else {
            strongSelf->_IPLabel.text = @"0.0.0.0";
        }
    }];
}

//查询版本
- (void)queryVersion {
    [self showProgressHUD];
    __weak __typeof(self) weakSelf = self;
    [self.wifi checkVersionComplete:^(NSString * _Nullable key, NSString * _Nullable value, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:0.5];
        if (0 < value.length) {
            strongSelf->_versionLabel.text = value;
        } else {
            strongSelf.alertController = [strongSelf showAlertControllerWithTitle:LS(@"Failed to query module version")];
        }
    }];
}

//升级
- (void)upgrade {
    NSString *name = [self->_upgradeTextField text];
    if (name.length <= 0) {
        self.alertController = [self showAlertControllerWithTitle:LS(@"Please enter the firmware name")];
        return;
    }
    [self upgradeWithName:name];
    [self->_upgradeTextField resignFirstResponder];
}

- (void)upgradeWithName:(NSString *)name {
    __weak __typeof(self) weakSelf = self;
    
    _upgrading = YES;
    if (!self.otaTimeoutTimer) {
        self.otaTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(otaTimeoutAction) userInfo:nil repeats:NO];
    }
    [self showProgressHUDWithTitle:LS(@"Upgrading firmware, please wait")];
    [_wifi otaWithName:name progress:^(NSNumber * _Nonnull percent) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.otaTimeoutTimer) {
            [strongSelf.otaTimeoutTimer invalidate];
            strongSelf.otaTimeoutTimer = nil;
        }
        if (strongSelf.upgrading) {
            strongSelf->_progressHUD.label.text = [NSString stringWithFormat:@"%@(%ld%%)",LS(@"Upgrading firmware, please wait"),percent.integerValue];
        }
        if (!strongSelf.otaTimeoutTimer) {
            strongSelf.otaTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:strongSelf selector:@selector(otaTimeoutAction) userInfo:nil repeats:NO];
        }
    } complete:^(BOOL isSuccess, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.otaTimeoutTimer) {
            [strongSelf.otaTimeoutTimer invalidate];
            strongSelf.otaTimeoutTimer = nil;
        }
        if (error.code == FSCCommomError_NetworkLack) {
            [SVProgressHUD dismiss];
            strongSelf.alertController = [strongSelf showAlertControllerWithTitle:LS(@"OTA upgrade requires completing Bluetooth network distribution first")];
            strongSelf->_restoreButton.enabled = YES;
            strongSelf->_queryIPButton.enabled = YES;
            strongSelf->_upgradeButton.enabled = YES;
            strongSelf->_queryVersionButton.enabled = YES;
        }
        [strongSelf progressHUDDidHide:strongSelf->_progressHUD];
        if (strongSelf.upgrading) {
            strongSelf.upgrading = NO;
            strongSelf.alertController = [strongSelf showAlertControllerWithTitle:(isSuccess ? LS(@"Module firmware upgrade success") : LS(@"Module firmware upgrade fail"))];
        }
    }];
}

- (void)otaTimeoutAction {
    if (self.otaTimeoutTimer) {
        [self.otaTimeoutTimer invalidate];
        self.otaTimeoutTimer = nil;
    }
    [self progressHUDDidHide:self->_progressHUD];
    if (self.upgrading) {
        self.upgrading = NO;
        self.alertController = [self showAlertControllerWithTitle:LS(@"Module firmware upgrade fail")];
    }
}

//恢复出厂设置
-(void)restore {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Do you want to restore the module to its factory settings") message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *determineAction = [UIAlertAction actionWithTitle:LS(@"Restore factory settings") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showProgressHUDWithTitle:LS(@"Restoring factory settings, please wait")];
        __weak __typeof(self) weakSelf = self;
        [strongSelf->_wifi restore:^(BOOL, NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:120];
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:determineAction];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)setupView {
    //
    UILabel *upgradeLabel = [[UILabel alloc] init];
    upgradeLabel.textColor = [UIColor grayColor];
    upgradeLabel.text = LS(@"Firmware Name:");
    [self.view addSubview:upgradeLabel];
    [upgradeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.width.mas_equalTo(@100);
        make.top.equalTo(self.view.mas_top).offset(20);
        make.height.equalTo(@60);
    }];

    // 升级固件名输入
    _upgradeTextField = [[UITextField alloc] init];
    _upgradeTextField.delegate = self;
    _upgradeTextField.textColor = [UIColor blackColor];
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the firmware name") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    _upgradeTextField.attributedPlaceholder = attributedPlaceholder;
    _upgradeTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_upgradeTextField];
    [_upgradeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(upgradeLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view.mas_top).offset(20);
        make.height.equalTo(@60);
    }];
    
    //
    UIView *upgradeLineView = [[UIView alloc] init];
    upgradeLineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:upgradeLineView];
    [upgradeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(upgradeLabel.mas_left);
        make.right.equalTo(_upgradeTextField.mas_right);
        make.top.equalTo(_upgradeTextField.mas_bottom).offset(1);
        make.height.equalTo(@1);
    }];
    
    UIImage *image = [[UIImage imageWithColor:[UIColor colorWithRed:22/255.0 green:117/255.0 blue:224/255.0 alpha:1.0] borderColor:[UIColor darkGrayColor] size:CGSizeMake(40, 35) radius:15] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    
    // 升级按钮
    _upgradeButton = [[UIButton alloc] init];
    [_upgradeButton setTitle:LS(@"Upgrade") forState:UIControlStateNormal];
    [_upgradeButton setBackgroundImage:image forState:UIControlStateNormal];
    _upgradeButton.enabled = NO;
    [_upgradeButton addTarget:self action:@selector(upgrade) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_upgradeButton];
    [_upgradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self->_upgradeTextField.mas_bottom).offset(20);
        make.height.equalTo(@35);
    }];

    //
    UILabel *queryIPPromptLabel = [[UILabel alloc] init];
    queryIPPromptLabel.textColor = [UIColor grayColor];
    queryIPPromptLabel.text = LS(@"Module IP");
    [self.view addSubview:queryIPPromptLabel];
    [queryIPPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(_upgradeButton.mas_bottom).offset(20);
        make.width.mas_equalTo(@100);
        make.height.equalTo(@60);
    }];
    
    // 查询模块ip的显示字体
    _IPLabel = [[UILabel alloc] init];
    _IPLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_IPLabel];
    [_IPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(queryIPPromptLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(_upgradeButton.mas_bottom).offset(20);
        make.height.equalTo(@60);
    }];
    
    UIView *ipLineView = [[UIView alloc] init];
    ipLineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:ipLineView];
    [ipLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(queryIPPromptLabel);
        make.right.equalTo(_IPLabel);
        make.top.equalTo(_IPLabel.mas_bottom).offset(1);
        make.height.equalTo(@1);
    }];
    
    // 查询IP按钮
    _queryIPButton = [[UIButton alloc] init];
    [_queryIPButton setTitle:LS(@"Inquire") forState:UIControlStateNormal];
    [_queryIPButton setBackgroundImage:image forState:UIControlStateNormal];
    _queryIPButton.enabled = NO;
    [_queryIPButton addTarget:self action:@selector(queryIP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_queryIPButton];
    [_queryIPButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(ipLineView.mas_bottom).offset(20);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@35);//高度
    }];
    
    //
    UILabel *queryVersionPromptLabel = [[UILabel alloc] init];
    queryVersionPromptLabel.textColor = [UIColor grayColor];
    queryVersionPromptLabel.text = LS(@"ModuleVersion");
    [self.view addSubview:queryVersionPromptLabel];
    [queryVersionPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(_queryIPButton.mas_bottom).offset(20);
        make.width.mas_equalTo(@100);
        make.height.equalTo(@60);
    }];
    
    //Ver显示字体
    _versionLabel = [[UILabel alloc] init];
    _versionLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_versionLabel];
    [_versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(queryVersionPromptLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(_queryIPButton.mas_bottom).offset(20);
        make.height.equalTo(@60);
    }];
    
    UIView *versionLineView = [[UIView alloc] init];
    versionLineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:versionLineView];
    [versionLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(queryVersionPromptLabel);
        make.right.equalTo(_versionLabel);
        make.top.equalTo(_versionLabel.mas_bottom).offset(1);
        make.height.equalTo(@1);
    }];

    //查询VER按钮
    _queryVersionButton = [[UIButton alloc] init];
    [_queryVersionButton setTitle:LS(@"Inquire") forState:UIControlStateNormal];
    [_queryVersionButton setBackgroundImage:image forState:UIControlStateNormal];
    _queryVersionButton.enabled = NO;
    [_queryVersionButton addTarget:self action:@selector(queryVersion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_queryVersionButton];
    [_queryVersionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(versionLineView.mas_bottom).offset(20);
        make.height.equalTo(@35);
    }];

    //恢复出厂设备
    _restoreButton = [[UIButton alloc] init];
    [_restoreButton setTitle:LS(@"Restore factory settings") forState:UIControlStateNormal];
    [_restoreButton setBackgroundImage:image forState:UIControlStateNormal];
    _restoreButton.enabled = NO;
    [_restoreButton addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_restoreButton];
    [_restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(_queryVersionButton.mas_bottom).offset(60);
        make.height.equalTo(@35);//高度
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)showProgressHUDWithTitle:(NSString *)title {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
    }
    
    _progressHUD.label.text = title;
    
    [self.view setUserInteractionEnabled:NO];
    [view addSubview:_progressHUD];
    
    [_progressHUD showAnimated:YES];
}

- (void)progressHUDDidHide:(UIView *)progressHUD {
    if (progressHUD == _progressHUD) {
        [self.view setUserInteractionEnabled:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

@end

