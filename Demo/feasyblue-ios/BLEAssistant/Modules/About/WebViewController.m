//
//  WebViewController.m
//  FeasycomWatch
//
//  Created by LiDong on 2020/7/20.
//  Copyright © 2020 LIDONG. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import <AFNetworking/AFNetworking.h>

#define kRequestURL @"https://api.feasycom.com/agreement"

@interface WebViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic) NSInteger type;

@end

@implementation WebViewController

- (instancetype)initWithType:(NSInteger)type {
    if (self = [super init]) {
        [self setHidesBottomBarWhenPushed:YES];
        _type = type;
        [self loadBackBarButtonItem];
    }
    return self;
}

- (void)loadBackBarButtonItem {
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 44)];
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    const CGRect bounds = view.bounds;
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = languages[0];
    __weak __typeof(self) weakSelf = self;
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [httpSessionManager POST:kRequestURL parameters:@{ @"app" : @"blue", @"type" : @(_type) } headers:@{ @"local" : [currentLanguage hasPrefix:@"zh-"] ? @"cn" : @"en" } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *data = responseObject[@"data"];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSString *URLString = data[@"url"];
            
            if (URLString) {
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
                
                [weakSelf.webView loadRequest:request];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
    
    _webView = [[WKWebView alloc] initWithFrame:bounds];
    [view addSubview:_webView];
}

@end
