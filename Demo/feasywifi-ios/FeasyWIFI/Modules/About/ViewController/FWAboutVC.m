//
//  FWAboutVC.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/6.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "FWAboutVC.h"
#import "NSString+FscKit.h"
#import "FWfeedbackController.h"
#import "FWAboutTView.h"
#import "FWAboutModel.h"

@interface FWAboutVC ()
@property (nonatomic, strong) FWAboutTView *aboutTView;
@property (nonatomic, copy) NSArray<FWAboutModel *> *messageArray;
@end

@implementation FWAboutVC

- (id)init {
    self = [super init];
    if (self) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:LS(@"About") image:[UIImage imageNamed:LS(@"About")] tag:2];
        [self setTabBarItem:tabBarItem];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationView];
    self.aboutTView.aboutModelArray = self.messageArray;
}

- (void)setupNavigationView {
    self.title = LS(@"About");
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
    // 透明
    self.navigationController.navigationBar.translucent = YES;
    // navigation控件颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // 反馈按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 30)];
    [button setTitle:LS(@"FeedBack") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:button];
             self.navigationItem.rightBarButtonItem  = right;
}

- (void)rightClick {
    FWfeedbackController *feedbackview = [[FWfeedbackController alloc]init];
    [self.navigationController pushViewController:feedbackview animated:YES];
}

#pragma mark - lazyLoad
- (FWAboutTView *)aboutTView {
    if (!_aboutTView) {
        _aboutTView = [[FWAboutTView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-kTabBar_Height-kTabBar_Safe_Height) style:UITableViewStylePlain];
        [self.view addSubview:_aboutTView];
    }
    return _aboutTView;
}

- (NSArray<FWAboutModel *> *)messageArray {
    if (!_messageArray) {
        NSArray *titleArray = @[LS(@"Company"),
                                LS(@"Telephone"),
                                LS(@"Web"),
                                LS(@"Mail"),
                                LS(@"Wechat"),
                                LS(@"CompanyProfile"),
                                LS(@"Version")];
        NSArray *messageArray = @[LS(@"CompanyName"),
                                  @"0755-27924639",
                                  @"www.feasycom.com",
                                  @"support@feasycom.com",
                                  @"Feasycom",
                                  LS(@"More"),
                                  [NSString getLocalAppVersion]];
        NSArray *imageNameArray = @[@"", @"", @"", @"", @"WeChat", @"", @""];
        NSMutableArray *aboutModelArray = [NSMutableArray array];
        for (int i = 0; i < titleArray.count; i++) {
            FWAboutModel *aboutModel = [[FWAboutModel alloc] init];
            aboutModel.name = [titleArray objectAtIndex:i];
            aboutModel.message = [messageArray objectAtIndex:i];
            aboutModel.imageName = [imageNameArray objectAtIndex:i];
            [aboutModelArray addObject:aboutModel];
        }
        _messageArray = aboutModelArray.copy;
    }
    return _messageArray;
}

@end
