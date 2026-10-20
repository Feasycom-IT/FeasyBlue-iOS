//
//  FEGroupChatViewController.m
//  BLEAssistant
//
//  Created by chenchanghua on 2025/4/16.
//  Copyright © 2025 feasycom. All rights reserved.
//

#import "FEGroupChatViewController.h"
#import "FEBluetoothSDK.h"
#import "FEPeripheral.h"
#import <UserNotifications/UserNotifications.h>

static NSString * const kFEGroupChatPushEnabledKey = @"FEGroupChatPushEnabledKey";
static NSString * const kFEGroupChatLoopIntervalKey = @"FEGroupChatLoopIntervalKey";

@interface FEGroupChatViewController ()

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UITextView *receiveTextView;
@property (nonatomic, strong) NSMutableArray<NSString *> *logLines;

// 循环发送
@property (nonatomic, strong) UILabel *intervalLabel;
@property (nonatomic, strong) UITextField *intervalField;
@property (nonatomic, strong) UIButton *loopSendButton;
@property (nonatomic, strong) NSTimer *loopSendTimer;
@property (nonatomic, assign) BOOL isLoopSending;

// 推送开关
@property (nonatomic, strong) UILabel *pushSwitchLabel;
@property (nonatomic, strong) UISwitch *pushSwitch;

@end

@implementation FEGroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"Mass messaging");
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self restoreSavedSettings];
    [self observeIncomingData];
}

- (void)dealloc {
    [self stopLoopSend];
}

#pragma mark - UI

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat contentWidth = self.view.frame.size.width - 2 * padding;
    
    // 输入框
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(padding, 100, contentWidth, 40)];
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.placeholder = LS(@"Please enter the content to be sent");
    [self.view addSubview:self.inputField];
    
    // 单次发送按钮
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(padding, CGRectGetMaxY(self.inputField.frame) + 10, contentWidth, 40);
    self.sendButton.backgroundColor = [UIColor grayColor];
    [self.sendButton setTitle:LS(@"Send") forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.layer.cornerRadius = 6;
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    // 间隔说明
    self.intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(self.sendButton.frame) + 15, 90, 30)];
    self.intervalLabel.text = LS(@"Interval(s)");
    self.intervalLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.intervalLabel];
    
    // 间隔输入框
    self.intervalField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.intervalLabel.frame) + 10, CGRectGetMinY(self.intervalLabel.frame), 80, 30)];
    self.intervalField.borderStyle = UITextBorderStyleRoundedRect;
    self.intervalField.keyboardType = UIKeyboardTypeDecimalPad;
    self.intervalField.placeholder = @"1.0";
    [self.view addSubview:self.intervalField];
    
    // 循环发送按钮
    self.loopSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loopSendButton.frame = CGRectMake(self.view.frame.size.width - padding - 130, CGRectGetMinY(self.intervalLabel.frame) - 5, 130, 40);
    self.loopSendButton.backgroundColor = [UIColor darkGrayColor];
    [self.loopSendButton setTitle:LS(@"Start Loop Send") forState:UIControlStateNormal];
    [self.loopSendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.loopSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loopSendButton.layer.cornerRadius = 6;
    [self.loopSendButton addTarget:self action:@selector(loopSendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loopSendButton];
    
    // 推送开关标题
    self.pushSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(self.intervalLabel.frame) + 20, 220, 30)];
    self.pushSwitchLabel.text = LS(@"Receive by Notification");
    self.pushSwitchLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.pushSwitchLabel];
    
    // 推送开关
    self.pushSwitch = [[UISwitch alloc] init];
    self.pushSwitch.frame = CGRectMake(self.view.frame.size.width - padding - self.pushSwitch.frame.size.width,
                                       CGRectGetMinY(self.pushSwitchLabel.frame) - 2,
                                       self.pushSwitch.frame.size.width,
                                       self.pushSwitch.frame.size.height);
    [self.pushSwitch addTarget:self action:@selector(pushSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pushSwitch];
    
    // 接收框
    CGFloat receiveY = CGRectGetMaxY(self.pushSwitchLabel.frame) + 15;
    CGFloat receiveHeight = self.view.frame.size.height - receiveY - 120;
    self.receiveTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, receiveY, contentWidth, receiveHeight)];
    self.receiveTextView.editable = NO;
    self.receiveTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.receiveTextView.layer.borderWidth = 1.0;
    self.receiveTextView.layer.cornerRadius = 5;
    self.receiveTextView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.receiveTextView];
}

- (void)restoreSavedSettings {
    NSNumber *savedPushEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:kFEGroupChatPushEnabledKey];
    if (savedPushEnabled) {
        self.pushSwitch.on = savedPushEnabled.boolValue;
    }
    
    NSString *savedInterval = [[NSUserDefaults standardUserDefaults] objectForKey:kFEGroupChatLoopIntervalKey];
    self.intervalField.text = savedInterval.length > 0 ? savedInterval : @"1.0";
}

#pragma mark - Actions

- (void)sendButtonTapped {
    [self sendCurrentInputToAllPeripherals];
}

- (void)loopSendButtonTapped {
    [self.view endEditing:YES];
    
    if (self.isLoopSending) {
        [self stopLoopSend];
    } else {
        [self startLoopSend];
    }
}

- (void)pushSwitchChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:kFEGroupChatPushEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (sender.on) {
        [self requestNotificationAuthorizationIfNeeded];
    }
}

#pragma mark - Loop Send

- (void)startLoopSend {
    NSString *text = self.inputField.text ?: @"";
    if (text.length == 0) {
        [self appendLogLine:LS(@"Loop send failed: input is empty")];
        return;
    }
    
    NSTimeInterval interval = [self validLoopInterval];
    self.isLoopSending = YES;
    
    [self.loopSendButton setTitle:LS(@"Stop Loop Send") forState:UIControlStateNormal];
    self.loopSendButton.backgroundColor = [UIColor redColor];
    
    // 先立刻发一次
    [self sendCurrentInputToAllPeripherals];
    
    self.loopSendTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self
                                                        selector:@selector(loopSendTimerFired)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.loopSendTimer forMode:NSRunLoopCommonModes];
    
    NSString *log = [NSString stringWithFormat:@"%@: %.2fs", LS(@"Loop send started, interval"), interval];
    [self appendLogLine:log];
}

- (void)stopLoopSend {
    self.isLoopSending = NO;
    
    if (self.loopSendTimer) {
        [self.loopSendTimer invalidate];
        self.loopSendTimer = nil;
    }
    
    [self.loopSendButton setTitle:LS(@"Start Loop Send") forState:UIControlStateNormal];
    self.loopSendButton.backgroundColor = [UIColor darkGrayColor];
}

- (void)loopSendTimerFired {
    [self sendCurrentInputToAllPeripherals];
}

- (NSTimeInterval)validLoopInterval {
    NSString *text = self.intervalField.text ?: @"";
    NSTimeInterval interval = text.doubleValue;
    
    // 做个兜底，防止填 0、负数、非法字符
    if (interval < 0.1) {
        interval = 1.0;
        self.intervalField.text = @"1.0";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.intervalField.text forKey:kFEGroupChatLoopIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return interval;
}

#pragma mark - Send

- (void)sendCurrentInputToAllPeripherals {
    NSString *text = self.inputField.text ?: @"";
    if (text.length == 0) {
        return;
    }
    
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray<FEPeripheral *> *connectedPeripherals = [FEBluetoothSDK sharedFEBluetoothSDK].peripherals;
    if (connectedPeripherals.count == 0) {
        [self appendLogLine:LS(@"No connected devices")];
        return;
    }
    
    NSMutableArray<NSString *> *uuidStrings = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedUUIDs"];
    for (FEPeripheral *p in connectedPeripherals) {
        if ([uuidStrings containsObject:p.identifier.UUIDString]) {
            [p send:data withResponse:YES];
        }
        [p send:data withResponse:YES];
    }
    
    NSString *line = [NSString stringWithFormat:@"%@: %@", LS(@"Send"), text];
    [self appendLogLine:line];
}

#pragma mark - Receive

- (void)observeIncomingData {
    if (!self.logLines) {
        self.logLines = [NSMutableArray array];
    }
    
    NSArray<FEPeripheral *> *connectedPeripherals = [FEBluetoothSDK sharedFEBluetoothSDK].peripherals;
    for (FEPeripheral *p in connectedPeripherals) {
        __weak typeof(self) weakSelf = self;
        [p callBackConnectStatus:nil
                     connectType:nil
                      deviceInfo:nil
                            RSSI:nil
                            send:nil
                         receive:^(FEPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSData *value = characteristic.value;
            NSString *incoming = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            if (incoming.length == 0 && value.length > 0) {
                incoming = [value description];
            }
            if (incoming.length == 0) {
                incoming = @"<empty>";
            }
            
            NSString *line = [NSString stringWithFormat:@"[%@]: %@", peripheral.displayName ?: @"Unknown", incoming];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf appendLogLine:line];
                [strongSelf tryPushNotificationForIncomingLine:line];
            });
        }];
    }
}

- (void)appendLogLine:(NSString *)line {
    if (!self.logLines) {
        self.logLines = [NSMutableArray array];
    }
    
    [self.logLines addObject:line];
    if (self.logLines.count > 200) {
        [self.logLines removeObjectsInRange:NSMakeRange(0, self.logLines.count - 200)];
    }
    
    self.receiveTextView.text = [self.logLines componentsJoinedByString:@"\n"];
    if (self.receiveTextView.text.length > 0) {
        [self.receiveTextView scrollRangeToVisible:NSMakeRange(self.receiveTextView.text.length - 1, 1)];
    }
}

#pragma mark - Notification

- (void)requestNotificationAuthorizationIfNeeded {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"notification permission granted = %d, error = %@", granted, error);
        }];
    }
}

- (void)tryPushNotificationForIncomingLine:(NSString *)line {
    if (!self.pushSwitch.isOn) {
        return;
    }
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state == UIApplicationStateActive) {
        return;
    }
    
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = LS(@"BLE Received");
        content.body = line ?: @"";
        content.sound = [UNNotificationSound defaultSound];
        
        NSString *identifier = [NSString stringWithFormat:@"fe_group_chat_%@", [[NSUUID UUID] UUIDString]];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.2 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                               withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"add local notification error = %@", error);
            }
        }];
    }
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
