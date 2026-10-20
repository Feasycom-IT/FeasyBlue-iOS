//
//  FEChangeDetailViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/2/8.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FEChangeDetailViewController.h"
#import "FEBluetoothSDK.h"
#import "FEPeripheral.h"
#import "NSString+FscKit.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface FEChangeDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FEBluetoothSDK *bluetoothSDK;
@property (nonatomic, strong) FEPeripheral *fePeripheral;
@property (nonatomic, strong) NSMutableArray<NSString *> *commands;
@property (nonatomic, assign) NSInteger commandIndex;

@property (nonatomic, assign) BOOL timeout;
@property (nonatomic, strong) NSMutableString *receivedString_cache;

@property (nonatomic, assign) NSInteger presetCommandCount;
@property (nonatomic, assign) BOOL didPromptAfterPreset;
@property (nonatomic, assign) BOOL presetFinished;

@property (nonatomic, strong) UITextView *logTextView;

@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UITableView *quickCmdTableView;
@property (nonatomic, strong) NSArray<NSString *> *quickCommands;

@end

@implementation FEChangeDetailViewController

- (void)dealloc {
    [self.bluetoothSDK disconnect:self.fePeripheral];
}

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral commands:(NSArray *)commands {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _bluetoothSDK = [FEBluetoothSDK sharedFEBluetoothSDK];
        _fePeripheral = peripheral;
        _commands = [commands mutableCopy];
        _presetCommandCount = commands.count;
        _didPromptAfterPreset = NO;
        _presetFinished = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.fePeripheral.displayName;
    [self setupLogView];
    [self setupInputBar];
    [self setupQuickCommands];
    [self setupQuickCmdTableView];
    [self layoutLogAndInputBarAndTable];
    [self updateSendButtonState];
    
    [self setupCallbacks];
    [self addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], LS(@"Device Connecting")]];
    
    [SVProgressHUD showWithStatus:nil];
    [self.bluetoothSDK connect:self.fePeripheral];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bluetoothSDK disconnect:self.fePeripheral];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setupCallbacks {
    __weak __typeof(self) weakSelf = self;
    [self.fePeripheral callBackConnectStatus:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.fePeripheral.connectState == CONNECTSTATE_SUCCESS) {
            [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], LS(@"connected")]];
            [strongSelf.fePeripheral enterAtCommandMode];
        } else {
            [SVProgressHUD dismiss];
            [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], LS(@"Disconnected BLE")]];
        }
    } connectType: ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.fePeripheral.connectType == FEPeripheralConnectType_atCommand) {
            [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], LS(@"Enter OTA Status Success")]];
            [SVProgressHUD showWithStatus:LS(@"connected")];
            [SVProgressHUD dismissWithDelay:0.25];
            [strongSelf sendNextCommand];
        } else if (strongSelf.fePeripheral.connectType == FEPeripheralConnectType_atCommand_prepare) {
            [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], LS(@"Enter OTA Status ing")]];
        } else {
            [SVProgressHUD dismiss];
            [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], LS(@"Disconnected BLE")]];
        }
    } deviceInfo:^(FEPeripheral * _Nonnull peripheral, FEDeviceInfo * _Nullable deviceInfo) {
        
    } RSSI:^(FEPeripheral * _Nonnull peripheral, NSNumber * _Nullable RSSI, NSError * _Nullable error) {
        
    } send:^(FEPeripheral * _Nonnull peripheral, NSError * _Nullable error, BOOL pause, BOOL finish) {
        
    } receive:^(FEPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.timeout) {
            return;
        }
        // 接收到的数据
        NSString *receivedString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        if (strongSelf.fePeripheral.connectType != FEPeripheralConnectType_atCommand) {
            return;
        }
        
        if (_presetFinished) {
            [self addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], receivedString]];
            return;
        }
        
        // 发送的指令
        NSString *command = strongSelf.commands[strongSelf.commandIndex - 1];
        
        if ([command containsString:@"="]) {// 修改
            
            // 示例: [19:52:58:670] PiN 修改成功
            if ([receivedString isEqualToString:@"\r\nOK\r\n"]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
                
                [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@%@",[NSString getNowTimeTimestamp], LS(@"modifiedCompleted"), [command stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]]];
                [strongSelf sendNextCommand];
            } else if ([receivedString isEqualToString:@"\r\nERROR\r\n"]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
                
                [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@%@",[NSString getNowTimeTimestamp], LS(@"modifiedFailed"), [command stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]]];
                [strongSelf sendNextCommand];
            }
            
        } else {// 读取
            
            /*
             BT986 V973
             会分两包返回，比如读取AT+NAME
             第一包：+NAME=986\r\n
             第二包：\r\nOK\r\n
             因此做了拼包处理
             */
            
            if ([receivedString containsString:@"\r\nOK\r\n"]) {
                [strongSelf.receivedString_cache appendString:receivedString];
                
                [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@%@",[NSString getNowTimeTimestamp], LS(@"readCompleted"), [command stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]]];
                
                NSArray *comps = [strongSelf.receivedString_cache componentsSeparatedByString:@"="];
                if (comps.count >= 2) {
                    NSString *reqContent = [comps[1] stringByReplacingOccurrencesOfString:@"\r\n\r\nOK\r\n" withString:@""];
                    
                    [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@",[NSString getNowTimeTimestamp], reqContent]];
                    
                    strongSelf.receivedString_cache = nil;
                    [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
                    
                    [strongSelf sendNextCommand];
                }
            } else if ([receivedString isEqualToString:@"\r\nERROR\r\n"]) {
                [strongSelf.receivedString_cache appendString:receivedString];
                
                [strongSelf addLabelWithText:[NSString stringWithFormat:@"[%@] %@%@",[NSString getNowTimeTimestamp], LS(@"readFailed"), [command stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]]];
                
                strongSelf.receivedString_cache = nil;
                [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
                
                [strongSelf sendNextCommand];
            } else {
                [strongSelf.receivedString_cache appendString:receivedString];
            }
        }
    }];
}

// 发送AT指令
- (void)sendNextCommand {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.commandIndex < self.commands.count) {
        NSString *command = self.commands[self.commandIndex ++];
        [self.fePeripheral send:[command dataUsingEncoding:NSUTF8StringEncoding] withResponse:NO];
        NSLog(@"发送AT指令:%@", command);
        
        if (!_presetFinished) {
            NSString *substring = @"AT+RESTORE";
            if ([command rangeOfString:substring].location == NSNotFound) {
                [self performSelector:@selector(commandsTimeout) withObject:nil afterDelay:20];
            }
        } else {
            [self addLabelWithText:[NSString stringWithFormat:@"[%@] %@", [NSString getNowTimeTimestamp], command]];
        }
    } else {
        if (!self.didPromptAfterPreset && self.commandIndex >= self.presetCommandCount) {
            self.didPromptAfterPreset = YES;
            
            self.presetFinished = YES;
            [self updateSendButtonState];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FEIncreaseModifiedCountNotification object:nil];
            
            [self showDisconnectConfirmAfterPreset];
            return;
        }
    }
}

- (void)commandsTimeout {
    if (!_timeout) {
        _timeout = YES;
        [self.bluetoothSDK disconnect:self.fePeripheral];
        [self showAlertControllerAndPopWithTitle:LS(@"Send command timeout")];
    }
}

- (void)addLabelWithText:(NSString *)text {
    if (text.length == 0) return;
    
    NSString *line = text;
    if (![line hasSuffix:@"\n"]) {
        line = [line stringByAppendingString:@"\n"];
    }
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:line
                                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [self.logTextView.textStorage appendAttributedString:attr];
    
    NSInteger len = self.logTextView.text.length;
    if (len > 0) {
        [self.logTextView scrollRangeToVisible:NSMakeRange(len - 1, 1)];
    }
}

- (void)setupLogView {
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.editable = NO;
    self.logTextView.selectable = YES;
    self.logTextView.alwaysBounceVertical = YES;
    self.logTextView.font = [UIFont systemFontOfSize:14];
    
    if (@available(iOS 13.0, *)) {
        self.logTextView.backgroundColor = [UIColor systemBackgroundColor];
        self.logTextView.textColor = [UIColor labelColor];
    } else {
        self.logTextView.backgroundColor = [UIColor whiteColor];
        self.logTextView.textColor = [UIColor darkTextColor];
    }
    
    self.logTextView.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8);
    [self.view addSubview:self.logTextView];
}

- (void)layoutLogAndInputBarAndTable {
    // log 在最上面，到 inputBar 之前
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.inputBar.mas_top);
    }];
    
    // inputBar 在中间，上接 log，下接 table
    [self.inputBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.quickCmdTableView.mas_top);
        make.height.mas_equalTo(56);
    }];
    
    // table 在最底部
    [self.quickCmdTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(350);
    }];
}

- (void)setupInputBar {
    self.inputBar = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        self.inputBar.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.inputBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    [self.view addSubview:self.inputBar];
    
    self.inputField = [[UITextField alloc] init];
    self.inputField.placeholder = @"AT+XXX";
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.returnKeyType = UIReturnKeySend;
    [self.inputBar addSubview:self.inputField];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendBtn setTitle:LS(@"Send") forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(onSendTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.inputBar addSubview:self.sendBtn];
    
    [self.inputBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(56);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.inputBar).offset(-12);
        make.centerY.equalTo(self.inputBar);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(36);
    }];
    
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputBar).offset(12);
        make.centerY.equalTo(self.inputBar);
        make.right.equalTo(self.sendBtn.mas_left).offset(-12);
        make.height.mas_equalTo(36);
    }];
}

- (void)updateSendButtonState {
    self.sendBtn.enabled = self.presetFinished;
    self.sendBtn.alpha = self.presetFinished ? 1.0 : 0.4;
}

- (void)onSendTapped {
    if (!self.presetFinished) {
        return;
    }
    
    NSString *cmd = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (cmd.length == 0) return;
    
    if (![cmd hasSuffix:@"\r\n"]) {
        cmd = [cmd stringByAppendingString:@"\r\n"];
    }
    [self.commands addObject:cmd];
    [self sendNextCommand];
    
    self.inputField.text = @"";
}

- (void)showDisconnectConfirmAfterPreset {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:LS(@"Completed")
                                                                message:LS(@"Preset commands finished. Disconnect BLE now?")
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    [ac addAction:[UIAlertAction actionWithTitle:LS(@"Disconnect")
                                           style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.bluetoothSDK disconnect:self.fePeripheral];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:LS(@"Stay")
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)setupQuickCmdTableView {
    self.quickCmdTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.quickCmdTableView.dataSource = self;
    self.quickCmdTableView.delegate = self;
    self.quickCmdTableView.tableFooterView = [UIView new];
    [self.quickCmdTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"QuickCmdCell"];
    [self.view addSubview:self.quickCmdTableView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.quickCommands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuickCmdCell" forIndexPath:indexPath];
    cell.textLabel.text = self.quickCommands[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *cmd = self.quickCommands[indexPath.row];
    
    // 复制到输入框（不自动加 \r\n，让用户可以编辑；发送时再补）
    self.inputField.text = cmd;
    
    // 把光标放到末尾
    [self.inputField becomeFirstResponder];
}

#pragma mark - Getter

- (NSMutableString *)receivedString_cache {
    if (!_receivedString_cache) {
        _receivedString_cache = [NSMutableString string];
    }
    return _receivedString_cache;
}

- (void)setupQuickCommands {
    self.quickCommands = @[
        @"AT",
        @"AT+A2DPCONN",
        @"AT+A2DPDISC",
        @"AT+A2DPINFO",
        @"AT+A2DPSR",
        @"AT+A2DPSTAT",
        @"AT+ADDMP",
        @"AT+ADDR",
        @"AT+ADVADDR",
        @"AT+ADVBLE",
        @"AT+ADVDATA",
        @"AT+ADVEN",
        @"AT+ADVIN",
        @"AT+APAC",
        @"AT+AUDROUTE",
        @"AT+AUXCFG",
        @"AT+AUTOCONN",
        @"AT+BACKWARD",
        @"AT+BAUD",
        @"AT+BISNAME",
        @"AT+BRAP",
        @"AT+BROKER",
        @"AT+BSSID",
        @"AT+BTEN",
        @"AT+CAP",
        @"AT+CFM",
        @"AT+CHINFO",
        @"AT+CLIENTID",
        @"AT+CLRHEADER",
        @"AT+CLOSE",
        @"AT+COD",
        @"AT+DEVNAME",
        @"AT+DEVSECRET",
        @"AT+DEVSTAT",
        @"AT+DHCP",
        @"AT+DISC",
        @"AT+DNS",
        @"AT+DSCA",
        @"AT+FLOWCTL",
        @"AT+FORWARD",
        @"AT+GATTAC",
        @"AT+GATTDISC",
        @"AT+GATTSEND",
        @"AT+GATTSTAT",
        @"AT+GETFD",
        @"AT+GETMP",
        @"AT+GETNP",
        @"AT+GW",
        @"AT+HEADER",
        @"AT+HELP",
        @"AT+HFPCFG",
        @"AT+HFPCONN",
        @"AT+HFPDIAL",
        @"AT+HFPDISC",
        @"AT+HFPDTMF",
        @"AT+HFPINFO",
        @"AT+HFPMCAL",
        @"AT+HFPSTAT",
        @"AT+HFPSR",
        @"AT+HFPVR",
        @"AT+HFPANSW",
        @"AT+HFPCHUP",
        @"AT+HFPADTS",
        @"AT+HIDCMD",
        @"AT+HIDCONN",
        @"AT+HIDDLY",
        @"AT+HIDDISC",
        @"AT+HIDMODE",
        @"AT+HIDSEND",
        @"AT+HIDSTAT",
        @"AT+HTTP",
        @"AT+I2CREG",
        @"AT+I2SCFG",
        @"AT+IBEACON",
        @"AT+IDCFG",
        @"AT+LAP",
        @"AT+LEADDR",
        @"AT+LECCONN",
        @"AT+LECHCNT",
        @"AT+LEDISC",
        @"AT+LENAME",
        @"AT+LESEND",
        @"AT+LESTAT",
        @"AT+LINKCFG",
        @"AT+LIP",
        @"AT+LPM",
        @"AT+MAC",
        @"AT+MASK",
        @"AT+MAXCON",
        @"AT+MDNSEN",
        @"AT+MICGAIN",
        @"AT+MICMUTE",
        @"AT+MODE",
        @"AT+MQTTCLS",
        @"AT+MQTTKAI",
        @"AT+MQTTMODE",
        @"AT+MQTTPORT",
        @"AT+MQTTPWD",
        @"AT+MQTTS",
        @"AT+MQTTSEND",
        @"AT+MQTTVER",
        @"AT+NAME",
        @"AT+OTA",
        @"AT+PAGE",
        @"AT+PAIR",
        @"AT+PIN",
        @"AT+PIOCFG",
        @"AT+PLAY",
        @"AT+PLAYPAUSE",
        @"AT+PLIST",
        @"AT+PROFILE",
        @"AT+PROKEY",
        @"AT+RAP",
        @"AT+REFLOWCTL",
        @"AT+REGUUID",
        @"AT+REBOOT",
        @"AT+REPEAT",
        @"AT+RESTORE",
        @"AT+ROLE",
        @"AT+RSSI",
        @"AT+RSSICFG",
        @"AT+SCAN",
        @"AT+SCFG",
        @"AT+SECURITY",
        @"AT+SEP",
        @"AT+SETFD",
        @"AT+SETMP",
        @"AT+SHUFFLE",
        @"AT+SIP",
        @"AT+SMCFG",
        @"AT+SOCK",
        @"AT+SPKCOV",
        @"AT+SPPCFG",
        @"AT+SPPCONN",
        @"AT+SPPDISC",
        @"AT+SPPSEND",
        @"AT+SPPSTAT",
        @"AT+SSP",
        @"AT+STAT",
        @"AT+STOP",
        @"AT+SUBTPC",
        @"AT+TPMODE",
        @"AT+TXPOWER",
        @"AT+UARTCFG",
        @"AT+UNSUBALL",
        @"AT+UNSUBTPC",
        @"AT+USERNAME",
        @"AT+UUIDCFG",
        @"AT+VER",
        @"AT+WEBCFG",
        @"AT+WEBSOCK",
        @"AT+WFSEND",
        @"AT+WLANC",
        @"AT+WPSCFG",
        @"AT+WSCLS",
        @"AT+WSSEND",
        @"AT+WSSTAT"
    ];
}

@end
