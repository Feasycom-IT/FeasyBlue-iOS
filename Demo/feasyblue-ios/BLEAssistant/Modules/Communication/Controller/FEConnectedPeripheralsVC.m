//
//  FEConnectedPeripheralsVC.m
//  BLEAssistant
//
//  Created by chenchanghua on 2026/4/15.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import "FEConnectedPeripheralsVC.h"
#import "FEBluetoothSDK.h"
#import "FEPeripheral.h"
#import "FEGroupChatViewController.h"
#import "FEUserDefaultCache.h"

@interface FEConnectedPeripheralsVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIButton *buildGroupButton;
@property (nonatomic, strong) UIButton *disconnectAllButton;
@property (nonatomic, strong) UIButton *reconnectButton;
@property (nonatomic, strong) UIButton *sendGroupMessageButton;
@property (nonatomic, strong) NSArray<FEPeripheral *> *dataSource;

@end

@implementation FEConnectedPeripheralsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LS(@"ConnectedDevice");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationItem];
    [self setupToolBar];
    [self setupTableView];
    [self loadData];
}

#pragma mark - Setup

- (void)setupNavigationItem {
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(refreshButtonClicked)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (void)setupToolBar {
    self.toolBar = [[UIToolbar alloc] init];
    self.toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.toolBar];
    
    self.buildGroupButton = [self toolBarButtonWithTitle:LS(@"InGroup") action:@selector(buildGroupAction)];
    self.disconnectAllButton = [self toolBarButtonWithTitle:LS(@"DisconnectAll") action:@selector(disconnectAllAction)];
    self.reconnectButton = [self toolBarButtonWithTitle:LS(@"Reconnect") action:@selector(reconnectAction)];
    self.sendGroupMessageButton = [self toolBarButtonWithTitle:LS(@"Broadcast") action:@selector(sendGroupMessageAction)];
    
    UIBarButtonItem *buildGroupItem = [[UIBarButtonItem alloc] initWithCustomView:self.buildGroupButton];
    UIBarButtonItem *disconnectAllItem = [[UIBarButtonItem alloc] initWithCustomView:self.disconnectAllButton];
    UIBarButtonItem *reconnectItem = [[UIBarButtonItem alloc] initWithCustomView:self.reconnectButton];
    UIBarButtonItem *sendGroupMessageItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendGroupMessageButton];
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolBar.items = @[
        flex1,
        buildGroupItem,
        flex2,
        disconnectAllItem,
        flex3,
        reconnectItem,
        flex4,
        sendGroupMessageItem,
        flex5
    ];
    
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.toolBar.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.toolBar.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.toolBar.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
        [self.toolBar.heightAnchor constraintEqualToConstant:56.0]
    ]];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.tableView];
    
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.toolBar.topAnchor]
    ]];
}

#pragma mark - Data

- (void)loadData {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.dataSource = [FEBluetoothSDK sharedFEBluetoothSDK].peripherals;
//        [self.tableView reloadData];
//    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[FEBluetoothSDK sharedFEBluetoothSDK] refreshSystemConnectedPeripheralsForServiceUUIDs:@[[CBUUID UUIDWithString:@"FFF0"]]];
        self.dataSource = [FEBluetoothSDK sharedFEBluetoothSDK].systemConnectedPeripherals;
        NSLog(@"%ld", [FEBluetoothSDK sharedFEBluetoothSDK].systemConnectedPeripherals.count);
        [self.tableView reloadData];
    });
}

#pragma mark - Actions

- (void)refreshButtonClicked {
    [self loadData];
}

- (void)buildGroupAction {
    // TODO: 建群
    [self showTapFeedbackForButton:self.buildGroupButton];
    
    if (self.dataSource.count > 0) {
        NSMutableArray<NSString *> *uuidStrings = [NSMutableArray array];
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            FEPeripheral *p = self.dataSource[i];
            NSString *uuidString = p.identifier.UUIDString;
            if (uuidString.length > 0) {
                [uuidStrings addObject:uuidString];
            }
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:uuidStrings forKey:@"SavedUUIDs"];
        [defaults synchronize];
    }
}

- (void)disconnectAllAction {
    // TODO: 全断
    [self showTapFeedbackForButton:self.disconnectAllButton];
    
    for (int i = 0; i < [FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals.count; i++) {
        FEPeripheral *p = [FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals[i];
        [p callBackConnectStatus:nil connectType:nil deviceInfo:nil RSSI:nil send:nil receive:nil];
    }
    
    [[FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals removeAllObjects];
    
    if (self.dataSource.count > 0) {
        for (int i = 0; i < self.dataSource.count; i++) {
            [[FEBluetoothSDK sharedFEBluetoothSDK] disconnect:self.dataSource[i]];
        }

        for (int i = 1; i <= 3; i++) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadData];
            });
        }
    }
}

- (void)reconnectAction {
    // TODO: 重连
    [self showTapFeedbackForButton:self.reconnectButton];
    
    NSArray<NSString *> *uuidStrings = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedUUIDs"];
    if (uuidStrings.count == 0) {
        return;
    }
    
    NSMutableArray<NSUUID *> *uuids = [NSMutableArray array];
    for (NSInteger i = 0; i < uuidStrings.count; i++) {
        NSString *savedUUIDString = uuidStrings[i];
        NSUUID *savedUUID = [[NSUUID alloc] initWithUUIDString:savedUUIDString];
        if (savedUUID) {
            [uuids addObject:savedUUID];
        }
    }
    
    if (self.dataSource.count > 0) {
        __block NSInteger connectedCount_retrievedPeripherals = 0;
        for (int i = 0; i < self.dataSource.count; i++) {
            FEPeripheral *p = self.dataSource[i];
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(p) weakP = p;
            [p callBackConnectStatus:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __strong typeof(weakP) strongP = weakP;
                if (strongP.connectState == CONNECTSTATE_SUCCESS) {
                    [strongP enterCommunicationModeWithFacp:[FEUserDefaultCache getIsUseFacp]];
                    if (++connectedCount_retrievedPeripherals == [FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals.count) {
                        [strongSelf loadData];
                    }
                }
            } connectType:^{
                
            } deviceInfo:^(FEPeripheral * _Nonnull peripheral, FEDeviceInfo * _Nullable info) {
                
            } RSSI:^(FEPeripheral * _Nonnull peripheral, NSNumber * _Nullable RSSI, NSError * _Nullable error) {
                
            } send:^(FEPeripheral * _Nonnull peripheral, NSError * _Nullable error, BOOL pause, BOOL finish) {
                
            } receive:^(FEPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
                NSLog(@"[APPVersion%@]peripheral = %@, value = %@", APPVersion, peripheral.displayName, characteristic.value);
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[FEBluetoothSDK sharedFEBluetoothSDK] connect:p enableAutoReconnect:YES];
            });
        }
    }
    return;
    
    __weak typeof(self) weakSelf = self;
    [[FEBluetoothSDK sharedFEBluetoothSDK] retrievePeripheralsWithIdentifiers:uuids completion:^(BOOL isSuccess) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (isSuccess) {
            __block NSInteger connectedCount_retrievedPeripherals = 0;
            for (int i = 0; i < [FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals.count; i++) {
                FEPeripheral *p = [FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals[i];
                
                __weak typeof(strongSelf) weakSelf = strongSelf;
                __weak typeof(p) weakP = p;
                [p callBackConnectStatus:^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    __strong typeof(weakP) strongP = weakP;
                    if (strongP.connectState == CONNECTSTATE_SUCCESS) {
                        [strongP enterCommunicationModeWithFacp:[FEUserDefaultCache getIsUseFacp]];
                        if (++connectedCount_retrievedPeripherals == [FEBluetoothSDK sharedFEBluetoothSDK].retrievedPeripherals.count) {
                            [strongSelf loadData];
                        }
                    }
                } connectType:^{
                    
                } deviceInfo:^(FEPeripheral * _Nonnull peripheral, FEDeviceInfo * _Nullable info) {
                    
                } RSSI:^(FEPeripheral * _Nonnull peripheral, NSNumber * _Nullable RSSI, NSError * _Nullable error) {
                    
                } send:^(FEPeripheral * _Nonnull peripheral, NSError * _Nullable error, BOOL pause, BOOL finish) {
                    
                } receive:^(FEPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
                    NSLog(@"[APPVersion%@]peripheral = %@, value = %@", APPVersion, peripheral.displayName, characteristic.value);
                }];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[FEBluetoothSDK sharedFEBluetoothSDK] connect:p enableAutoReconnect:YES];
                });
            }
        }
    }];
}

- (void)sendGroupMessageAction {
    // TODO: 群发消息
    [self showTapFeedbackForButton:self.sendGroupMessageButton];
    FEGroupChatViewController *vc = [[FEGroupChatViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showTapFeedbackForButton:(UIButton *)button {
    if (![button isKindOfClass:[UIButton class]]) {
        return;
    }
    
    UIColor *normalBackgroundColor = [UIColor clearColor];
    UIColor *highlightBackgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.9];
    
    UIColor *normalTitleColor = [UIColor systemBlueColor];
    UIColor *highlightTitleColor = [UIColor whiteColor];
    
    button.backgroundColor = highlightBackgroundColor;
    [button setTitleColor:highlightTitleColor forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.18
                          delay:0.08
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.backgroundColor = normalBackgroundColor;
        [button setTitleColor:normalTitleColor forState:UIControlStateNormal];
    } completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    FEPeripheral *peripheral = self.dataSource[indexPath.row];
    cell.textLabel.text = peripheral.displayName.length > 0 ? peripheral.displayName : @"Unknown Device";
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FEPeripheral *peripheral = self.dataSource[indexPath.row];
    NSLog(@"点击设备: %@", peripheral.displayName);
}

- (UIButton *)toolBarButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 72, 36);
    button.layer.cornerRadius = 8.0;
    button.layer.masksToBounds = YES;
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    button.backgroundColor = [UIColor clearColor];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
