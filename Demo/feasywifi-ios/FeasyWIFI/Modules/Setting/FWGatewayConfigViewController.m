//
//  FWGatewayConfigViewController.m
//  FeasyWIFI
//
//  Created by app on 2023/6/19.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import "FWGatewayConfigViewController.h"
#import "FWPopoverViewController.h"
#import "UIImage+Color.h"
#import "WDComboBoxControl.h"
#import "FWTcpClientViewController.h"

@interface FWGatewayConfigViewController ()<WDComboBoxControlDelegate, WDComboBoxControlDataSource, UITextFieldDelegate>{
    MBProgressHUD *_progressHUD;
    CGFloat viewOrigalY;
    CGFloat currentTextFieldY;
}

- (NSArray<NSArray *> *)titleOfSection;
- (NSArray<NSArray<NSArray *> *> *)dataSourceOfColunm;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) FEPeripheral *peripheral;
@property (nonatomic, strong) FEWiFi *wifi;

@property (nonatomic, strong) UILabel *tcpServerLabel;
@property (nonatomic, strong) UITextField *tcpServerTextField;
@property (nonatomic, strong) UILabel *portLabel;
@property (nonatomic, strong) UITextField *portTextField;
@property (nonatomic, strong) UIButton *connBtn;

@property (nonatomic, strong) UILabel *brokerLabel;
@property (nonatomic, strong) UITextField *brokerTextField;
@property (nonatomic, strong) UILabel *clientIDLabel;
@property (nonatomic, strong) UITextField * clientIDTextField;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UILabel *passwordLabel;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UILabel *topicLabel;
@property (nonatomic, strong) UITextField *topicTextField;



@end

@implementation FWGatewayConfigViewController

const int MAS_TOP = 75;
const int HEIGHT = 43;
int networkType = 0;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    viewOrigalY = self.view.frame.origin.y;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currentTextFieldY = textField.frame.origin.y;
}

- (void)keyboardWillShow:(NSNotification *)notification{
    if(_tcpServerTextField.isFirstResponder||_brokerTextField.isFirstResponder||_portTextField.isFirstResponder||_clientIDTextField.isFirstResponder||_usernameTextField.isFirstResponder){
        return;
    }
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect frame = [self.view frame];
    frame.origin.y = 85-height;
    self.view.frame = frame;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    CGRect frame = self.view.frame;
    frame.origin.y = viewOrigalY;
    self.view.frame = frame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = LS(@"GatewayConfiguation");
    self.view.backgroundColor = [UIColor colorWithRed:(0xeb / 255.0f) green:(0xeb / 255.0f) blue:(0xea / 255.0f) alpha:1];
    [self setupView];
    
    UIButton *button = [[UIButton alloc] init];
        [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonShow:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button.layer.borderColor = UIColor.lightGrayColor.CGColor;
        button.layer.borderWidth = 0.5;
        button.backgroundColor = [UIColor colorWithRed:22/255.0 green:117/255.0 blue:224/255.0 alpha:1.0];
        [button setTitle:LS(@"ProtocolSelect") forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(30);
            make.width.mas_equalTo(300);

        }];
        self.button = button;
    
    UIButton *imageBtn = [[UIButton alloc]init];
    [imageBtn setBackgroundImage:[UIImage imageNamed:@"bottom"] forState:UIControlStateNormal];
    [self.view addSubview:imageBtn];
    [imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view).offset(130);
        make.top.mas_equalTo(self.view.mas_top).offset(34);
        make.width.mas_equalTo(16);
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral{
//    if(self = [super initWithNibName:@"FWGatewayConfigViewController" bundle:nil]){
    if(self = [super initWithNibName:nil bundle:nil]){
        
    }
    _peripheral = peripheral;
    return self;
}

- (void)setupView{

//    UIImage *image = [[UIImage imageWithColor:[UIColor colorWithRed:22/255.0 green:117/255.0 blue:224/255.0 alpha:1.0] borderColor:[UIColor darkGrayColor] size:CGSizeMake(40, 35) radius:15] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
//    UIButton *btn = [[UIButton alloc]init];
//    [btn setTitle:@"select" forState:UIControlStateNormal];
//    [btn setEnabled:true];
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(selectNetType:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(15);
//        make.width.mas_equalTo(@100);
//        make.top.equalTo(upgradeLabel.mas_bottom).offset(20);
//        make.height.equalTo(@80);
//    }];
}

-(void)dealloc{
    if (_progressHUD) {
        [_progressHUD hideAnimated:NO];
        [_progressHUD removeFromSuperview];
    }
}

- (void)selectNetType:(UIButton*)sender{
    NSArray *array = @[@"TCP",@"MQTT"];
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc]initWithItems:array sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *netType){
        __strong typeof (weakSelf) stongSelf = weakSelf;
        NSLog(@".........select net = %@",netType);
    };
    
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)buttonShow:(UIButton *)sender {
    WDComboBoxControl *view = [[WDComboBoxControl alloc] initViewWithMaxHeight:200 fromView:sender showDirection:WDComboBoxControlDirectionBottom];
    view.dataSource = self;
    view.delegate = self;
    view.backgroundButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [view showInView];
}

#pragma mark =============== WDComBoxControlDataSource ===============
- (NSArray<NSString *> *)titleOfSection {
    return @[@"", @"", @"", @"", @"", @""];
}

- (NSArray<NSArray<NSString *> *> *)dataSourceOfColunm {
    return @[@[LS(@"ProtocolSelect"), @"MQTT", @"TCP"]];
}

#pragma mark =============== WDComBoxControlDelegate ===============
- (void)selectedAtIndexPath:(NSIndexPath *)indexPath resultTitle:(NSString *)title fromSourceView:(UIView *)sourceView {
    UIButton *sender = (UIButton *)sourceView;
    [sender setTitle:title forState:UIControlStateNormal];
    
    UIImage *image = [[UIImage imageWithColor:[UIColor colorWithRed:22/255.0 green:117/255.0 blue:224/255.0 alpha:1.0] borderColor:[UIColor darkGrayColor] size:CGSizeMake(40, 35) radius:15] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    // 连接按钮
    if(nil == _connBtn){
        _connBtn = [[UIButton alloc] init];
        [_connBtn setTitle:LS(@"Connect") forState:UIControlStateNormal];
        [_connBtn setBackgroundImage:image forState:UIControlStateNormal];
        _connBtn.enabled = true;
        [_connBtn addTarget:self action:@selector(networkConfig) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_connBtn];
        [_connBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_bottom).offset(-80);
            make.height.equalTo(@35);
        }];
    }
    
    if([LS(@"ProtocolSelect") isEqualToString:title]){
        networkType = 0;
        _connBtn.hidden = true;
        _tcpServerLabel.hidden = true;
        _tcpServerTextField.hidden = true;
        _portLabel.hidden = true;
        _portTextField.hidden = true;
        _brokerLabel.hidden = true;
        _brokerTextField.hidden = true;
        _clientIDTextField.hidden = true;
        _clientIDLabel.hidden = true;
        _usernameLabel.hidden = true;
        _usernameTextField.hidden = true;
        _passwordLabel.hidden = true;
        _passwordTextField.hidden = true;
        _topicLabel.hidden = true;
        _topicTextField.hidden = true;
    }
    else if([@"TCP" isEqualToString:title]){
        [self setupTcpView];
        _connBtn.hidden = NO;
        networkType = 1;
    }else if([@"MQTT" isEqualToString:title]){
        [self setupMQTTView];
        _connBtn.hidden = NO;
        networkType = 2;
    }
    
}

- (void)setupMQTTView{
    __block int iAutoAdd = 1;
    _tcpServerLabel.hidden = true;
    _tcpServerTextField.hidden = true;
    _portLabel.hidden = NO;
    _portTextField.hidden = NO;
    
    _brokerLabel.hidden = NO;
    _brokerTextField.hidden = NO;
    _clientIDTextField.hidden = NO;
    _clientIDLabel.hidden = NO;
    _usernameLabel.hidden = NO;
    _usernameTextField.hidden = NO;
    _passwordLabel.hidden = NO;
    _passwordTextField.hidden = NO;
    _topicLabel.hidden = NO;
    _topicTextField.hidden = NO;

    
    if(nil == _brokerLabel){
        _brokerLabel = [[UILabel alloc] init];
        _brokerLabel.textColor = [UIColor grayColor];
        _brokerLabel.text = LS(@"broker:");
        [self.view addSubview:_brokerLabel];
        [_brokerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }else{
        _brokerLabel.hidden = NO;
    }

    if(nil == _brokerTextField){
        _brokerTextField = [[UITextField alloc] init];
        _brokerTextField.delegate = self;
        _brokerTextField.textColor = [UIColor blackColor];
        _brokerTextField.backgroundColor = [UIColor whiteColor];
        NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the broker") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
//        _brokerTextField.attributedPlaceholder = attributedPlaceholder;
        _brokerTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_brokerTextField];
        [_brokerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_brokerLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }else{
        _brokerTextField.hidden = NO;
    }
    
    if(nil == _portLabel){
        _portLabel = [[UILabel alloc] init];
        _portLabel.textColor = [UIColor grayColor];
        _portLabel.text = LS(@"port:");
        [self.view addSubview:_portLabel];
        [_portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }

    //  Port
    if(nil == _portTextField){
        _portTextField = [[UITextField alloc] init];
        _portTextField.delegate = self;
        _portTextField.textColor = [UIColor blackColor];
        _portTextField.backgroundColor = [UIColor whiteColor];
        _portTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"1883") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _portTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_portTextField];
        [_portTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_portLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }else{
        iAutoAdd++;
    }
    
    //client ID
    if(nil == _clientIDLabel){
        _clientIDLabel = [[UILabel alloc] init];
        _clientIDLabel.textColor = [UIColor grayColor];
        _clientIDLabel.text = LS(@"client ID:");
        [self.view addSubview:_clientIDLabel];
        [_clientIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }

    if(nil == _clientIDTextField){
        _clientIDTextField = [[UITextField alloc] init];
        _clientIDTextField.delegate = self;
        _clientIDTextField.textColor = [UIColor blackColor];
        _clientIDTextField.backgroundColor = [UIColor whiteColor];
//        _clientIDTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the client ID") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _clientIDTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_clientIDTextField];
        [_clientIDTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_portLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }
    
    //username
    if(nil == _usernameLabel){
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.textColor = [UIColor grayColor];
        _usernameLabel.text = LS(@"username:");
        [self.view addSubview:_usernameLabel];
        [_usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }

    if(nil == _usernameTextField){
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.delegate = self;
        _usernameTextField.textColor = [UIColor blackColor];
        _usernameTextField.backgroundColor = [UIColor whiteColor];
//        _usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the username") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _usernameTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_usernameTextField];
        [_usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_portLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }
    
    //password
    if(nil == _passwordLabel){
        _passwordLabel = [[UILabel alloc] init];
        _passwordLabel.textColor = [UIColor grayColor];
        _passwordLabel.text = LS(@"password:");
        [self.view addSubview:_passwordLabel];
        [_passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }

    if(nil == _passwordTextField){
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.delegate = self;
        _passwordTextField.textColor = [UIColor blackColor];
        _passwordTextField.backgroundColor = [UIColor whiteColor];
//        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the password") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_passwordTextField];
        [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_portLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }
    
    //topic
    if(nil == _topicLabel){
        _topicLabel = [[UILabel alloc] init];
        _topicLabel.textColor = [UIColor grayColor];
        _topicLabel.text = LS(@"topic:");
        [self.view addSubview:_topicLabel];
        [_topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }

    if(nil == _topicTextField){
        _topicTextField = [[UITextField alloc] init];
        _topicTextField.delegate = self;
        _topicTextField.backgroundColor = [UIColor whiteColor];
        _topicTextField.textColor = [UIColor blackColor];
        _topicTextField.backgroundColor = [UIColor whiteColor];
//        _topicTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the topic") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _topicTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_topicTextField];
        [_topicTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_portLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }
}

- (void)setupTcpView {
    __block int iAutoAdd = 1;
    
    _tcpServerLabel.hidden = NO;
    _tcpServerTextField.hidden = NO;
    _portLabel.hidden = NO;
    _portTextField.hidden = NO;
    
    _brokerLabel.hidden = YES;
    _brokerTextField.hidden = YES;
    _clientIDTextField.hidden = YES;
    _clientIDLabel.hidden = YES;
    _usernameLabel.hidden = YES;
    _usernameTextField.hidden = YES;
    _passwordLabel.hidden = YES;
    _passwordTextField.hidden = YES;
    _topicLabel.hidden = YES;
    _topicTextField.hidden = YES;
    
    if(nil == _tcpServerLabel){
        _tcpServerLabel = [[UILabel alloc] init];
        _tcpServerLabel.textColor = [UIColor grayColor];
        _tcpServerLabel.text = LS(@"tcp server:");
        [self.view addSubview:_tcpServerLabel];
        [_tcpServerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }else{
        _tcpServerLabel.hidden = NO;
    }

    // TCP Server
    if(nil == _tcpServerTextField){
        _tcpServerTextField = [[UITextField alloc] init];
        _tcpServerTextField.delegate = self;
        _tcpServerTextField.textColor = [UIColor blackColor];
        _tcpServerTextField.backgroundColor = [UIColor whiteColor];
//        NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the tcp server") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
//        _tcpServerTextField.attributedPlaceholder = attributedPlaceholder;
        _tcpServerTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_tcpServerTextField];
        [_tcpServerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tcpServerLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }else{
        _tcpServerTextField.hidden = NO;
    }
    
    
    if(nil == _portLabel){
        _portLabel = [[UILabel alloc] init];
        _portLabel.textColor = [UIColor grayColor];
        _portLabel.text = LS(@"port:");
        [self.view addSubview:_portLabel];
        [_portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(@100);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd);
            make.height.equalTo(@(HEIGHT));
        }];
    }

    //  Port
    if(nil == _portTextField){
        _portTextField = [[UITextField alloc] init];
        _portTextField.delegate = self;
        _portTextField.textColor = [UIColor blackColor];
        _portTextField.backgroundColor = [UIColor whiteColor];
//        _portTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Please enter the port") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _portTextField.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:_portTextField];
        [_portTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_portLabel.mas_right).offset(10);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(MAS_TOP * iAutoAdd++);
            make.height.equalTo(@(HEIGHT));
        }];
    }
    
    
}

- (void)networkConfig{
    self.title = nil;
    if(1 == networkType){
        NSString *tcpserver = _tcpServerTextField.text;
        NSString *port = _portTextField.text;
        [self showProgressHUDWithTitle:LS(@"TCPConfiguring")];
        __weak __typeof(self) weakSelf = self;
        [self.wifi btConfigTCP:tcpserver port:port reconnect:true completeBlock:^(NSString * _Nullable IPAddress, NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf hideProgressHUD];
            if (error) {
                [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
            } else {
                //[strongSelf showAlertControllerWithTitle:LS(@"Config network success") message:@""];
//                if (IPAddress) {
//                    [strongSelf showAlertControllerWithTitle:LS(@"Config network success") message:[NSString stringWithFormat:@"IP Address:%@", IPAddress]];
//                } else {
//                    [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
//                }
                FWTcpClientViewController *tcpClientController = [[FWTcpClientViewController alloc]initWithServer:tcpserver port:port];
                tcpClientController.hidesBottomBarWhenPushed = YES;
                [strongSelf.navigationController pushViewController:tcpClientController animated:YES];
            }
        }];
    }else if(2 == networkType){
        NSString *broker = _brokerTextField.text;
        NSString *clientID = _clientIDTextField.text;
        NSString *username = _usernameTextField.text;
        NSString *password = _passwordTextField.text;
        NSString *topic = _topicTextField.text;
        NSString *port = _portTextField.text;
        
        [self showProgressHUDWithTitle:LS(@"MQTTConfiguring")];
        __weak __typeof(self) weakSelf = self;
        [self.wifi btConfigMQTTWithBroker:broker port:port clientID:clientID userName:username password:password topic:topic reconnect:true completeBlock:^(NSString * _Nullable IPAddress, NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf hideProgressHUD];
            if (error) {
                [strongSelf showAlertControllerWithTitle:LS(@"DistributionNetworkFailed")];
            } else {
                [strongSelf showAlertControllerWithTitle:LS(@"Config network success") message:@""];
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_portTextField resignFirstResponder];
    [_tcpServerTextField resignFirstResponder];
    [_brokerTextField resignFirstResponder];
    [_clientIDTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_topicTextField resignFirstResponder];
    return YES;
}

#pragma mark - HUD
- (void)showProgressHUD {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    [self.view setUserInteractionEnabled:NO];
    [self.view addSubview:_progressHUD];
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

- (FEWiFi *)wifi {
    if (!_wifi) {
        _wifi = [[FEWiFi alloc] initWithPeripheral:_peripheral];
    }
    return _wifi;
}

- (void)showProgressHUDWithTitle:(NSString *)title {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    
    UIView *view = self.view;
    
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
    }
    
    _progressHUD.label.text = title;
    
    [view setUserInteractionEnabled:NO];
    [view addSubview:_progressHUD];
    
    [_progressHUD showAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

@end
