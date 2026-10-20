//
//  FWSettingViewController.m
//  FeasyWIFI
//
//  Created by ericj on 2018/7/5.
//  Copyright © 2018年 Feasycom. All rights reserved.
//
// 先连接蓝牙，连接上发送AT+RAP 蓝牙返回ok ,然后发送查询是否连上，发送AT+LIP，然后发送AT+OTA=0
#import "FWSettingViewController.h"
#import "FWPeripheralsViewController.h"
#import "FEPeripheral.h"
#import "FWBTNetworkDetailViewController.h"
#import "FWOTAController.h"
#import "FWGatewayConfigViewController.h"

@interface FWSettingViewController ()
@property (nonatomic, strong) FEPeripheral *connectedPeripheral;
@end

@implementation FWSettingViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 断开蓝牙连接
    [[FEBluetoothSDK sharedFEBluetoothSDK] disconnect:self.connectedPeripheral complete:^(FEPeripheral * _Nonnull peripheral) {
        
    }];
}

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral {
    if (self = [super init]) {
        self.connectedPeripheral = peripheral;
    }
    return self;
}

- (void)setupMoniter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bTPoweredOffAction) name:@"CBManagerStatePoweredOffNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bTPoweredOffAction) name:@"ConnectstateDisconnectNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger maxLength_title = 12;
    NSString *prefereTitle = self.connectedPeripheral.deviceInfo.name;
    if (prefereTitle.length > maxLength_title) {
        prefereTitle = [[prefereTitle substringToIndex:maxLength_title] stringByAppendingString:@"…"];
    }
    self.title = prefereTitle;
    [self setupNavigationView];
    [self setupUI];
    [self setupMoniter];
}

- (void)setupNavigationView {
    // 返回按钮
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] init];
    backBtn.title = LS(@"Back");
    self.navigationItem.backBarButtonItem = backBtn;
}

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 44 - 49)];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 115 * 4 + 20 * 5)];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 115 * 4 + 20 * 5)];
    [scrollView addSubview:contentView];
    [self.view addSubview:scrollView];

    //蓝牙配网
    UIButton *bluetoothview  = [[UIButton alloc]init];
    [bluetoothview setTitle:LS(@"BluetoothDistributionNetwork") forState:UIControlStateNormal];
    [bluetoothview setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    bluetoothview.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    bluetoothview .backgroundColor =[UIColor colorWithRed:68/225.0 green:231/225.0 blue:189/225.0 alpha:1.0];
    [bluetoothview  addTarget:self action:@selector(bluetoothConfig:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:bluetoothview];
    [bluetoothview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(20);
        make.right.equalTo(contentView).offset(-20);
        make.height.equalTo(@115);
        make.top.equalTo(contentView).offset(20);
    }];

    //OTA升级
    UIButton *oatupgrade = [[UIButton alloc]init];
    [oatupgrade setTitle: LS(@"OTAUpgrade") forState: UIControlStateNormal];
    [oatupgrade setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    oatupgrade.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    oatupgrade.backgroundColor =[UIColor colorWithRed:68/225.0 green:231/225.0 blue:189/225.0 alpha:1.0];
    [oatupgrade addTarget:self action:@selector(selectota:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:oatupgrade];
    [oatupgrade mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(20);
        make.right.equalTo(contentView).offset(-20);
        make.top.equalTo(bluetoothview.mas_bottom).offset(20);
        make.height.equalTo(@115);
    }];
    
    //网关配置
    UIButton *gatewayConfiguation = [[UIButton alloc]init];
    [gatewayConfiguation setTitle: LS(@"GatewayConfiguation") forState: UIControlStateNormal];
    [gatewayConfiguation setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    gatewayConfiguation.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    gatewayConfiguation.backgroundColor =[UIColor colorWithRed:68/225.0 green:231/225.0 blue:189/225.0 alpha:1.0];
    [gatewayConfiguation addTarget:self action:@selector(selectgatewayconfig:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:gatewayConfiguation];
    [gatewayConfiguation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(20);
        make.right.equalTo(contentView).offset(-20);
        make.top.equalTo(oatupgrade.mas_bottom).offset(20);
        make.height.equalTo(@115);
    }];
}

// 蓝牙配网Action
- (void)bluetoothConfig:(UIButton *)sender {
    FWBTNetworkDetailViewController *bTNetworkDetailVC = [[FWBTNetworkDetailViewController alloc] initWithPeripheral:self.connectedPeripheral];
    bTNetworkDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:bTNetworkDetailVC animated:YES];
}

// OTA升级Action
- (void)selectota:(UIButton*)sender {
    FWOTAController *oTAVC = [[FWOTAController alloc] initWithPeripheral:self.connectedPeripheral];
    oTAVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:oTAVC animated:YES];
}

- (void)selectgatewayconfig:(UIButton*)sender {
    FWGatewayConfigViewController *gatewayConfigVC = [[FWGatewayConfigViewController alloc]initWithPeripheral:self.connectedPeripheral];
    gatewayConfigVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gatewayConfigVC animated:YES];
}

- (void)bTPoweredOffAction {
    [self.navigationController popToViewController:self animated:YES];
    [self showAlertControllerAndPopWithTitle:LS(@"The device is disconnected from Bluetooth")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
