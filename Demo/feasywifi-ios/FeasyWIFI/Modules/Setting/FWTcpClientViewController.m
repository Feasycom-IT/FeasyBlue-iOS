//
//  FWTcpClientViewController.m
//  FeasyWIFI
//
//  Created by app on 2023/6/29.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import "FWTcpClientViewController.h"
#import "FWTcpClient.h"

@interface FWTcpClientViewController ()<FWTcpClientDelegate, UITextViewDelegate>{
    NSString *mHost;
    NSString *mPort;
}

@property (weak, nonatomic) IBOutlet UITextView *sendTextView;
@property (weak, nonatomic) IBOutlet UITextView *RecieveTextView;
@property (weak, nonatomic) IBOutlet UILabel *labelRecieve;
@property (weak, nonatomic) IBOutlet UILabel *labelSend;

@property (weak, nonatomic) IBOutlet UIButton *btnClear;

@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (nonatomic, strong) FWTcpClient *tcpClient;


@end

@implementation FWTcpClientViewController

- (instancetype)initWithServer:(NSString*)server port:(NSString*)port {
    if(self = [super initWithNibName:nil bundle:nil]){
        mHost = server;
        mPort = port;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = LS(@"TCP Client");
    [_btnSend setTitle:LS(@"SEND") forState:UIControlStateNormal];
    [_btnClear setTitle:LS(@"CLEAR") forState:UIControlStateNormal];
    _labelSend.text = LS(@"SEND");
    _labelRecieve.text = LS(@"RECIEVE");
    _RecieveTextView.editable = NO;
    _sendTextView.delegate = self;
    [_btnSend addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    [_btnClear addTarget:self action:@selector(clrRecieveTextView) forControlEvents:UIControlEventTouchUpInside];
    _tcpClient = [FWTcpClient shareFWTcpClient];
    _tcpClient.delegate = self;
    NSError *error;
    self.navigationItem.title = LS(@"Tcp client connecting");
    _btnSend.enabled = false;
    BOOL connResult = [_tcpClient connectToHost:mHost onPort:[mPort intValue] withTimeout:20 error:&error];
    NSLog(@"connect error:%@,connResult=%d",error,connResult);
    if(nil != error){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"connet fail") message:error.userInfo.description preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertActionOK = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"connect fail....");
        }];
        [alertController addAction:alertActionOK];
        [self presentViewController:alertController animated:YES completion:nil];
        [_btnSend setEnabled:false];
        [self.navigationItem setTitle:LS(@"Tcp client disconnect")];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidDisappear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //[_tcpClient disconnect];
}

- (void)dealloc{
    [_tcpClient disconnect];
    _tcpClient = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

- (void)sendData{
    NSLog(@"send data......");
    NSString *sendStr = _sendTextView.text;
    NSData *data = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
    [_tcpClient writeData:data withTimeout:-1 tag:0];
}

- (void)clrRecieveTextView{
    _RecieveTextView.text = @"";
}

#pragma mark - FWTcpClientDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"didConnectToHost host:%@,port:%d",host,port);
    [self.navigationItem setTitle:LS(@"Tcp client connected")];
    _btnSend.enabled = true;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [self.navigationItem setTitle:LS(@"Tcp client disconnect")];
    [_btnSend setEnabled:false];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *readData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@" readData:%@",readData);
    NSString *dispStr = [NSString stringWithFormat:@"%@%@",_RecieveTextView.text,readData];
    _RecieveTextView.text = dispStr;
    [_tcpClient readDataWithTimeout:-1 tag:0];
}



@end
