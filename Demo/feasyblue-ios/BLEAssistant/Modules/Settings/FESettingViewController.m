//
//  FESettingViewController.m
//  BLEAssistant
//
//  Created by yumingyue on 2016/12/5.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "FESettingViewController.h"
#import "FEDFUPeripheralsViewController.h"
#import "FEChangeATCommandsViewController.h"
#import "FEPasswordViewController.h"

@interface FESettingViewController ()

@property (nonatomic, strong) UIButton *parameterModificateButton;// 参数修改按钮
@property (nonatomic, strong) UIButton *otaButton;// 空中升级按钮

@end

@implementation FESettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LS(@"setting");
    
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor darkGrayColor];
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem.title = LS(@"goBack");
    
    [self setupViewContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupViewContent {
    self.parameterModificateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.parameterModificateButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.parameterModificateButton setTitle:LS(@"Parameter modification") forState:UIControlStateNormal];
    [self.parameterModificateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.parameterModificateButton addTarget:self action:@selector(parameterModificateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.parameterModificateButton];
    [self.parameterModificateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(60);
    }];
    
    self.otaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.otaButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.otaButton setTitle:LS(@"OTA") forState:UIControlStateNormal];
    [self.otaButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.otaButton addTarget:self action:@selector(otaButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.otaButton];
    [self.otaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.parameterModificateButton.mas_bottom).offset(1);
        make.height.mas_equalTo(60);
    }];
}

- (void)parameterModificateButtonAction {
    if ([[FEUserDefaultCache getUserPassword] isEqualToString:@"20138888"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FEChangeATCommandsViewController" bundle:nil];
        FEChangeATCommandsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sto_ATCommandsTV"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        //首次进入，需输入密码
        FEPasswordViewController *passwordview = [[FEPasswordViewController alloc] init];
        [self.navigationController pushViewController:passwordview animated:YES];
    }
}

- (void)otaButtonAction {
    FEDFUPeripheralsViewController *viewController = [[FEDFUPeripheralsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
