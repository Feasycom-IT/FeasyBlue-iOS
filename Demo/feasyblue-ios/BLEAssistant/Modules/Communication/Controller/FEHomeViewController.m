//
//  FEHomeViewController.m
//  BLEAssistant
//
//  Created by LiDong on 2021/4/21.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FEHomeViewController.h"
#import "FECommunicationChatViewController.h"
#import "FWADView.h"
#import "WebViewController.h"
#import "FEPeripheral.h"
#import "FEConnectedPeripheralsVC.h"
#import "FEBluetoothSDK.h"

@interface FEHomeViewController ()
@property (nonatomic, assign) NSInteger connectedPeripheralCount;
@end

@implementation FEHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 后续需要的版本升级提示
     NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
     NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     NSString *displayedVersion = [userDefaults stringForKey:@"displayedVersion"];
     
     if (![appVersion isEqualToString:displayedVersion]) {
     [userDefaults setValue:appVersion forKey:@"displayedVersion"];
     [userDefaults synchronize];
     [self performSelector:@selector(loadUserAgreement) withObject:nil afterDelay:0];
     }
     */
    
    // 开屏页的广告
    [FWADView showWithSeconds:5];
    usleep(100);
    
    self.title = LS(@"Communication");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.connectedPeripheralCount = [FEBluetoothSDK sharedFEBluetoothSDK].peripherals.count;
    
    if ([FEUserDefaultCache getIsGroupCommunication]) {
        [self setupNavigationContent_Show];
    } else {
        [self setupNavigationContent_Hide];
    }
}

/* 后续需要的版本升级提示
 - (void)loadUserAgreement {
 WebViewController *viewController = [[WebViewController alloc] initWithType:1];
 [self.navigationController pushViewController:viewController animated:NO];
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FEPeripheral *peripheral = self.peripherals[indexPath.row];
    FECommunicationChatViewController *viewController = [[FECommunicationChatViewController alloc] initWithPeripheral:peripheral];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)setupNavigationContent_Hide {
    self.navigationItem.rightBarButtonItems = @[];
}

- (void)setupNavigationContent_Show {
    NSString *title = LS(@"ConnectedDevice");
    if (self.connectedPeripheralCount > 0) {
        title = [NSString stringWithFormat:@"%@ *%ld", LS(@"ConnectedDevice"), (long)self.connectedPeripheralCount];
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(button1Action)];
    
    self.navigationItem.rightBarButtonItems = @[rightButton];
}

- (void)button1Action {
    FEConnectedPeripheralsVC *vc = [[FEConnectedPeripheralsVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
