//
//  AppDelegate.m com.feasycom.FeasyWIFI
//  FeasyWIFI
//
//  Created by ericj on 2018/7/5.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AFNetworking/AFNetworking.h>
#import "FWAboutVC.h"
#import "FWPeripheralsViewController.h"


@interface AppDelegate () {
    CLLocationManager *_loactionManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 如需崩溃统计，请替换为自己的 Bugly App ID
    NSString *buglyAppId = @"YOUR_BUGLY_APP_ID";
    if (![buglyAppId isEqualToString:@"YOUR_BUGLY_APP_ID"]) {
        [Bugly startWithAppId:buglyAppId];
    }
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // UIKeyWindow
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // TabBar
    NSMutableDictionary *attrs_tabBarText_normal = [NSMutableDictionary dictionary];
    attrs_tabBarText_normal[NSFontAttributeName] = [UIFont systemFontOfSize:17.0];
    attrs_tabBarText_normal[NSForegroundColorAttributeName] = [UIColor systemBlueColor];
    
    NSMutableDictionary *attrs_tabBarText_selected = [NSMutableDictionary dictionary];
    attrs_tabBarText_selected[NSFontAttributeName] = [UIFont systemFontOfSize:17.0];
    attrs_tabBarText_selected[NSForegroundColorAttributeName] = [UIColor systemBlueColor];
    //
    FWPeripheralsViewController *peripheralsVC = [[FWPeripheralsViewController alloc] init];
    peripheralsVC.hidesBottomBarWhenPushed = NO;
    UINavigationController *nav_peripheralsVC = [[UINavigationController alloc] initWithRootViewController:peripheralsVC];
    nav_peripheralsVC.tabBarItem.title = @"Setting";
    [nav_peripheralsVC.tabBarItem setTitleTextAttributes:attrs_tabBarText_normal forState:UIControlStateNormal];
    [nav_peripheralsVC.tabBarItem setTitleTextAttributes:attrs_tabBarText_selected forState:UIControlStateSelected];
    //
    FWAboutVC *aboutVC = [[FWAboutVC alloc] init];
    aboutVC.hidesBottomBarWhenPushed = NO;
    UINavigationController *nav_aboutVC = [[UINavigationController alloc] initWithRootViewController:aboutVC];
    nav_aboutVC.tabBarItem.title = LS(@"About");
    [nav_aboutVC.tabBarItem setTitleTextAttributes:attrs_tabBarText_normal forState:UIControlStateNormal];
    [nav_aboutVC.tabBarItem setTitleTextAttributes:attrs_tabBarText_selected forState:UIControlStateSelected];
    //
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    tabBarVC.viewControllers = @[nav_peripheralsVC, nav_aboutVC];
    tabBarVC.selectedIndex = 0;
    self.window.rootViewController = tabBarVC;
    
    id navigationBarAppearance = [UINavigationBar appearance];
    
    [navigationBarAppearance setTintColor:[UIColor blueColor]];
    [navigationBarAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    // Override point for customization after application launch.
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    CGFloat version = [phoneVersion floatValue];
    
    // 如果是iOS13 未开启地理位置权限 需要提示一下
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && version >= 13) {
        _loactionManager = [[CLLocationManager alloc] init];
        
        [_loactionManager requestWhenInUseAuthorization];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 //强制退出
 // exit(0);
    
//    if (_advertisementViewController) {
//        [_advertisementViewController dismissViewControllerAnimated:NO completion:nil];
//        _advertisementViewController = nil;
//    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
