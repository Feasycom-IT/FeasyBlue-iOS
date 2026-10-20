//
//  FWfeedbackController.m
//  FeasyWIFI
//
//  Created by wenyewei on 2020/6/4.
//  Copyright © 2020 Feasycom. All rights reserved.
//

#import "FWfeedbackController.h"
#import "FeasyCallbackSDK.h"
#import "Header.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface FWfeedbackController () <UITextViewDelegate,UIAlertViewDelegate> {
    UIButton *_typeButtons[4];
}

@property (nonatomic, strong) UITextView *textfield;
@property (nonatomic, strong) NSArray *textarray;
@property (nonatomic, strong) UIButton *submitbtn;
@property (nonatomic, strong) UIButton *tagButton;
@property (nonatomic, assign) FEEDBACKTYPE type;

@end

@implementation FWfeedbackController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = LS(@"FeedBack");
    self.view.backgroundColor = [UIColor colorWithRed:(0xeb / 255.0f) green:(0xeb / 255.0f) blue:(0xea / 255.0f) alpha:1];
    
    [self setUPUIuitextfield];
    [self tapBackgroundToClose];
}

- (void)setUPUIuitextfield {
    
    _textarray = @[LS(@"Advices"), LS(@"Dysfunction"), LS(@"AbnormalUI"), LS(@"Cooperation")];
    int gapWidth = 10;
    int gapLeading = 20;
    int gapTop = 20 + kNavBar_Height;
    int btnWidth = ([UIScreen mainScreen].bounds.size.width - gapLeading * 2 - (_textarray.count - 1) * gapWidth) / _textarray.count;
    int btnHight = 40;
    for (int i = 0; i < _textarray.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(gapLeading+(gapWidth+btnWidth)*i, gapTop, btnWidth, btnHight)];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        button.tag = 100+i;
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitle:_textarray[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _typeButtons[i] = button;
    }
    [_typeButtons[0] setSelected:YES];
    _type = FEEDBACKTYPE_ADVICE;
    
    _textfield = [[UITextView alloc] initWithFrame:CGRectMake(10, _typeButtons[0].frame.origin.y + btnHight + 20, [UIScreen mainScreen].bounds.size.width - 10 * 2, 200)];
    _textfield.layer.cornerRadius = 4;
    _textfield.delegate = self;
    _textfield.font = [UIFont systemFontOfSize:16];
    _textfield.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_textfield];
  
    _submitbtn = [[UIButton alloc]initWithFrame:CGRectMake(10, _textfield.frame.origin.y + _textfield.bounds.size.height + 20, [UIScreen mainScreen].bounds.size.width - 10 * 2, 40)];
    _submitbtn.backgroundColor = [UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1];
    _submitbtn.layer.cornerRadius = 5;
    _submitbtn.layer.masksToBounds = YES;
    
    [_submitbtn setTitle:LS(@"Submit") forState:UIControlStateNormal];
    [_submitbtn addTarget:self action:@selector(submitbtlClick) forControlEvents:UIControlEventTouchUpInside];
    [_submitbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_submitbtn];
}

- (void)tagButtonAction:(UIButton*)sender {
  /*
       FEEDBACKTYPE_ADVICE,        // 建议
      FEEDBACKTYPE_BUG,           // 功能异常
      FEEDBACKTYPE_UI,            // 界面异常
      FEEDBACKTYPE_COOPERATION,   // 合作
    */
    if (sender.selected) {
        return;
    }
    for (int i = 0 ; i < 4; i++) {
        UIButton *button = [self.view viewWithTag:100+i];
        button.selected = NO;
    }
    sender.selected = YES;
    if (sender.tag == 100) {
        _type = FEEDBACKTYPE_ADVICE;
    } else if (sender.tag == 101) {
        _type = FEEDBACKTYPE_BUG;
    } else if (sender.tag ==102) {
        _type = FEEDBACKTYPE_UI;
    } else if(sender.tag ==103) {
        _type = FEEDBACKTYPE_COOPERATION;
    }
}

- (void)tapBackgroundToClose {//需要在- (void)viewDidLoad{}中调用
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
    [tap setNumberOfTapsRequired:1];//触击次数设为1
    [self.view addGestureRecognizer:tap];//添加手势到view中
}

- (void)tapBackground {//定义  点击背景关闭键盘（放弃第一响应者身份）的方法
    [_textfield resignFirstResponder];
}

- (void)submitbtlClick {

    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] <= AFNetworkReachabilityStatusNotReachable) {
        [self createAlertController:LS(@"NoNetwork")];
        return;
    }
    NSString *text = _textfield.text;
    const NSInteger textLength = text.length;
    
    if (0 == textLength) {
        [self createAlertController:LS(@"Please input feedback content")];
        return;
    } else {
        NSString *newText = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        newText = [newText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        newText = [newText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (0 == newText.length) {
            [self createAlertController:LS(@"Please input feedback content")];
            return;
        }
        if (512 < textLength) {
            [self createAlertController:LS(@"Please input feedback content")];
            return;
        }
    }
    [FeasyCallbackSDK feedback:_textfield.text feedbackType:_type contact:@"" complete:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self createAlertController:LS(@"Feedback success")];
            }else{
                [self createAlertController:LS(@"Feedback fail")];
            }
        });
        
    }];
}

- (void)createAlertController:(NSString *)string {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:string message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:okAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

@end
