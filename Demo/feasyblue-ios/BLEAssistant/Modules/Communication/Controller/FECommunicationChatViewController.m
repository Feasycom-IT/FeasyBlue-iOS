//
//  FECommunicationChatViewController.m
//  FeasycomLE
//
//  Created by 余明悦 on 16/7/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "FECommunicationChatViewController.h"
#import <zlib.h>
#import <SVProgressHUD.h>
#import "NSString+FEString.h"
#import "FESendFileTableViewController.h"
#import "FEServicesViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "FEBluetoothSDK.h"
#import "FEPeripheral.h"
#import "FEWiFi.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "FECommunicationChatView.h"
#import "FERSSIWhileConnectedVC.h"

BOOL _sendWithResponse = NO;//🤔️普通通讯永远是 不响应的写？不与传输配置里面选项对应起来？

typedef NS_ENUM(NSInteger, FECommunicateStatus) {
    FECommunicateStatus_unconnecte = 1, // 未连接
    FECommunicateStatus_inconnecte = 2, // 连接成功
    FECommunicateStatus_outconnecte     // 断开连接
};

typedef NS_ENUM(NSInteger, FESendoutFileStatus) {
    FESendoutFileStatus_never,      // 未发送
    FESendoutFileStatus_ing,        // 发送中
    FESendoutFileStatus_suspend,    // 暂停
    FESendoutFileStatus_finish,     // 发送完成
    FESendoutFileStatus_break       // 中止发送
};

@interface FECommunicationChatViewController () <UITextViewDelegate, UITextFieldDelegate, FESendFileTableViewControllerDelegate, UINavigationBarDelegate>

@property (nonatomic, strong) FEBluetoothSDK *bluetoothSDK;
@property (nonatomic, strong) FEPeripheral *peripheral;

@property (nonatomic, assign) FECommunicateStatus communicateStatus;
@property (nonatomic, assign) FESendoutFileStatus sendoutFileStatus;

@property (nonatomic, strong) UIBarButtonItem *l2capModeItem;

@property (nonatomic, assign) BOOL useL2CAPTransport;
@property (nonatomic, assign) CBL2CAPPSM l2capPSM;
@property (nonatomic, assign) BOOL hasTriedOpenL2CAP;

@property (nonatomic, strong) FECommunicationChatView *communicationChatView;

@property (nonatomic, strong) NSMutableData *receivedData;// 接收到的字节data数据

@property (nonatomic, assign) BOOL isFrequencySend;// 是否循环发送

@property (nonatomic, strong) NSTimer *intervalSendTimer;// 定时器

@property (nonatomic, strong) NSFileHandle *fileHandler;// 文件句柄
@property (nonatomic, copy) NSString *filePath;// 接收数据的文件地址

@property (nonatomic, strong) NSData *sendData;// 发送框源data
@property (nonatomic, strong) NSData *sendoutFileData;// 文件源data

@property (nonatomic, assign) BOOL isFinishedSendoutFile;// 文件源data是否发送完毕

@property (nonatomic) NSInteger totalSendingLength;// 发送数据的总大小（发送框或文件的总大小）

@property (nonatomic, strong) UIImageView *rSSIImageView;
@property (nonatomic, strong) UILabel *rSSILabel;
@property (nonatomic, strong) NSTimer *rSSIReadTimer;// 读取RSSI值定时器
@property (nonatomic, strong) FERSSIWhileConnectedVC *rSSIWhileConnectedVC;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *speedsArr;

@property (nonatomic, assign) NSInteger total_seByteCount;// 总发送字节数
@property (nonatomic, assign) NSInteger total_sePackageCount;// 总发送包数

@property (nonatomic, strong) id popDelegate;

@end

@implementation FECommunicationChatViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral {
    if (self == [super init]) {
        [self setHidesBottomBarWhenPushed:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        _peripheral = peripheral;
        _peripheral.facpTpye = FSCFacpType_2_1;
        _peripheral.isGetCompleteGATTStructure = [FEUserDefaultCache getIsGetCompleteGATTStructure];
        _bluetoothSDK = [FEBluetoothSDK sharedFEBluetoothSDK];
        _sendWithResponse = NO;
        _useL2CAPTransport = NO;   // 默认还是走原来的 GATT
        _l2capPSM = 0;
        _hasTriedOpenL2CAP = NO;
        
        // 以当前时间为名称的fsc文件地址
        NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSDate *dateNow = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *fileName = [NSString stringWithFormat:@"Received %@", [[dateFormatter stringFromDate:dateNow] stringByAppendingString:@".txt"]];
        self.filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_filePath]) {
            [fileManager createFileAtPath:_filePath contents:nil attributes:nil];
        }
        self.fileHandler = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    }
    return self;
}

- (void)setupNotify {
    [self addObserver:self forKeyPath:@"communicateStatus" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [self addObserver:self forKeyPath:@"sendoutFileStatus" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
}

- (void)removeNotify {
    [self removeObserver:self forKeyPath:@"communicateStatus"];
    [self removeObserver:self forKeyPath:@"sendoutFileStatus"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"communicateStatus"]) {
        if (self.communicateStatus == FECommunicateStatus_unconnecte) {
            [self.communicationChatView.sendoutBtn setEnabled:NO];
            [self.communicationChatView.sendoutFileBtn setEnabled:NO];
            [self.communicationChatView.frequencySwitch setEnabled:NO];
            [self.communicationChatView.transformConfigureBtn setEnabled:NO];
            [self.communicationChatView.exportReceiveFileBtn setEnabled:NO];
            [self.communicationChatView.clearDataBtn setEnabled:NO];
        }
        if (self.communicateStatus == FECommunicateStatus_inconnecte) {
            [self.communicationChatView.sendoutBtn setEnabled:YES];
            [self.communicationChatView.sendoutFileBtn setEnabled:YES];
            [self.communicationChatView.frequencySwitch setEnabled:YES];
            [self.communicationChatView.transformConfigureBtn setEnabled:YES];
            [self.communicationChatView.exportReceiveFileBtn setEnabled:YES];
            [self.communicationChatView.clearDataBtn setEnabled:YES];
        }
        if (self.communicateStatus == FECommunicateStatus_outconnecte) {
            [self.communicationChatView.sendoutBtn setEnabled:NO];
            [self.communicationChatView.sendoutFileBtn setEnabled:NO];
            [self.communicationChatView.frequencySwitch setEnabled:NO];
            [self.communicationChatView.transformConfigureBtn setEnabled:NO];
            [self.communicationChatView.exportReceiveFileBtn setEnabled:NO];
            [self.communicationChatView.clearDataBtn setEnabled:NO];
        }
    }
    if ([keyPath isEqualToString:@"sendoutFileStatus"]) {
        if (self.sendoutFileStatus == FESendoutFileStatus_never) {
            self.communicationChatView.transformConfigureBtn.enabled = YES;
            self.communicationChatView.exportReceiveFileBtn.enabled = YES;
            self.communicationChatView.clearDataBtn.enabled = YES;
            self.communicationChatView.sendoutBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn.enabled = YES;
            self.communicationChatView.frequencyInputTextField.enabled = YES;
            self.communicationChatView.frequencyInputTextField2.enabled = YES;
            self.communicationChatView.frequencySwitch.enabled = YES;
            self.communicationChatView.hexSwitch.enabled = YES;
            self.communicationChatView.newlineSwitch.enabled = YES;
        }
        if (self.sendoutFileStatus == FESendoutFileStatus_ing) {
            self.communicationChatView.transformConfigureBtn.enabled = NO;
            self.communicationChatView.exportReceiveFileBtn.enabled = NO;
            self.communicationChatView.clearDataBtn.enabled = NO;
            self.communicationChatView.sendoutBtn.enabled = NO;
            self.communicationChatView.sendoutFileBtn.enabled = NO;
            self.communicationChatView.sendoutFileBtn2.enabled = NO;
            self.communicationChatView.frequencyInputTextField.enabled = NO;
            self.communicationChatView.frequencyInputTextField2.enabled = NO;
            self.communicationChatView.frequencySwitch.enabled = self.communicationChatView.frequencySwitch.isOn;
            self.communicationChatView.hexSwitch.enabled = NO;
            self.communicationChatView.newlineSwitch.enabled = NO;
        }
        if (self.sendoutFileStatus == FESendoutFileStatus_suspend) {
            self.communicationChatView.transformConfigureBtn.enabled = YES;
            self.communicationChatView.exportReceiveFileBtn.enabled = YES;
            self.communicationChatView.clearDataBtn.enabled = YES;
            self.communicationChatView.sendoutBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn2.enabled = YES;
            self.communicationChatView.frequencyInputTextField.enabled = YES;
            self.communicationChatView.frequencyInputTextField2.enabled = YES;
            self.communicationChatView.frequencySwitch.enabled = YES;
            self.communicationChatView.hexSwitch.enabled = YES;
            self.communicationChatView.newlineSwitch.enabled = YES;
        }
        if (self.sendoutFileStatus == FESendoutFileStatus_finish) {
            self.communicationChatView.transformConfigureBtn.enabled = YES;
            self.communicationChatView.exportReceiveFileBtn.enabled = YES;
            self.communicationChatView.clearDataBtn.enabled = YES;
            self.communicationChatView.sendoutBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn2.enabled = YES;
            self.communicationChatView.frequencyInputTextField.enabled = YES;
            self.communicationChatView.frequencyInputTextField2.enabled = YES;
            self.communicationChatView.suspendSendoutBtn.selected = YES;
            self.communicationChatView.frequencySwitch.enabled = YES;
            self.communicationChatView.hexSwitch.enabled = YES;
            self.communicationChatView.newlineSwitch.enabled = YES;
        }
        if (self.sendoutFileStatus == FESendoutFileStatus_break) {
            self.communicationChatView.transformConfigureBtn.enabled = YES;
            self.communicationChatView.exportReceiveFileBtn.enabled = YES;
            self.communicationChatView.clearDataBtn.enabled = YES;
            self.communicationChatView.sendoutBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn.enabled = YES;
            self.communicationChatView.sendoutFileBtn2.enabled = YES;
            self.communicationChatView.frequencyInputTextField.enabled = YES;
            self.communicationChatView.frequencyInputTextField2.enabled = YES;
            self.communicationChatView.frequencySwitch.enabled = YES;
            self.communicationChatView.hexSwitch.enabled = YES;
            self.communicationChatView.newlineSwitch.enabled = YES;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.popDelegate;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    if (self.sendoutFileStatus == FESendoutFileStatus_ing) {
        [self.peripheral continueSend];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.intervalSendTimer invalidate];
    self.intervalSendTimer = nil;
    [self.peripheral stopSend];
    //[self.peripheral closeL2CAPChannel];
}

- (void)dealloc {
    [self.rSSIReadTimer invalidate];
    self.rSSIReadTimer = nil;
    // 清空记录接受数据的文件
    [self.fileHandler truncateFileAtOffset:0];
    
    [self removeNotify];
    
    [self.peripheral callBackConnectStatus:nil connectType:nil deviceInfo:nil RSSI:nil send:nil receive:nil];
    [self.peripheral stopSend];
    [self.peripheral clear];
    if (![FEUserDefaultCache getIsGroupCommunication]) {
        [self.bluetoothSDK disconnect:self.peripheral];
    }
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [FEUserDefaultCache saveSendData:self.sendData];
    [FEUserDefaultCache saveIntervalTime:self.communicationChatView.frequencyInputTextField.text];
    [FEUserDefaultCache saveIntervalTime:self.communicationChatView.frequencyInputTextField2.text];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO; //YES：允许右滑返回 NO：禁止右滑返回
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// 禁用右滑返回手势
    self.popDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    
    [self setupNotify];
    
    // title上显示蓝牙外设名称
    NSDictionary *advertisementData = _peripheral.advertisementData;
    NSString *advertisementName = advertisementData[CBAdvertisementDataLocalNameKey];
    NSString *title = advertisementName ?: self.peripheral.displayName ?: @"";
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5; 
    titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat maxW = screenW - 140;
    titleLabel.frame = CGRectMake(0, 0, MAX(80, maxW), 44);
    
    self.navigationItem.titleView = titleLabel;
    
    self.communicationChatView = [[FECommunicationChatView alloc] init];
    [self.view addSubview:self.communicationChatView];
    
    [self.communicationChatView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 顶部：直接使用安全区域
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
        }
        
        // 底部：安全区域底部
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }
        
        make.left.right.equalTo(self.view);
    }];
    
    [self setupBtnAction];
    
    self.communicateStatus = FECommunicateStatus_unconnecte;
    
    [SVProgressHUD showWithStatus:nil];
    
    // 设置蓝牙回调代理
    [self setupBluetoothCallbacks];
    [self.bluetoothSDK connect:self.peripheral];
    
    // 创建一个使用本来的样式进行渲染的图片（在导航栏右侧添加按钮）
    UIControl *rSSIView = [[UIControl alloc] initWithFrame:CGRectMake(0, 10, 60, 30)];
    [rSSIView addTarget:self action:@selector(enterRSSIDataVC) forControlEvents:UIControlEventTouchUpInside];
    
    self.rSSILabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 35, 20)];
    self.rSSILabel.font = [UIFont systemFontOfSize:16];
    self.rSSILabel.text = @"--";
    [rSSIView addSubview:self.rSSILabel];
    self.rSSIImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rssi_0"]];
    self.rSSIImageView.frame = CGRectMake(35, 0, 25 , 30);
    [rSSIView addSubview:self.rSSIImageView];
    
    UIBarButtonItem *rSSIBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rSSIView];
    
    self.l2capModeItem =
    [[UIBarButtonItem alloc] initWithTitle:@"L2CAP OFF"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(toggleL2CAPMode)];
    
    if ([FEUserDefaultCache getIsUseL2CAPChannel]) {
        self.navigationItem.rightBarButtonItems = @[rSSIBarBtnItem, self.l2capModeItem];
    } else {
        self.navigationItem.rightBarButtonItems = @[rSSIBarBtnItem];
    }
    
    // Delegate
    self.communicationChatView.sendoutTextView.delegate = self;
    self.communicationChatView.frequencyInputTextField.delegate = self;
    self.communicationChatView.frequencyInputTextField2.delegate = self;
    
    self.receivedData = [[NSMutableData alloc] initWithCapacity:2048];
    
    //读取上一次设置
    self.communicationChatView.hexSwitch.on = [FEUserDefaultCache getHexSendSwitch];
    self.communicationChatView.newlineSwitch.on = [FEUserDefaultCache getnewlineSendSwitch];
    NSString *intervalText = [FEUserDefaultCache getIntervalTime];
    self.communicationChatView.frequencyInputTextField.text = intervalText.length > 0 ? intervalText : @"0";
    self.sendData = [FEUserDefaultCache getSendData];
    self.communicationChatView.sendoutTextView.text = self.communicationChatView.hexSwitch.isOn ? [NSString dataToHex:self.sendData] : [NSString dataToUTF8:self.sendData];
    
    // 更新输入框中字节计数Lable数值
    [self updateSendingBytes];
}

- (void)updateRSSIView:(NSNumber *)rssiValue {
    NSInteger rssi = [rssiValue integerValue];
    if (rssi < -100) {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_0"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    } else if (rssi < -85) {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_1"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    } else if (rssi < -70) {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_2"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    } else if (rssi < -65) {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_3"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    } else if (rssi < -50) {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_4"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    } else if (rssi < -35) {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_5"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    } else {
        self.rSSIImageView.image = [UIImage imageNamed:@"rssi_5"];
        self.rSSILabel.text = [NSString stringWithFormat:@"%ld", rssi];
    }
}

- (void)enterRSSIDataVC {
    return;
    [self.navigationController pushViewController:self.rSSIWhileConnectedVC animated:YES];
}

- (void)setupBluetoothCallbacks {
    __weak typeof(self) weakSelf = self;
    
    [self.peripheral callBackConnectStatus:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.peripheral.connectState == CONNECTSTATE_SUCCESS) {
            [strongSelf dismissPresentedViewControllerRecursively];
            
            if (strongSelf.useL2CAPTransport) {
                [strongSelf presentL2CAPInputIfNeeded];
            } else {
                [strongSelf.peripheral enterCommunicationModeWithFacp:[FEUserDefaultCache getIsUseFacp]];
            }
            
            [strongSelf.rSSIReadTimer fire];
        } else if (strongSelf.peripheral.connectState == CONNECTSTATE_FAIL) {
            [SVProgressHUD dismiss];
            [strongSelf showAlertControllerWithTitle:LS(@"ConnectionFailed")];
            [strongSelf.rSSIReadTimer invalidate];
            strongSelf.rSSIReadTimer = nil;
        } else {
            [SVProgressHUD dismiss];
            [strongSelf showAlertControllerWithTitle:LS(@"disconnected")];
            strongSelf.communicateStatus = FECommunicateStatus_outconnecte;
            [strongSelf.rSSIReadTimer invalidate];
            strongSelf.rSSIReadTimer = nil;
            strongSelf.hasTriedOpenL2CAP = NO;
        }
    } connectType:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.peripheral.connectType == FEPeripheralConnectType_communication_prepare) {
            strongSelf.communicateStatus = FECommunicateStatus_inconnecte;
            [SVProgressHUD showWithStatus:LS(@"connecting")];
            [SVProgressHUD dismissWithDelay:0.25];
        }
        else if (strongSelf.peripheral.connectType == FEPeripheralConnectType_communication) {
            strongSelf.communicateStatus = FECommunicateStatus_inconnecte;
            [SVProgressHUD showWithStatus:strongSelf.useL2CAPTransport ? @"L2CAP Connected" : LS(@"connected")];
            [SVProgressHUD dismissWithDelay:0.25];
        } else {
            [SVProgressHUD dismiss];
            [strongSelf showAlertControllerWithTitle:LS(@"ConnectionFailed")];
            if (strongSelf.useL2CAPTransport) {
                strongSelf.useL2CAPTransport = !strongSelf.useL2CAPTransport;
                strongSelf.l2capModeItem.title = @"L2CAP OFF";
            }
        }
    } deviceInfo:^(FEPeripheral * _Nonnull peripheral, FEDeviceInfo * _Nullable info) {
        
    } RSSI:^(FEPeripheral * _Nonnull peripheral, NSNumber * _Nullable RSSI, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.rSSIWhileConnectedVC valueForRSSIChanged:RSSI];
        [strongSelf updateRSSIView:RSSI];
        
    } send:^(FEPeripheral * _Nonnull peripheral, NSError * _Nullable error, BOOL pause, BOOL finish) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"pause:%d~finish:%d", pause, finish);
        
        strongSelf.isFinishedSendoutFile = finish;
        
        if (!pause && !finish) {
            strongSelf.sendoutFileStatus = FESendoutFileStatus_ing;
        }
        if (pause) {
            strongSelf.sendoutFileStatus = FESendoutFileStatus_suspend;
        }
        if (finish && !strongSelf.isFrequencySend) {
            strongSelf.sendoutFileStatus = FESendoutFileStatus_finish;
            [strongSelf finishSendoutFile];
        }
        
        [strongSelf refreshSendoutView];
        
    } receive:^(FEPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSData *data = characteristic.value;
        [strongSelf handleReceivedPayload:data];
    }];
    
    [self.peripheral callBackL2CAPReceive:^(FEPeripheral * _Nonnull peripheral, NSData * _Nonnull data, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            NSLog(@"L2CAP receive error: %@", error);
            return;
        }
        [strongSelf handleReceivedPayload:data];
    }];
}
#pragma mark - FESendFileTableViewControllerDelegate
// 这个是从发送文件VC返回回来的文件源data
- (void)sendData:(NSData *)data {
    self.total_seByteCount = self.communicationChatView.sendoutByteCountLabel.text.integerValue;
    self.total_sePackageCount = self.communicationChatView.sendoutPackageCountLabel.text.integerValue;
    
    self.sendoutFileData = data;
    self.totalSendingLength = data.length;
    
    self.speedsArr = [NSMutableArray array];
    if (self.communicationChatView.sendingProgressBgView.hidden) {
        self.communicationChatView.sendingProgressBgView.hidden = NO;
    }
    // 需发送:__
    self.communicationChatView.sendoutNeedCountLabel.text = [NSString stringWithFormat:@"%@%ld", LS(@"communication_sendTotal"), self.totalSendingLength];
    // 恢复成暂停按钮
    self.communicationChatView.suspendSendoutBtn.selected = NO;
    
    [self.peripheral clearSingleRecord];
    [self.peripheral sendFinishInterval:[self.communicationChatView.frequencyInputTextField2.text integerValue]];// 分包之间的发送间隔时间
    [self.peripheral send:data withResponse:_sendWithResponse];//🤔️不是应该从统一的地方去取值是否响应吗
}

- (void)handleReceivedPayload:(NSData *)data {
    if (data.length == 0) return;
    
    if (self.receivedData.length > 2000) {
        [self.receivedData setLength:0];
    }
    [self.receivedData appendData:data];
    
    [self.fileHandler seekToEndOfFile];
    [self.fileHandler writeData:data];
    
    [self refreshReceiveView];
}

- (void)presentL2CAPInputIfNeeded {
    if (!self.useL2CAPTransport) return;
    if (self.hasTriedOpenL2CAP) return;
    if (self.peripheral.connectState != CONNECTSTATE_SUCCESS) return;
    
    self.hasTriedOpenL2CAP = YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"L2CAP"
                                                                   message:@"请输入从端显示的 PSM"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"例如 25";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        if (self.l2capPSM > 0) {
            textField.text = [NSString stringWithFormat:@"%u", self.l2capPSM];
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.useL2CAPTransport = NO;
        strongSelf.hasTriedOpenL2CAP = NO;
        
        // 回退走原来的 GATT/FACP
        [strongSelf.peripheral enterCommunicationModeWithFacp:[FEUserDefaultCache getIsUseFacp]];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"连接"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *text = alert.textFields.firstObject.text ?: @"";
        NSInteger value = text.integerValue;
        if (value <= 0 || value > UINT16_MAX) {
            strongSelf.useL2CAPTransport = NO;
            strongSelf.hasTriedOpenL2CAP = NO;
            [strongSelf showAlertControllerWithTitle:@"PSM 无效"];
            [strongSelf.peripheral enterCommunicationModeWithFacp:[FEUserDefaultCache getIsUseFacp]];
            return;
        }
        
        strongSelf.l2capPSM = (CBL2CAPPSM)value;
        [strongSelf.peripheral enterCommunicationModeWithL2CAPChannel:strongSelf.l2capPSM];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Target
- (void)setupBtnAction {
    // 传输配置
    [self.communicationChatView.transformConfigureBtn addTarget:self action:@selector(transformConfigure:) forControlEvents:UIControlEventTouchUpInside];
    // 导出接收到的文件
    [self.communicationChatView.exportReceiveFileBtn addTarget:self action:@selector(exportReceiveFile) forControlEvents:UIControlEventTouchUpInside];
    // 清除数据
    [self.communicationChatView.clearDataBtn addTarget:self action:@selector(clearDataAction:) forControlEvents:UIControlEventTouchUpInside];
    // 发送输入框内容
    [self.communicationChatView.sendoutBtn addTarget:self action:@selector(sendoutAction:) forControlEvents:UIControlEventTouchUpInside];
    // 发送文件1
    [self.communicationChatView.sendoutFileBtn addTarget:self action:@selector(sendoutFileAction:) forControlEvents:UIControlEventTouchUpInside];
    // 发送文件2
    [self.communicationChatView.sendoutFileBtn2 addTarget:self action:@selector(sendoutFileAction:) forControlEvents:UIControlEventTouchUpInside];
    // 停止发送文件
    [self.communicationChatView.stopSendoutBtn addTarget:self action:@selector(stopSendoutFileAction) forControlEvents:UIControlEventTouchUpInside];
    // 暂停发送文件
    [self.communicationChatView.suspendSendoutBtn addTarget:self action:@selector(suspendSendoutAction:) forControlEvents:UIControlEventTouchUpInside];
    // 十六进制转化
    [self.communicationChatView.hexSwitch addTarget:self action:@selector(hexSwitchAction:) forControlEvents:UIControlEventValueChanged];
    // 发送新行切换
    [self.communicationChatView.newlineSwitch addTarget:self action:@selector(newlineSwitchAction:) forControlEvents:UIControlEventValueChanged];
    // 循环发送开关
    [self.communicationChatView.frequencySwitch addTarget:self action:@selector(frequencySwitchAction:) forControlEvents:UIControlEventValueChanged];
}
#pragma mark - Action
// 传输配置Action
- (void)transformConfigure:(UIButton *)btn {
    [self.peripheral stopSend];
    FEServicesViewController *viewController = [[FEServicesViewController alloc] initWithPeripheral:_peripheral];
    [self.navigationController pushViewController:viewController animated:YES];
}
// 导出接收文件Action
- (void)exportReceiveFile {
    
    UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:_filePath]] applicationActivities:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        viewController.popoverPresentationController.sourceView = self.view;
        viewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2.f, self.view.frame.size.height/2.f, 1.f, 1.f);
        viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self.navigationController presentViewController:viewController animated:YES completion:NULL];
}
// 清空数据Action
- (void)clearDataAction:(UIButton *)btn {
    // 清空已接收的数据
    [self.receivedData setLength:0];
    [self.fileHandler truncateFileAtOffset:0];
    
    self.total_seByteCount = 0;
    self.total_sePackageCount = 0;
    [self.speedsArr removeAllObjects];
    
    // 清空相关通讯记录
    [self.peripheral clearAllRecord];
    // 刷新界面
    [self refreshView];
}
// 发送输入框内容Action
- (void)sendoutAction:(UIButton *)btn {
    self.totalSendingLength = self.sendData.length;
    if (self.totalSendingLength > 0) {
        if (self.communicationChatView.newlineSwitch.isOn) {
            NSMutableData *multableData = [NSMutableData data];
            [multableData appendData:self.sendData];
            Byte szBuf[] = {0x0D,0x0A}; 
            [multableData appendData:[NSData dataWithBytes:szBuf length:2]];
            [self.peripheral send:multableData withResponse:_sendWithResponse];
        } else {
            [self.peripheral send:self.sendData withResponse:_sendWithResponse];
        }
        self.total_seByteCount = self.communicationChatView.sendoutByteCountLabel.text.integerValue;
    }
}
// 发送文件Action
- (void)sendoutFileAction:(UIButton *)btn {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FESendFileTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"sto_sendFileVC"];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}
// 停止发送文件Action
- (void)stopSendoutFileAction {
    [self.peripheral stopSend];
    self.sendoutFileStatus = FESendoutFileStatus_break;
    self.communicationChatView.suspendSendoutBtn.selected = NO;
    self.communicationChatView.sendingProgressBgView.hidden = YES;
    self.total_seByteCount = self.communicationChatView.sendoutByteCountLabel.text.integerValue;
    self.total_sePackageCount = self.communicationChatView.sendoutPackageCountLabel.text.integerValue;
}
// 暂停发送/恢复发送Action
- (void)suspendSendoutAction:(UIButton *)btn {
    if (!btn.isSelected) {
        btn.selected = YES;
        [self.peripheral pauseSend];// 暂停发送
    } else {
        btn.selected = NO;
        if (self.isFinishedSendoutFile) {
            [self sendData:self.sendoutFileData];// 重新发送
            self.total_seByteCount = self.communicationChatView.sendoutByteCountLabel.text.integerValue;
            self.total_sePackageCount = self.communicationChatView.sendoutPackageCountLabel.text.integerValue;
        } else {
            [self.peripheral sendFinishInterval:[self.communicationChatView.frequencyInputTextField2.text integerValue]];// 分包之间的发送间隔时间
            [self.peripheral continueSend];// 继续发送
        }
    }
}
// 切换16进制Action
- (void)hexSwitchAction:(UISwitch *)swi {
    const BOOL isHex = swi.isOn;    
    [FEUserDefaultCache saveHexSendSwitch:isHex];
    
    self.communicationChatView.receiveTextView.text = isHex ? [NSString dataToHex:self.receivedData] : [NSString dataToUTF8:self.receivedData];
    
    self.communicationChatView.sendoutTextView.text = isHex ? [NSString dataToHex:self.sendData] : [NSString dataToUTF8:self.sendData];
}
//
- (void)newlineSwitchAction:(UISwitch *)swi {
    [FEUserDefaultCache saveNewlineSendSwitch:swi.isOn];
}
// 循环发送Action
- (void)frequencySwitchAction:(UISwitch *)swi {
    if ([self.communicationChatView.sendoutTextView.text length] <= 0 && swi.isOn) {
        swi.on = NO;
        return;
    }
    if (swi.isOn) {
        self.sendoutFileStatus = FESendoutFileStatus_ing;
        self.isFrequencySend = YES;
        self.totalSendingLength = 0;
        
        if (_intervalSendTimer == nil) {
            // 需要对部分模块做兼容
            NSInteger intValue = [self.communicationChatView.frequencyInputTextField.text integerValue];
            self.intervalSendTimer = [NSTimer scheduledTimerWithTimeInterval:(intValue > 5 ? intValue : 5) * 0.001 target:self selector:@selector(frequencySendAction) userInfo:nil repeats:YES];//2
            [self.intervalSendTimer fire];
        }
    } else {
        self.sendoutFileStatus = FESendoutFileStatus_never;
        self.isFrequencySend = NO;
        
        if (_intervalSendTimer) {
            [self.intervalSendTimer invalidate];
            self.intervalSendTimer = nil;
        }
        //        [self.peripheral stopSend]; 20220110 多次开启关闭循环发送 记录的字节总数有偏差
    }
}
// 循环发送Action
- (void)frequencySendAction {
    const NSInteger dataLength = _sendData.length;
    if (dataLength > 0) {
        self.totalSendingLength += dataLength;
        [self.peripheral send:_sendData withResponse:_sendWithResponse];
        self.total_seByteCount = self.communicationChatView.sendoutByteCountLabel.text.integerValue;
        //🤔️是否需要响应难道不是从特征的属性中去读取？
    }
}

// 发送完成，全部发送完毕
- (void)finishSendoutFile {
    self.communicationChatView.sendedSpeedLabel.text = [NSString stringWithFormat:@"%@%0.0f Byte/s", LS(@"communication_sendSpeed"), self.peripheral.sendCount / self.peripheral.sendTimeInterval];
    [self.speedsArr addObject:[NSNumber numberWithInt:(int)(self.peripheral.sendCount / self.peripheral.sendTimeInterval)]];
}

- (void)refreshReceiveView {
    // 接收:__字节__包
    NSString *stringB = [NSString stringWithFormat:@"%ld", self.peripheral.receiveCount];
    self.communicationChatView.receiveByteCountLabel.text = stringB;
    NSString *stringP = [NSString stringWithFormat:@"%ld", self.peripheral.rePackageCount];
    self.communicationChatView.receivePackageCountLabel.text = stringP;
    // 接收CRC32:__
    NSString *crcShow = [[NSString alloc] initWithFormat:@"%08lX",self.peripheral.crc32_re];
    self.communicationChatView.receiveCRCValueLabel.text = crcShow;
    // 接收框
    NSString *stringR = self.communicationChatView.hexSwitch.isOn ? [NSString dataToHex:_receivedData] : [NSString dataToUTF8:_receivedData];
    self.communicationChatView.receiveTextView.text = stringR;
    // 接收框位置调整
    const CGSize contentSize = self.communicationChatView.receiveTextView.contentSize;
    [self.communicationChatView.receiveTextView scrollRectToVisible:CGRectMake(0, contentSize.height-15, contentSize.width, 10) animated:YES];
}

- (void)refreshSendoutView {
    // 发送:__字节__包
    NSLog(@"发送:__字节:%ld, %ld", self.total_seByteCount, self.peripheral.sendCount);
    self.communicationChatView.sendoutByteCountLabel.text = [NSString stringWithFormat:@"%ld", self.total_seByteCount + self.peripheral.sendCount];
    self.communicationChatView.sendoutPackageCountLabel.text = [NSString stringWithFormat:@"%ld", self.total_sePackageCount + self.peripheral.sePackageCount];
    // 发送CRC32:__
    NSString *crcSend = [[NSString alloc] initWithFormat:@"%08lX",self.peripheral.all_seCRC32];
    self.communicationChatView.sendoutCRCValueLabel.text = crcSend;
    // progress
    double progress = 0.f;
    if (self.totalSendingLength > 0) {
        progress = (double)self.peripheral.sendCount / (double)self.totalSendingLength;
    }
    [self.communicationChatView.sendingProgress setProgress:progress animated:NO];
    self.communicationChatView.sendingProgressValueLabel.text = [NSString stringWithFormat:@"%.1f %%", progress * 100.0];
    // 已发送:__
    self.communicationChatView.sendedByteCountLabel.text = [NSString stringWithFormat:@"%@%ld", LS(@"communication_sended"), self.peripheral.sendCount];
    // 速率
    self.communicationChatView.sendedSpeedLabel.text = [NSString stringWithFormat:@"%@%d Byte/s", LS(@"communication_sendSpeed"), (int)(self.peripheral.sendCount / self.peripheral.sendTimeInterval)];
    [self.speedsArr addObject:[NSNumber numberWithInt:(int)(self.peripheral.sendCount / self.peripheral.sendTimeInterval)]];
    // 发送时间:__
    const int timeInterval = round(self.peripheral.sendTimeInterval);
    self.communicationChatView.sendedTimeLabel.text = [NSString stringWithFormat:@"%@%02d:%02d:%02d", LS(@"communication_sendTime"), timeInterval / 3600, (timeInterval % 3600) / 60, timeInterval % 60];
}

// 刷新界面内容
- (void)refreshView {
    [self refreshReceiveView];
    [self refreshSendoutView];
}

- (void)toggleL2CAPMode {
    self.useL2CAPTransport = !self.useL2CAPTransport;
    self.hasTriedOpenL2CAP = NO;
    
    self.l2capModeItem.title = self.useL2CAPTransport ? @"L2CAP ON" : @"L2CAP OFF";
    
    if (self.peripheral.connectState == CONNECTSTATE_SUCCESS) {
        if (self.useL2CAPTransport) {
            [self presentL2CAPInputIfNeeded];
        } else {
            [self.peripheral closeL2CAPChannel];
            [self.peripheral enterCommunicationModeWithFacp:[FEUserDefaultCache getIsUseFacp]];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (0 == [textField.text integerValue] && 1 <= [textField.text length] && [string hasPrefix:@"0"]) {
        return NO;
    }
    if ([textField.text integerValue]*10+[string integerValue] >= 65535) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
        if ([textField.text isEqualToString:@"6553"] && [string isEqualToString:@"5"]) {
            return YES;
        }
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (self.communicationChatView.hexSwitch.isOn) {
        self.sendData = [textView.text hexToData];
    } else {
        self.sendData = [textView.text UTF8ToData];
    }
    
    [self updateSendingBytes];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.communicationChatView.hexSwitch.on) {
        if ([self isHexString:text]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}
// 更新输入框中字节计数Lable数值
- (void)updateSendingBytes {
    NSString *sendText = self.communicationChatView.sendoutTextView.text;
    if (self.communicationChatView.hexSwitch.isOn) {
        const NSInteger sendingLength = sendText.length;
        NSInteger whiteSpaceCount = 0;
        for (NSInteger i = 0; i < sendingLength; i++) {
            const unichar c = [sendText characterAtIndex:i];
            if (c == '\x20') {
                whiteSpaceCount ++;
            }
        }
        self.communicationChatView.sendoutByteCalculateLabel.text = [NSString stringWithFormat:@"%d%@", (int)(sendingLength - whiteSpaceCount) / 2, LS(@"communication_byte")];
    } else {
        self.communicationChatView.sendoutByteCalculateLabel.text = [NSString stringWithFormat:@"%d%@", (int)[sendText lengthOfBytesUsingEncoding:NSUTF8StringEncoding], LS(@"communication_byte")];
    }
}

// 检查输入的是否为16进制(不分大小写)
- (BOOL)isHexString:(NSString *)string {
    
    for (int i = 0; i < string.length; i++) {
        NSString *subString = [string substringWithRange:NSMakeRange(i,1)];
        NSString *number=@"[0-9a-fA-F]";
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
        if (![numberPre evaluateWithObject:subString] && ![subString isEqualToString:@" "] && ![subString isEqualToString:@"\n"]) {
            return NO;
        }
    }
    return YES;
}

// 右滑断开连接
- (void)didMoveToParentViewController:(UIViewController*)parent {
    [super didMoveToParentViewController:parent];
}

// 第三种键盘弹起方法（调整view的约束）
- (void)showKeyboard:(NSNotification *)notification {
    // 读取userInfo中的动画种类
    NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // 读取userInfo中的动画时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 获取弹起的键盘的frame中的左顶点位置的y
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [self.communicationChatView.sendoutBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.communicationChatView.mas_left).offset(10);
        make.right.mas_equalTo(self.communicationChatView.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.communicationChatView.mas_bottom).offset(-height);
    }];
    
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

// 第三种键盘弹起方法（调整view的约束）
- (void)closeKeyboard:(NSNotification *)notification {
    [self.communicationChatView.sendoutBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.communicationChatView.mas_left).offset(10);
        make.right.mas_equalTo(self.communicationChatView.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.communicationChatView.mas_bottom);
    }];
    [self.view layoutIfNeeded];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.communicationChatView.sendoutTextView resignFirstResponder];
    [self.communicationChatView.frequencyInputTextField resignFirstResponder];
    [self.communicationChatView.frequencyInputTextField2 resignFirstResponder];
}

- (FERSSIWhileConnectedVC *)rSSIWhileConnectedVC {
    if (!_rSSIWhileConnectedVC) {
        _rSSIWhileConnectedVC = [[FERSSIWhileConnectedVC alloc] init];
    }
    return _rSSIWhileConnectedVC;
}

/// MARK: Getter

- (NSTimer *)rSSIReadTimer {
    if (!_rSSIReadTimer) {
        _rSSIReadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
    }
    return _rSSIReadTimer;
}

@end

