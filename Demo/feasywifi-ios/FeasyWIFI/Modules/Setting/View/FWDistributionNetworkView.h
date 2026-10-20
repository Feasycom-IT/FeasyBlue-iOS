//
//  FWDistributionNetworkView.h
//  FeasyWIFI
//
//  Created by ericj on 2018/7/20.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>



// 蓝牙配网View
@interface FWDistributionNetworkView : UIView <UITextFieldDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UITextField *networkNameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UISwitch *DHCPSwitch;
@property (nonatomic, strong) UILabel *IPLabel;
@property (nonatomic, strong) UITextField *IPTextField;//静态IP地址
@property (nonatomic, strong) UIButton *configButton;
@property (nonatomic, strong) UIView *IPLineView;

@property (nonatomic, copy, readonly) NSDictionary *networkConfigerInfoDic;

- (void)changedDHCPSwitch;

- (instancetype)initWithTitles:(NSArray *)titles inputPlaceHolders:(NSArray *)inputPlaceHolders;

@end
