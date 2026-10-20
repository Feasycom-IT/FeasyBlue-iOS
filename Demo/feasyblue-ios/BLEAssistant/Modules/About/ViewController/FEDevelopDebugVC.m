//
//  FEDevelopDebugVC.m
//  BLEAssistant
//
//  Created by chenchanghua on 2023/3/28.
//  Copyright © 2023 feasycom. All rights reserved.
//

#import "FEDevelopDebugVC.h"
#import "FEUserDefaultCache.h"
#import <Masonry/Masonry.h>
#import "FEBluetoothSDK.h"

@interface FEDevelopDebugVC ()

@property (nonatomic, strong) UILabel *extendedBLESupportValueLabel;
@property (nonatomic, strong) UISwitch *isUseFacpSwitch;
@property (nonatomic, strong) UISwitch *isUseScanLogSwitch;
@property (nonatomic, strong) UISwitch *isGroupCommunicationSwitch;
@property (nonatomic, strong) UISwitch *isUseL2CAPChannelSwitch;
@property (nonatomic, strong) UISwitch *isGetCompleteGATTStructureSwitch;

@end

@implementation FEDevelopDebugVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationContent];
    [self setupViewContent];
}

- (void)setupNavigationContent {
    self.title = LS(@"Developer debugging");
}

- (void)setupViewContent {
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scrollView];
    
    UIView *contentView = [[UIView alloc] init];
    [scrollView addSubview:contentView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scrollView).offset(12);
        make.left.equalTo(scrollView).offset(12);
        make.right.equalTo(scrollView).offset(-12);
        make.bottom.equalTo(scrollView).offset(-12);
        make.width.equalTo(scrollView).offset(-24);
    }];
    
    UIView *extendedBLEItemView = [self createInfoItemWithTitle:@"Extended Scan & Connect"
                                                    description:LS(@"Indicates whether this device supports extended BLE scanning and enhanced connection creation.")
                                                          value:[FEBluetoothSDK isExtendedBLESupported] ? LS(@"Supported") : LS(@"Not Supported")];
    
    UIView *facpItemView = [self createSettingItemWithTitle:@"Facp"
                                                description:LS(@"Enable FACP by default when establishing a GATT connection with a Bluetooth device. (Enabled by default after app restart)")
                                              switchControl:&_isUseFacpSwitch
                                                   switchOn:[FEUserDefaultCache getIsUseFacp]
                                                     action:@selector(isUseFacpSwitchAction:)];
    
    UIView *scanLogItemView = [self createSettingItemWithTitle:@"Log-AdvertisementData"
                                                   description:LS(@"Log AdvertisementData when scanning Bluetooth devices for debugging purposes.")
                                                 switchControl:&_isUseScanLogSwitch
                                                      switchOn:[FEUserDefaultCache getIsUseScanLog]
                                                        action:@selector(isUseScanLogSwitchAction:)];
    
    UIView *groupCommunicationItemView = [self createSettingItemWithTitle:@"Group Communication"
                                                              description:LS(@"Enable multi-device group communication to send or manage data across multiple connected devices.")
                                                            switchControl:&_isGroupCommunicationSwitch
                                                                 switchOn:[FEUserDefaultCache getIsGroupCommunication]
                                                                   action:@selector(isGroupCommunicationSwitchAction:)];
    
    UIView *l2capItemView = [self createSettingItemWithTitle:@"L2CAP Channel"
                                                 description:LS(@"Prefer using the L2CAP channel for data transmission when communicating with Bluetooth devices.")
                                               switchControl:&_isUseL2CAPChannelSwitch
                                                    switchOn:[FEUserDefaultCache getIsUseL2CAPChannel]
                                                      action:@selector(isUseL2CAPChannelLabelAction:)];
    
    UIView *completeGATTStructureItemView = [self createSettingItemWithTitle:@"Complete GATT Structure"
                                                                 description:LS(@"Enable full GATT discovery for debugging, including services, characteristics, descriptors, and descriptor values. Some devices may disconnect when descriptor values are read.(Enabled by default after app restart)")
                                                               switchControl:&_isGetCompleteGATTStructureSwitch
                                                                    switchOn:[FEUserDefaultCache getIsGetCompleteGATTStructure]
                                                                      action:@selector(isGetCompleteGATTStructureSwitchAction:)];
    
    [contentView addSubview:extendedBLEItemView];
    [contentView addSubview:facpItemView];
    [contentView addSubview:scanLogItemView];
    [contentView addSubview:groupCommunicationItemView];
    [contentView addSubview:l2capItemView];
    [contentView addSubview:completeGATTStructureItemView];
    
    [extendedBLEItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(contentView);
    }];
    
    [facpItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(extendedBLEItemView.mas_bottom).offset(12);
        make.left.right.equalTo(contentView);
    }];
    
    [scanLogItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(facpItemView.mas_bottom).offset(12);
        make.left.right.equalTo(contentView);
    }];
    
    [groupCommunicationItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scanLogItemView.mas_bottom).offset(12);
        make.left.right.equalTo(contentView);
    }];
    
    [l2capItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(groupCommunicationItemView.mas_bottom).offset(12);
        make.left.right.equalTo(contentView);
    }];
    
    [completeGATTStructureItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(l2capItemView.mas_bottom).offset(12);
        make.left.right.equalTo(contentView);
        make.bottom.equalTo(contentView);
    }];
}

#pragma mark - UI Builder

- (UIView *)createInfoItemWithTitle:(NSString *)title
                        description:(NSString *)description
                              value:(NSString *)value {
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 10.0;
    containerView.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [containerView addSubview:titleLabel];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.textColor = [value isEqualToString:LS(@"Supported")] ? [UIColor systemGreenColor] : [UIColor systemRedColor];
    valueLabel.font = [UIFont boldSystemFontOfSize:14];
    valueLabel.textAlignment = NSTextAlignmentRight;
    [containerView addSubview:valueLabel];
    self.extendedBLESupportValueLabel = valueLabel;
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = description;
    descLabel.textColor = [UIColor grayColor];
    descLabel.font = [UIFont systemFontOfSize:13];
    descLabel.numberOfLines = 0;
    [containerView addSubview:descLabel];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [containerView addSubview:lineView];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).offset(14);
        make.left.equalTo(containerView).offset(15);
        make.right.lessThanOrEqualTo(valueLabel.mas_left).offset(-10);
    }];
    
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(containerView).offset(-15);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(12);
        make.left.equalTo(containerView).offset(15);
        make.right.equalTo(containerView).offset(-15);
        make.height.mas_equalTo(0.5);
    }];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.left.equalTo(containerView).offset(15);
        make.right.equalTo(containerView).offset(-15);
        make.bottom.equalTo(containerView).offset(-14);
    }];
    
    return containerView;
}

- (UIView *)createSettingItemWithTitle:(NSString *)title
                           description:(NSString *)description
                         switchControl:(UISwitch * __strong *)switchControl
                              switchOn:(BOOL)isOn
                                action:(SEL)action {
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 10.0;
    containerView.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [containerView addSubview:titleLabel];
    
    UISwitch *sw = [[UISwitch alloc] init];
    [sw setOn:isOn];
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:sw];
    *switchControl = sw;
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = description;
    descLabel.textColor = [UIColor grayColor];
    descLabel.font = [UIFont systemFontOfSize:13];
    descLabel.numberOfLines = 0;
    [containerView addSubview:descLabel];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [containerView addSubview:lineView];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).offset(14);
        make.left.equalTo(containerView).offset(15);
        make.right.lessThanOrEqualTo(sw.mas_left).offset(-10);
    }];
    
    [sw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(containerView).offset(-15);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(12);
        make.left.equalTo(containerView).offset(15);
        make.right.equalTo(containerView).offset(-15);
        make.height.mas_equalTo(0.5);
    }];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.left.equalTo(containerView).offset(15);
        make.right.equalTo(containerView).offset(-15);
        make.bottom.equalTo(containerView).offset(-14);
    }];
    
    return containerView;
}

#pragma mark - Actions

- (void)isUseFacpSwitchAction:(UISwitch *)swit {
    [FEUserDefaultCache saveIsUseFacp:swit.isOn];
}

- (void)isUseScanLogSwitchAction:(UISwitch *)swit {
    [FEUserDefaultCache saveIsUseScanLog:swit.isOn];
}

- (void)isGroupCommunicationSwitchAction:(UISwitch *)swit {
    [FEUserDefaultCache saveIsGroupCommunication:swit.isOn];
}

- (void)isUseL2CAPChannelLabelAction:(UISwitch *)swit {
    [FEUserDefaultCache saveIsUseL2CAPChannel:swit.isOn];
}

- (void)isGetCompleteGATTStructureSwitchAction:(UISwitch *)swit {
    [FEUserDefaultCache saveIsGetCompleteGATTStructure:swit.isOn];
}

@end
