//
//  UIViewController+Extension.h
//  FeasyWIFI
//
//  Created by LiDong on 2021/4/15.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Extension)

- (UIAlertController *)showAlertControllerWithTitle:(NSString *)title;
- (UIAlertController *)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message;
- (UIAlertController *)showAlertControllerAndPopWithTitle:(NSString *)title;
- (UIAlertController *)showAlertControllerAndPopWithTitle:(NSString *)title message:(NSString *)message;
- (UIAlertController *)showAlertControllerAndPopRootVCWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
