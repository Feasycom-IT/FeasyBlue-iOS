//
//  FEPeripheralsViewController.m
//  FeasycomLE
//
//  Created by 余明悦 on 16/7/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "FEPeripheralsViewController.h"
#import "FEFilterViewController.h"
#import "FECommunicationTableViewCell.h"
#import "FEBluetoothSDK.h"
#import "Masonry.h"
#import <MJRefresh.h>
#import "FEAdvDataPreviewViewController.h"

@interface FEPeripheralsViewController ()

@property (nonatomic, assign) FEPageType pageType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FEBluetoothSDK *bluetoothSDK;
@property (nonatomic, strong) NSTimer *refreshRSSITimer;

@property (nonatomic, strong, readwrite) NSMutableArray<FEPeripheral *> *peripherals;

@property (nonatomic, assign) BOOL filterNameEnabled;
@property (nonatomic, copy) NSString  *filterName;
@property (nonatomic, assign) NSInteger minimumRSSI;

@property (nonatomic, strong) UIImageView *filterImageV;
@property (nonatomic, strong) UIView *buttonView;

@end

@implementation FEPeripheralsViewController

- (instancetype)initWithPageType:(const FEPageType)pageType {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self setHidesBottomBarWhenPushed:YES];
        _pageType = pageType;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _bluetoothSDK = [FEBluetoothSDK sharedFEBluetoothSDK];
    _peripherals = [[NSMutableArray alloc] initWithCapacity:1024];
}

- (void)refresh {
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_pageType == FECommandPage) {
        self.filterNameEnabled = [FEUserDefaultCache getFilterEnabled_parameter];
        self.minimumRSSI = [FEUserDefaultCache getMinimumRSSI_parameter];
        self.filterName = [FEUserDefaultCache getName_prefix_parameter];
    } else if (_pageType == FEDFUPage) {
        self.filterNameEnabled = [FEUserDefaultCache getFilterEnabled_update];
        self.minimumRSSI = [FEUserDefaultCache getMinimumRSSI_update];
        self.filterName = [FEUserDefaultCache getName_prefix_update];
    } else {
        self.filterNameEnabled = [FEUserDefaultCache getFilterEnabled];
        self.minimumRSSI = [FEUserDefaultCache getMinimumRSSI];
        self.filterName = [FEUserDefaultCache getName_prefix];
    }
    if (-100 > _minimumRSSI || -30 < _minimumRSSI) {
        _minimumRSSI = -100;// (-100, -30) 为正常范围，只要不是正常值，直接赋值 -100
    }
    
    if (self.filterNameEnabled || self.minimumRSSI > -100) {
        [self.filterImageV setImage:[UIImage imageNamed:@"icon_filtter_ing"]];
    } else {
        [self.filterImageV setImage:[UIImage imageNamed:@"icon_filtter_none"]];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [self.tableView.mj_header beginRefreshing];
    
    if (!_refreshRSSITimer) {
        self.refreshRSSITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.bluetoothSDK stopScan];
    
    if (_refreshRSSITimer) {
        [_refreshRSSITimer invalidate];
        _refreshRSSITimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self setupUI];
    __weak __typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.peripherals removeAllObjects];
        if (strongSelf.bluetoothSDK.feBluetoothSDKState != FEBluetoothSDKState_PoweredOff) {
            [strongSelf.bluetoothSDK stopScan];
            strongSelf.bluetoothSDK.isPrintDiscoverPeripheralLog = [FEUserDefaultCache getIsUseScanLog];
            [strongSelf.bluetoothSDK scanForPeripheralsWithServices:nil block:^(FEPeripheral * _Nonnull peripheral, BOOL isNew) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                const NSInteger RSSIValue = [peripheral.RSSI integerValue];
                if (RSSIValue > 0) {
                    return;
                }
                if (RSSIValue > strongSelf.minimumRSSI) {
                    if (strongSelf.filterNameEnabled && strongSelf.filterName.length > 0) {
                        NSString *advertisementName = peripheral.advertisementData[CBAdvertisementDataLocalNameKey];
                        NSString *name = advertisementName ? : peripheral.displayName;
                        
                        if (nil != name && [name rangeOfString:strongSelf.filterName options:NSCaseInsensitiveSearch].location != NSNotFound) {
                            [strongSelf updatePripheral:peripheral];
                        }
                    } else {
                        [strongSelf updatePripheral:peripheral];
                    }
                }
            }];
        } else {
            [strongSelf showAlertControllerWithTitle:LS(@"FeasyBlue requires Bluetooth")];
        }
        [strongSelf.tableView reloadData];
        [strongSelf.tableView.mj_header endRefreshing];
    }];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.buttonView.frame = CGRectMake(0, [self safeNavigationBarHeight],
                                       self.view.bounds.size.width, 44);
}

- (void)setupUI {
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, [self safeNavigationBarHeight], self.view.frame.size.width, 44)];
    self.buttonView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.buttonView];
    
    UIView *sortView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.buttonView.frame.size.width/2.0, self.buttonView.frame.size.height)];
    [self.buttonView addSubview:sortView];
    UITapGestureRecognizer *tapSort = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sort)];
    [sortView addGestureRecognizer:tapSort];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"排序"]];
    [sortView addSubview:imageView];
    UILabel *sortLable = [[UILabel alloc] init];
    sortLable.text = LS(@"sort");
    sortLable.font = [UIFont systemFontOfSize:17];
    [sortView addSubview:sortLable];
    
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(self.buttonView.frame.size.width/2.0, 0, self.buttonView.frame.size.width/2.0, self.buttonView.frame.size.height)];
    [self.buttonView addSubview:filterView];
    UITapGestureRecognizer *tapFilter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToFilter)];
    [filterView addGestureRecognizer:tapFilter];
    self.filterImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_filtter_none"]];
    [filterView addSubview:self.filterImageV];
    UILabel *filterLable = [[UILabel alloc] init];
    filterLable.text = LS(@"Filter");
    filterLable.font = [UIFont systemFontOfSize:17];
    [filterView addSubview:filterLable];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor blackColor];
    [self.buttonView addSubview:lineView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerNib:[UINib nibWithNibName:@"FECommunicationTableViewCell"bundle:nil] forCellReuseIdentifier:@"CommCell"];
    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.buttonView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-kTabBar_Height);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sortView).offset(12);
        make.bottom.equalTo(sortView).offset(-12);
        make.right.equalTo(sortView).offset(-(sortView.frame.size.width/2.0)-5);
        make.width.mas_equalTo(20*1.6);
    }];
    [sortLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imageView);
        make.left.equalTo(sortView).offset((sortView.frame.size.width/2.0)+5);
    }];
    [self.filterImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(imageView);
        make.right.equalTo(filterView).offset(-(filterView.frame.size.width/2.0)-8);
        make.width.mas_equalTo(20);
    }];
    [filterLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.filterImageV);
        make.left.equalTo(filterView).offset((filterView.frame.size.width/2.0)+5);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonView).offset(10);
        make.bottom.equalTo(self.buttonView).offset(-10);
        make.centerX.equalTo(self.buttonView);
        make.width.mas_equalTo(1);
    }];
}

- (void)clickToFilter {
    FEFilterViewController *viewController = [[FEFilterViewController alloc] initWithPageType:_pageType];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)sort {
    self.peripherals = [[self.peripherals sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id _Nonnull obj2) {
        const NSInteger value1 = [[(FEPeripheral *)obj1 RSSI] integerValue];
        const NSInteger value2 = [[(FEPeripheral *)obj2 RSSI] integerValue];
        if (value1 > value2) {
            return NSOrderedAscending;
        } else if (value1 < value2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }] mutableCopy];
    [self.tableView reloadData];
}

- (void)updatePripheral:(FEPeripheral *)peripheral {
    const NSInteger index = [_peripherals indexOfObject:peripheral];
    
    if (NSNotFound == index) {
        const NSInteger newRow = [_peripherals count];
        
        [_peripherals insertObject:peripheral atIndex:newRow];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        _peripherals[index].RSSI = peripheral.RSSI;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (FECommunicationTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FECommunicationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommCell" forIndexPath:indexPath];
    FEPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    NSDictionary *advertisementData = peripheral.advertisementData;
    NSString *advertisementName = advertisementData[CBAdvertisementDataLocalNameKey];
    NSArray *serviceUUIDs = advertisementData[@"kCBAdvDataServiceUUIDs"];
    NSNumber *isConnectable = advertisementData[CBAdvertisementDataIsConnectable];
    NSNumber *txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey];
    
    cell.isConnectable = isConnectable.boolValue;
    cell.txPower = (txPower == nil)? -1 : txPower.integerValue;
    
    if (advertisementName) {
        [cell refreshName:advertisementName];
    } else {
        [cell refreshName:peripheral.displayName];
    }
    
    if (0 < serviceUUIDs) {
        cell.serviceUUIDsLabel.text = [serviceUUIDs componentsJoinedByString:@","];
    } else {
        cell.serviceUUIDsLabel.text = @"";
    }
    
    [cell refreshRSSI:[peripheral.RSSI integerValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
    return 60;
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView
contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
                                    point:(CGPoint)point API_AVAILABLE(ios(13.0)) {
    
    FEPeripheral *peripheral = self.peripherals[indexPath.row];
    NSDictionary *adv = peripheral.advertisementData ?: @{};
    
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"Name: %@\n", peripheral.peripheralName ?: @"-"];
    [text appendFormat:@"RSSI: %@\n\n", peripheral.RSSI ?: @"-"];
    [text appendString:@"advertisementData:\n"];
    [text appendString:adv.description];
    NSData *manufacturerData = adv[CBAdvertisementDataManufacturerDataKey];
    [text appendString:@",ManufacturerData HEX："];
    [text appendString:[self hexStringFromData:manufacturerData]];
    
    UIContextMenuConfiguration *config =
    [UIContextMenuConfiguration configurationWithIdentifier:nil
                                            previewProvider:^UIViewController * _Nullable{
        return [[FEAdvDataPreviewViewController alloc] initWithText:text];
    } actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        return nil;
    }];
    
    return config;
}

-(void)refreshRSSI{
    const NSInteger count = _peripherals.count;
    for (NSInteger i = 0; i < count; i++) {
        FECommunicationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell refreshRSSI:[[self.peripherals[i] RSSI] integerValue]];
    }
}

- (NSString *)hexStringFromData:(NSData *)data {
    NSMutableString *string = [NSMutableString stringWithCapacity:data.length * 2];
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    for (int i = 0; i < data.length; ++i) {
        [string appendFormat:@"%02x ", dataBuffer[i]];
    }
    return [string copy];
}

@end

