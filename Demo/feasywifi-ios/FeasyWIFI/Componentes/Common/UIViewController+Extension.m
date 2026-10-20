//
//  UIViewController+Extension.m
//  FeasyWIFI
//
//  Created by LiDong on 2021/4/15.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (UIAlertController *)showAlertControllerWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (UIAlertController *)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (UIAlertController *)showAlertControllerAndPopWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (UIAlertController *)showAlertControllerAndPopWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (UIAlertController *)showAlertControllerAndPopRootVCWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

@end
