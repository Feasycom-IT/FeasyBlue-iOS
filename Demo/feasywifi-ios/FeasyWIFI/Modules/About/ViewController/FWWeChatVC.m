//
//  FWWeChatVC.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/7.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "FWWeChatVC.h"

@interface FWWeChatVC ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation FWWeChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LS(@"Wechat");
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WeChat"]];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width - 100, kScreen_Width - 100));
    }];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.layer.cornerRadius = 5;
    saveButton.layer.masksToBounds = YES;
    saveButton.backgroundColor = [UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1];
    [saveButton setTitle:LS(LS(@"Save")) forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(10);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(kScreen_Width - 20);
        make.height.mas_equalTo(40);
    }];
}

- (void)save {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"Save to mobile photo album") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf saveToPhotoLibrary];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)saveToPhotoLibrary {
    UIImage *image = [UIImage imageNamed:@"WeChat"];
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (0 == error.code) {
        [SVProgressHUD showInfoWithStatus:LS(@"The picture has been saved to the phone album")];
    }
}

@end
