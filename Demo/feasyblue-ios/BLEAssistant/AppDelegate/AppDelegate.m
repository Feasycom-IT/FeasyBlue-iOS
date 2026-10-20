//
//  AppDelegate.m
//  BLEAssistant
//
//  Created by 余明悦 on 16/7/22.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "AppDelegate.h"
#import "FERootViewController.h"
#import "MemoryInfo.h"
#import "NSString+FscKit.h"
#import "FEBluetoothSDK.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "FSCLogExportManager.h"
#import "FEOtaFileManager.h"

@interface AppDelegate () {
    NSFileManager *fileMangerlog;
    NSString *truePathlog;
}

@property (nonatomic, assign) UIBackgroundTaskIdentifier backIden;
@property (nonatomic, strong) MemoryInfo *info;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 如需崩溃统计，请替换为自己的 Bugly App ID
    NSString *buglyAppId = @"YOUR_BUGLY_APP_ID";
    if (![buglyAppId isEqualToString:@"YOUR_BUGLY_APP_ID"]) {
        [Bugly startWithAppId:buglyAppId];
    }
    [FSCLogExportManagerShared startLogRecord];
    
    id appearance = [UINavigationBar appearance];
    [appearance setBarStyle:UIBarStyleBlack];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.info = [MemoryInfo shareMemoryInfo];
    self.info.pop = NO;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    FERootViewController *feRootVC = [[FERootViewController alloc] init];
    [self.window setRootViewController:feRootVC];
    
    [FEUserDefaultCache saveIsUseFacp:YES];
    [FEUserDefaultCache saveIsGroupCommunication:NO];
    [FEUserDefaultCache saveIsGetCompleteGATTStructure:YES];
    [FEUserDefaultCache saveUserPassword:@""];
    
    return YES;
}

- (void)dealloc {
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    if (!url) return NO;
    
    NSURL *fileURL = url.isFileURL ? url : [NSURL fileURLWithPath:url.path ?: @""];
    
    [FEOtaFileManager importFileURL:fileURL sourceTag:@"OpenURL" completion:^(NSString * _Nullable finalPath, NSError * _Nullable error) {
        if (error) {
            NSLog(@"OpenURL import failed: %@", error);
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FENotificationUrlNotification
                                                            object:nil
                                                          userInfo:@{@"url":finalPath}];
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if (self.info.shouldPop) {
        self.info.pop = YES;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self endBack];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * logPath = [docPath stringByAppendingPathComponent:@"Caches"];
    logPath = [logPath stringByAppendingPathComponent:@"Logs"];;
    fileMangerlog = [NSFileManager defaultManager];
    NSError * error = nil;
    NSArray * fileList = [[NSArray alloc]init];
    fileList = [fileMangerlog contentsOfDirectoryAtPath:logPath error:&error];
    NSMutableArray * listArray = [[NSMutableArray alloc]init];
    
    for (NSString * oneLogPath in fileList) {
        if([oneLogPath hasPrefix:[NSBundle mainBundle].bundleIdentifier]) {
            truePathlog = [logPath stringByAppendingPathComponent:oneLogPath];
            [listArray addObject:truePathlog];
            [fileMangerlog removeItemAtPath:truePathlog error:nil];
        }
    }
    return;
}

- (void)beginTask {
    __weak __typeof(self) weakSelf = self;
    
    _backIden = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf endBack];
    }];
}

- (void)endBack {
    [[UIApplication sharedApplication] endBackgroundTask:_backIden];
    _backIden = UIBackgroundTaskInvalid;
}

@end
