//
//  FEDFUDownloadViewController.m
//  BLEAssistant
//
//  Created by LiDong on 2020/6/11.
//  Copyright © 2020 feasycom. All rights reserved.
//

#import "FEDFUDownloadViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "FEOtaFileManager.h"

@interface FEDFUDownloadViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *downedFilePath;
@property (nonatomic, copy) NSString *pendingDfuInput;

@end

@implementation FEDFUDownloadViewController

- (void)dealloc {
    NSLog(@"dealloc_FEDFUDownloadViewController");
}

- (instancetype)init {
    if (self = [super init]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 100, 20)];
    [self.statusLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:self.statusLabel];

    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 130, 20, 100, 20)];
    [self.progressLabel setTextAlignment:NSTextAlignmentRight];
    [self.progressLabel setFont:[UIFont systemFontOfSize:14]];
    [self.progressLabel setText:@"%0"];
    [self.view addSubview:self.progressLabel];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 70, [[UIScreen mainScreen] bounds].size.width - 60, 32)];
    [self.view addSubview:self.progressView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentInputAlert];
}

- (void)startDownloading {
    [self.statusLabel setText:LS(@"DOWNLOADING")];
    
    NSString *URLString = [NSString stringWithFormat:@"https://dfu.feasycom.com/%@.dfu", self.textField.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        int64_t total = downloadProgress.totalUnitCount;
        double percentage = total > 0 ? (double)downloadProgress.completedUnitCount / (double)total : 0;

        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.progressView setProgress:percentage];
            [strongSelf.progressLabel setText:[NSString stringWithFormat:@"%.1f%%", percentage * 100.f]];
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            NSString *tmp = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename ?: @"tmp.dfu"];
            return [NSURL fileURLWithPath:tmp];
        }
        
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *fileName = response.suggestedFilename ?: @"firmware.dfu";
        NSString *path = [cacheDir stringByAppendingPathComponent:fileName];
        
        strongSelf.filePath = path;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
        }
        
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.statusLabel setText:LS(@"DOWNLOAD_FAILED")];
                [strongSelf.statusLabel sizeToFit];
                if (error.code == -1011) {
                    [strongSelf expressDownloadFailed];
                }
            });
            return;
        }
        
        [FEOtaFileManager importFileURL:filePath sourceTag:@"Server" completion:^(NSString * _Nullable finalPath, NSError * _Nullable importError) {
            
            if (importError || finalPath.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.statusLabel setText:LS(@"DOWNLOAD_FAILED")];
                    [strongSelf.statusLabel sizeToFit];
                    [strongSelf expressDownloadFailed];
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.downedFilePath = finalPath;
                [strongSelf.statusLabel setText:LS(@"DOWNLOAD_SUCCEEDED")];
                [strongSelf.statusLabel sizeToFit];
                [strongSelf expressDownloadSuccessed];
            });
        }];
    }];
    
    [downloadTask resume];
}

- (void)expressDownloadSuccessed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Infomation") message:LS(@"Firmware download succeeded") preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LS(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSArray *vcs = strongSelf.navigationController.viewControllers;
        UIViewController *vc = vcs[vcs.count - 3];
        [strongSelf.navigationController popToViewController:vc animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:FEFileDownloadedNotification object:nil userInfo:@{ @"url" : strongSelf.downedFilePath }];
    }];
    [alertController addAction:OKAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)expressDownloadFailed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Firmware download failed") message:LS(@"Prompt: Please confirm whether the firmware path is correct and valid") preferredStyle:UIAlertControllerStyleAlert];

    __weak __typeof(self) weakSelf = self;
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LS(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf presentInputAlert];
    }];
    
    [alertController addAction:OKAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)presentInputAlert {
    [self presentInputAlertAndShake:NO];
}

- (void)presentInputAlertAndShake:(BOOL)shouldShake {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:LS(@"Please enter the download path of the firmware")
                                        message:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *OKAction =
    [UIAlertAction actionWithTitle:LS(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        NSString *text = self.textField.text ?: @"";
        self.pendingDfuInput = text;
        
        if (text.length == 0) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentInputAlertAndShake:YES];
            }];
            return;
        }
        
        [self startDownloading];
        [FEUserDefaultCache saveLastInputDfuPath:text];
    }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:LS(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        textField.placeholder = LS(@"Download file name");
        self.textField = textField;
        
        if (self.pendingDfuInput.length > 0) {
            textField.text = self.pendingDfuInput;
        } else {
            NSString *last = [FEUserDefaultCache getLastInputDfuPath];
            if (last.length > 0) textField.text = last;
        }
    }];
    
    [alertController addAction:OKAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        if (shouldShake) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self shakeView:alertController.view];
        }
    }];
}

- (void)shakeView:(UIView *)view {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    anim.duration = 0.4;
    anim.values = @[@(-12), @(12), @(-10), @(10), @(-6), @(6), @(0)];
    [view.layer addAnimation:anim forKey:@"shake"];
}

@end
