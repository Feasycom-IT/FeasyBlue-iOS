//
//  FWPeripheralsViewController.m
//  FeasyWIFI
//
//  Created by ericj on 2018/8/28.
//  Copyright © 2018年 Feasycom. All rights reserved.
//


#import "FWPeripheralsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FWPeripheralsTableViewCell.h"
#import "FWBTNetworkDetailViewController.h"
#import "FWOTAController.h"
#import "FEBluetoothSDK.h"
#import "NSString+FWString.h"
#import "FWSettingViewController.h"
#import "FWADView.h"
#import "FEFilterViewController.h"

@interface FWPeripheralsViewController () <UITableViewDelegate, UITableViewDataSource> {
    MBProgressHUD *_progressHUD;
}

@property (nonatomic, strong) FEBluetoothSDK *bluetoothSDK;
@property (nonatomic, strong) FEFilterModel *currentFilterModel;
@property (nonatomic, strong) UITableView *peripheralTableView;
@property (nonatomic, strong) FEPeripheral *selectedPeripheral;

@end

@implementation FWPeripheralsViewController

- (instancetype)init {
    if (self = [super init]) {
        self.bluetoothSDK = [FEBluetoothSDK sharedFEBluetoothSDK];
        self.bluetoothSDK.isShowLog = YES;
        [self.bluetoothSDK stateChange:^(CBCentralManager * _Nonnull manager) {
            if (manager.state == CBManagerStatePoweredOff) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CBManagerStatePoweredOffNotification" object:nil];
            }
        }];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.bluetoothSDK.filter.isFilterName = self.currentFilterModel.isFilterName;
    self.bluetoothSDK.filter.filtrationName = self.currentFilterModel.filterName;
    self.bluetoothSDK.filter.isFilterRSSI = YES;
    self.bluetoothSDK.filter.minRSSI = self.currentFilterModel.filterMinimumRSSI;
    self.bluetoothSDK.filter.maxRSSI = -30;
    [self.peripheralTableView.mj_header beginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bluetoothSDK stopScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationView];
    [FWADView showWithSeconds:5];
    usleep(100);
    [self.view addSubview:self.peripheralTableView];
}

- (void)setupNavigationView {
    self.title = LS(@"Setting");
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
    //透明
    self.navigationController.navigationBar.translucent = NO;
    //navigation控件颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Sort") style:UIBarButtonItemStylePlain target:self action:@selector(sortAction)];
    [self.navigationItem setLeftBarButtonItem:sortItem];
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Filter") style:UIBarButtonItemStylePlain target:self action:@selector(filterAction)];
    [self.navigationItem setRightBarButtonItem:filterItem];
    // 返回按钮
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] init];
    backBtn.title = LS(@"Back");
    self.navigationItem.backBarButtonItem = backBtn;
}

- (void)insertPeripheral:(FEPeripheral *)peripheral{
    [self.peripheralTableView reloadData];
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[FEBluetoothSDK sharedFEBluetoothSDK].scanPeripherals.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

// 刷新某个设备
- (void)reloadPeripheral:(FEPeripheral *)peripheral {
    NSArray<FEPeripheral *> *array = [FEBluetoothSDK sharedFEBluetoothSDK].scanPeripherals;
    NSInteger index = [array indexOfObject:peripheral];
    for (NSIndexPath *indexPath in self.peripheralTableView.indexPathsForVisibleRows) {
        if (indexPath.row == index) {
            // 找到对应的cell，减少卡顿
            FWPeripheralsTableViewCell *cell = [self.peripheralTableView cellForRowAtIndexPath:indexPath];
            NSDictionary *advertisementData = [peripheral advertisementData];
            
            [cell reflashName:peripheral.deviceInfo.name ? peripheral.deviceInfo.name : peripheral.peripheral.name];
            [cell reflashRSSI:[peripheral.RSSI integerValue]];
            
            cell.UUIDLabel.text = [peripheral.peripheral.identifier UUIDString];
            
            NSArray *serviceUUIDs = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
            
            if (0 < [serviceUUIDs count]) {
                cell.serviceUUIDsLabel.text = [serviceUUIDs componentsJoinedByString:@","];
            } else {
                cell.serviceUUIDsLabel.text = @"";
            }
        }
    }
}

// 排序Action
- (void)sortAction {
    NSMutableArray *peripherals = self.bluetoothSDK.scanPeripherals;
    const NSInteger count = peripherals.count;
    
    for (NSInteger i = 1; i < count; ++ i) {
        FEPeripheral *peripheral = peripherals[i];
        const NSInteger RSSIValue = [peripheral.RSSI integerValue];
        
        for (NSInteger j = 0; j < i; ++ j) {
            if ([[peripherals[j] RSSI] integerValue] < RSSIValue) {
                [peripherals removeObjectAtIndex:i];
                [peripherals insertObject:peripheral atIndex:j];
                break;
            }
        }
    }
    [self.peripheralTableView reloadData];
}

// 过滤Action
- (void)filterAction {
    // 取值
    self.currentFilterModel.isFilterName = [FEUserDefaultCache getFilterEnabled_parameter];
    self.currentFilterModel.filterName = [FEUserDefaultCache getName_prefix_parameter];
    self.currentFilterModel.filterMinimumRSSI = [FEUserDefaultCache getMinimumRSSI_parameter] == 0 ? -100 : [FEUserDefaultCache getMinimumRSSI_parameter];/* 第一次安装读取为0 */
    
    __weak typeof(self) weakSelf = self;
    FEFilterViewController *viewController = [[FEFilterViewController alloc] initWithFilterModel:self.currentFilterModel didChangedFilter:^(FEFilterModel *currentFilter) {
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentFilterModel = currentFilter;
        // 赋值
        [FEUserDefaultCache saveFilterEnabled_parameter:currentFilter.isFilterName];
        [FEUserDefaultCache saveName_prefix_parameter:currentFilter.filterName];
        [FEUserDefaultCache saveMinimumRSSI_parameter:currentFilter.filterMinimumRSSI];
    }];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (FEFilterModel *)currentFilterModel {
    if (!_currentFilterModel) {
        _currentFilterModel = [[FEFilterModel alloc] init];
        _currentFilterModel.isFilterName = [FEUserDefaultCache getFilterEnabled_parameter];
        _currentFilterModel.filterName = [FEUserDefaultCache getName_prefix_parameter];
        _currentFilterModel.filterMinimumRSSI = [FEUserDefaultCache getMinimumRSSI_parameter] == 0 ? -100 : [FEUserDefaultCache getMinimumRSSI_parameter];;
    }
    return _currentFilterModel;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bluetoothSDK.scanPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FWPeripheralsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PeripheralsCell"];
    }
    FEPeripheral *peripheral = [self.bluetoothSDK.scanPeripherals objectAtIndex:indexPath.row];
    NSDictionary *advertisementData = [peripheral advertisementData];
    
    [cell reflashName:peripheral.deviceInfo.name ? peripheral.deviceInfo.name : peripheral.peripheral.name];
    [cell reflashRSSI:[peripheral.RSSI integerValue]];
    
    cell.UUIDLabel.text = [peripheral.peripheral.identifier UUIDString];
    
    NSArray *serviceUUIDs = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    if (0 < [serviceUUIDs count]) {
        cell.serviceUUIDsLabel.text = [serviceUUIDs componentsJoinedByString:@","];
    } else {
        cell.serviceUUIDsLabel.text = @"";
    }
    
    NSDictionary *data = [advertisementData valueForKey:@"kCBAdvDataServiceData"];
    
    NSData *UIDData = [data objectForKey:[CBUUID UUIDWithString:@"FFF0"]];
    
    // 把data转换为字符串
    NSString *str = [NSString fan_dataToHexString:UIDData];
    NSString *macString = nil;
    
    if (str.length >= 21) {
        macString = [[str substringWithRange:NSMakeRange(8,12)] uppercaseString];
    } else {
        UIDData = advertisementData[@"kCBAdvDataManufacturerData"];
        str = [NSString fan_dataToHexString:UIDData];
        
        if (str.length >= 16) {
            macString = [[str substringWithRange:NSMakeRange(4, 12)] uppercaseString];
        }
    }
 
    if (macString) {
        NSString *str1 = [macString substringWithRange:NSMakeRange(0,2)];
        NSString *str2 = [macString substringWithRange:NSMakeRange(2,2)];
        NSString *str3 = [macString substringWithRange:NSMakeRange(4,2)];
        NSString *str4 = [macString substringWithRange:NSMakeRange(6,2)];
        NSString *str5 = [macString substringWithRange:NSMakeRange(8,2)];
        NSString *str6 = [macString substringWithRange:NSMakeRange(10,2)];
        
        cell.macLabel.text = [NSString stringWithFormat:@"mac: %@:%@:%@:%@:%@:%@",str1,str2,str3,str4,str5,str6];
    } else {
        cell.macLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 没有开启蓝牙功能
    if ([self.bluetoothSDK.centraManage state] == CBManagerStatePoweredOff) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showAlertControllerAndPopWithTitle:LS(@"Please try again when open bluetooth")];
        return;
    }

    self.selectedPeripheral = self.bluetoothSDK.scanPeripherals[indexPath.row];
    [self showProgressHUDWithTitle:LS(@"Connecting")];
    __weak __typeof(self) weakSelf = self;
    [[FEBluetoothSDK sharedFEBluetoothSDK] connectToModify:self.selectedPeripheral connectState:^(FEPeripheral * _Nonnull peripheral, CONNECTSTATE connectState) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
        if (connectState == CONNECTSTATE_SUCCESS) {
            FWSettingViewController *settingVC = [[FWSettingViewController alloc] initWithPeripheral:peripheral];
            settingVC.hidesBottomBarWhenPushed = YES;
            [strongSelf.navigationController pushViewController:settingVC animated:YES];
        } else if (connectState == CONNECTSTATE_FAIL) {
            [[FEBluetoothSDK sharedFEBluetoothSDK] disconnect:peripheral complete:^(FEPeripheral * _Nonnull peripheral) {
                [strongSelf.peripheralTableView reloadData];
            }];
            [self showAlertControllerAndPopWithTitle:LS(@"ConnectionFailed")];
        } else if (connectState == CONNECTSTATE_DISCONNECT) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectstateDisconnectNotification" object:nil];
            [[FEBluetoothSDK sharedFEBluetoothSDK] disconnect:peripheral complete:^(FEPeripheral * _Nonnull peripheral) {
                [strongSelf.peripheralTableView reloadData];
            }];
            [self showAlertControllerAndPopWithTitle:LS(@"The device is disconnected from Bluetooth")];
        } else {
            
        }
    }];
}

#pragma mark - lazyLoad
- (UITableView *)peripheralTableView {
    if (!_peripheralTableView) {
        _peripheralTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - kTabBar_Height - kTabBar_Safe_Height) style:UITableViewStylePlain];
        _peripheralTableView.delegate = self;
        _peripheralTableView.dataSource = self;
        _peripheralTableView.rowHeight = 60;
        [_peripheralTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_peripheralTableView registerNib:[UINib nibWithNibName:@"FWPeripheralsTableViewCell"bundle:nil] forCellReuseIdentifier:@"PeripheralsCell"];
        __weak __typeof(self) weakSelf = self;
        _peripheralTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf.bluetoothSDK clear];
            [weakSelf.bluetoothSDK.scanPeripherals removeAllObjects];
            [weakSelf.peripheralTableView reloadData];
            [weakSelf.peripheralTableView.mj_header endRefreshing];
            [weakSelf.bluetoothSDK stopScan];
            [weakSelf.bluetoothSDK scan:^(FEPeripheral* peripheral, BOOL isNew) {
                NSDictionary *advitisement = [peripheral advertisementData];
                NSDate *manufactureData = [advitisement valueForKey:@"kCBAdvDataManufacturerData"];
                if(manufactureData==nil&&(peripheral.peripheral.name==nil||peripheral.deviceInfo.name==nil)){
                    
                }else if (isNew) {
                    [weakSelf insertPeripheral:peripheral];
                } else {
                    [weakSelf reloadPeripheral:peripheral];
                }
            }];
        }];
    }
    return  _peripheralTableView;;
}

- (void)showProgressHUDWithTitle:(NSString *)title {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    
    UIView *view = APPDelegate.window;
    
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
    }
    
    _progressHUD.label.text = title;
    [_progressHUD.button setTitle:LS(@"Cancel") forState:UIControlStateNormal];
    [_progressHUD.button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_progressHUD.button addTarget:self action:@selector(cancelLinkAction) forControlEvents:UIControlEventTouchUpInside];
    
    [view setUserInteractionEnabled:YES];
    [view addSubview:_progressHUD];
    
    [_progressHUD showAnimated:YES];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_progressHUD hideAnimated:YES];
        [self performSelector:@selector(progressHUDDidHide:) withObject:_progressHUD afterDelay:0.5];
    }
}

- (void)progressHUDDidHide:(UIView *)progressHUD {
    if (progressHUD == _progressHUD) {
        [self.view setUserInteractionEnabled:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

- (void)cancelLinkAction {
    [[FEBluetoothSDK sharedFEBluetoothSDK] disconnect:self.selectedPeripheral complete:^(FEPeripheral * _Nonnull peripheral) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
