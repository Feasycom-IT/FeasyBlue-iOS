//
//  FWDistributionNetworkView.m
//  FeasyWIFI
//
//  Created by ericj on 2018/7/20.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "FWDistributionNetworkView.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface CustomViewModel : NSObject
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *messageTF;
@end

@implementation CustomViewModel
@end

@interface FWDistributionNetworkView ()
@property (nonatomic, strong) NSMutableArray<CustomViewModel *> *customViewModelArray;
@property (nonatomic, copy, readwrite) NSDictionary *networkConfigerInfoDic;
@property (nonatomic, strong) UIScrollView *baseScrollView;
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *inputPlaceHolders;
@property (nonatomic, strong) UILabel *DHCPLabel;
@end

@implementation FWDistributionNetworkView

- (instancetype)initWithTitles:(NSArray *)titles inputPlaceHolders:(NSArray *)inputPlaceHolders {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.titles = titles;
        self.inputPlaceHolders = inputPlaceHolders;
        [self setupViewContent];
    }
    return self;
}

- (void)setupViewContent {
    self.customViewModelArray = [NSMutableArray array];
    NSArray *titleArray = self.titles;
    NSArray *inputPlaceHolders = self.inputPlaceHolders;
    for (int i = 0; i < titleArray.count; i++) {
        CustomViewModel *customVM = [self factoryViewByTitle:[titleArray objectAtIndex:i] placeholder:[inputPlaceHolders objectAtIndex:i] delegate:self];
        [self.customViewModelArray addObject:customVM];
    }
    self.networkNameTextField = self.customViewModelArray[0].messageTF;
    self.networkNameTextField.text = [NSString getWifiName];
    self.passwordTextField = self.customViewModelArray[1].messageTF;
    self.IPTextField = self.customViewModelArray[2].messageTF;
    
    //
    [self addSubview:self.customViewModelArray[0].bgView];
    [self.customViewModelArray[0].bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(20);
        make.left.mas_equalTo(self.mas_left);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
    }];
    //
    [self addSubview:self.customViewModelArray[1].bgView];
    [self.customViewModelArray[1].bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customViewModelArray[0].bgView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.mas_left);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
    }];
    // DHCP
    self.DHCPLabel = [UILabel createLabelWithText:LS(@"DHCP:") withFont:17];
    [self addSubview:self.DHCPLabel];
    [self.DHCPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(15);
        make.top.equalTo(self.customViewModelArray[1].bgView.mas_bottom).offset(20);
        make.width.equalTo(@100);
        make.height.equalTo(@31);
    }];
    
    self.DHCPSwitch = [[UISwitch alloc] init];
    self.DHCPSwitch.on = YES;// UI默认为yes
    [self.DHCPSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.DHCPSwitch];
    [self.DHCPSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.passwordTextField);
        make.centerY.mas_equalTo(self.DHCPLabel.mas_centerY);
        make.width.equalTo(@51);
        make.height.equalTo(@31);
    }];
    //
    for (int i = 2; i < self.customViewModelArray.count; i++) {
        if (i == 2) {
            [self addSubview:self.customViewModelArray[i].bgView];
            [self.customViewModelArray[i].bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.DHCPLabel.mas_bottom).offset(20);
                make.left.mas_equalTo(self.mas_left);
                make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
            }];
            continue;
        }
        self.customViewModelArray[i].bgView.hidden = YES;// UI默认为隐藏
        [self addSubview:self.customViewModelArray[i].bgView];
        [self.customViewModelArray[i].bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.customViewModelArray[i-1].bgView.mas_bottom).offset(20);
            make.left.mas_equalTo(self.mas_left);
            make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
        }];
    }
    // 配置按钮
    self.configButton = [[UIButton alloc] init];
    self.configButton.hidden = NO;
    [self.configButton setTitle:LS(@"Start configuring network") forState:UIControlStateNormal];
    self.configButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.configButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.configButton.backgroundColor = [UIColor colorWithRed:22/255.0 green:117/255.0 blue:224/255.0 alpha:1.0];
    self.configButton.layer.cornerRadius = 23.0;
    [self addSubview:self.configButton];
    [self.configButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.DHCPLabel.mas_bottom).offset(30);// UI默认是动态配网
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.mas_equalTo(44);
    }];
}

- (CustomViewModel *)factoryViewByTitle:(NSString *)title placeholder:(NSString *)inputPlaceHolder delegate:(id)delegate {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:17];
    [bgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@80);
        make.left.mas_equalTo(bgView.mas_left).offset(15);
        make.centerY.mas_equalTo(bgView.mas_centerY);
    }];
    
    UITextField *inputTF = [[UITextField alloc] init];
    inputTF.borderStyle = UITextBorderStyleRoundedRect;
    inputTF.delegate = delegate;
    inputTF.returnKeyType = UIReturnKeyDone;
    inputTF.textColor = [UIColor blackColor];
    inputTF.placeholder = inputPlaceHolder;
    
    [bgView addSubview:inputTF];
    [inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(5);
        make.right.mas_equalTo(bgView.mas_right).offset(-15);
        make.centerY.mas_equalTo(bgView.mas_centerY);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor grayColor];
    [bgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@1);
        make.bottom.mas_equalTo(bgView.mas_bottom).offset(-1);
        make.left.mas_equalTo(bgView.mas_left).offset(15);
        make.right.mas_equalTo(bgView.mas_right).offset(-15);
    }];
    
    CustomViewModel *viewModel = [[CustomViewModel alloc] init];
    viewModel.bgView = bgView;
    viewModel.titleLabel = titleLabel;
    viewModel.messageTF = inputTF;
    
    return viewModel;
}

- (NSDictionary *)networkConfigerInfoDic {
    if (!_networkConfigerInfoDic) {
        _networkConfigerInfoDic = [[NSDictionary alloc] init];
    }
    NSArray *dicKeys = @[@"wifiName", @"wifiPassword", @"staticIP", @"GW", @"MASK", @"DNS"];
    NSMutableDictionary *configerMDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < self.customViewModelArray.count; i++) {
        if (i < 2) {
            configerMDic[[dicKeys objectAtIndex:i]] = self.customViewModelArray[i].messageTF.text;
        } else {
            configerMDic[[dicKeys objectAtIndex:i]] = self.DHCPSwitch.isOn ? @"" : self.customViewModelArray[i].messageTF.text;
        }
        
    }
    _networkConfigerInfoDic = configerMDic.copy;
    return _networkConfigerInfoDic;;
}

- (void)changedDHCPSwitch {
    [self switchAction:self.DHCPSwitch];
}

- (void)switchAction:(UISwitch *)swit {
    self.configButton.hidden = NO;
    for (int i = 2; i < self.customViewModelArray.count; i++) {
        self.customViewModelArray[i].bgView.hidden = swit.isOn;
    }
    if (swit.isOn) {
        [self.configButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.DHCPLabel.mas_bottom).offset(30);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.height.mas_equalTo(44);
        }];
    } else {
        [self.configButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.customViewModelArray.lastObject.bgView.mas_bottom).offset(30);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.height.mas_equalTo(44);
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

@end
