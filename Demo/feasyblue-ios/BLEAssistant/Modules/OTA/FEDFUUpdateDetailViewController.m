//
//  FEDFUUpdateDetailViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/1/26.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FEDFUUpdateDetailViewController.h"
#import "FEDFUDownloadViewController.h"
#import "FEDFUFileTableViewController.h"
#import "FEBluetoothSDK.h"
#import "FEPeripheral.h"
#import "FEOTA.h"
#import "NSString+FscKit.h"
#import "FEOtaFileListViewController.h"

@interface FEDFUUpdateDetailViewController ()

@property (nonatomic, strong) FEBluetoothSDK *bluetoothSDK;
@property (nonatomic, strong) NSMutableArray<FEPeripheral *> *peripherals;
@property (nonatomic, strong) FEPeripheral *peripheral;
@property (nonatomic, strong) FEOTA *ota;

@property (nonatomic, strong) UILabel *updateStateLabel;
@property (nonatomic, strong) UILabel *updateProgressLabel;
@property (nonatomic, strong) UIProgressView *updateProgressView;

@property (nonatomic, strong) UIButton *selectFileButton;
@property (nonatomic, strong) UIButton *importFileButton;

@property (nonatomic, copy) NSString *selectedFilePath;
@property (nonatomic, strong) UILabel *selectedFileNameLabel;
@property (nonatomic, assign) BOOL isDownType;

@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, strong) UILabel *device_moduleLabel;
@property (nonatomic, strong) UILabel *device_appLabel;
@property (nonatomic, strong) UILabel *device_BLLabel;

@property (nonatomic, strong) UILabel *firmware_moduleLabel;
@property (nonatomic, strong) UILabel *firmware_appLabel;
@property (nonatomic, strong) UILabel *firmware_BLLabel;
@property (nonatomic, strong) FEFirmwareInfoModel *firmwareInfoModel;

@property (nonatomic, strong) UISwitch *restoreSwitch;
@property (nonatomic, strong) UIButton *otaUpdateButton;

@property (nonatomic, assign) BOOL connecting;

@property (nonatomic, strong) id popDelegate;

@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, assign) BOOL isStart;

@end

@implementation FEDFUUpdateDetailViewController

- (void)dealloc {
    NSLog(@"dealloc_FEDFUUpdateDetailViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.ota startProgress:nil finish:nil abort:nil timeout:nil];
    [self.bluetoothSDK disconnect:self.peripheral];
}

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral peripherals:(NSArray<FEPeripheral *> *)peripherals {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bluetoothSDK = [FEBluetoothSDK sharedFEBluetoothSDK];
        self.peripheral = peripheral;
        self.peripherals = [peripherals mutableCopy];
        [self.peripherals removeObject:peripheral];
        [self.peripherals insertObject:peripheral atIndex:0];
        
        self.selectedFilePath = [FEUserDefaultCache getUpgradeFilePath];
    }
    return self;
}

- (void)refreshUIByChangedSelectedFile {
    if (self.selectedFilePath) {
        [self checkRecordedFirmwarePathAvailability];
    }
}

- (void)setupMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePathDidReceive:) name:FENotificationUrlNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePathDidReceive2:) name:FEFileDownloadedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.popDelegate;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.popDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    
    [self setTitle:LS(@"firmwareUpgrade")];
    [self setupUI];
    [self setupMonitor];
    [self refreshUIByChangedSelectedFile];
    
    /*
     __weak __typeof(self) weakSelf = self;
     [self.peripheral callBackConnectStatus:^(FEPeripheral * _Nonnull peripheral, CBPeripheralState state) {
     
     } deviceInfo:^(FEPeripheral * _Nonnull peripheral, FEDeviceInfo * _Nullable deviceInfo) {
     __strong __typeof(weakSelf) strongSelf = weakSelf;
     //
     strongSelf.deviceModel = [peripheral.deviceInfo.modelName stringByReplacingOccurrencesOfString:@"FSC-" withString:@""];
     strongSelf.device_moduleLabel.text = strongSelf.deviceModel;
     //
     NSArray *components = [peripheral.deviceInfo.system_version componentsSeparatedByString:@","];
     if (components.count > 0) {
     strongSelf.device_appLabel.text = components[0];
     }
     //
     strongSelf.device_BLLabel.text = peripheral.deviceInfo.device_version;
     // 拿到设备信息后，断开连接
     [strongSelf.bluetoothSDK disconnect:strongSelf.peripheral complete:^(FEPeripheral * _Nonnull peripheral) {
     
     }];
     //
     [strongSelf hideProgressHUD];
     } RSSI:^(FEPeripheral * _Nonnull peripheral, NSNumber * _Nullable RSSI, NSError * _Nullable error) {
     
     } send:^(FEPeripheral * _Nonnull peripheral, NSError * _Nullable error, BOOL pause, BOOL finish) {
     
     } receive:^(FEPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
     
     }];
     // 目的：拿到设备信息
     [self.bluetoothSDK connect:self.peripheral connectState:^(FEPeripheral * _Nonnull peripheral, CONNECTSTATE connectState) {
     typeof(weakSelf) strongSelf = weakSelf;
     if (connectState == CONNECTSTATE_FAIL || CONNECTSTATE_DISCONNECT) {
     [strongSelf hideProgressHUD];
     }
     }];
     //
     [self showProgressHUD];
     */
}

- (void)showProgressHUD {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
}

- (void)hideProgressHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.view setUserInteractionEnabled:YES];
}

- (void)filePathDidReceive:(NSNotification *)notification {
    self.selectedFilePath = notification.userInfo[@"url"];
    [FEUserDefaultCache saveUpgradeFilePath:self.selectedFilePath];
    self.isDownType = NO;
    [self updateFromSelectedPath];
}

- (void)filePathDidReceive2:(NSNotification *)notification {
    self.selectedFilePath = notification.userInfo[@"url"];
    [FEUserDefaultCache saveUpgradeFilePath:self.selectedFilePath];
    self.isDownType = YES;
    [self updateFromSelectedPath];
}

- (void)checkRecordedFirmwarePathAvailability {
    NSString *fileExtension = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.selectedFilePath]) {
        fileExtension = [[self.selectedFilePath pathExtension] lowercaseString];
    } else {
        self.selectedFilePath = nil;
        [FEUserDefaultCache saveUpgradeFilePath:self.selectedFilePath];
        self.firmware_moduleLabel.text = @"-";
        self.firmware_appLabel.text = @"-";
        self.firmware_BLLabel.text = @"-";
        self.selectedFileNameLabel.text = LS(@"unselectedFirmware");
        return;
    }
    if (![fileExtension isEqualToString:@"bin"] && ![fileExtension isEqualToString:@"dfu"]) {
        return;
    }
    [self updateFromSelectedPath];
}

- (void)updateFromSelectedPath {
    self.updateStateLabel.text = LS(@"waitForTheUpgrade");
    self.updateProgressLabel.text = @"0%";
    self.updateProgressView.progress = 0.0f;
    if (self.isDownType) {
        self.selectedFileNameLabel.text = [NSString stringWithFormat:@"%@/%@",[FEUserDefaultCache getLastInputDfuPath].stringByDeletingLastPathComponent, [self.selectedFilePath lastPathComponent]];
    } else {
        self.selectedFileNameLabel.text = [NSString stringWithFormat:@"%@", [self.selectedFilePath lastPathComponent]];
    }
    NSData *selectedFileData = [[NSData alloc] initWithContentsOfFile:self.selectedFilePath];
    NSLog(@"读取固件文件中的信息");
    __weak __typeof(self) weakSelf = self;
    [FEFirmwareInfoModel modelFromOTAData:selectedFileData complete:^(FEFirmwareInfoModel * _Nonnull model) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.firmwareInfoModel = model;
        [strongSelf refreshView_firmwareInfo];
        strongSelf.ota = [[FEOTA alloc] initWithPeripheral:strongSelf.peripheral dfuData:selectedFileData];
    } option:^(FEFirmwareInfoModel * _Nonnull model) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"The selected firmware does not pass the verification") message:LS(@"If you continue to use the firmware for forced upgrade, the module may become unusable. Please be careful") preferredStyle:UIAlertControllerStyleAlert];
        __weak __typeof(self) weakSelf = strongSelf;
        UIAlertAction *forceUseAction = [UIAlertAction actionWithTitle:LS(@"Mandatory use") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.firmwareInfoModel = model;
            [strongSelf refreshView_firmwareInfo];
        }];
        UIAlertAction *rechoiceAction = [UIAlertAction actionWithTitle:LS(@"reselect") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.selectedFilePath = nil;
            [FEUserDefaultCache saveUpgradeFilePath:strongSelf.selectedFilePath];
            strongSelf.firmware_moduleLabel.text = @"-";
            strongSelf.firmware_appLabel.text = @"-";
            strongSelf.firmware_BLLabel.text = @"-";
            strongSelf.selectedFileNameLabel.text = LS(@"unselectedFirmware");
        }];
        [alertController addAction:rechoiceAction];
        [alertController addAction:forceUseAction];
        [strongSelf.navigationController presentViewController:alertController animated:YES completion:NULL];
    } failed:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.firmwareInfoModel.modelTypeNum = -1;
        [strongSelf showAlertControllerWithTitle:LS(@"The selected firmware file is invalid, please select again")];
    }];
}

- (void)clickToSelectFile:(UIButton *)sender {
    FEOtaFileListViewController *vc = [FEOtaFileListViewController new];
    vc.allowedExtensions = @[@"bin", @"dfu"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)importFile:(id)sender {
    FEDFUFileTableViewController *viewController = [[FEDFUFileTableViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)refreshView_firmwareInfo {
    self.firmware_moduleLabel.text = self.firmwareInfoModel.modelType ? self.firmwareInfoModel.modelType : LS(@"unknown");
    self.firmware_appLabel.text = self.firmwareInfoModel.versionRange;
    self.firmware_BLLabel.text = self.firmwareInfoModel.bootloader;
}

- (void)gotoOTAUpdate:(UIButton *)sender {
    if (self.selectedFilePath == nil) {
        [self showAlertControllerWithTitle:LS(@"Please select the upgrade firmware first")];
    } else {
        [self startOTAUpdate];
    }
}

- (void)startOTAUpdate {
    __weak __typeof(self) weakSelf = self;
    [self.peripheral callBackConnectStatus:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.peripheral.connectState == CONNECTSTATE_SUCCESS) {
            [strongSelf.peripheral enterOtaModeWithFactory:strongSelf.restoreSwitch.isOn];
        } else {
            
            if ([strongSelf.updateProgressLabel.text isEqualToString:@"100%"]) {
                strongSelf.updateStateLabel.text = LS(@"upgrade_succeeded");
                [strongSelf showAlertControllerAndPopWithTitle:LS(@"upgrade_succeeded")];
            } else if ([strongSelf.updateProgressLabel.text isEqualToString:@"0%"]) {
                
                if (strongSelf.peripheral.deviceInfo.moduleNumber == 36 || strongSelf.peripheral.deviceInfo.moduleNumber == 99 || strongSelf.peripheral.deviceInfo.moduleNumber == 100 || strongSelf.peripheral.deviceInfo.moduleNumber == 101 || strongSelf.peripheral.deviceInfo.moduleNumber == 90) {
                    
                    if (!strongSelf.startTime) {
                        strongSelf.startTime = [NSDate date];
                    }
                    
                    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:strongSelf.startTime];
                    
                    if (elapsedTime < 150.0) {
                        // 如果还未超过150秒，5秒后再尝试重连
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [strongSelf startOTAUpdate];
                        });
                        return;
                    } else {
                        // 超过150秒后处理连接失败逻辑
                        strongSelf.updateStateLabel.text = LS(@"connectionTimeout");
                        [strongSelf showAlertControllerAndPopWithTitle:LS(@"connectionTimeout")];
                    }
                }
                
            } else {
                strongSelf.updateStateLabel.text = LS(@"Disconnected");
                [strongSelf showAlertControllerAndPopWithTitle:LS(@"Disconnected")];
            }
            strongSelf.updateStateLabel.textColor = [UIColor redColor];
            strongSelf.selectFileButton.enabled = YES;
            strongSelf.importFileButton.enabled = YES;
            strongSelf.restoreSwitch.enabled = YES;
            strongSelf.otaUpdateButton.enabled = YES;
        }
    } connectType: ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.peripheral.connectType == FEPeripheralConnectType_ota) {
            if ([strongSelf.device_moduleLabel.text isEqualToString:@"-"]/* || [strongSelf.device_moduleLabel.text isEqualToString:LS(@"unknown")]*/) {
                strongSelf.device_moduleLabel.text = strongSelf.peripheral.deviceInfo.moduleName ? strongSelf.peripheral.deviceInfo.moduleName : LS(@"unknown");
            }
            if ([strongSelf.device_appLabel.text isEqualToString:@"-"]/* || [strongSelf.device_appLabel.text isEqualToString:LS(@"unknown")]*/) {
                strongSelf.device_appLabel.text = strongSelf.peripheral.deviceInfo.appVersion ? strongSelf.peripheral.deviceInfo.appVersion : LS(@"unknown");
            }
            if ([strongSelf.device_BLLabel.text isEqualToString:@"-"]/* || [strongSelf.device_BLLabel.text isEqualToString:LS(@"unknown")]*/) {
                strongSelf.device_BLLabel.text = strongSelf.peripheral.deviceInfo.firmwareVersion ? strongSelf.peripheral.deviceInfo.firmwareVersion : LS(@"unknown");
            }
            
            if ([strongSelf.firmwareInfoModel contrastDevideAndFirmwareForContinueUpgrading:strongSelf.peripheral.deviceInfo]) {
                
                if (strongSelf.isStart) {
                    return;
                } else {
                    strongSelf.isStart = YES;
                }
                
                __weak __typeof(strongSelf) weakSelf = strongSelf;
                [strongSelf.ota startProgress:^(float progress, NSInteger length, NSInteger finishLength) {
                    
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.updateProgressView.progress = progress;
                    strongSelf.updateProgressLabel.text = [NSString stringWithFormat:@"%.f%%", progress * 100.0];
                } finish:^{
                    
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.updateStateLabel.text = LS(@"updateCompleted");
                    strongSelf.updateStateLabel.textColor = [UIColor greenColor];
                    strongSelf.selectFileButton.enabled = YES;
                    strongSelf.importFileButton.enabled = YES;
                    strongSelf.restoreSwitch.enabled = YES;
                    strongSelf.otaUpdateButton.enabled = YES;
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"upgrade_succeeded")];
                } abort:^{
                    
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.updateStateLabel.text = LS(@"updateFailed");
                    strongSelf.updateStateLabel.textColor = [UIColor redColor];
                    strongSelf.selectFileButton.enabled = YES;
                    strongSelf.importFileButton.enabled = YES;
                    strongSelf.restoreSwitch.enabled = YES;
                    strongSelf.otaUpdateButton.enabled = YES;
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"updateFailed")];
                } timeout:^{
                    
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.updateStateLabel.text = LS(@"updateFailed:timeout");
                    strongSelf.updateStateLabel.textColor = [UIColor redColor];
                    strongSelf.selectFileButton.enabled = YES;
                    strongSelf.importFileButton.enabled = YES;
                    strongSelf.restoreSwitch.enabled = YES;
                    strongSelf.otaUpdateButton.enabled = YES;
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"updateFailed:timeout")];
                }];
            } else {
                strongSelf.updateStateLabel.text = LS(@"Upgrade failed: the firmware is inappropriate");
                strongSelf.updateStateLabel.textColor = [UIColor redColor];
                strongSelf.selectFileButton.enabled = YES;
                strongSelf.importFileButton.enabled = YES;
                strongSelf.restoreSwitch.enabled = YES;
                strongSelf.otaUpdateButton.enabled = YES;
                [strongSelf showAlertControllerAndPopWithTitle:LS(@"Upgrade failed: the firmware is inappropriate")];
            }
        }
    } deviceInfo:nil RSSI:nil send:nil receive:nil];
    if (self.selectedFilePath == nil) {
        return;
    }
    if (self.firmwareInfoModel.modelTypeNum == -1) {
        [self showAlertControllerWithTitle:LS(@"The selected firmware file is invalid, please select again")];
        return;
    }
    
    self.updateStateLabel.text = LS(@"updating");
    self.updateStateLabel.textColor = [UIColor blackColor];
    self.updateProgressLabel.text = @"0%";
    self.updateProgressView.hidden = NO;
    self.updateProgressView.progress = 0.0;
    
    self.selectFileButton.enabled = NO;
    self.importFileButton.enabled = NO;
    self.restoreSwitch.enabled = NO;
    self.otaUpdateButton.enabled = NO;
    
    [self.bluetoothSDK connect:self.peripheral];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];

    self.updateStateLabel = [self createLabelWithText:LS(@"waitForTheUpgrade") fontSize:14];
    [self.view addSubview:self.updateStateLabel];

    self.updateProgressLabel = [self createLabelWithText:@"0%" fontSize:14];
    [self.view addSubview:self.updateProgressLabel];

    self.updateProgressView = [[UIProgressView alloc] init];
    [self.view addSubview:self.updateProgressView];

    self.selectFileButton = [[UIButton alloc] init];
    [self.selectFileButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.selectFileButton setTitle:LS(@"selectFirmware") forState:UIControlStateNormal];
    self.selectFileButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.selectFileButton addTarget:self action:@selector(clickToSelectFile:) forControlEvents:UIControlEventTouchUpInside];
    self.selectFileButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:self.selectFileButton];

    self.importFileButton = [[UIButton alloc] init];
    [self.importFileButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.importFileButton setTitle:LS(@"importFirmware") forState:UIControlStateNormal];
    self.importFileButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.importFileButton addTarget:self action:@selector(importFile:) forControlEvents:UIControlEventTouchUpInside];
    self.importFileButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:self.importFileButton];

    UILabel *fileLabel = [self createLabelWithText:LS(@"selectedFirmware") fontSize:14];
    [self.view addSubview:fileLabel];

    self.selectedFileNameLabel = [self createLabelWithText:LS(@"unselectedFirmware") fontSize:14];
    self.selectedFileNameLabel.numberOfLines = 0;
    [self.view addSubview:self.selectedFileNameLabel];

    UILabel *currentLabel = [self createLabelWithText:LS(@"currentModule") fontSize:14];
    [self.view addSubview:currentLabel];

    UILabel *updateFileLabel = [self createLabelWithText:LS(@"upgradeFirmware") fontSize:14];
    [self.view addSubview:updateFileLabel];

    UILabel *appVersionLabel = [self createLabelWithText:LS(@"appVersion") fontSize:14];
    [self.view addSubview:appVersionLabel];

    UILabel *blLabel = [self createLabelWithText:LS(@"blVersion") fontSize:14];
    [self.view addSubview:blLabel];

    UILabel *moduleLabel = [self createLabelWithText:LS(@"model") fontSize:14];
    [self.view addSubview:moduleLabel];

    self.device_moduleLabel = [self createLabelWithText:@"-" fontSize:14];
    [self.view addSubview:self.device_moduleLabel];

    self.device_appLabel = [self createLabelWithText:@"-" fontSize:14];
    [self.view addSubview:self.device_appLabel];

    self.device_BLLabel = [self createLabelWithText:@"-" fontSize:14];
    [self.view addSubview:self.device_BLLabel];

    self.firmware_moduleLabel = [self createLabelWithText:@"-" fontSize:14];
    [self.view addSubview:self.firmware_moduleLabel];

    self.firmware_appLabel = [self createLabelWithText:@"-" fontSize:14];
    [self.view addSubview:self.firmware_appLabel];

    self.firmware_BLLabel = [self createLabelWithText:@"-" fontSize:14];
    [self.view addSubview:self.firmware_BLLabel];

    self.otaUpdateButton = [[UIButton alloc] init];
    [self.otaUpdateButton setTitle:LS(@"startTheUpgrade") forState:UIControlStateNormal];
    self.otaUpdateButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.otaUpdateButton addTarget:self action:@selector(gotoOTAUpdate:) forControlEvents:UIControlEventTouchUpInside];
    [self.otaUpdateButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateDisabled];
    [self.otaUpdateButton setBackgroundImage:[UIImage imageNamed:@"button OK"] forState:UIControlStateNormal];
    self.otaUpdateButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:self.otaUpdateButton];

    self.restoreSwitch = [[UISwitch alloc] init];
    [self.view addSubview:self.restoreSwitch];

    UILabel *reLabel = [self createLabelWithText:LS(@"upgradeAndRestoreFactorySettings") fontSize:14];
    [self.view addSubview:reLabel];
    
    [self.updateStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset([self safeNavigationBarHeight] + 8);
        make.left.equalTo(self.view).offset(8);
    }];
    
    [self.updateProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-8);
        make.bottom.equalTo(self.updateStateLabel);
    }];
    
    [self.updateProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.updateStateLabel.mas_bottom).offset(15);
        make.left.equalTo(self.updateStateLabel);
        make.right.equalTo(self.updateProgressLabel);
        make.height.mas_equalTo(3);
    }];
    
    [self.selectFileButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.updateProgressView).offset(20);
        make.left.equalTo(self.view).offset(8);
    }];
    
    [self.importFileButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.updateProgressView).offset(20);
        make.left.equalTo(self.selectFileButton.mas_right).offset(8);
    }];
    
    [fileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectFileButton);
        make.top.equalTo(self.selectFileButton.mas_bottom).offset(8);
    }];
    
    [self.selectedFileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(fileLabel.mas_right).offset(8);
        make.top.equalTo(fileLabel);
        make.right.equalTo(self.view).offset(-8);
    }];

    [fileLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];;
    [self.selectedFileNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectedFileNameLabel.mas_bottom).offset(80);
        make.left.equalTo(self.selectFileButton);
    }];
    
    [updateFileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(currentLabel.mas_bottom).offset(20);
        make.left.equalTo(currentLabel);
    }];
    [moduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectedFileNameLabel.mas_bottom).offset(50);
        make.left.equalTo(self.selectedFileNameLabel).offset(10);
    }];
    [appVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(moduleLabel.mas_right).offset(30);
        make.top.equalTo(moduleLabel);
    }];
    [blLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(appVersionLabel);
        make.left.equalTo(appVersionLabel.mas_right).offset(30);
    }];
    [self.firmware_moduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(moduleLabel);
        make.centerY.equalTo(updateFileLabel);
    }];
    [self.firmware_appLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(appVersionLabel);
        make.centerY.equalTo(self.firmware_moduleLabel);
    }];
    [self.firmware_BLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(blLabel);
        make.centerY.equalTo(self.firmware_appLabel);
    }];
    [self.device_moduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.firmware_moduleLabel);
        make.centerY.equalTo(currentLabel);
    }];
    [self.device_appLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.firmware_appLabel);
        make.centerY.equalTo(self.device_moduleLabel);
    }];
    [self.device_BLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.firmware_BLLabel);
        make.centerY.equalTo(self.device_appLabel);
    }];
    [self.otaUpdateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.bottom.equalTo(self.view).offset(-(kTabBar_Height+8));
        make.height.mas_equalTo(44);
    }];
    [self.restoreSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(8);
        make.bottom.equalTo(self.otaUpdateButton.mas_top).offset(-20);
    }];
    [reLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.restoreSwitch.mas_right).offset(8);
        make.centerY.equalTo(self.restoreSwitch);
    }];
}

- (UILabel *)createLabelWithText:(NSString *)text fontSize:(CGFloat)size {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    return label;
}

#pragma mark - getter

- (FEFirmwareInfoModel *)firmwareInfoModel {
    if (!_firmwareInfoModel) {
        _firmwareInfoModel = [[FEFirmwareInfoModel alloc] init];
    }
    return _firmwareInfoModel;
}

@end


