//
//  FWADView.m
//  FeasyWIFI
//
//  Created by ericj on 2020/7/14.
//  Copyright © 2020 Feasycom. All rights reserved.
//

#import "FWADView.h"
#import "FWADRootClass.h"
#import <SDWebImage.h>
#import "AFNetworking.h"

#define kRequestURL @"https://api.feasycom.com/lanch"

@interface FWADView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (nonatomic) NSInteger seconds;
@end

@implementation FWADView

+ (void)showWithSeconds:(NSInteger)seconds{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    FWADView *targetView = [[[NSBundle mainBundle] loadNibNamed:@"FWADView" owner:nil options:0] firstObject];
    targetView.frame = window.bounds;
    [window addSubview:targetView];
    targetView.seconds = seconds;
    NSLog(@"进来了");
    [targetView.secondBtn setTitle:[NSString stringWithFormat:@"%lds | Close", targetView.seconds] forState:UIControlStateNormal];
    __weak typeof(targetView) weakself = targetView;
    NSString *imageUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"lanchad"];
    if (imageUrl){
        NSLog(@"有图片：%@", imageUrl);
        [targetView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
    // 获取图片
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [httpSessionManager POST:kRequestURL parameters:@{ @"app" : @"wifi" } headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        FWADRootClass *root = [[FWADRootClass alloc] initWithDictionary:responseObject];
        [weakself.imageView sd_setImageWithURL:[NSURL URLWithString:root.data.image] placeholderImage:[UIImage imageNamed:@"launchImage"]];
        [[NSUserDefaults standardUserDefaults] setValue:root.data.image forKey:@"lanchad"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    // 有倒计时开启倒计时
    if (targetView.seconds > 0){
        [NSTimer scheduledTimerWithTimeInterval:1 target:targetView selector:@selector(secondTimerGo:) userInfo:nil repeats:YES];
    }
}

- (IBAction)clickClose:(id)sender {
    __weak typeof(self) weakself = self;
     [UIView animateWithDuration:0.2 animations:^{
         weakself.alpha = 0;
     } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
     }];
}

// 倒计时
- (void)secondTimerGo:(NSTimer *)timer{
    NSLog(@"倒计时：%ld", self.seconds);
    self.seconds--;
    NSString *secondString = [NSString stringWithFormat:@"%lds | Close", self.seconds];
    self.secondBtn.titleLabel.text = secondString;
    [self.secondBtn setTitle:secondString forState:UIControlStateNormal];
    
    if (self.seconds == 0){
        [self clickClose:nil];
        [timer invalidate];
    }
}


@end
