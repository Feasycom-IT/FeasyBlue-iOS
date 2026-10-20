//
//  FERootViewController.m
//  BLEAssistant
//
//  Created by chenchanghua on 2025/10/15.
//  Copyright © 2025 feasycom. All rights reserved.
//

#import "FERootViewController.h"

@interface FERootViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@end

@implementation FERootViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllerArr = [NSMutableArray array];
        
        [self addViewController:@"FEHomeViewController" title:LS(@"Communication") img:@"communication"];// 通讯
        [self addViewController:@"FESettingViewController" title:LS(@"Setting") img:@"setting"];// 设置
        [self addViewController:@"FEStoreController" title:LS(@"Store") img:@"on"];// 商城
        [self addViewController:@"FEForumController" title:LS(@"Forum") img:@"forum"];// 论坛
        [self addViewController:@"FWAboutVC" title:LS(@"Company Info") img:@"about"];// 关于
        
        [self setViewControllers:self.viewControllerArr];
    }
    return self;
}

- (void)addViewController:(NSString *)className title:(NSString *)title img:(NSString *)img {
    UIViewController *viewController = [[NSClassFromString(className) alloc] init];
    UIImage *image = [UIImage imageNamed:img];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    [viewController setTabBarItem:tabBarItem];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.viewControllerArr addObject:navigationController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UIInterfaceOrientationPortrait == toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
