//
//  FWCompanyMessageVC.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/7.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "FWCompanyMessageVC.h"

@interface FWCompanyMessageVC ()
@property (nonatomic, strong) UIScrollView *baseScrollView;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UILabel *label3;
@end

@implementation FWCompanyMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LS(@"CompanyProfile");

    //下层的scroolView
    self.baseScrollView = [[UIScrollView alloc] init];
    self.baseScrollView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-kTabBar_Safe_Height);
    self.baseScrollView.scrollEnabled = YES;
    self.baseScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.baseScrollView];
    //contentView
    UIView *contentView = [[UIView alloc]init];
    [self.baseScrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.baseScrollView);
        make.width.equalTo(self.baseScrollView);
    }];
    //
    UIImage *image1 = [UIImage imageNamed:@"aboutPic4"];
    CGSize size_image1 = image1.size;
    NSString *text1=LS(@"FeasycomProfile");
    UIImage *image2 = [UIImage imageNamed:@"aboutPic2"];
    CGSize size_image2 = image2.size;
    NSString *text2 = LS(@"WeChatOffical");
    UIImage *image3 = [UIImage imageNamed:@"aboutPic3"];
    CGSize size_image3 = image3.size;
    NSString *text3 = LS(@"ServiceTenet");
    //
    self.imageView1 = [[UIImageView alloc] initWithImage:image1];
    [contentView addSubview:self.imageView1];
    [self.imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(size_image1.height);
        make.left.right.mas_equalTo(contentView);
        make.top.mas_equalTo(contentView.mas_top);
    }];
    
    self.label1 = [[UILabel alloc] init];
    self.label1.text = text1;
    self.label1.numberOfLines = 0;
    self.label1.textColor = [UIColor blackColor];
    self.label1.font = [UIFont systemFontOfSize:17];
    [contentView addSubview:self.label1];
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.mas_equalTo(self.imageView1.mas_bottom);
    }];
    //
    self.imageView2 = [[UIImageView alloc] initWithImage:image2];
    [contentView addSubview:self.imageView2];
    [self.imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(size_image2.height);
        make.left.right.mas_equalTo(contentView);
        make.top.mas_equalTo(self.label1.mas_bottom);
    }];
    
    self.label2 = [[UILabel alloc] init];
    self.label2.text = text2;
    self.label2.numberOfLines = 0;
    self.label2.textColor = [UIColor blackColor];
    self.label2.font = [UIFont systemFontOfSize:17];
    [contentView addSubview:self.label2];
    [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.mas_equalTo(self.imageView2.mas_bottom);
    }];
    //
    self.imageView3 = [[UIImageView alloc] initWithImage:image3];
    [contentView addSubview:self.imageView3];
    [self.imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(size_image3.height);
        make.left.right.mas_equalTo(contentView);
        make.top.mas_equalTo(self.label2.mas_bottom);
    }];
    
    self.label3 = [[UILabel alloc] init];
    self.label3.text = text3;
    self.label3.numberOfLines = 0;
    self.label3.textColor = [UIColor blackColor];
    self.label3.font = [UIFont systemFontOfSize:17];
    [contentView addSubview:self.label3];
    [self.label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.mas_equalTo(self.imageView3.mas_bottom);
    }];
    
    //content
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.label3.mas_bottom);
    }];
}

@end
